import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase Core 초기화 및 익명 로그인 (Firestore 보안 규칙 `request.auth` 대응).
///
/// 초기화·로그인 실패 시에도 앱은 계속 실행된다.
Future<void> bootstrapFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    await _ensureAnonymousUser();
  } catch (e, st) {
    debugPrint('Firebase 초기화/익명 로그인 실패 — Firestore 동기화는 사용할 수 없습니다: $e');
    if (kDebugMode) {
      debugPrint('$st');
    }
  }
}

Future<void> _ensureAnonymousUser() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser != null) return;
  await auth.signInAnonymously();
}
