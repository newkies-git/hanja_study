import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_content_sync.dart';

import '../auth/auth_providers.dart';
import '../database/repositories/local_repositories.dart';
import '../database/repositories/repository_interfaces.dart';
import '../settings/app_settings_keys.dart';
import '../utils/normalized_points_parser.dart';
import '../utils/stroke_svg_render.dart' show HanjaStrokeVisual, layoutPerStrokeLocalPointsAsGrid, sampleSvgPathsToNormalizedPolylines;

/// 앱 전역 단일 [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// 한자 Repository Provider.
final hanjaRepositoryProvider = Provider<HanjaRepository>((ref) {
  return LocalHanjaRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return LocalProgressRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return LocalStudySessionRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return LocalUserRepository(ref.watch(appDatabaseProvider));
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return LocalActivityRepository(ref.watch(appDatabaseProvider));
});

/// 현재 로그인 상태인 Firebase User.
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final auth = FirebaseAuth.instance;
  return auth.authStateChanges();
});

/// 로컬 DB에서 가져온 현재 사용자 프로필 정보.
final currentUserProfileProvider = FutureProvider<UserProfileTableData?>((ref) async {
  final user = ref.watch(firebaseUserProvider).value;
  if (user == null) return null;
  
  final repo = ref.watch(userRepositoryProvider);
  return repo.fetchById(user.uid);
});

/// 한자 총 갯수 FutureProvider.
final totalHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchTotalCount();
});

/// 마스터한 한자 갯수 FutureProvider.
final masteredHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(progressRepositoryProvider).fetchMasteredCount();
});

/// 학습중(learning) 한자 갯수 FutureProvider.
final learningHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(progressRepositoryProvider).fetchLearningCount();
});

/// 학습 탭 그리드. Firestore `구분`에 따라 `schoolLevel`이 middle/high/both로 갈리므로
/// 중학만 필터하면 데이터가 비는 경우가 있다 — 동기화된 전체 한자를 쓴다.
final learnHanjaListProvider = FutureProvider<List<HanjaTableData>>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchAllOrderedByReading();
});

final hanjaByIdProvider = FutureProvider.family<HanjaTableData?, String>((ref, id) {
  return ref.watch(hanjaRepositoryProvider).fetchById(id);
});

/// 획순·쓰기 가이드용. `svg_paths`가 있으면 [viewer/stroke_entities_viewer.html] 과 동일 좌표계,
/// 없으면 획별 로컬 0~1 좌표를 타일 그리드로 배치한다 (`normalize_to_unit_square` 획마다 독립).
final hanjaStrokeVisualProvider =
    FutureProvider.family<HanjaStrokeVisual, String>((ref, hanjaId) async {
  final HanjaRepository repo = ref.watch(hanjaRepositoryProvider);
  final List<String>? svg = await repo.fetchStrokeSvgPaths(hanjaId);
  if (svg != null && svg.isNotEmpty) {
    return HanjaStrokeVisual(
      svgPaths: svg,
      polylineStrokes: sampleSvgPathsToNormalizedPolylines(svg),
    );
  }
  final rows = await repo.fetchStrokes(hanjaId);
  final parsed = rows
      .map((row) => parseNormalizedPoints(row.normalizedPoints))
      .where((s) => s.length >= 2)
      .toList();
  return HanjaStrokeVisual(
    svgPaths: null,
    polylineStrokes: layoutPerStrokeLocalPointsAsGrid(parsed),
  );
});

/// [HanjaStrokeVisual.polylineStrokes]만 필요한 위젯용.
final hanjaStrokePointsProvider =
    FutureProvider.family<List<List<Offset>>, String>((ref, hanjaId) async {
  final HanjaStrokeVisual v =
      await ref.watch(hanjaStrokeVisualProvider(hanjaId).future);
  return v.polylineStrokes;
});

/// 획순 테이블의 [HanjaStrokeTable.direction] (strokeIndex 오름차순). 채점 힌트용.
final hanjaStrokeDirectionsProvider =
    FutureProvider.family<List<String?>, String>((ref, hanjaId) async {
  final rows = await ref.watch(hanjaRepositoryProvider).fetchStrokes(hanjaId);
  return rows.map((r) => r.direction).toList();
});

final hanjaWordsProvider =
    FutureProvider.family<List<HanjaWordTableData>, String>((ref, hanjaId) {
  return ref.watch(hanjaRepositoryProvider).fetchWords(hanjaId);
});

final hanjaIdiomsProvider =
    FutureProvider.family<List<HanjaIdiomTableData>, String>((ref, hanjaId) {
  return ref.watch(hanjaRepositoryProvider).fetchIdioms(hanjaId);
});

final todayCompletedCountProvider = FutureProvider<int>((ref) {
  return ref.watch(progressRepositoryProvider).fetchTodayCompletedCount();
});

