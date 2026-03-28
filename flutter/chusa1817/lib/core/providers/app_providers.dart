import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_content_sync.dart';

/// 앱 전역 단일 [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
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
