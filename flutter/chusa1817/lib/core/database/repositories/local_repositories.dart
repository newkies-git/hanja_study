import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../settings/app_settings_keys.dart';

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
  Future<List<HanjaTableData>> fetchByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (_db.select(_db.hanjaTable)..where((t) => t.id.isIn(ids))).get();
  }

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
  LocalProgressRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;
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
    final now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final countExp = _db.dailyHanjaActivityTable.hanjaId.count(distinct: true);
    final query = _db.selectOnly(_db.dailyHanjaActivityTable)
      ..addColumns([countExp])
      ..where(_db.dailyHanjaActivityTable.date.equals(startOfDay) &
          _db.dailyHanjaActivityTable.status.isIn(['mastered', 'completed']));
    return (await query.map((row) => row.read(countExp)).getSingle()) ?? 0;
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
  Future<Map<DateTime, (int completed, int learning)>> fetchDailyActivityStatusCounts({
    int days = 7,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final rows = await (_db.select(_db.dailyHanjaActivityTable)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              // NOTE: review_needed는 "복습 대상"이며 주간 활동량(학습 진행/완료)에는 포함하지 않는다.
              t.status.isIn(['learning', 'mastered', 'completed'])))
        .get();

    final Map<DateTime, Set<String>> completedByDay = {};
    final Map<DateTime, Set<String>> learningByDay = {};
    for (final r in rows) {
      final d = r.date;
      final day = DateTime(d.year, d.month, d.day);
      if (r.status == 'mastered' || r.status == 'completed') {
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
    final dateCol = _db.userProgressTable.lastStudiedAt;
    final query = _db.selectOnly(_db.userProgressTable)
      ..addColumns([dateCol])
      ..where(_db.userProgressTable.lastStudiedAt.isNotNull());
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
    bool? isBookmarked,
    String? forceStatus, // 'learning' | 'mastered'
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

    final String progressStatus = (isCorrect
        ? (n >= 4 ? 'mastered' : 'learning')
        : 'review_needed');
    final String resolvedStatus = (forceStatus == null || forceStatus.isEmpty)
        ? progressStatus
        : forceStatus;

    await _db.into(_db.userProgressTable).insertOnConflictUpdate(
          UserProgressTableCompanion(
            id: Value(id),
            userId: Value(existing?.userId ?? ''),
            hanjaId: Value(hanjaId),
            status: Value(resolvedStatus),
            totalAttempts: Value(totalAttempts),
            correctAttempts: Value(correctAttempts),
            accuracyRate: Value(accuracyRate),
            lastStudiedAt: Value(studiedAt),
            nextReviewAt: Value(nextReviewAt),
            isBookmarked: isBookmarked != null ? Value(isBookmarked) : Value(existing?.isBookmarked ?? false),
            reviewCount: Value(n),
            intervalDays: Value(interval),
            easeFactor: Value(ef),
            updatedAt: Value(now),
          ),
        );

    // ── 일별 통계 동기화 ───────────────────────────────────────────────────
    final String userId = existing?.userId ?? '';
    final date = DateTime(now.year, now.month, now.day);
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    // 상태별 COUNT — 전체 행을 Dart로 읽지 않고 DB에서 집계
    final inProgressCountExp = _db.userProgressTable.id.count();
    final inProgressQuery = _db.selectOnly(_db.userProgressTable)
      ..where(_db.userProgressTable.status.isIn(['learning', 'review_needed']))
      ..addColumns([inProgressCountExp]);
    final inProgress =
        (await inProgressQuery.map((r) => r.read(inProgressCountExp)).getSingle()) ?? 0;

    final masteredCountExp = _db.userProgressTable.id.count();
    final masteredQuery = _db.selectOnly(_db.userProgressTable)
      ..where(_db.userProgressTable.status.equals('mastered'))
      ..addColumns([masteredCountExp]);
    final mastered =
        (await masteredQuery.map((r) => r.read(masteredCountExp)).getSingle()) ?? 0;

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
    // 일별 집계는 "전체 누적 진도"와 같은 기준을 써야 주간/전체 현황이 일관된다.
    // - userProgress.status == mastered → daily status = mastered
    // - learning/review_needed → daily status = learning (주간 그래프에서는 학습중으로 함께 집계)
    final bool isMastered = resolvedStatus == 'mastered';

    await _db.into(_db.dailyHanjaActivityTable).insertOnConflictUpdate(
          DailyHanjaActivityTableCompanion(
            id: Value(activityId),
            date: Value(date),
            userId: Value(userId),
            hanjaId: Value(hanjaId),
            status: Value(isMastered ? 'mastered' : (resolvedStatus == 'review_needed' ? 'review_needed' : 'learning')),
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
  Future<int> fetchLearningCount() async {
    final countExp = _db.userProgressTable.id.count();
    final query = _db.selectOnly(_db.userProgressTable)
      ..where(_db.userProgressTable.status.isIn(['learning', 'review_needed']))
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<List<(HanjaTableData hanja, String status, bool isBookmarked)>> fetchTodayLearningHanja({
    int dailyGoal = 5,
    int orderIndex = 0,
    bool isAscending = true,
    String schoolLevel = 'all',
  }) async {
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);
    final String todayDateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    const String userId = ''; // 현재 세션 기반 userId (기본값)

    // 1. 당일 최초 호출 시 '일일 할당 및 이월(Carryover)' 수행
    final String? lastRefreshed =
        await _settings.get(AppSettingsKeys.lastDailyActivityRefreshedAt);

    if (lastRefreshed != todayDateStr) {
      // 1-1. 기존의 '오늘 날짜' 데이터 중 결정적 ID 형식이 아닌 것(UUID 등)이 있다면 
      // 데이터 정합성을 위해 미리 정리 (중복 방지)
      final existingToday = await (_db.select(_db.dailyHanjaActivityTable)
            ..where((t) => t.date.equals(todayDate)))
          .get();
      
      final expectedPrefix = '${todayDate.millisecondsSinceEpoch}_';
      for (final row in existingToday) {
        if (!row.id.startsWith(expectedPrefix)) {
          // 구버전(UUID) 데이터 삭제
          await (_db.delete(_db.dailyHanjaActivityTable)..where((t) => t.id.equals(row.id))).go();
        }
      }

      // 1-2. [이월] 어제까지 학습을 다 하지 못한(status != 'mastered') 단어들을 오늘로 이동
      final incomplete = await (_db.select(_db.dailyHanjaActivityTable)
            ..where((t) =>
                t.status.equals('mastered').not() &
                t.date.isSmallerThanValue(todayDate))
            ..limit(dailyGoal))
          .get();

      // 현재 오늘 목록에 이미 있는 한자 ID 목록 (중복 이월 방지)
      final currentTodayHanjaIds = (await (_db.select(_db.dailyHanjaActivityTable)
                ..where((t) => t.date.equals(todayDate)))
              .get())
          .map((r) => r.hanjaId)
          .toSet();

      for (final row in incomplete) {
        if (currentTodayHanjaIds.contains(row.hanjaId)) {
          // 이미 오늘 목록에 있다면 이전 기록만 삭제하고 스킵
          await (_db.delete(_db.dailyHanjaActivityTable)..where((t) => t.id.equals(row.id))).go();
          continue;
        }

        final newId = '${todayDate.millisecondsSinceEpoch}_${row.userId}_${row.hanjaId}';
        await _db.into(_db.dailyHanjaActivityTable).insertOnConflictUpdate(
              DailyHanjaActivityTableCompanion(
                id: Value(newId),
                date: Value(todayDate),
                userId: Value(row.userId),
                hanjaId: Value(row.hanjaId),
                status: Value(row.status),
                updatedAt: Value(now),
              ),
            );
        await (_db.delete(_db.dailyHanjaActivityTable)..where((t) => t.id.equals(row.id))).go();
        currentTodayHanjaIds.add(row.hanjaId);
      }

      // 1-3. 이월 후 오늘 목록 수량 확인
      final countExp = _db.dailyHanjaActivityTable.id.count();
      final countQuery = _db.selectOnly(_db.dailyHanjaActivityTable)
        ..addColumns([countExp])
        ..where(_db.dailyHanjaActivityTable.date.equals(todayDate));
      final int todayCount =
          (await countQuery.map((row) => row.read(countExp)).getSingle()) ?? 0;

      // 1-4. [신규 할당] 이월된 수를 뺀 나머지(=목표량에서 부족한 수)만큼 신규 한자 채우기
      final int remaining = math.max(0, dailyGoal - todayCount);
      if (remaining > 0) {
        final nextHanjasQuery = _db.select(_db.hanjaTable).join([
          leftOuterJoin(
            _db.userProgressTable,
            _db.userProgressTable.hanjaId.equalsExp(_db.hanjaTable.id),
          ),
        ])
          ..where(_db.userProgressTable.status.isNull() |
              _db.userProgressTable.status.equals('unseen'));

        // 유형(학교급) 필터: 'all'이면 전체, 아니면 해당 school_level만
        if (schoolLevel != 'all') {
          nextHanjasQuery.where(_db.hanjaTable.schoolLevel.equals(schoolLevel));
        }

        final mode = isAscending ? OrderingMode.asc : OrderingMode.desc;

        if (orderIndex == 1) {
          nextHanjasQuery.orderBy([
            OrderingTerm(expression: _db.hanjaTable.totalStrokes, mode: mode)
          ]);
        } else if (orderIndex == 2) {
          nextHanjasQuery.orderBy([OrderingTerm.random()]);
        } else {
          nextHanjasQuery.orderBy(
              [OrderingTerm(expression: _db.hanjaTable.reading, mode: mode)]);
        }

        // 중복 방지(오늘 이미 할당/이월된 한자 제외) + 필요한 수만큼만
        if (currentTodayHanjaIds.isNotEmpty) {
          nextHanjasQuery.where(
            _db.hanjaTable.id.isNotIn(currentTodayHanjaIds.toList()),
          );
        }
        nextHanjasQuery.limit(remaining);

        final nextRows = await nextHanjasQuery.get();
        for (final row in nextRows) {
          final hanja = row.readTable(_db.hanjaTable);
          final String activityId = '${todayDate.millisecondsSinceEpoch}_${userId}_${hanja.id}';
          
          await _db.into(_db.dailyHanjaActivityTable).insertOnConflictUpdate(
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

      // 갱신 날짜 업데이트
      await _settings.set(
          AppSettingsKeys.lastDailyActivityRefreshedAt, todayDateStr);
    }

    // 2. 오늘 등록된 활동 가져오기
    final query = _db.select(_db.dailyHanjaActivityTable).join([
      innerJoin(
        _db.hanjaTable,
        _db.hanjaTable.id.equalsExp(_db.dailyHanjaActivityTable.hanjaId),
      ),
      leftOuterJoin(
        _db.userProgressTable,
        _db.userProgressTable.hanjaId.equalsExp(_db.dailyHanjaActivityTable.hanjaId),
      ),
    ])
      ..where(_db.dailyHanjaActivityTable.date.equals(todayDate))
      ..orderBy([OrderingTerm.asc(_db.dailyHanjaActivityTable.createdAt)]);

    final rows = await query.get();
    
    // 3. 중복 한자 제거 및 목표량 제한 (안전장치)
    final Map<String, (HanjaTableData, String, bool)> uniqueMap = {};
    for (final row in rows) {
      final hanja = row.readTable(_db.hanjaTable);
      final status = row.readTable(_db.dailyHanjaActivityTable).status;
      final bool isBookmarked = row.readTableOrNull(_db.userProgressTable)?.isBookmarked ?? false;
      
      // 상태 업데이트 우선순위: mastered > learning > planned
      if (!uniqueMap.containsKey(hanja.id)) {
        uniqueMap[hanja.id] = (hanja, status, isBookmarked);
      } else {
        final existingStatus = uniqueMap[hanja.id]!.$2;
        if (status == 'mastered' || (status == 'learning' && existingStatus == 'planned')) {
          uniqueMap[hanja.id] = (hanja, status, isBookmarked);
        }
      }
    }

    List<(HanjaTableData, String, bool)> resultList = uniqueMap.values.toList();
    
    // 수량 제한: dailyGoal을 넘지 않도록 (단, 이미 학습 완료된 것이 상한을 넘는 경우 등 예외 케이스 고려)
    if (resultList.length > dailyGoal) {
      resultList = resultList.take(dailyGoal).toList();
    }

    // 4. 표시용 'learning' 상태 설정
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
