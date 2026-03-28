import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase Core 초기화 (실패 시 디버그에서만 무시하고 계속).
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    debugPrint('Firebase.initializeApp 실패 — Firestore 동기화는 사용할 수 없습니다: $e');
    if (kDebugMode) {
      debugPrint('$st');
    }
  }
}
