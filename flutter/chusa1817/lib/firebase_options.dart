// ignore_for_file: lines_longer_than_80_chars
//
// `flutterfire configure` 실행 시 이 파일이 덮어씌워집니다.
// 로컬 개발 전 Firebase 콘솔에서 앱을 등록한 뒤 실제 값으로 교체하세요.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase 초기화용 옵션 (플랫폼별).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          '이 플랫폼용 DefaultFirebaseOptions가 없습니다. firebase_options.dart를 구성하세요.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyReplaceWithFlutterFireConfigure',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'chusa1817-dev',
    storageBucket: 'chusa1817-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyReplaceWithFlutterFireConfigure',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'chusa1817-dev',
    storageBucket: 'chusa1817-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyReplaceWithFlutterFireConfigure',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'chusa1817-dev',
    storageBucket: 'chusa1817-dev.appspot.com',
    iosBundleId: 'com.basis.hanja.chusa1817',
  );
}
