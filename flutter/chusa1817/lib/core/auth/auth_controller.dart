import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_providers.dart';
import '../database/app_database.dart';
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
      final credential = await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      final user = credential.user;
      if (user != null) {
        await ref.read(activityRepositoryProvider).recordLogin(user.uid);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await ref.read(activityRepositoryProvider).recordLogin(user.uid);
      }
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Generate a random nonce for security
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // 2. Start Apple ID Authentication
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // 3. Create Firebase Credential
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // 4. Sign in to Firebase
      final userCredential = await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await ref.read(activityRepositoryProvider).recordLogin(user.uid);
      }
    });
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
      
      final user = credential.user;
      if (user != null) {
        // 1. Firebase Auth 프로필 이름 업데이트
        await user.updateDisplayName(name);
        // 2. 변경사항 즉시 반영을 위한 리로드
        await user.reload();

        // 3. 로컬 DB(Drift)에 사용자 프로필 저장 (PRD5: Local-First)
        final userRepo = ref.read(userRepositoryProvider);
        await userRepo.upsert(UserProfileTableCompanion(
          id: Value(user.uid),
          email: Value(email),
          displayName: Value(name),
          updatedAt: Value(DateTime.now()),
        ));

        // 4. 첫 로그인 기록
        await ref.read(activityRepositoryProvider).recordLogin(user.uid);
      }
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
      await GoogleSignIn().signOut();
      await auth.signOut();
      
      final settings = ref.read(settingsRepositoryProvider);
      await settings.set(AppSettingsKeys.onboardingCompleted, 'false');
      
      ref.invalidate(onboardingCompletedProvider);
      await auth.signInAnonymously();
    });
  }

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.-_';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hashes a string using SHA256.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

