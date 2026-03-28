// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breeze_chusa_1817/main.dart';
import 'package:breeze_chusa_1817/shared/widgets/gradient_primary_button.dart';

void main() {
  testWidgets('Landing screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HanjaApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Learning'), findsOneWidget);
    expect(find.text('학습 시작하기'), findsOneWidget);

    // The bottom CTA can be below the initial viewport.
    await tester.fling(find.byType(ListView), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();
    expect(find.byType(GradientPrimaryButton), findsOneWidget);
  });
}
