import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repository_interfaces.dart';

/// [SettingsRepository]의 로컬 DB 구현체.
class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<String?> get(String key) async {
    final row = await (_database.select(_database.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> set(String key, String value) async {
    await _database.into(_database.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
