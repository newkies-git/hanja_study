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
  Future<HanjaTableData?> fetchNextToLearn({
    int orderIndex = 0,
    bool isAscending = true,
  }) async {
    // '오늘의 학습'은 아직 한 번도 학습하지 않은('unseen') 한자만 추천한다.
    final query = _db.select(_db.hanjaTable).join([
      leftOuterJoin(
        _db.userProgressTable,
        _db.userProgressTable.hanjaId.equalsExp(_db.hanjaTable.id),
      ),
    ])
      ..where(_db.userProgressTable.status.isNull() |
          _db.userProgressTable.status.equals('unseen'));

    final mode = isAscending ? OrderingMode.asc : OrderingMode.desc;

    if (orderIndex == 1) {
      query.orderBy(
          [OrderingTerm(expression: _db.hanjaTable.totalStrokes, mode: mode)]);
    } else if (orderIndex == 2) {
      query.orderBy([OrderingTerm.random()]);
    } else {
      query.orderBy([OrderingTerm(expression: _db.hanjaTable.reading, mode: mode)]);
    }

    query.limit(1);

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

    // ── SM-2 알고리즘 계산 ────────────────────────────────────────────────
    int n = existing?.reviewCount ?? 0;
    int interval = existing?.intervalDays ?? 0;
    double ef = existing?.easeFactor ?? 2.5;

    final DateTime nextReviewAt;

    if (isCorrect) {
      // 정답인 경우 (q=4 정도로 가정)
      if (n == 0) {
        interval = 1;
      } else if (n == 1) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
      n++;
      // EF 업데이트 (q=4 기준: EF' = EF + (0.1 - (5-4)*(0.08+(5-4)*0.02)) = EF - 0.0)
      // 여기서는 정답 시 EF를 유지하거나 미세하게 조정
      ef = ef + (0.1 - (5 - 4) * (0.08 + (5 - 4) * 0.02));
    } else {
      // 오답인 경우 (q=0~2)
      n = 0;
      interval = 1; // 즉시 다시 학습하도록 1일 설정 (또는 수 시간 내)
      // 오답 시 EF 감소: EF = EF - 0.2 (하한 1.3)
      ef = (ef - 0.2).clamp(1.3, 2.5);
    }

    if (ef < 1.3) ef = 1.3;
    nextReviewAt = DateTime(now.year, now.month, now.day).add(Duration(days: interval));

    await _db.into(_db.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(id),
            userId: Value(existing?.userId ?? ''),
            hanjaId: Value(hanjaId),
            status: Value(isCorrect 
                ? (n >= 4 ? 'mastered' : 'learning') 
                : 'review_needed'),
            totalAttempts: Value(totalAttempts),
            correctAttempts: Value(correctAttempts),
            accuracyRate: Value(accuracyRate),
            lastStudiedAt: Value(studiedAt),
            nextReviewAt: Value(nextReviewAt),
            reviewCount: Value(n),
            intervalDays: Value(interval),
            easeFactor: Value(ef),
            updatedAt: Value(now),
          ),
        );

    // ── 일별 통계 동기화 ───────────────────────────────────────────────────
    // 진도 업데이트 후 당일의 학습 중/완료 상태를 집계하여 스냅샷 갱신
    final String userId = existing?.userId ?? '';
    final date = DateTime(now.year, now.month, now.day);
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    // 전체 진도에서 상태별 자동 집계 (성능 이슈 고려 시 추후 변경 가능)
    final allProgress = await _db.select(_db.userProgressTable).get();
    final inProgress = allProgress.where((p) => p.status == 'learning' || p.status == 'review_needed').length;
    final mastered = allProgress.where((p) => p.status == 'mastered').length;

    await _db.into(_db.dailyActivityStatsTable).insertOnConflictUpdate(
          DailyActivityStatsTableCompanion(
            id: Value(statsId),
            date: Value(date),
            userId: Value(userId),
            inProgressCount: Value(inProgress),
            completedCount: Value(mastered),
            updatedAt: Value(now),
          ),
        );

    // ── 일별 한자 활동 기록 ───────────────────────────────────────────────
    // 어떤 한자를 공부했는지 상세 목록에 기록
    final activityId = '${date.millisecondsSinceEpoch}_${userId}_$hanjaId';
    final isMastered = (isCorrect && (accuracyRate > 0.8)); // 임시 마스터 판정 기준

    await _db.into(_db.dailyHanjaActivityTable).insertOnConflictUpdate(
          DailyHanjaActivityTableCompanion(
            id: Value(activityId),
            date: Value(date),
            userId: Value(userId),
            hanjaId: Value(hanjaId),
            status: Value(isMastered ? 'completed' : 'learning'),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<int> fetchMasteredCount() async {
    final countExp = _db.userProgressTable.id.count();
    final query = _db.selectOnly(_db.userProgressTable)
      ..where(_db.userProgressTable.status.equals('mastered'))
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<List<(HanjaTableData hanja, String status)>> fetchTodayLearningHanja({
    int dailyGoal = 5,
    int orderIndex = 0,
    bool isAscending = true,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);
    const String userId = ''; // 현재 세션 기반 userId (기본값)

    // 1. 오늘 이미 등록된 활동(planned, learning, completed) 가져오기
    final query = _db.select(_db.dailyHanjaActivityTable).join([
      innerJoin(
        _db.hanjaTable,
        _db.hanjaTable.id.equalsExp(_db.dailyHanjaActivityTable.hanjaId),
      ),
    ])
      ..where(_db.dailyHanjaActivityTable.date.equals(todayDate))
      ..orderBy([OrderingTerm.asc(_db.dailyHanjaActivityTable.createdAt)]);

    final rows = await query.get();
    final existingList = rows.map((row) {
      return (
        row.readTable(_db.hanjaTable),
        row.readTable(_db.dailyHanjaActivityTable).status,
      );
    }).toList();

    if (existingList.length >= dailyGoal) {
      return existingList;
    }

    // 2. 일일 목표량(dailyGoal)에 미달할 경우 'unseen' 한자를 충원
    final int gap = dailyGoal - existingList.length;
    final List<String> existingIds = existingList.map((e) => e.$1.id).toList();

    // 학습하지 않은 한자 중 아직 오늘의 리스트에 없는 것들을 가져온다.
    final nextHanjasQuery = _db.select(_db.hanjaTable).join([
      leftOuterJoin(
        _db.userProgressTable,
        _db.userProgressTable.hanjaId.equalsExp(_db.hanjaTable.id),
      ),
    ])
      ..where(_db.userProgressTable.status.isNull() |
          _db.userProgressTable.status.equals('unseen'))
      ..where(_db.hanjaTable.id.isNotIn(existingIds));

    final mode = isAscending ? OrderingMode.asc : OrderingMode.desc;

    if (orderIndex == 1) {
      nextHanjasQuery.orderBy(
          [OrderingTerm(expression: _db.hanjaTable.totalStrokes, mode: mode)]);
    } else if (orderIndex == 2) {
      nextHanjasQuery.orderBy([OrderingTerm.random()]);
    } else {
      nextHanjasQuery.orderBy(
          [OrderingTerm(expression: _db.hanjaTable.reading, mode: mode)]);
    }

    nextHanjasQuery.limit(gap);

    final nextRows = await nextHanjasQuery.get();
    final List<(HanjaTableData, String)> resultList = [...existingList];

    for (final row in nextRows) {
      final hanja = row.readTable(_db.hanjaTable);
      final String activityId = _uuid.v4();
      
      // DB에 'planned' 상태로 미리 등록 (다음 조회 시 유지되도록)
      await _db.into(_db.dailyHanjaActivityTable).insert(
        DailyHanjaActivityTableCompanion.insert(
          id: activityId,
          date: todayDate,
          userId: userId,
          hanjaId: hanja.id,
          status: const Value('planned'),
          updatedAt: Value(now),
        ),
      );
      
      resultList.add((hanja, 'planned'));
    }

    // 3. 만약 'learning' 상태인 한자가 하나도 없다면 첫 번째 'planned'를 'learning'으로 간주(표시용)
    final bool hasLearning = resultList.any((e) => e.$2 == 'learning');
    if (!hasLearning) {
      for (int i = 0; i < resultList.length; i++) {
        if (resultList[i].$2 == 'planned') {
          resultList[i] = (resultList[i].$1, 'learning');
          break;
        }
      }
    }

    return resultList;
  }

  @override
  Future<List<UserProgressTableData>> fetchTopErrorProneHanja({int limit = 10}) async {
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);

    // 오답률이 높은(정확도가 낮은) 순서로 정렬하여 가져오기.
    // 단, 오늘 이미 공부한 한자는 제외하여 '오늘의 추천 복습' 리스트에서 제거되는 효과를 줌.
    return (_db.select(_db.userProgressTable)
          ..where((t) =>
              t.totalAttempts.isBiggerThanValue(0) &
              (t.lastStudiedAt.isNull() | t.lastStudiedAt.isSmallerThanValue(todayStart)))
          ..orderBy([
            (t) => OrderingTerm.asc(t.accuracyRate), // 정확도 낮은 순(오답률 높은 순)
            (t) => OrderingTerm.desc(t.totalAttempts), // 시도 횟수가 많은 순(자주 틀리는 것 우선)
          ])
          ..limit(limit))
        .get();
  }

  @override
  Future<void> seedSampleReviewHanja() async {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));

    // 1. 아직 진도 데이터가 없는(또는 'unseen'인) 한자 5개 가져오기
    final query = _db.select(_db.hanjaTable).join([
      leftOuterJoin(
        _db.userProgressTable,
        _db.userProgressTable.hanjaId.equalsExp(_db.hanjaTable.id),
      ),
    ])
      ..where(_db.userProgressTable.id.isNull())
      ..limit(5);

    final rows = await query.get();
    if (rows.isEmpty) return;

    // 2. 각 한자에 대해 오답 가득한 진도 데이터 삽입
    for (final row in rows) {
      final hanja = row.readTable(_db.hanjaTable);
      final String id = _uuid.v4();

      // 시도 5회 중 정답 1회 (정확도 20%)
      const int totalAttempts = 5;
      const int correctAttempts = 1;
      const double accuracyRate = correctAttempts / totalAttempts;

      await _db.into(_db.userProgressTable).insertOnConflictUpdate(
            UserProgressTableCompanion(
              id: Value(id),
              hanjaId: Value(hanja.id),
              status: const Value('review_needed'),
              totalAttempts: const Value(totalAttempts),
              correctAttempts: const Value(correctAttempts),
              accuracyRate: const Value(accuracyRate),
              lastStudiedAt: Value(yesterday), // 어제 공부한 것으로 설정
              nextReviewAt: Value(now), // 지금 바로 복습 필요
              updatedAt: Value(now),
            ),
          );
    }
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
    final now = DateTime.now();
    await (_db.update(_db.studySessionTable)
          ..where((t) => t.id.equals(sessionId)))
        .write(StudySessionTableCompanion(
      endedAt: Value(now),
      correctCount: Value(correctCount),
      updatedAt: Value(now),
    ));

    // ── 일별 통계 동기화 ───────────────────────────────────────────────────
    // 세션 종료 후 당일 학습 횟수(sessionCount) 증가
    final date = DateTime(now.year, now.month, now.day);
    const userId = ''; // 현재 세션 테이블에 userId가 없는 경우 기본값
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    await _db.customStatement(
        'INSERT INTO daily_activity_stats (id, date, user_id, session_count, created_at, updated_at) '
        'VALUES (?, ?, ?, 1, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET session_count = session_count + 1, updated_at = ?',
        [statsId, date.toIso8601String(), userId, now.toIso8601String(), now.toIso8601String(), now.toIso8601String()],
      );
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

/// [UserRepository]의 로컬 DB 구현체.
class LocalUserRepository implements UserRepository {
  const LocalUserRepository(this._db);

  final AppDatabase _db;

  @override
  Future<UserProfileTableData?> fetchById(String id) =>
      (_db.select(_db.userProfileTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<UserProfileTableData?> fetchByEmail(String email) =>
      (_db.select(_db.userProfileTable)..where((t) => t.email.equals(email)))
          .getSingleOrNull();

  @override
  Future<void> upsert(UserProfileTableCompanion data) =>
      _db.into(_db.userProfileTable).insertOnConflictUpdate(data);
}

/// [ActivityRepository]의 로컬 DB 구현체.
class LocalActivityRepository implements ActivityRepository {
  const LocalActivityRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<void> recordLogin(String userId) async {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    await _db.batch((batch) {
      // 1. 상세 이력 추가
      batch.insert(_db.loginHistoryTable, LoginHistoryTableCompanion(
        id: Value(_uuid.v4()),
        userId: Value(userId),
        loginAt: Value(now),
      ));

      // 2. 당일 통계 업데이트 (로그인 횟수 증가)
      // Drift에서 직접 increment를 지원하지 않는 경우 먼저 조회 후 업데이트
      batch.customStatement(
        'INSERT INTO daily_activity_stats (id, date, user_id, login_count, created_at, updated_at) '
        'VALUES (?, ?, ?, 1, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET login_count = login_count + 1, updated_at = ?',
        [statsId, date.toIso8601String(), userId, now.toIso8601String(), now.toIso8601String(), now.toIso8601String()],
      );
    });
  }

  @override
  Future<DailyActivityStatsTableData?> fetchDailyStats(String userId, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return (_db.select(_db.dailyActivityStatsTable)
          ..where((t) => t.userId.equals(userId) & t.date.equals(d)))
        .getSingleOrNull();
  }

  @override
  Future<void> updateDailyStudyStats({
    required String userId,
    required DateTime date,
    int? planned,
    int? inProgress,
    int? completed,
  }) async {
    final d = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final statsId = '${d.millisecondsSinceEpoch}_$userId';

    await _db.into(_db.dailyActivityStatsTable).insertOnConflictUpdate(
          DailyActivityStatsTableCompanion(
            id: Value(statsId),
            date: Value(d),
            userId: Value(userId),
            plannedCount: planned != null ? Value(planned) : const Value.absent(),
            inProgressCount: inProgress != null ? Value(inProgress) : const Value.absent(),
            completedCount: completed != null ? Value(completed) : const Value.absent(),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<List<DailyActivityStatsTableData>> fetchRecentStats(String userId, {int days = 7}) {
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final d = DateTime(start.year, start.month, start.day);

    return (_db.select(_db.dailyActivityStatsTable)
          ..where((t) => t.userId.equals(userId) & t.date.isBiggerOrEqualValue(d))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }
}
