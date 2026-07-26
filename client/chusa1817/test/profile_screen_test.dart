import 'package:chusa1817/core/auth/auth_providers.dart';
import 'package:chusa1817/core/providers/app_providers.dart';
import 'package:chusa1817/features/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('ProfileScreen renders user profile and menu items', (tester) async {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(_FakeFirebaseAuth()),
        authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        isNonAnonymousUserProvider.overrideWith((ref) => false),
        totalHanjaCountProvider.overrideWith((ref) => 1800),
        bookmarkedHanjaListProvider.overrideWith((ref) => []),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('익명 사용자'), findsOneWidget);
    expect(find.text('학습 요약'), findsOneWidget);
    expect(find.text('학습 설정 (목표 & 시간)'), findsOneWidget);
    expect(find.text('데이터 동기화 (Firestore)'), findsOneWidget);
  });
}
