import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:firebase_core/firebase_core.dart';

import '../database/app_database.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Firestore 동기화 결과 집계.
class ContentSyncResult {
  const ContentSyncResult({
    required this.basisCount,
    required this.extendCount,
    required this.strokeDocCount,
    required this.strokeRowCount,
    required this.wordCount,
    required this.idiomCount,
    this.remoteContentVersion,
  });

  final int basisCount;
  final int extendCount;
  final int strokeDocCount;
  final int strokeRowCount;
  final int wordCount;
  final int idiomCount;
  final int? remoteContentVersion;

  @override
  String toString() =>
      'ContentSyncResult(basis: $basisCount, extend: $extendCount, '
      'strokeDocs: $strokeDocCount, strokeRows: $strokeRowCount, '
      'words: $wordCount, idioms: $idiomCount, version: $remoteContentVersion)';
}

/// Firestore → 로컬 Drift DB 풀 동기화.
///
/// 소스 컬렉션: `hanja_basis`, `hanja_extend`, `hanja_stroke`, `hanja_word`, `config/content`.
class FirestoreContentSyncService {
  FirestoreContentSyncService({
    required FirebaseFirestore firestore,
    required AppDatabase database,
  })  : _firestore = firestore,
        _database = database;

  final FirebaseFirestore _firestore;
  final AppDatabase _database;

  /// 원격 콘텐츠 버전 (없으면 null).
  Future<int?> fetchRemoteContentVersion() async {
    _ensureFirebase();
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.doc(FirestorePaths.configContentPath).get();
    final Object? rawVersion = doc.data()?['contentVersion'];
    if (rawVersion is int) return rawVersion;
    if (rawVersion is num) return rawVersion.toInt();
    return null;
  }

