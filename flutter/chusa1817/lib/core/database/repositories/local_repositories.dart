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
  Future<List<HanjaWordTableData>> fetchWords(String hanjaId) =>
      (_db.select(_db.hanjaWordTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();

  @override
  Future<List<HanjaIdiomTableData>> fetchIdioms(String hanjaId) =>
      (_db.select(_db.hanjaIdiomTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();
}

/// [ProgressRepository]의 로컬 DB 구현체.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._db);

  final AppDatabase _db;

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
    if (existing == null) return;
    await (_db.update(_db.userProgressTable)
          ..where((t) => t.hanjaId.equals(hanjaId)))
        .write(UserProgressTableCompanion(
      isBookmarked: Value(!existing.isBookmarked),
      updatedAt: Value(DateTime.now()),
    ));
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
