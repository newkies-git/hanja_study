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
      final syncService = ref.read(firestoreContentSyncProvider);
      final database = ref.read(appDatabaseProvider);

      // 1. 버전 체크 - 로딩 상태 진입 전 수행
      final localVersion = await _loadLocalContentVersion(database);
      final remoteVersion = await syncService.fetchRemoteContentVersion();

      if (kDebugMode) {
        debugPrint('콘텐츠 동기화 버전 비교(syncIfNeeded): local=$localVersion, remote=$remoteVersion');
      }

      // 변경사항이 없으면 즉시 null 반환 (로딩 UI 띄우지 않음)
      if (remoteVersion == null || localVersion == remoteVersion) {
        return null;
      }

      // 2. 실제 변경 확인 시 로딩 개시
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        try {
          final result = await syncService.syncAllContent(
            onProgress: (stage, detail) {
              ref.read(contentSyncProgressProvider.notifier).state =
                  ContentSyncProgressState(stage, detail);
            },
          );
          _invalidateHanjaListCaches();
          return result;
        } finally {
          ref.read(contentSyncProgressProvider.notifier).state = null;
        }
      });
      return state.value;
    });
  }

  /// Firestore 콘텐츠를 다시 받는다. [force]가 true면 버전 체크 없이 강제 진행.
  Future<ContentSyncResult?> syncFromFirestoreNow({bool force = false}) async {
    return _mutex.run(() async {
      final syncService = ref.read(firestoreContentSyncProvider);
      final database = ref.read(appDatabaseProvider);

      if (!force) {
        final localVersion = await _loadLocalContentVersion(database);
        final remoteVersion = await syncService.fetchRemoteContentVersion();

        if (kDebugMode) {
          debugPrint('수동 동기화 버전 비교: local=$localVersion, remote=$remoteVersion');
        }

        if (remoteVersion != null && localVersion == remoteVersion) {
          // 이미 최신이면 "변경 없음" 결과 반환 (UI에서 감지용)
          return const ContentSyncResult(
            basisCount: 0,
            extendCount: 0,
            strokeDocCount: 0,
            strokeRowCount: 0,
            wordCount: 0,
            idiomCount: 0,
            remoteContentVersion: -1, // -1: Skip due to version match
          );
        }
      }

      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        try {
          final result = await syncService.syncAllContent(
            onProgress: (stage, detail) {
              ref.read(contentSyncProgressProvider.notifier).state =
                  ContentSyncProgressState(stage, detail);
            },
          );
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
    ref.invalidate(learnHanjaPageProvider);
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

