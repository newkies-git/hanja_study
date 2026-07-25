import 'package:chusa1817/core/database/app_database.dart';
import 'package:chusa1817/core/database/repositories/local_repositories.dart';
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

void main() {
  test('LocalHanjaRepository.fetchTotalCount returns inserted count', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = LocalHanjaRepository(db, _FakeFirebaseAuth());

    await db.into(db.hanjaTable).insert(
          HanjaTableCompanion.insert(
            id: 'uuid-1',
            character: '佳',
            reading: '가',
            meaning: '아름다울',
            radical: '人',
            radicalName: '사람 인',
            totalStrokes: 8,
            schoolLevel: 'middle',
          ),
        );

    await db.into(db.hanjaTable).insert(
          HanjaTableCompanion.insert(
            id: 'uuid-2',
            character: '學',
            reading: '학',
            meaning: '배울',
            radical: '子',
            radicalName: '아들 자',
            totalStrokes: 16,
            schoolLevel: 'middle',
          ),
        );

    final count = await repository.fetchTotalCount();
    expect(count, 2);
  });
}
