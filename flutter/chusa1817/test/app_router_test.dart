import 'package:chusa1817/core/auth/auth_providers.dart';
import 'package:chusa1817/core/providers/app_providers.dart';
import 'package:chusa1817/core/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('Unauthenticated user navigating to home is redirected to landing', (tester) async {
    final fakeAuth = _FakeFirebaseAuth();

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(fakeAuth),
        isSignedInProvider.overrideWith((ref) => false),
        isNonAnonymousUserProvider.overrideWith((ref) => false),
        onboardingCompletedProvider.overrideWith((ref) => false),
      ],
    );

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('추사 1817'), findsOneWidget);
  });
}
