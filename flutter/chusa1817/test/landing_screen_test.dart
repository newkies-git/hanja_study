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

    expect(find.text('Welcome to Learning'), findsOneWidget);
    expect(find.text('앱 둘러보기'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();
    expect(find.text('로그인'), findsOneWidget);
  });
}

