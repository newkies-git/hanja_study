import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(firebaseAuthProvider).createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(firebaseAuthProvider).sendPasswordResetEmail(email: email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(firebaseAuthProvider).signOut();
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

