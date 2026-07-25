import 'package:chusa1817/core/firebase/content_sync_progress.dart';
import 'package:chusa1817/shared/widgets/content_sync_progress_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ContentSyncProgressSection renders progress state correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContentSyncProgressSection(
            progress: ContentSyncProgressState(ContentSyncStage.hanjaBasis, '100 / 1800'),
            isSyncLoading: true,
            hasError: false,
          ),
        ),
      ),
    );

    expect(find.text('동기화 진행'), findsOneWidget);
    expect(find.text('hanja_basis'), findsOneWidget);
    expect(find.text('100 / 1800'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ContentSyncProgressSection renders error state icon when hasError is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContentSyncProgressSection(
            progress: ContentSyncProgressState(ContentSyncStage.hanjaBasis, '네트워크 연결 오류'),
            isSyncLoading: false,
            hasError: true,
          ),
        ),
      ),
    );

    expect(find.text('동기화 진행'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('네트워크 연결 오류'), findsOneWidget);
  });
}
