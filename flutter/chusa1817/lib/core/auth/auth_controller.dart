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

  String? _captureAnonymousUserId(FirebaseAuth auth) {
    final User? user = auth.currentUser;
    if (user == null || !user.isAnonymous) return null;
    return user.uid;
  }

  Future<void> _finalizeSignedInUser({
    required User? user,
    required String? previousAnonymousUserId,
  }) async {
    if (user == null) return;

    if (previousAnonymousUserId != null &&
        previousAnonymousUserId.isNotEmpty &&
        previousAnonymousUserId != user.uid) {
      await ref.read(progressRepositoryProvider).migrateLocalUserScopedData(
            fromUserId: previousAnonymousUserId,
            toUserId: user.uid,
          );
    }

    await ref.read(activityRepositoryProvider).recordLogin(user.uid);
    invalidateUserScopedDataProviders(ref);
  }

  Future<UserCredential> _linkOrSignInWithCredential({
    required FirebaseAuth auth,
    required AuthCredential credential,
  }) async {
    final User? currentUser = auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        return await currentUser.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        final bool shouldFallBackToSignIn =
            error.code == 'credential-already-in-use' ||
                error.code == 'email-already-in-use' ||
                error.code == 'provider-already-linked';
        if (!shouldFallBackToSignIn) rethrow;
      }
    }
    return auth.signInWithCredential(credential);
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final FirebaseAuth auth = ref.read(firebaseAuthProvider);
      final String? anonymousUserId = _captureAnonymousUserId(auth);
      final UserCredential credential =
          await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _finalizeSignedInUser(
        user: credential.user,
        previousAnonymousUserId: anonymousUserId,
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseAuth auth = ref.read(firebaseAuthProvider);
      final String? anonymousUserId = _captureAnonymousUserId(auth);
      final UserCredential userCredential = await _linkOrSignInWithCredential(
        auth: auth,
        credential: credential,
      );
      await _finalizeSignedInUser(
        user: userCredential.user,
        previousAnonymousUserId: anonymousUserId,
      );
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final String rawNonce = _generateNonce();
      final String hashedNonce = _sha256ofString(rawNonce);

      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final FirebaseAuth auth = ref.read(firebaseAuthProvider);
      final String? anonymousUserId = _captureAnonymousUserId(auth);
      final UserCredential userCredential = await _linkOrSignInWithCredential(
        auth: auth,
        credential: credential,
      );
      await _finalizeSignedInUser(
        user: userCredential.user,
        previousAnonymousUserId: anonymousUserId,
      );
    });
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final FirebaseAuth auth = ref.read(firebaseAuthProvider);
      final String? anonymousUserId = _captureAnonymousUserId(auth);
      final User? currentUser = auth.currentUser;

      late final UserCredential credential;
      if (currentUser != null && currentUser.isAnonymous) {
        credential = await currentUser.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
      } else {
        credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final User? user = credential.user;
      if (user == null) return;

      await user.updateDisplayName(name);
      await user.reload();
      final User reloadedUser = auth.currentUser ?? user;

      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.upsert(UserProfileTableCompanion(
        id: Value(reloadedUser.uid),
        email: Value(email),
        displayName: Value(name),
        updatedAt: Value(DateTime.now()),
      ));

      await _finalizeSignedInUser(
        user: reloadedUser,
        previousAnonymousUserId: anonymousUserId,
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
      final FirebaseAuth auth = ref.read(firebaseAuthProvider);
      await GoogleSignIn().signOut();
      await auth.signOut();

      final settings = ref.read(settingsRepositoryProvider);
      await settings.set(AppSettingsKeys.onboardingCompleted, 'false');

      await auth.signInAnonymously();
      invalidateUserScopedDataProviders(ref);
      ref.invalidate(onboardingCompletedProvider);
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
