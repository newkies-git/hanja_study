import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../firebase/firestore_paths.dart';
import '../providers/app_providers.dart';
import 'firestore_content_sync.dart';

final contentSyncControllerProvider =
    AutoDisposeAsyncNotifierProvider<ContentSyncController, ContentSyncResult?>(
  ContentSyncController.new,
);

class ContentSyncController extends AutoDisposeAsyncNotifier<ContentSyncResult?> {
  @override
  Future<ContentSyncResult?> build() async => null;

  Future<ContentSyncResult?> syncIfNeeded() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final syncService = ref.read(firestoreContentSyncProvider);
      final database = ref.read(appDatabaseProvider);

      final localVersion = await _loadLocalContentVersion(database);
      final remoteVersion = await syncService.fetchRemoteContentVersion();

      if (remoteVersion == null) return null;
      if (localVersion == remoteVersion) return null;

      return syncService.syncAllContent();
    });
    return state.value;
  }

  Future<int?> _loadLocalContentVersion(AppDatabase database) async {
    final row = await (database.select(database.contentConfigTable)
          ..where(
            (t) => t.id.equals(FirestorePaths.localContentConfigRowId),
          ))
        .getSingleOrNull();
    return row?.contentVersion;
  }
}

