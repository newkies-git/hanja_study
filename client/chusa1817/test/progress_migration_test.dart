import 'package:chusa1817/core/database/app_database.dart';
import 'package:chusa1817/core/database/repositories/local_repositories.dart';
import 'package:chusa1817/core/database/repositories/repository_interfaces.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String?> get(String key) async => null;

  @override
  Future<void> set(String key, String value) async {}
}

void main() {
  test('migrateLocalUserScopedData moves progress and keeps target conflicts',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = LocalProgressRepository(
      db,
      _FakeSettingsRepository(),
      _FakeFirebaseAuth(),
    );

    const String fromUserId = 'anon-uid';
    const String toUserId = 'account-uid';
    final DateTime now = DateTime.now();

    await db.into(db.userProgressTable).insert(
          UserProgressTableCompanion.insert(
            id: 'progress-shared',
            userId: const Value(fromUserId),
            hanjaId: 'hanja-shared',
            status: const Value('learning'),
            totalAttempts: const Value(3),
            correctAttempts: const Value(1),
            accuracyRate: const Value(0.33),
            lastStudiedAt: Value(now),
          ),
        );
    await db.into(db.userProgressTable).insert(
          UserProgressTableCompanion.insert(
            id: 'progress-only-anon',
            userId: const Value(fromUserId),
            hanjaId: 'hanja-only-anon',
            status: const Value('learning'),
            totalAttempts: const Value(2),
            correctAttempts: const Value(2),
            accuracyRate: const Value(1.0),
            lastStudiedAt: Value(now),
          ),
        );
    await db.into(db.userProgressTable).insert(
          UserProgressTableCompanion.insert(
            id: 'progress-account',
            userId: const Value(toUserId),
            hanjaId: 'hanja-shared',
            status: const Value('mastered'),
            totalAttempts: const Value(10),
            correctAttempts: const Value(9),
            accuracyRate: const Value(0.9),
            lastStudiedAt: Value(now),
          ),
        );

    await repository.migrateLocalUserScopedData(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );

    final List<UserProgressTableData> remainingFrom =
        await (db.select(db.userProgressTable)
              ..where((t) => t.userId.equals(fromUserId)))
            .get();
    expect(remainingFrom, isEmpty);

    final List<UserProgressTableData> targetRows =
        await (db.select(db.userProgressTable)
              ..where((t) => t.userId.equals(toUserId)))
            .get();
    expect(targetRows.length, 2);

    final UserProgressTableData shared = targetRows
        .firstWhere((row) => row.hanjaId == 'hanja-shared');
    expect(shared.id, 'progress-account');
    expect(shared.status, 'mastered');

    final UserProgressTableData moved = targetRows
        .firstWhere((row) => row.hanjaId == 'hanja-only-anon');
    expect(moved.id, 'progress-only-anon');
    expect(moved.userId, toUserId);
  });
}