final streakDaysProvider = FutureProvider<int>((ref) {
  return ref.watch(progressRepositoryProvider).fetchStreakDays();
});

final weeklyStudyCountsProvider = FutureProvider<List<int>>((ref) async {
  final counts = await ref.watch(progressRepositoryProvider).fetchDailyStudyCounts(days: 7);
  final DateTime now = DateTime.now();
  final DateTime start =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  return List.generate(7, (i) {
    final date = start.add(Duration(days: i));
    final day = DateTime(date.year, date.month, date.day);
    return counts[day] ?? 0;
  });
});

final weeklyActivityBreakdownProvider =
    FutureProvider<({List<int> completed, List<int> learning, List<int> total})>((ref) async {
  final map = await ref.watch(progressRepositoryProvider).fetchDailyActivityStatusCounts(days: 7);
  final DateTime now = DateTime.now();
  final DateTime start =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final completed = <int>[];
  final learning = <int>[];
  final total = <int>[];
  for (int i = 0; i < 7; i++) {
    final date = start.add(Duration(days: i));
    final day = DateTime(date.year, date.month, date.day);
    final v = map[day];
    final c = v?.$1 ?? 0;
    final l = v?.$2 ?? 0;
    completed.add(c);
    learning.add(l);
    total.add(c + l);
  }
  return (completed: completed, learning: learning, total: total);
});

final upcomingReviewHanjaProvider = FutureProvider<
    ({
      List<(String hanjaId, String hanja, String meaning, DateTime nextReviewAt, double accuracy)> items,
      int remaining,
    })>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);
  final limit = await ref.watch(dailyGoalProvider.future);

  final totalCount = await progressRepository.fetchUpcomingForReviewCount();
  final upcoming = await progressRepository.fetchUpcomingForReview(limit: limit);
  if (upcoming.isEmpty) return (items: <(String, String, String, DateTime, double)>[], remaining: 0);
  final hanjaMap = {
    for (final h in await hanjaRepository.fetchByIds(
        upcoming.map((r) => r.hanjaId).toList()))
      h.id: h
  };
  final items = upcoming
      .where((r) => hanjaMap.containsKey(r.hanjaId) && r.nextReviewAt != null)
      .map((r) {
        final h = hanjaMap[r.hanjaId]!;
        return (
          r.hanjaId,
          h.character,
          '${h.meaning} ${h.reading}'.trim(),
          r.nextReviewAt!,
          r.accuracyRate,
        );
      })
      .toList();
  final remaining = (totalCount - limit).clamp(0, totalCount);
  return (items: items, remaining: remaining);
});

final dailyGoalProvider = FutureProvider<int>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final raw = await settings.get(AppSettingsKeys.dailyGoal);
  final value = int.tryParse(raw ?? '');
  return value ?? 5;
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final raw = await settings.get(AppSettingsKeys.onboardingCompleted);
  return raw == 'true';
});

final orderIndexProvider = FutureProvider<int>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final raw = await settings.get(AppSettingsKeys.orderIndex);
  final value = int.tryParse(raw ?? '');
  return value ?? 0;
});

final isAscendingProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final raw = await settings.get(AppSettingsKeys.isAscending);
  return raw?.toLowerCase() == 'true' || raw == null; // 기본값 true
});

final schoolLevelProvider = FutureProvider<String>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final raw = await settings.get(AppSettingsKeys.schoolLevel);
  // 'middle' | 'high' | 'all'
  return (raw == null || raw.isEmpty) ? 'all' : raw;
});

final recommendedReviewHanjaProvider =
    FutureProvider<List<(String hanjaId, String hanja, String meaning, String subInfo)>>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);

  final errorProneList = await progressRepository.fetchTopErrorProneHanja(limit: 10);
  if (errorProneList.isEmpty) return [];
  final hanjaMap = {
    for (final h in await hanjaRepository.fetchByIds(
        errorProneList.map((e) => e.hanjaId).toList()))
      h.id: h
  };
  return errorProneList
      .where((e) => hanjaMap.containsKey(e.hanjaId))
      .map((e) {
        final h = hanjaMap[e.hanjaId]!;
        return (
          h.id,
          h.character,
          '${h.meaning} ${h.reading}'.trim(),
          '${h.radical}   ${h.totalStrokes}',
        );
      })
      .toList();
});

final dueForReviewHanjaProvider =
    FutureProvider<List<(String hanjaId, String hanja, String meaning, double accuracy)>>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);
  final limit = await ref.watch(dailyGoalProvider.future);

  final dueList = await progressRepository.fetchDueForReview(limit: limit);
  if (dueList.isEmpty) return [];
  final hanjaMap = {
    for (final h in await hanjaRepository.fetchByIds(
        dueList.map((r) => r.hanjaId).toList()))
      h.id: h
  };
  return dueList
      .where((r) => hanjaMap.containsKey(r.hanjaId))
      .map((r) {
        final h = hanjaMap[r.hanjaId]!;
        return (r.hanjaId, h.character, '${h.meaning} ${h.reading}'.trim(), r.accuracyRate);
      })
      .toList();
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firestore → Drift 콘텐츠 동기화.
final firestoreContentSyncProvider = Provider<FirestoreContentSyncService>((ref) {
  return FirestoreContentSyncService(
    firestore: ref.watch(firebaseFirestoreProvider),
    database: ref.watch(appDatabaseProvider),
  );
});

