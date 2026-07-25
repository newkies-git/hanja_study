import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_database.dart';
import 'repository_interfaces.dart';

/// [HanjaRepository]의 로컬 DB 구현체.
class LocalHanjaRepository implements HanjaRepository {
  const LocalHanjaRepository(this._database, this._firebaseAuth);

  final AppDatabase _database;
  final FirebaseAuth _firebaseAuth;

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<HanjaTableData?> fetchById(String id) =>
      (_database.select(_database.hanjaTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<List<HanjaTableData>> fetchByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (_database.select(_database.hanjaTable)..where((t) => t.id.isIn(ids))).get();
  }

  @override
  Future<List<HanjaTableData>> fetchAllOrderedByReading() =>
      (_database.select(_database.hanjaTable)
            ..orderBy([(t) => OrderingTerm.asc(t.reading)]))
          .get();

  @override
  Future<List<HanjaStrokeTableData>> fetchStrokes(String hanjaId) =>
      (_database.select(_database.hanjaStrokeTable)
            ..where((t) => t.hanjaId.equals(hanjaId))
            ..orderBy([(t) => OrderingTerm.asc(t.strokeIndex)]))
          .get();

  @override
  Future<List<String>?> fetchStrokeSvgPaths(String hanjaId) async {
    final HanjaStrokeSvgPathsTableData? row =
        await (_database.select(_database.hanjaStrokeSvgPathsTable)
              ..where((t) => t.hanjaId.equals(hanjaId)))
            .getSingleOrNull();
    if (row == null || row.pathsJson.isEmpty) return null;
    try {
      final List<dynamic> decoded = jsonDecode(row.pathsJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HanjaWordTableData>> fetchWords(String hanjaId) =>
      (_database.select(_database.hanjaWordTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();

  @override
  Future<List<HanjaIdiomTableData>> fetchIdioms(String hanjaId) =>
      (_database.select(_database.hanjaIdiomTable)
            ..where((t) => t.hanjaId.equals(hanjaId)))
          .get();

  @override
  Future<int> fetchTotalCount() async {
    final countExp = _database.hanjaTable.id.count();
    final query = _database.selectOnly(_database.hanjaTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  @override
  Future<HanjaTableData?> fetchNextToLearn({
    int orderIndex = 0,
    bool isAscending = true,
  }) async {
    // '오늘의 학습'은 아직 한 번도 학습하지 않은('unseen') 한자만 추천한다.
    final String userId = _currentUserId;
    final query = _database.select(_database.hanjaTable).join([
      leftOuterJoin(
        _database.userProgressTable,
        _database.userProgressTable.hanjaId.equalsExp(_database.hanjaTable.id) &
            _database.userProgressTable.userId.equals(userId),
      ),
    ])
      ..where(_database.userProgressTable.status.isNull() |
          _database.userProgressTable.status.equals('unseen'));

    final mode = isAscending ? OrderingMode.asc : OrderingMode.desc;

    if (orderIndex == 1) {
      query.orderBy(
          [OrderingTerm(expression: _database.hanjaTable.totalStrokes, mode: mode)]);
    } else if (orderIndex == 2) {
      query.orderBy([OrderingTerm.random()]);
    } else {
      query.orderBy([OrderingTerm(expression: _database.hanjaTable.reading, mode: mode)]);
    }

    query.limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return row.readTable(_database.hanjaTable);
  }
}