  /// 관리 웹과 동일한 Firestore 컬렉션에서 전체 동기화.
  ///
  /// 콘텐츠 테이블(`hanja_basis`·`hanja_extend`·`hanja_stroke`·`hanja_word`·`hanja_idiom`)은
  /// 서버 스냅샷으로 갱신한다. 사용자 진도(`user_progress` 등)는 건드리지 않는다.
  Future<ContentSyncResult> syncAllContent({int pageSize = 400}) async {
    _ensureFirebase();

    final int? remoteVersion = await fetchRemoteContentVersion();

    await _database.into(_database.contentConfigTable).insertOnConflictUpdate(
          ContentConfigTableCompanion(
            id: const Value(FirestorePaths.localContentConfigRowId),
            contentVersion: Value(remoteVersion),
            syncedAt: Value(DateTime.now()),
          ),
        );

    int basisCount = 0;
    int extendCount = 0;

    await _database.transaction(() async {
      await _database.delete(_database.hanjaStrokeTable).go();
      await _database.delete(_database.hanjaWordTable).go();
      await _database.delete(_database.hanjaIdiomTable).go();
      await _database.delete(_database.hanjaExtendTable).go();
      await _database.delete(_database.hanjaTable).go();
    });

    Query<Map<String, dynamic>> basisQuery = _firestore
        .collection(FirestorePaths.hanjaBasisCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await basisQuery.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _database.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
            in page.docs) {
          final HanjaTableCompanion row = FirestoreBasisMapper.hanjaFromBasisDoc(
            docSnapshot.id,
            docSnapshot.data(),
          );
          await _database.into(_database.hanjaTable).insertOnConflictUpdate(
                row.copyWith(updatedAt: Value(DateTime.now())),
              );
          basisCount++;
        }
      });

      if (page.docs.length < pageSize) break;
      basisQuery = _firestore
          .collection(FirestorePaths.hanjaBasisCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    Query<Map<String, dynamic>> extendQuery = _firestore
        .collection(FirestorePaths.hanjaExtendCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await extendQuery.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _database.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
            in page.docs) {
          final Map<String, dynamic> data = docSnapshot.data();
          await _database.into(_database.hanjaExtendTable).insertOnConflictUpdate(
                HanjaExtendTableCompanion.insert(
                  id: docSnapshot.id,
                  payloadJson: jsonEncode(data),
                  syncedAt: Value(DateTime.now()),
                ),
              );

          final HanjaTableCompanion extended =
              FirestoreHanjaMapper.hanjaFromMap(docSnapshot.id, data);
          await _database.into(_database.hanjaTable).insertOnConflictUpdate(
                extended.copyWith(updatedAt: Value(DateTime.now())),
              );
          extendCount++;
        }
      });

      if (page.docs.length < pageSize) break;
      extendQuery = _firestore
          .collection(FirestorePaths.hanjaExtendCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    final Map<String, String> charToHanjaId = await _loadCharacterToHanjaIdMap();
    final Set<String> hanjaIds = await _loadHanjaIds();

    int strokeDocCount = 0;
    int strokeRowCount = 0;

    Query<Map<String, dynamic>> strokeQuery = _firestore
        .collection(FirestorePaths.hanjaStrokeCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await strokeQuery.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _database.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
            in page.docs) {
          final Map<String, dynamic> data = docSnapshot.data();
          final String? hanjaId = _resolveHanjaIdForStroke(
            data,
            hanjaIds,
            charToHanjaId,
          );
          if (hanjaId == null) continue;

          final List<dynamic>? strokes = data['strokes'] as List<dynamic>?;
          if (strokes == null || strokes.isEmpty) continue;

          final List<HanjaStrokeTableCompanion> strokeRows =
              FirestoreStrokeMapper.strokesFromEmbeddedList(hanjaId, strokes);
          if (strokeRows.isEmpty) continue;
          strokeDocCount++;
          for (final HanjaStrokeTableCompanion strokeCompanion in strokeRows) {
            await _database
                .into(_database.hanjaStrokeTable)
                .insertOnConflictUpdate(strokeCompanion);
            strokeRowCount++;
          }
        }
      });

      if (page.docs.length < pageSize) break;
      strokeQuery = _firestore
          .collection(FirestorePaths.hanjaStrokeCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    int wordCount = 0;
    int idiomCount = 0;

    Query<Map<String, dynamic>> wordQuery = _firestore
        .collection(FirestorePaths.hanjaWordCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await wordQuery.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _database.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> wordDocSnapshot
            in page.docs) {
          final Map<String, dynamic> data = wordDocSnapshot.data();
          final List<String> relatedCharacters = _relatedHanjaChars(data);
          final String entryType = data['entry_type']?.toString() ?? '단어';

          for (final String relatedCharacter in relatedCharacters.toSet()) {
            final String? relatedHanjaId = charToHanjaId[relatedCharacter];
            if (relatedHanjaId == null) continue;

            if (entryType == '성어') {
              final HanjaIdiomTableCompanion? idiomCompanion =
                  FirestoreWordMapper.idiomRow(
                wordDocId: wordDocSnapshot.id,
                hanjaId: relatedHanjaId,
                data: data,
              );
              if (idiomCompanion != null) {
                await _database
                    .into(_database.hanjaIdiomTable)
                    .insertOnConflictUpdate(idiomCompanion);
                idiomCount++;
              }
            } else {
              final HanjaWordTableCompanion? wordCompanion =
                  FirestoreWordMapper.wordRow(
                wordDocId: wordDocSnapshot.id,
                hanjaId: relatedHanjaId,
                data: data,
              );
              if (wordCompanion != null) {
                await _database
                    .into(_database.hanjaWordTable)
                    .insertOnConflictUpdate(wordCompanion);
                wordCount++;
              }
            }
          }
        }
      });

      if (page.docs.length < pageSize) break;
      wordQuery = _firestore
          .collection(FirestorePaths.hanjaWordCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    return ContentSyncResult(
      basisCount: basisCount,
      extendCount: extendCount,
      strokeDocCount: strokeDocCount,
      strokeRowCount: strokeRowCount,
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

  /// `stroke_data_id` → 한자 행 id. 없으면 `char`로 역참조.
  String? _resolveHanjaIdForStroke(
    Map<String, dynamic> data,
    Set<String> hanjaIds,
    Map<String, String> charToHanjaId,
  ) {
    final String strokeDataId = data['stroke_data_id']?.toString().trim() ?? '';
    if (strokeDataId.isNotEmpty && hanjaIds.contains(strokeDataId)) {
      return strokeDataId;
    }

    final String character = data['char']?.toString().trim() ?? '';
    if (character.isNotEmpty) {
      final String? hanjaIdByChar = charToHanjaId[character];
      if (hanjaIdByChar != null) return hanjaIdByChar;
    }
    if (strokeDataId.isNotEmpty) return strokeDataId;
    return null;
  }

  Future<Set<String>> _loadHanjaIds() async {
    final List<HanjaTableData> rows =
        await _database.select(_database.hanjaTable).get();
    return rows.map((hanjaRow) => hanjaRow.id).toSet();
  }

  Future<Map<String, String>> _loadCharacterToHanjaIdMap() async {
    final List<HanjaTableData> rows =
        await _database.select(_database.hanjaTable).get();
    final Map<String, String> map = {};
    for (final HanjaTableData hanjaRow in rows) {
      map.putIfAbsent(hanjaRow.character, () => hanjaRow.id);
    }
    return map;
  }

  List<String> _relatedHanjaChars(Map<String, dynamic> data) {
    final Object? rawRelated = data['related_hanja'];
    if (rawRelated is! List) return [];
    return rawRelated.map((item) => item.toString()).toList();
  }
}