/// 오늘 공부할 다음 한자 하나를 가져온다. 홈 화면의 '학습 이어하기' 버튼용.
final nextHanjaToLearnProvider = FutureProvider<HanjaTableData?>((ref) async {
  final (orderIndex, isAscending) = await (
    ref.watch(orderIndexProvider.future),
    ref.watch(isAscendingProvider.future),
  ).wait;
  return ref
      .watch(hanjaRepositoryProvider)
      .fetchNextToLearn(orderIndex: orderIndex, isAscending: isAscending);
});

/// 특정 한자의 학습 진도(북마크 포함)를 가져온다.
final hanjaProgressProvider =
    FutureProvider.family<UserProgressTableData?, String>((ref, hanjaId) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.fetchProgress(hanjaId);
});

/// 오답 노트: 학습 이력이 있고 정확도가 낮은 전체 한자 목록.
///
/// 정확도 오름차순(오답률 높은 순) + 시도횟수 내림차순으로 정렬한다.
/// [recommendedReviewHanjaProvider]와 달리 limit 없이 전수를 반환한다.
final wrongAnswerHanjaProvider = FutureProvider<
    List<({String hanjaId, String hanja, String reading, String meaning, double accuracy, int totalAttempts, int correctAttempts})>>(
  (ref) async {
    final progressRepository = ref.watch(progressRepositoryProvider);
    final hanjaRepository = ref.watch(hanjaRepositoryProvider);

    final errorList =
        await progressRepository.fetchTopErrorProneHanja(limit: 9999);
    if (errorList.isEmpty) return [];
    final hanjaMap = {
      for (final h in await hanjaRepository.fetchByIds(
          errorList.map((e) => e.hanjaId).toList()))
        h.id: h
    };
    return errorList
        .where((e) => hanjaMap.containsKey(e.hanjaId))
        .map((e) {
          final h = hanjaMap[e.hanjaId]!;
          return (
            hanjaId: h.id,
            hanja: h.character,
            reading: h.reading,
            meaning: h.meaning,
            accuracy: e.accuracyRate,
            totalAttempts: e.totalAttempts,
            correctAttempts: e.correctAttempts,
          );
        })
        .toList();
  },
);

/// 일일 학습 계획 갱신 Notifier (쓰기 전담).
///
/// 설정(목표량·정렬·학교급)이 변경될 때마다 재실행되어
/// [ProgressRepository.refreshDailyPlan]으로 이월 및 신규 채우기를 수행한다.
class DailyPlanNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    final (goal, orderIndex, isAscending, schoolLevel) = await (
      ref.watch(dailyGoalProvider.future),
      ref.watch(orderIndexProvider.future),
      ref.watch(isAscendingProvider.future),
      ref.watch(schoolLevelProvider.future),
    ).wait;
    await ref.read(progressRepositoryProvider).refreshDailyPlan(
      dailyGoal: goal,
      orderIndex: orderIndex,
      isAscending: isAscending,
      schoolLevel: schoolLevel,
    );
  }
}

final dailyPlanProvider =
    AsyncNotifierProvider<DailyPlanNotifier, void>(DailyPlanNotifier.new);

/// 오늘 학습할 한자 목록 (순수 읽기).
///
/// [dailyPlanProvider] 갱신 완료 후 읽기만 수행한다.
final todayLearningHanjaListProvider = FutureProvider<List<(HanjaTableData, String, bool)>>((ref) async {
  await ref.watch(dailyPlanProvider.future); // 쓰기 완료 대기
  final goal = await ref.watch(dailyGoalProvider.future);
  return ref.read(progressRepositoryProvider).readTodayHanjaList(dailyGoal: goal);
});

// ── 테마 모드 ──────────────────────────────────────────────────────────────────

/// 앱 전역 테마 모드 노티파이어.
/// 시작 시 DB에서 저장된 값을 비동기 로드하며, 변경 즉시 영구 저장한다.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // 비동기 초기화: 로드 전까지는 시스템 기본값 사용
    Future(() async {
      final settings = ref.read(settingsRepositoryProvider);
      final raw = await settings.get(AppSettingsKeys.themeMode);
      state = _parse(raw);
    });
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(AppSettingsKeys.themeMode, _serialize(mode));
  }

  static ThemeMode _parse(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark'  => ThemeMode.dark,
    _       => ThemeMode.system,
  };

  static String _serialize(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark  => 'dark',
    _               => 'system',
  };
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
