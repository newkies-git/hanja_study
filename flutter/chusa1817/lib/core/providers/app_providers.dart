import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_content_sync.dart';

import '../database/repositories/local_repositories.dart';
import '../database/repositories/repository_interfaces.dart';
import '../utils/normalized_points_parser.dart';

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

/// 한자 총 갯수 FutureProvider.
final totalHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchTotalCount();
});

final middleSchoolHanjaListProvider = FutureProvider<List<HanjaTableData>>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchByLevel('middle');
});

final hanjaByIdProvider = FutureProvider.family<HanjaTableData?, String>((ref, id) {
  return ref.watch(hanjaRepositoryProvider).fetchById(id);
});

final hanjaStrokePointsProvider =
    FutureProvider.family<List<List<Offset>>, String>((ref, hanjaId) async {
  final rows = await ref.watch(hanjaRepositoryProvider).fetchStrokes(hanjaId);
  return rows.map((row) => parseNormalizedPoints(row.normalizedPoints)).toList();
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
    FutureProvider<List<(String hanjaId, String hanja, String meaning)>>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final hanjaRepository = ref.watch(hanjaRepositoryProvider);

  final dueList = await progressRepository.fetchDueForReview();
  final results = <(String, String, String)>[];

  for (final due in dueList) {
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
