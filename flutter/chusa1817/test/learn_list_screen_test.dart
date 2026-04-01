import 'package:chusa1817/core/database/app_database.dart';
import 'package:chusa1817/core/providers/app_providers.dart';
import 'package:chusa1817/features/learn/learn_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Learn list shows grid when data provided', (WidgetTester tester) async {
    final fakeHanjaRows = <HanjaTableData>[
      HanjaTableData(
        id: 'uuid-1',
        serverId: null,
        character: '佳',
        reading: '가',
        meaning: '아름다울',
        radical: '人',
        radicalName: '사람 인',
        totalStrokes: 8,
        schoolLevel: 'middle',
        grade: null,
        origin: null,
        usageNote: null,
        syncStatus: 'synced',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        syncRevision: 0,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          middleSchoolHanjaListProvider.overrideWith((ref) async => fakeHanjaRows),
        ],
        child: MaterialApp(
          home: const Scaffold(body: LearnListScreen()),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('佳'), findsOneWidget);
    expect(find.text('아름다울'), findsOneWidget);
  });
}

