import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase Core · App Check · 익명 로그인 (Firestore 보안 규칙 `request.auth` 대응).
///
/// App Check 토큰은 SDK가 요청에 첨부한다. Firestore **강제 적용(Enforce)** 은
/// 보안 규칙이 아니라 Firebase Console에서만 켠다 (`request.app` 을 rules에 쓰지 말 것).
Future<void> bootstrapFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    await _activateAppCheck();
    await _ensureAnonymousUser();
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase 초기화/익명 로그인 실패 — Firestore 동기화는 사용할 수 없습니다: $error',
    );
    if (kDebugMode) {
      debugPrint('$stackTrace');
    }
  }
}

Future<void> _activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleDeviceCheckProvider(),
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    if (kDebugMode) {
      debugPrint('Firebase App Check 활성화 완료 (디버그 프로바이더 적용)');
    }
  } catch (error) {
    debugPrint('Firebase App Check 활성화 실패(계속 진행): $error');
  }
}

Future<void> _ensureAnonymousUser() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser != null) return;
  await auth.signInAnonymously();
}
