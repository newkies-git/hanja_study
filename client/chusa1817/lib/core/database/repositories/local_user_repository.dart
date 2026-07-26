import '../app_database.dart';
import 'repository_interfaces.dart';

/// [UserRepository]의 로컬 DB 구현체.
class LocalUserRepository implements UserRepository {
  const LocalUserRepository(this._database);

  final AppDatabase _database;

  @override
  Future<UserProfileTableData?> fetchById(String id) =>
      (_database.select(_database.userProfileTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<void> upsert(UserProfileTableCompanion data) =>
      _database.into(_database.userProfileTable).insertOnConflictUpdate(data);
}
