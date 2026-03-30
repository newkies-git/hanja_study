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
    projectId: 'chusa-1817',
    storageBucket: 'chusa-1817.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCUxymYw3IuDKlwbN_R-69yI3GpA_pYlw',
    appId: '1:115363684571:android:d9c6925f0aa2f31c7bacfe',
    messagingSenderId: '115363684571',
    projectId: 'chusa-1817',
    storageBucket: 'chusa-1817.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhbe13PErgvk6cJnXhkDUOMJT-CHJSOzY',
    appId: '1:115363684571:ios:0416765dc465518b7bacfe',
    messagingSenderId: '115363684571',
    projectId: 'chusa-1817',
    storageBucket: 'chusa-1817.firebasestorage.app',
    iosBundleId: 'com.basis.hanja.chusa1817',
  );

}