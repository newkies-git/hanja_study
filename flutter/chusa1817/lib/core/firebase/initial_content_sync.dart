import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_sync_controller.dart';
import 'content_sync_progress.dart';

/// 앱 기동 후 Firestore → 로컬 동기화를 연결할 래퍼.
///
/// 현재는 [child]만 그대로 표시한다. 동기화는 이후 단계에서
/// [FirestoreContentSyncService.syncAllContent] 등으로 붙인다.
class InitialContentSync extends ConsumerStatefulWidget {
  const InitialContentSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InitialContentSync> createState() => _InitialContentSyncState();
}

class _InitialContentSyncState extends ConsumerState<InitialContentSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentSyncControllerProvider.notifier).syncIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(contentSyncControllerProvider);
    final progress = ref.watch(contentSyncProgressProvider);
    final isSyncing = syncState.isLoading;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          widget.child,
          if (isSyncing)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LinearProgressIndicator(minHeight: 2),
                  if (progress != null)
                    Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.92),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          _syncStageLabel(progress.stage, progress.detail),
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _syncStageLabel(ContentSyncStage stage, String? detail) {
    final String base = switch (stage) {
      ContentSyncStage.idle => '동기화',
      ContentSyncStage.resetLocal => '로컬 테이블 초기화',
      ContentSyncStage.hanjaBasis => 'hanja_basis',
      ContentSyncStage.hanjaExtend => 'hanja_extend',
      ContentSyncStage.hanjaStroke => 'hanja_stroke',
      ContentSyncStage.hanjaWord => 'hanja_word',
      ContentSyncStage.savingVersion => '버전 저장',
      ContentSyncStage.done => '완료',
    };
    if (detail == null || detail.isEmpty) return base;
    return '$base · $detail';
  }
}
