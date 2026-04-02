import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../firebase/firestore_paths.dart';
import '../providers/app_providers.dart';
import 'content_sync_progress.dart';
import 'firestore_content_sync.dart';

final contentSyncControllerProvider =
    AsyncNotifierProvider<ContentSyncController, ContentSyncResult?>(
  ContentSyncController.new,
);

/// 동시에 두 번 [syncAllContent]가 돌면 DB/상태가 꼬일 수 있어 직렬화한다.
final class _SyncMutex {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() fn) {
    final completer = Completer<void>();
    final Future<T> next = _tail.then((_) async {
      try {
        return await fn();
      } finally {
        completer.complete();
      }
    });
    _tail = completer.future;
    return next;
  }
}

class ContentSyncController extends AsyncNotifier<ContentSyncResult?> {
  final _SyncMutex _mutex = _SyncMutex();

  @override
  Future<ContentSyncResult?> build() async {
    ref.keepAlive();
    return null;
  }

  Future<ContentSyncResult?> syncIfNeeded() async {
    return _mutex.run(() async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final syncService = ref.read(firestoreContentSyncProvider);
        final database = ref.read(appDatabaseProvider);

        final localVersion = await _loadLocalContentVersion(database);
        final remoteVersion = await syncService.fetchRemoteContentVersion();

        if (kDebugMode) {
          debugPrint('콘텐츠 동기화 버전 비교: local=$localVersion, remote=$remoteVersion');
        }

        if (remoteVersion == null) return null;
        if (localVersion == remoteVersion) return null;

        try {
          final result = await syncService.syncAllContent(
            onProgress: (stage, detail) {
              ref.read(contentSyncProgressProvider.notifier).state =
                  ContentSyncProgressState(stage, detail);
            },
          );
          if (kDebugMode) {
            debugPrint('콘텐츠 동기화 완료: $result');
          }
          _invalidateHanjaListCaches();
          return result;
        } finally {
          ref.read(contentSyncProgressProvider.notifier).state = null;
        }
      });
      return state.value;
    });
  }

  /// `config/content` 버전과 관계없이 Firestore 콘텐츠를 전부 다시 받는다.
  ///
  /// 대상: [FirestorePaths]의 `hanja_basis`, `hanja_extend`, `hanja_stroke`, `hanja_word`.
  Future<ContentSyncResult?> syncFromFirestoreNow() async {
    return _mutex.run(() async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final syncService = ref.read(firestoreContentSyncProvider);
        try {
          final result = await syncService.syncAllContent(
            onProgress: (stage, detail) {
              ref.read(contentSyncProgressProvider.notifier).state =
                  ContentSyncProgressState(stage, detail);
            },
          );
          if (kDebugMode) {
            debugPrint('콘텐츠 수동 동기화 완료: $result');
          }
          _invalidateHanjaListCaches();
          return result;
        } finally {
          ref.read(contentSyncProgressProvider.notifier).state = null;
        }
      });
      return state.value;
    });
  }

  void _invalidateHanjaListCaches() {
    ref.invalidate(learnHanjaListProvider);
    ref.invalidate(totalHanjaCountProvider);
    ref.invalidate(hanjaStrokeVisualProvider);
    ref.invalidate(hanjaStrokePointsProvider);
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

