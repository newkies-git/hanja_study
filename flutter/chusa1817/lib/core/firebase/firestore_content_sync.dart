import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:firebase_core/firebase_core.dart';

import '../database/app_database.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Firestore 동기화 결과 집계.
class ContentSyncResult {
  const ContentSyncResult({
    required this.hanjaCount,
    required this.strokeCount,
    required this.wordCount,
    required this.idiomCount,
    this.remoteContentVersion,
  });

  final int hanjaCount;
  final int strokeCount;
  final int wordCount;
  final int idiomCount;
  final int? remoteContentVersion;

  @override
  String toString() =>
      'ContentSyncResult(hanja: $hanjaCount, strokes: $strokeCount, '
      'words: $wordCount, idioms: $idiomCount, version: $remoteContentVersion)';
}

/// Firestore → 로컬 Drift DB 풀 동기화.
///
/// - [syncAllContent]: 한자·획·단어/성어를 가져와 SQLite에 반영
/// - [fetchRemoteContentVersion]: `config/content`의 `contentVersion`만 조회
class FirestoreContentSyncService {
  FirestoreContentSyncService({
    required FirebaseFirestore firestore,
    required AppDatabase database,
  })  : _fs = firestore,
        _db = database;

  final FirebaseFirestore _fs;
  final AppDatabase _db;

  /// 원격 콘텐츠 버전 (없으면 null).
  Future<int?> fetchRemoteContentVersion() async {
    _ensureFirebase();
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _fs.doc(FirestorePaths.configContentPath).get();
    final Object? v = doc.data()?['contentVersion'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  /// 한자 → 획 → 단어/성어 순으로 전부 동기화.
  Future<ContentSyncResult> syncAllContent({
    bool loadStrokesFromSubcollection = true,
    int hanjaPageSize = 400,
    int wordsPageSize = 200,
  }) async {
    _ensureFirebase();

    int hanjaCount = 0;
    int strokeCount = 0;
    int wordCount = 0;
    int idiomCount = 0;

    final int? remoteVersion = await fetchRemoteContentVersion();

    Query<Map<String, dynamic>> hanjaQuery = _fs
        .collection(FirestorePaths.hanjaCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await hanjaQuery.limit(hanjaPageSize).get();
      if (page.docs.isEmpty) break;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in page.docs) {
        final Map<String, dynamic> data = doc.data();
        final String hanjaId = FirestoreHanjaMapper.resolveHanjaId(doc.id, data);
        final HanjaTableCompanion hanja =
            FirestoreHanjaMapper.hanjaFromMap(doc.id, data);

        final List<HanjaStrokeTableCompanion> strokeRows =
            await _loadStrokeRowsForDocument(doc, hanjaId, loadStrokesFromSubcollection);

        await _db.transaction(() async {
          await _db.into(_db.hanjaTable).insertOnConflictUpdate(
                hanja.copyWith(
                  updatedAt: Value(DateTime.now()),
                ),
              );
          await (_db.delete(_db.hanjaStrokeTable)..where((t) => t.hanjaId.equals(hanjaId)))
              .go();
          for (final HanjaStrokeTableCompanion c in strokeRows) {
            await _db.into(_db.hanjaStrokeTable).insertOnConflictUpdate(c);
          }
        });

        hanjaCount++;
        strokeCount += strokeRows.length;
      }

      if (page.docs.length < hanjaPageSize) break;
      hanjaQuery = _fs
          .collection(FirestorePaths.hanjaCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    final Map<String, String> charToHanjaId = await _loadCharacterToHanjaIdMap();

    Query<Map<String, dynamic>> wordsQuery = _fs
        .collection(FirestorePaths.wordsCollection)
        .orderBy(FieldPath.documentId);
    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await wordsQuery.limit(wordsPageSize).get();
      if (page.docs.isEmpty) break;

      await _db.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in page.docs) {
          final Map<String, dynamic> data = doc.data();
          final List<String> related = _relatedHanjaChars(data);
          final String entryType = data['entry_type']?.toString() ?? '단어';

          for (final String ch in related.toSet()) {
            final String? hid = charToHanjaId[ch];
            if (hid == null) continue;

            if (entryType == '성어') {
              final HanjaIdiomTableCompanion? row = FirestoreWordMapper.idiomRow(
                wordDocId: doc.id,
                hanjaId: hid,
                data: data,
              );
              if (row != null) {
                await _db.into(_db.hanjaIdiomTable).insertOnConflictUpdate(row);
                idiomCount++;
              }
            } else {
              final HanjaWordTableCompanion? row = FirestoreWordMapper.wordRow(
                wordDocId: doc.id,
                hanjaId: hid,
                data: data,
              );
              if (row != null) {
                await _db.into(_db.hanjaWordTable).insertOnConflictUpdate(row);
                wordCount++;
              }
            }
          }
        }
      });

      if (page.docs.length < wordsPageSize) break;
      wordsQuery = _fs
          .collection(FirestorePaths.wordsCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    return ContentSyncResult(
      hanjaCount: hanjaCount,
      strokeCount: strokeCount,
      wordCount: wordCount,
      idiomCount: idiomCount,
      remoteContentVersion: remoteVersion,
    );
  }

  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase가 초기화되지 않았습니다. main()에서 Firebase.initializeApp을 호출하고 '
        'firebase_options.dart / 네이티브 설정 파일을 구성하세요.',
      );
    }
  }

  Future<List<HanjaStrokeTableCompanion>> _loadStrokeRowsForDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String hanjaId,
    bool loadStrokesFromSubcollection,
  ) async {
    final Map<String, dynamic> data = doc.data();
    final Object? embedded = data['strokes'];
    if (embedded is List && embedded.isNotEmpty) {
      return FirestoreStrokeMapper.strokesFromEmbeddedList(hanjaId, embedded);
    }
    if (!loadStrokesFromSubcollection) return [];

    final QuerySnapshot<Map<String, dynamic>> sub = await _fs
        .collection(FirestorePaths.hanjaCollection)
        .doc(doc.id)
        .collection(FirestorePaths.strokesSubcollection)
        .get();

    final List<HanjaStrokeTableCompanion> out = [];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> s in sub.docs) {
      final HanjaStrokeTableCompanion? c =
          FirestoreStrokeMapper.strokeFromSubDoc(hanjaId, s.id, s.data());
      if (c != null) out.add(c);
    }
    return out;
  }

  Future<Map<String, String>> _loadCharacterToHanjaIdMap() async {
    final List<HanjaTableData> rows = await _db.select(_db.hanjaTable).get();
    final Map<String, String> map = {};
    for (final HanjaTableData r in rows) {
      map.putIfAbsent(r.character, () => r.id);
    }
    return map;
  }

  List<String> _relatedHanjaChars(Map<String, dynamic> data) {
    final Object? raw = data['related_hanja'];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }
}
