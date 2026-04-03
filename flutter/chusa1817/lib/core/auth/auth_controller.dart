import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_providers.dart';
import '../providers/app_providers.dart';
import '../settings/app_settings_keys.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Google 로그인 흐름 시작
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 사용자가 취소함

      // 2. 인증 상세 정보 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Firebase 자격 증명 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase 로그인
      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
    });
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(email: email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(firebaseAuthProvider);
      
      // Google 로그아웃도 함께 수행
      await GoogleSignIn().signOut();
      await auth.signOut();
      
      // 로그아웃 시 '온보딩 완료' 플래그를 초기화하여 랜딩 스크린으로 돌아갈 수 있게 함.
      final settings = ref.read(settingsRepositoryProvider);
      await settings.set(AppSettingsKeys.onboardingCompleted, 'false');
      
      // 상태 변경을 라우터가 즉시 인지하도록 프로바이더 무효화
      ref.invalidate(onboardingCompletedProvider);

      // 로그아웃 상태에서도 Firestore 규칙(`request.auth`)을 만족시키기 위해
      // 익명 세션은 유지한다 (비로그인은 isNonAnonymousUserProvider로 판단).
      await auth.signInAnonymously();
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

