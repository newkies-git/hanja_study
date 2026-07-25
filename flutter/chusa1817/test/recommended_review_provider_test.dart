import 'package:chusa1817/core/auth/auth_providers.dart';
import 'package:chusa1817/core/database/app_database.dart';
import 'package:chusa1817/core/providers/app_providers.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

void main() {
  test('recommendedReviewHanjaProvider returns UUID-based navigation tuple', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const hanjaId = 'uuid-1';

    await db.into(db.hanjaTable).insert(
          HanjaTableCompanion.insert(
            id: hanjaId,
            character: '佳',
            reading: '가',
            meaning: '아름다울',
            radical: '人',
            radicalName: '사람 인',
            totalStrokes: 8,
            schoolLevel: 'middle',
          ),
        );

    await db.into(db.userProgressTable).insert(
          UserProgressTableCompanion.insert(
            id: 'progress-1',
            userId: const Value(''),
            hanjaId: hanjaId,
            status: const Value('learning'),
            totalAttempts: const Value(5),
            correctAttempts: const Value(1),
            accuracyRate: const Value(0.2),
            nextReviewAt: Value(DateTime.now().subtract(const Duration(days: 1))),
          ),
        );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        firebaseAuthProvider.overrideWithValue(_FakeFirebaseAuth()),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(recommendedReviewHanjaProvider.future);
    expect(result, isNotEmpty);
    expect(result.first.$1, hanjaId);
    expect(result.first.$2, '佳');
  });
}
