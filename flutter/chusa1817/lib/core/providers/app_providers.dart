import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_content_sync.dart';

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
  return LocalHanjaRepository(ref.watch(appDatabaseProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return LocalProgressRepository(ref.watch(appDatabaseProvider));
});

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return LocalStudySessionRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});

/// 한자 총 갯수 FutureProvider.
final totalHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchTotalCount();
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

final upcomingReviewHanjaProvider =
    FutureProvider<List<(String hanjaId, String hanja, String meaning, DateTime nextReviewAt, double accuracy)>>(
        (ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);

  final upcoming = await progressRepository.fetchUpcomingForReview(limit: 20);
  final results = <(String, String, String, DateTime, double)>[];
  for (final row in upcoming) {
    final hanjaRow = await hanjaRepository.fetchById(row.hanjaId);
    if (hanjaRow == null) continue;
    final nextReviewAt = row.nextReviewAt;
    if (nextReviewAt == null) continue;
    results.add((
      hanjaRow.id,
      hanjaRow.character,
      '${hanjaRow.meaning} ${hanjaRow.reading}'.trim(),
      nextReviewAt,
      row.accuracyRate ?? 0.0,
    ));
  }
  return results;
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

final recommendedReviewHanjaProvider =
    FutureProvider<List<(String hanjaId, String hanja, String meaning)>>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);

  final dueList = await progressRepository.fetchDueForReview();
  final results = <(String, String, String)>[];

  for (final due in dueList.take(3)) {
    final hanjaRow = await hanjaRepository.fetchById(due.hanjaId);
    if (hanjaRow == null) continue;
    results.add((
      hanjaRow.id,
      hanjaRow.character,
      '${hanjaRow.meaning} ${hanjaRow.reading}'.trim(),
    ));
  }
  return results;
});

final dueForReviewHanjaProvider =
    FutureProvider<List<(String hanjaId, String hanja, String meaning, double accuracy)>>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);

  final dueList = await progressRepository.fetchDueForReview();
  final results = <(String, String, String, double)>[];

  for (final due in dueList) {
    final hanjaRow = await hanjaRepository.fetchById(due.hanjaId);
    if (hanjaRow == null) continue;
    results.add((
      hanjaRow.id,
      hanjaRow.character,
      '${hanjaRow.meaning} ${hanjaRow.reading}'.trim(),
      due.accuracyRate ?? 0.0,
    ));
  }
  return results;
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
