import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_sync_controller.dart';

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
    final isSyncing = syncState.isLoading;

    return Stack(
      children: [
        widget.child,
        if (isSyncing)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
