import 'package:chusa1817/features/landing/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Landing screen renders core CTAs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LandingScreen(),
      ),
    );

    // Initial pump ensures first frame is rendered.
    // LandingScreen has animations, let it settle.
    await tester.pumpAndSettle();

    expect(find.text('추사 1817'), findsOneWidget);
    expect(find.text('앱 둘러보기'), findsOneWidget);
    expect(find.text('가입 / 로그인'), findsOneWidget);
  });
}

