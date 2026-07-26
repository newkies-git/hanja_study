import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import 'repository_interfaces.dart';

/// [ActivityRepository]의 로컬 DB 구현체.
class LocalActivityRepository implements ActivityRepository {
  const LocalActivityRepository(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<void> recordLogin(String userId) async {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    await _database.batch((batch) {
      // 1. 상세 이력 추가
      batch.insert(_database.loginHistoryTable, LoginHistoryTableCompanion(
        id: Value(_uuid.v4()),
        userId: Value(userId),
        loginAt: Value(now),
      ));

      // 2. 당일 통계 업데이트 (로그인 횟수 증가)
      // Drift에서 직접 increment를 지원하지 않는 경우 먼저 조회 후 업데이트
      batch.customStatement(
        'INSERT INTO daily_activity_stats (id, date, user_id, login_count, created_at, updated_at) '
        'VALUES (?, ?, ?, 1, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET login_count = login_count + 1, updated_at = ?',
        [statsId, date.toIso8601String(), userId, now.toIso8601String(), now.toIso8601String(), now.toIso8601String()],
      );
    });
  }
}
