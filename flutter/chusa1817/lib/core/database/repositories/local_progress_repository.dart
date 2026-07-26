import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../settings/app_settings_keys.dart';
import '../app_database.dart';
import 'repository_interfaces.dart';

/// [ProgressRepository]의 로컬 DB 구현체.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._database, this._settings, this._firebaseAuth);

  final AppDatabase _database;
  final SettingsRepository _settings;
  final FirebaseAuth _firebaseAuth;
  static const _uuid = Uuid();

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  bool get _hasSignedInUser => _currentUserId.isNotEmpty;

  void _ensureSignedInUserForProgressWrite() {
    if (!_hasSignedInUser) {
      throw StateError('진도 저장에는 로그인된 사용자가 필요합니다.');
    }
  }

  Expression<bool> _ownedByCurrentUser($UserProgressTableTable t) =>
      t.userId.equals(_currentUserId);

  Expression<bool> _dailyOwnedByCurrentUser($DailyHanjaActivityTableTable t) =>
      t.userId.equals(_currentUserId);

  @override
  Future<UserProgressTableData?> fetchProgress(String hanjaId) {
    if (!_hasSignedInUser) return Future.value(null);
    return (_database.select(_database.userProgressTable)
          ..where(
            (t) => t.hanjaId.equals(hanjaId) & _ownedByCurrentUser(t),
          ))
        .getSingleOrNull();
  }

  @override
  Future<List<UserProgressTableData>> fetchDueForReview({int limit = 10}) {
    if (!_hasSignedInUser) return Future.value([]);
    final DateTime now = DateTime.now();
    return (_database.select(_database.userProgressTable)
          ..where(
            (t) =>
                _ownedByCurrentUser(t) &
                t.status.isIn(['learning', 'mastered', 'review_needed']) &
                t.nextReviewAt.isSmallerOrEqualValue(now),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
          ..limit(limit))
        .get();
  }

  @override
  Future<List<UserProgressTableData>> fetchUpcomingForReview({int limit = 10}) {
    if (!_hasSignedInUser) return Future.value([]);
    final DateTime now = DateTime.now();
    return (_database.select(_database.userProgressTable)
          ..where(
            (t) =>
                _ownedByCurrentUser(t) &
                t.status.isIn(['learning', 'mastered', 'review_needed']) &
                t.nextReviewAt.isBiggerThanValue(now),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
          ..limit(limit))
        .get();
  }

  @override
  Future<int> fetchUpcomingForReviewCount() async {
    if (!_hasSignedInUser) return 0;
    final DateTime now = DateTime.now();
    final rows = await (_database.select(_database.userProgressTable)
          ..where(
            (t) =>
                _ownedByCurrentUser(t) &
                t.status.isIn(['learning', 'mastered', 'review_needed']) &
                t.nextReviewAt.isBiggerThanValue(now),
          ))
        .get();
    return rows.length;
  }

  @override
  Future<int> fetchTodayCompletedCount() async {
    final now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final countExp = _database.dailyHanjaActivityTable.hanjaId.count(distinct: true);
    final query = _database.selectOnly(_database.dailyHanjaActivityTable)
      ..addColumns([countExp])
      ..where(_database.dailyHanjaActivityTable.date.equals(startOfDay) &
          _dailyOwnedByCurrentUser(_database.dailyHanjaActivityTable) &
          _database.dailyHanjaActivityTable.status.isIn(['mastered']));
    return (await query.map((row) => row.read(countExp)).getSingle()) ?? 0;
  }

  @override
  Future<Map<DateTime, (int completed, int learning)>> fetchDailyActivityStatusCounts({
    int days = 7,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final rows = await (_database.select(_database.dailyHanjaActivityTable)
          ..where((t) =>
              _dailyOwnedByCurrentUser(t) &
              t.date.isBiggerOrEqualValue(start) &
              // NOTE: review_needed는 "복습 대상"이며 주간 활동량(학습 진행/완료)에는 포함하지 않는다.
              t.status.isIn(['learning', 'mastered'])))
        .get();

    final Map<DateTime, Set<String>> completedByDay = {};
    final Map<DateTime, Set<String>> learningByDay = {};
    for (final r in rows) {
      final d = r.date;
      final day = DateTime(d.year, d.month, d.day);
      if (r.status == 'mastered') {
        (completedByDay[day] ??= <String>{}).add(r.hanjaId);
      } else if (r.status == 'learning') {
        (learningByDay[day] ??= <String>{}).add(r.hanjaId);
      }
    }

    final Map<DateTime, (int completed, int learning)> out = {};
    final Set<DateTime> allDays = {...completedByDay.keys, ...learningByDay.keys};
    for (final day in allDays) {
      out[day] = (
        completedByDay[day]?.length ?? 0,
        learningByDay[day]?.length ?? 0,
      );
    }
    return out;
  }

  @override
  Future<int> fetchStreakDays() async {
    // 전체 행이 아닌 last_studied_at 컬럼만 읽어 메모리를 절약한다.
    final dateCol = _database.userProgressTable.lastStudiedAt;
    final query = _database.selectOnly(_database.userProgressTable)
      ..addColumns([dateCol])
      ..where(
        _ownedByCurrentUser(_database.userProgressTable) &
            _database.userProgressTable.lastStudiedAt.isNotNull(),
      );
    final rows = await query.get();

    if (rows.isEmpty) return 0;

    final Set<String> studiedDates = rows
        .map((r) => r.read(dateCol))
        .nonNulls
        .map((d) => '${d.year}-${d.month}-${d.day}')
        .toSet();

    int streak = 0;
    DateTime day = DateTime.now();
    while (studiedDates.contains('${day.year}-${day.month}-${day.day}')) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<void> toggleBookmark(String hanjaId) async {
    _ensureSignedInUserForProgressWrite();
    final existing = await fetchProgress(hanjaId);
    final DateTime now = DateTime.now();

    final bool newBookmarkStatus = !(existing?.isBookmarked ?? false);

    await _database.into(_database.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(existing?.id ?? _uuid.v4()),
            userId: Value(_currentUserId),
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
    bool? isBookmarked,
    int? quality,
  }) async {
    _ensureSignedInUserForProgressWrite();
    final existing = await fetchProgress(hanjaId);
    final DateTime now = DateTime.now();

    final String id = existing?.id ?? _uuid.v4();
    final int totalAttempts = (existing?.totalAttempts ?? 0) + 1;
    final int correctAttempts = (existing?.correctAttempts ?? 0) + (isCorrect ? 1 : 0);
    final double accuracyRate =
        totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts;

    // SM-2: quality 0–5 (없으면 정답=4 / 오답=1)
    final int responseQuality = (quality ?? (isCorrect ? 4 : 1)).clamp(0, 5);

    int n = existing?.reviewCount ?? 0;
    int interval = existing?.intervalDays ?? 0;
    double ef = existing?.easeFactor ?? 2.5;

    final DateTime nextReviewAt;

    if (responseQuality >= 3) {
      if (n == 0) {
        interval = 1;
      } else if (n == 1) {
        interval = 6;
      } else {
        interval = (interval * ef).round().clamp(1, 3650);
      }
      n++;
      ef = ef + (0.1 - (5 - responseQuality) * (0.08 + (5 - responseQuality) * 0.02));
    } else {
      n = 0;
      interval = 1;
      ef = (ef - 0.2).clamp(1.3, 2.5);
    }

    if (ef < 1.3) ef = 1.3;
    nextReviewAt = DateTime(now.year, now.month, now.day).add(Duration(days: interval));

    final String progressStatus = responseQuality >= 3
        ? (n >= 4 ? 'mastered' : 'learning')
        : 'learning';

    await _database.into(_database.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(id),
            userId: Value(_currentUserId),
            hanjaId: Value(hanjaId),
            status: Value(progressStatus),
            totalAttempts: Value(totalAttempts),
            correctAttempts: Value(correctAttempts),
            accuracyRate: Value(accuracyRate),
            lastStudiedAt: Value(studiedAt),
            nextReviewAt: Value(nextReviewAt),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked)
                : Value(existing?.isBookmarked ?? false),
            reviewCount: Value(n),
            intervalDays: Value(interval),
            easeFactor: Value(ef),
            updatedAt: Value(now),
          ),
        );

    // ── 일별 통계 동기화 ───────────────────────────────────────────────────
    final String userId = _currentUserId;
    final date = DateTime(now.year, now.month, now.day);
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    // 상태별 COUNT — 전체 행을 Dart로 읽지 않고 DB에서 집계
    final inProgressCountExp = _database.userProgressTable.id.count();
    final inProgressQuery = _database.selectOnly(_database.userProgressTable)
      ..where(
        _ownedByCurrentUser(_database.userProgressTable) &
            _database.userProgressTable.status.equals('learning'),
      )
      ..addColumns([inProgressCountExp]);
    final inProgress =
        (await inProgressQuery.map((r) => r.read(inProgressCountExp)).getSingle()) ?? 0;

    final masteredCountExp = _database.userProgressTable.id.count();
    final masteredQuery = _database.selectOnly(_database.userProgressTable)
      ..where(
        _ownedByCurrentUser(_database.userProgressTable) &
            _database.userProgressTable.status.equals('mastered'),
      )
      ..addColumns([masteredCountExp]);
    final mastered =
        (await masteredQuery.map((r) => r.read(masteredCountExp)).getSingle()) ?? 0;

    await _database.into(_database.dailyActivityStatsTable).insertOnConflictUpdate(
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
    // 일별 집계는 "전체 누적 진도"와 같은 기준을 써야 주간/전체 현황이 일관된다.
    // SM-2: mastered → 'mastered', 그 외 → 'learning'
    final bool isMastered = progressStatus == 'mastered';

    await _database.into(_database.dailyHanjaActivityTable).insertOnConflictUpdate(
          DailyHanjaActivityTableCompanion(
            id: Value(activityId),
            date: Value(date),
            userId: Value(userId),
            hanjaId: Value(hanjaId),
            status: Value(isMastered ? 'mastered' : 'learning'),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<int> fetchMasteredCount() async {
    final countExp = _database.userProgressTable.id.count();
    final query = _database.selectOnly(_database.userProgressTable)
      ..where(
        _ownedByCurrentUser(_database.userProgressTable) &
            _database.userProgressTable.status.equals('mastered'),
      )
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<int> fetchLearningCount() async {
    final countExp = _database.userProgressTable.id.count();
    final query = _database.selectOnly(_database.userProgressTable)
      ..where(
        _ownedByCurrentUser(_database.userProgressTable) &
            _database.userProgressTable.status.equals('learning'),
      )
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<void> refreshDailyPlan({
    required int dailyGoal,
    required int orderIndex,
    required bool isAscending,
    required String schoolLevel,
  }) async {
    _ensureSignedInUserForProgressWrite();
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);
    final String todayDateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final String userId = _currentUserId;

    // ── 이월: 당일 최초 1회만 수행 (날짜 게이트) ─────────────────────────────
    final String? lastRefreshed =
        await _settings.get(AppSettingsKeys.lastDailyActivityRefreshedAt);

    if (lastRefreshed != todayDateStr) {
      // 구버전(UUID) 행 정리
      final existingToday = await (_database.select(_database.dailyHanjaActivityTable)
            ..where(
              (t) => t.date.equals(todayDate) & _dailyOwnedByCurrentUser(t),
            ))
          .get();
      final expectedPrefix = '${todayDate.millisecondsSinceEpoch}_';
      for (final row in existingToday) {
        if (!row.id.startsWith(expectedPrefix)) {
          await (_database.delete(_database.dailyHanjaActivityTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
        }
      }

      // 미완료 행 전부 이월 (목표량으로 자르지 않음)
      final incomplete = await (_database.select(_database.dailyHanjaActivityTable)
            ..where((t) =>
                _dailyOwnedByCurrentUser(t) &
                t.status.equals('mastered').not() &
                t.date.isSmallerThanValue(todayDate))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

      final currentTodayHanjaIds = (await (_database.select(_database.dailyHanjaActivityTable)
                ..where(
                  (t) =>
                      t.date.equals(todayDate) & _dailyOwnedByCurrentUser(t),
                ))
              .get())
          .map((r) => r.hanjaId)
          .toSet();

      for (final row in incomplete) {
        if (currentTodayHanjaIds.contains(row.hanjaId)) {
          await (_database.delete(_database.dailyHanjaActivityTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
          continue;
        }
        final newId = '${todayDate.millisecondsSinceEpoch}_${userId}_${row.hanjaId}';
        await _database.into(_database.dailyHanjaActivityTable).insertOnConflictUpdate(
              DailyHanjaActivityTableCompanion(
                id: Value(newId),
                date: Value(todayDate),
                userId: Value(userId),
                hanjaId: Value(row.hanjaId),
                status: Value(row.status),
                updatedAt: Value(now),
              ),
            );
        await (_database.delete(_database.dailyHanjaActivityTable)
              ..where((t) => t.id.equals(row.id)))
            .go();
        currentTodayHanjaIds.add(row.hanjaId);
      }

      await _settings.set(AppSettingsKeys.lastDailyActivityRefreshedAt, todayDateStr);
    }

    // ── 신규 채우기: 항상 실행 — 목표량 변경 시에도 즉시 반영 (멱등) ────────────
    final todayHanjaIds = (await (_database.select(_database.dailyHanjaActivityTable)
              ..where(
                (t) => t.date.equals(todayDate) & _dailyOwnedByCurrentUser(t),
              ))
            .get())
        .map((r) => r.hanjaId)
        .toSet();

    final int remaining = math.max(0, dailyGoal - todayHanjaIds.length);
    if (remaining > 0) {
      final nextHanjasQuery = _database.select(_database.hanjaTable).join([
        leftOuterJoin(
          _database.userProgressTable,
          _database.userProgressTable.hanjaId.equalsExp(_database.hanjaTable.id) &
              _database.userProgressTable.userId.equals(userId),
        ),
      ])
        ..where(_database.userProgressTable.status.isNull() |
            _database.userProgressTable.status.equals('unseen'));

      if (schoolLevel != 'all') {
        nextHanjasQuery.where(_database.hanjaTable.schoolLevel.equals(schoolLevel));
      }

      final mode = isAscending ? OrderingMode.asc : OrderingMode.desc;
      if (orderIndex == 1) {
        nextHanjasQuery.orderBy(
            [OrderingTerm(expression: _database.hanjaTable.totalStrokes, mode: mode)]);
      } else if (orderIndex == 2) {
        nextHanjasQuery.orderBy([OrderingTerm.random()]);
      } else {
        nextHanjasQuery.orderBy(
            [OrderingTerm(expression: _database.hanjaTable.reading, mode: mode)]);
      }

      if (todayHanjaIds.isNotEmpty) {
        nextHanjasQuery.where(
            _database.hanjaTable.id.isNotIn(todayHanjaIds.toList()));
      }
      nextHanjasQuery.limit(remaining);

      final nextRows = await nextHanjasQuery.get();
      for (final row in nextRows) {
        final hanja = row.readTable(_database.hanjaTable);
        final String activityId =
            '${todayDate.millisecondsSinceEpoch}_${userId}_${hanja.id}';
        await _database.into(_database.dailyHanjaActivityTable).insertOnConflictUpdate(
              DailyHanjaActivityTableCompanion.insert(
                id: activityId,
                date: todayDate,
                userId: userId,
                hanjaId: hanja.id,
                status: const Value('planned'),
                updatedAt: Value(now),
              ),
            );
      }
    }
  }

  @override
  Future<List<(HanjaTableData hanja, String status, bool isBookmarked)>> readTodayHanjaList({
    int dailyGoal = 5,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);

    // 오늘 등록된 활동 가져오기
    final query = _database.select(_database.dailyHanjaActivityTable).join([
      innerJoin(
        _database.hanjaTable,
        _database.hanjaTable.id.equalsExp(_database.dailyHanjaActivityTable.hanjaId),
      ),
      leftOuterJoin(
        _database.userProgressTable,
        _database.userProgressTable.hanjaId.equalsExp(_database.dailyHanjaActivityTable.hanjaId) &
            _database.userProgressTable.userId.equals(_currentUserId),
      ),
    ])
      ..where(
        _database.dailyHanjaActivityTable.date.equals(todayDate) &
            _dailyOwnedByCurrentUser(_database.dailyHanjaActivityTable),
      )
      ..orderBy([OrderingTerm.asc(_database.dailyHanjaActivityTable.createdAt)]);

    final rows = await query.get();

    // 중복 제거: mastered > learning > planned
    final Map<String, (HanjaTableData, String, bool)> uniqueMap = {};
    for (final row in rows) {
      final hanja = row.readTable(_database.hanjaTable);
      final status = row.readTable(_database.dailyHanjaActivityTable).status;
      final bool isBookmarked =
          row.readTableOrNull(_database.userProgressTable)?.isBookmarked ?? false;
      if (!uniqueMap.containsKey(hanja.id)) {
        uniqueMap[hanja.id] = (hanja, status, isBookmarked);
      } else {
        final existingStatus = uniqueMap[hanja.id]!.$2;
        if (status == 'mastered' ||
            (status == 'learning' && existingStatus == 'planned')) {
          uniqueMap[hanja.id] = (hanja, status, isBookmarked);
        }
      }
    }

    List<(HanjaTableData, String, bool)> resultList = uniqueMap.values.toList();
    if (resultList.length > dailyGoal) {
      resultList = resultList.take(dailyGoal).toList();
    }

    // 표시용 'learning' 상태: 아직 없으면 첫 번째 planned에 부여
    if (resultList.isNotEmpty) {
      final bool hasLearning = resultList.any((e) => e.$2 == 'learning');
      if (!hasLearning) {
        for (int i = 0; i < resultList.length; i++) {
          if (resultList[i].$2 == 'planned') {
            resultList[i] = (resultList[i].$1, 'learning', resultList[i].$3);
            break;
          }
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
    return (_database.select(_database.userProgressTable)
          ..where((t) =>
              _ownedByCurrentUser(t) &
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
    final String userId = _currentUserId;

    // 1. 아직 진도 데이터가 없는(또는 'unseen'인) 한자 5개 가져오기
    final query = _database.select(_database.hanjaTable).join([
      leftOuterJoin(
        _database.userProgressTable,
        _database.userProgressTable.hanjaId.equalsExp(_database.hanjaTable.id) &
            _database.userProgressTable.userId.equals(userId),
      ),
    ])
      ..where(_database.userProgressTable.id.isNull())
      ..limit(5);

    final rows = await query.get();
    if (rows.isEmpty) return;

    // 2. 각 한자에 대해 오답 가득한 진도 데이터 삽입
    for (final row in rows) {
      final hanja = row.readTable(_database.hanjaTable);
      final String id = _uuid.v4();

      // 시도 5회 중 정답 1회 (정확도 20%)
      const int totalAttempts = 5;
      const int correctAttempts = 1;
      const double accuracyRate = correctAttempts / totalAttempts;

      await _database.into(_database.userProgressTable).insertOnConflictUpdate(
            UserProgressTableCompanion(
              id: Value(id),
              userId: Value(userId),
              hanjaId: Value(hanja.id),
              status: const Value('learning'),
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

  @override
  Future<void> migrateLocalUserScopedData({
    required String fromUserId,
    required String toUserId,
  }) async {
    if (fromUserId.isEmpty || toUserId.isEmpty || fromUserId == toUserId) {
      return;
    }

    await _database.transaction(() async {
      final DateTime now = DateTime.now();

      final List<UserProgressTableData> sourceProgress =
          await (_database.select(_database.userProgressTable)
                ..where((t) => t.userId.equals(fromUserId)))
              .get();
      final Set<String> targetProgressHanjaIds = (await (_database
                  .select(_database.userProgressTable)
                ..where((t) => t.userId.equals(toUserId)))
              .get())
          .map((row) => row.hanjaId)
          .toSet();

      for (final UserProgressTableData row in sourceProgress) {
        if (targetProgressHanjaIds.contains(row.hanjaId)) {
          await (_database.delete(_database.userProgressTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
          continue;
        }
        await (_database.update(_database.userProgressTable)
              ..where((t) => t.id.equals(row.id)))
            .write(
              UserProgressTableCompanion(
                userId: Value(toUserId),
                updatedAt: Value(now),
                syncStatus: const Value('local_only'),
              ),
            );
      }

      final List<DailyHanjaActivityTableData> sourceActivities =
          await (_database.select(_database.dailyHanjaActivityTable)
                ..where((t) => t.userId.equals(fromUserId)))
              .get();
      final Set<String> targetActivityKeys = (await (_database
                  .select(_database.dailyHanjaActivityTable)
                ..where((t) => t.userId.equals(toUserId)))
              .get())
          .map(
            (row) =>
                '${row.date.toUtc().millisecondsSinceEpoch}_${row.hanjaId}',
          )
          .toSet();

      for (final DailyHanjaActivityTableData row in sourceActivities) {
        final String activityKey =
            '${row.date.toUtc().millisecondsSinceEpoch}_${row.hanjaId}';
        if (targetActivityKeys.contains(activityKey)) {
          await (_database.delete(_database.dailyHanjaActivityTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
          continue;
        }
        await (_database.update(_database.dailyHanjaActivityTable)
              ..where((t) => t.id.equals(row.id)))
            .write(
              DailyHanjaActivityTableCompanion(
                userId: Value(toUserId),
                updatedAt: Value(now),
                syncStatus: const Value('local_only'),
              ),
            );
      }

      final List<DailyActivityStatsTableData> sourceStats =
          await (_database.select(_database.dailyActivityStatsTable)
                ..where((t) => t.userId.equals(fromUserId)))
              .get();

      for (final DailyActivityStatsTableData row in sourceStats) {
        final String targetStatsId =
            '${row.date.millisecondsSinceEpoch}_$toUserId';
        final DailyActivityStatsTableData? existingTarget =
            await (_database.select(_database.dailyActivityStatsTable)
                  ..where((t) => t.id.equals(targetStatsId)))
                .getSingleOrNull();

        if (existingTarget != null) {
          await (_database.update(_database.dailyActivityStatsTable)
                ..where((t) => t.id.equals(existingTarget.id)))
              .write(
                DailyActivityStatsTableCompanion(
                  loginCount: Value(
                    existingTarget.loginCount + row.loginCount,
                  ),
                  sessionCount: Value(
                    existingTarget.sessionCount + row.sessionCount,
                  ),
                  plannedCount: Value(
                    math.max(existingTarget.plannedCount, row.plannedCount),
                  ),
                  inProgressCount: Value(
                    math.max(
                      existingTarget.inProgressCount,
                      row.inProgressCount,
                    ),
                  ),
                  completedCount: Value(
                    math.max(
                      existingTarget.completedCount,
                      row.completedCount,
                    ),
                  ),
                  updatedAt: Value(now),
                  syncStatus: const Value('local_only'),
                ),
              );
          await (_database.delete(_database.dailyActivityStatsTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
          continue;
        }

        await (_database.delete(_database.dailyActivityStatsTable)
              ..where((t) => t.id.equals(row.id)))
            .go();
        await _database.into(_database.dailyActivityStatsTable).insert(
              DailyActivityStatsTableCompanion.insert(
                id: targetStatsId,
                date: row.date,
                userId: toUserId,
                loginCount: Value(row.loginCount),
                sessionCount: Value(row.sessionCount),
                plannedCount: Value(row.plannedCount),
                inProgressCount: Value(row.inProgressCount),
                completedCount: Value(row.completedCount),
                syncStatus: const Value('local_only'),
                createdAt: Value(row.createdAt),
                updatedAt: Value(now),
                syncRevision: Value(row.syncRevision),
              ),
            );
      }

      await (_database.update(_database.loginHistoryTable)
            ..where((t) => t.userId.equals(fromUserId)))
          .write(LoginHistoryTableCompanion(userId: Value(toUserId)));
    });
  }
}
