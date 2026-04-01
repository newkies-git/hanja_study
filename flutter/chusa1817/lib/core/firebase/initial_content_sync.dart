import 'package:flutter/material.dart';

/// 앱 기동 후 Firestore → 로컬 동기화를 연결할 래퍼.
///
/// 현재는 [child]만 그대로 표시한다. 동기화는 이후 단계에서
/// [FirestoreContentSyncService.syncAllContent] 등으로 붙인다.
class InitialContentSync extends StatelessWidget {
  const InitialContentSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
