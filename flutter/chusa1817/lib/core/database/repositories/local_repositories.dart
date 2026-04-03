import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import 'repository_interfaces.dart';

/// [HanjaRepository]의 로컬 DB 구현체.
class LocalHanjaRepository implements HanjaRepository {
  const LocalHanjaRepository(this._db);

  final AppDatabase _db;

  @override
  Future<HanjaTableData?> fetchById(String id) =>
      (_db.select(_db.hanjaTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<List<HanjaTableData>> fetchByLevel(String level) =>
      (_db.select(_db.hanjaTable)
            ..where((t) => t.schoolLevel.equals(level))
            ..orderBy([(t) => OrderingTerm.asc(t.reading)]))
          .get();

  @override
  Future<List<HanjaTableData>> fetchAllOrderedByReading() =>
      (_db.select(_db.hanjaTable)
            ..orderBy([(t) => OrderingTerm.asc(t.reading)]))
          .get();

  @override
  Future<List<HanjaTableData>> search(String query) {
    final String q = '%$query%';
    return (_db.select(_db.hanjaTable)
          ..where((t) => t.reading.like(q) | t.meaning.like(q)))
        .get();
  }

  @override
  Future<void> upsert(HanjaTableCompanion data) =>
      _db.into(_db.hanjaTable).insertOnConflictUpdate(data);

  @override
  Future<List<HanjaStrokeTableData>> fetchStrokes(String hanjaId) =>
      (_db.select(_db.hanjaStrokeTable)
            ..where((t) => t.hanjaId.equals(hanjaId))
            ..orderBy([(t) => OrderingTerm.asc(t.strokeIndex)]))
          .get();

  @override
  Future<List<String>?> fetchStrokeSvgPaths(String hanjaId) async {
    final HanjaStrokeSvgPathsTableData? row =
        await (_db.select(_db.hanjaStrokeSvgPathsTable)
              ..where((t) => t.hanjaId.equals(hanjaId)))
            .getSingleOrNull();
    if (row == null || row.pathsJson.isEmpty) return null;
    try {
      final List<dynamic> decoded = jsonDecode(row.pathsJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HanjaWordTableData>> fetchWords(String hanjaId) =>
      (_db.select(_db.hanjaWordTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();

  @override
  Future<List<HanjaIdiomTableData>> fetchIdioms(String hanjaId) =>
      (_db.select(_db.hanjaIdiomTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();

  @override
  Future<int> fetchTotalCount() async {
    final countExp = _db.hanjaTable.id.count();
    final query = _db.selectOnly(_db.hanjaTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<HanjaTableData?> fetchNextToLearn() async {
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);

    final query = _db.select(_db.hanjaTable).join([
      leftOuterJoin(
        _db.userProgressTable,
        _db.userProgressTable.hanjaId.equalsExp(_db.hanjaTable.id),
      ),
    ])
      ..where(_db.userProgressTable.lastStudiedAt.isNull() |
          _db.userProgressTable.lastStudiedAt.isSmallerThanValue(todayStart))
      ..orderBy([OrderingTerm.asc(_db.hanjaTable.reading)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return row.readTable(_db.hanjaTable);
  }
}

/// [ProgressRepository]의 로컬 DB 구현체.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<UserProgressTableData?> fetchProgress(String hanjaId) =>
      (_db.select(_db.userProgressTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .getSingleOrNull();

  @override
  Future<List<UserProgressTableData>> fetchDueForReview() {
    final DateTime now = DateTime.now();
    return (_db.select(_db.userProgressTable)
          ..where(
            (t) =>
                t.nextReviewAt.isSmallerOrEqualValue(now) &
                t.status.isNotIn(['unseen']),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
        .get();
  }

  @override
  Future<List<UserProgressTableData>> fetchUpcomingForReview({int limit = 20}) {
    final DateTime now = DateTime.now();
    return (_db.select(_db.userProgressTable)
          ..where(
            (t) =>
                t.nextReviewAt.isBiggerThanValue(now) &
                t.status.isNotIn(['unseen']),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
          ..limit(limit))
        .get();
  }

  @override
  Future<int> fetchTodayCompletedCount() async {
    final DateTime startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final query = _db.select(_db.userProgressTable)
      ..where((t) => t.lastStudiedAt.isBiggerOrEqualValue(startOfDay));
    final rows = await query.get();
    return rows.length;
  }

  @override
  Future<Map<DateTime, int>> fetchDailyStudyCounts({int days = 7}) async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final rows = await (_db.select(_db.userProgressTable)
          ..where((t) => t.lastStudiedAt.isBiggerOrEqualValue(start)))
        .get();

    final Map<DateTime, int> counts = {};
    for (final row in rows) {
      final studiedAt = row.lastStudiedAt;
      if (studiedAt == null) continue;
      final day = DateTime(studiedAt.year, studiedAt.month, studiedAt.day);
      counts.update(day, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Future<int> fetchStreakDays() async {
    // 날짜별로 학습했는지 확인하여 연속일 계산 (간단 구현)
    final rows = await (_db.select(_db.userProgressTable)
          ..where((t) => t.lastStudiedAt.isNotNull()))
        .get();

    if (rows.isEmpty) return 0;

    final Set<String> studiedDates = rows
        .where((r) => r.lastStudiedAt != null)
        .map((r) {
          final d = r.lastStudiedAt!;
          return '${d.year}-${d.month}-${d.day}';
        })
        .toSet();

    int streak = 0;
    DateTime day = DateTime.now();
    while (studiedDates
        .contains('${day.year}-${day.month}-${day.day}')) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<List<UserProgressTableData>> fetchBookmarked() =>
      (_db.select(_db.userProgressTable)
            ..where((t) => t.isBookmarked.equals(true)))
          .get();

  @override
  Future<void> saveProgress(UserProgressTableCompanion data) =>
      _db.into(_db.userProgressTable).insertOnConflictUpdate(data);

  @override
  Future<void> toggleBookmark(String hanjaId) async {
    final existing = await fetchProgress(hanjaId);
    final DateTime now = DateTime.now();

    final bool newBookmarkStatus = !(existing?.isBookmarked ?? false);

    await _db.into(_db.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(existing?.id ?? _uuid.v4()),
            hanjaId: Value(hanjaId),
            isBookmarked: Value(newBookmarkStatus),
            updatedAt: Value(now),
            // 기존 데이터가 없을 경우 기본값들
            status: Value(existing?.status ?? 'unseen'),
          ),
        );
  }

  @override
  Future<void> upsertProgressByHanjaId({
    required String hanjaId,
    required DateTime studiedAt,
    required bool isCorrect,
  }) async {
    final existing = await fetchProgress(hanjaId);
    final DateTime now = DateTime.now();

    final String id = existing?.id ?? _uuid.v4();
    final int totalAttempts = (existing?.totalAttempts ?? 0) + 1;
    final int correctAttempts = (existing?.correctAttempts ?? 0) + (isCorrect ? 1 : 0);
    final double accuracyRate =
        totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts;

    final DateTime nextReviewAt = isCorrect
        ? studiedAt.add(const Duration(days: 1))
        : studiedAt.add(const Duration(hours: 6));

    await _db.into(_db.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(id),
            hanjaId: Value(hanjaId),
            status: Value(isCorrect ? 'learning' : 'review_needed'),
            totalAttempts: Value(totalAttempts),
            correctAttempts: Value(correctAttempts),
            accuracyRate: Value(accuracyRate),
            lastStudiedAt: Value(studiedAt),
            nextReviewAt: Value(nextReviewAt),
            updatedAt: Value(now),
          ),
        );
  }
}

/// [StudySessionRepository]의 로컬 DB 구현체.
class LocalStudySessionRepository implements StudySessionRepository {
  const LocalStudySessionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<String> startSession(String sessionType) async {
    final String id = _uuid.v4();
    await _db.into(_db.studySessionTable).insert(StudySessionTableCompanion(
          id: Value(id),
          startedAt: Value(DateTime.now()),
          sessionType: Value(sessionType),
        ));
    return id;
  }

  @override
  Future<void> endSession(String sessionId,
      {required int correctCount}) async {
    await (_db.update(_db.studySessionTable)
          ..where((t) => t.id.equals(sessionId)))
        .write(StudySessionTableCompanion(
      endedAt: Value(DateTime.now()),
      correctCount: Value(correctCount),
    ));
  }

  @override
  Future<void> saveAnswer(AnswerHistoryTableCompanion data) =>
      _db.into(_db.answerHistoryTable).insert(data);

  @override
  Future<List<StudySessionTableData>> fetchRecentSessions(int limit) =>
      (_db.select(_db.studySessionTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();
}

/// [SettingsRepository]의 로컬 DB 구현체.
class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<String?> get(String key) async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> set(String key, String value) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
