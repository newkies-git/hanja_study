import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_content_sync.dart';

import '../database/repositories/local_repositories.dart';
import '../database/repositories/repository_interfaces.dart';

/// 앱 전역 단일 [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 한자 Repository Provider.
final hanjaRepositoryProvider = Provider<HanjaRepository>((ref) {
  return LocalHanjaRepository(ref.watch(appDatabaseProvider));
});

/// 한자 총 갯수 FutureProvider.
final totalHanjaCountProvider = FutureProvider<int>((ref) {
  return ref.watch(hanjaRepositoryProvider).fetchTotalCount();
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
