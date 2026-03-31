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

  /// 관리 웹과 동일한 Firestore 컬렉션에서 전체 동기화.
  ///
  /// 콘텐츠 테이블(`hanja_basis`·`hanja_extend`·`hanja_stroke`·`hanja_word`·`hanja_idiom`)은
  /// 서버 스냅샷으로 갱신한다. 사용자 진도(`user_progress` 등)는 건드리지 않는다.
  Future<ContentSyncResult> syncAllContent({int pageSize = 400}) async {
    _ensureFirebase();

    final int? remoteVersion = await fetchRemoteContentVersion();

    await _db.into(_db.contentConfigTable).insertOnConflictUpdate(
          ContentConfigTableCompanion(
            id: const Value(FirestorePaths.localContentConfigRowId),
            contentVersion: Value(remoteVersion),
            syncedAt: Value(DateTime.now()),
          ),
        );

    int basisCount = 0;
    int extendCount = 0;

    await _db.transaction(() async {
      await _db.delete(_db.hanjaStrokeTable).go();
      await _db.delete(_db.hanjaWordTable).go();
      await _db.delete(_db.hanjaIdiomTable).go();
      await _db.delete(_db.hanjaExtendTable).go();
      await _db.delete(_db.hanjaTable).go();
    });

    Query<Map<String, dynamic>> basisQ = _fs
        .collection(FirestorePaths.hanjaBasisCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await basisQ.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _db.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in page.docs) {
          final HanjaTableCompanion row =
              FirestoreBasisMapper.hanjaFromBasisDoc(d.id, d.data());
          await _db.into(_db.hanjaTable).insertOnConflictUpdate(
                row.copyWith(updatedAt: Value(DateTime.now())),
              );
          basisCount++;
        }
      });

      if (page.docs.length < pageSize) break;
      basisQ = _fs
          .collection(FirestorePaths.hanjaBasisCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    Query<Map<String, dynamic>> extendQ = _fs
        .collection(FirestorePaths.hanjaExtendCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await extendQ.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _db.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in page.docs) {
          final Map<String, dynamic> data = d.data();
          await _db.into(_db.hanjaExtendTable).insertOnConflictUpdate(
                HanjaExtendTableCompanion.insert(
                  id: d.id,
                  payloadJson: jsonEncode(data),
                  syncedAt: Value(DateTime.now()),
                ),
              );

          final HanjaTableCompanion extended =
              FirestoreHanjaMapper.hanjaFromMap(d.id, data);
          await _db.into(_db.hanjaTable).insertOnConflictUpdate(
                extended.copyWith(updatedAt: Value(DateTime.now())),
              );
          extendCount++;
        }
      });

      if (page.docs.length < pageSize) break;
      extendQ = _fs
          .collection(FirestorePaths.hanjaExtendCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    final Map<String, String> charToHanjaId = await _loadCharacterToHanjaIdMap();
    final Set<String> hanjaIds = await _loadHanjaIds();

    int strokeDocCount = 0;
    int strokeRowCount = 0;

    Query<Map<String, dynamic>> strokeQ = _fs
        .collection(FirestorePaths.hanjaStrokeCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await strokeQ.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _db.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in page.docs) {
          final Map<String, dynamic> data = d.data();
          final String? hanjaId = _resolveHanjaIdForStroke(
            data,
            hanjaIds,
            charToHanjaId,
          );
          if (hanjaId == null) continue;

          final List<dynamic>? strokes = data['strokes'] as List<dynamic>?;
          if (strokes == null || strokes.isEmpty) continue;

          final List<HanjaStrokeTableCompanion> rows =
              FirestoreStrokeMapper.strokesFromEmbeddedList(hanjaId, strokes);
          if (rows.isEmpty) continue;
          strokeDocCount++;
          for (final HanjaStrokeTableCompanion c in rows) {
            await _db.into(_db.hanjaStrokeTable).insertOnConflictUpdate(c);
            strokeRowCount++;
          }
        }
      });

      if (page.docs.length < pageSize) break;
      strokeQ = _fs
          .collection(FirestorePaths.hanjaStrokeCollection)
          .orderBy(FieldPath.documentId)
          .startAfterDocument(page.docs.last);
    }

    int wordCount = 0;
    int idiomCount = 0;

    Query<Map<String, dynamic>> wordQ = _fs
        .collection(FirestorePaths.hanjaWordCollection)
        .orderBy(FieldPath.documentId);

    for (;;) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await wordQ.limit(pageSize).get();
      if (page.docs.isEmpty) break;

      await _db.transaction(() async {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in page.docs) {
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

      if (page.docs.length < pageSize) break;
      wordQ = _fs
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
    final String sid = data['stroke_data_id']?.toString().trim() ?? '';
    if (sid.isNotEmpty && hanjaIds.contains(sid)) return sid;

    final String ch = data['char']?.toString().trim() ?? '';
    if (ch.isNotEmpty) {
      final String? byChar = charToHanjaId[ch];
      if (byChar != null) return byChar;
    }
    if (sid.isNotEmpty) return sid;
    return null;
  }

  Future<Set<String>> _loadHanjaIds() async {
    final List<HanjaTableData> rows = await _db.select(_db.hanjaTable).get();
    return rows.map((r) => r.id).toSet();
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
