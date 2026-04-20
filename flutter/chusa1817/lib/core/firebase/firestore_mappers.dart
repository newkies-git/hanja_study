import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Firestore 문서 → Drift [HanjaTableCompanion] 매핑.
///
/// 필드명은 Python 파이프라인 JSON(`hanja_entities`)의 snake_case를 기본으로 하며,
/// camelCase 별칭도 허용한다.
abstract final class FirestoreHanjaMapper {
  /// 문서 ID와 `id` 필드 중 실제 한자 PK로 쓰는 값.
  static String resolveHanjaId(String docId, Map<String, dynamic> raw) {
    final String fromField = raw['id']?.toString() ?? '';
    return fromField.isNotEmpty ? fromField : docId;
  }

  static HanjaTableCompanion hanjaFromMap(String docId, Map<String, dynamic> raw) {
    final Map<String, dynamic> data = _normalizeKeys(raw);
    final String id = _string(data, 'id').isNotEmpty ? _string(data, 'id') : docId;

    return HanjaTableCompanion.insert(
      id: id,
      serverId: Value(_string(data, 'server_id').isEmpty ? docId : _string(data, 'server_id')),
      character: _string(data, 'char').isNotEmpty ? _string(data, 'char') : _string(data, 'character'),
      reading: _string(data, 'reading'),
      meaning: _string(data, 'meaning'),
      radical: _string(data, 'radical'),
      radicalName: _string(data, 'radical_meaning').isNotEmpty
          ? _string(data, 'radical_meaning')
          : _string(data, 'radicalName'),
      totalStrokes: _int(data, 'stroke_count', fallbackKey: 'totalStrokes') ?? 0,
      schoolLevel: _normalizeSchoolLevel(
        _string(data, 'school_level').isNotEmpty
            ? _string(data, 'school_level')
            : _string(data, 'schoolLevel'),
      ),
      grade: Value(_parseGrade(data['grade'])),
      origin: Value(_nullableString(data['origin_note'] ?? data['origin'])),
      usageNote: Value(_nullableString(data['shape_explanation'] ?? data['usageNote'])),
      syncStatus: const Value('synced'),
      syncRevision: Value(_int(data, 'sync_revision', fallbackKey: 'syncRevision') ?? 0),
    );
  }

  static Map<String, dynamic> _normalizeKeys(Map<String, dynamic> raw) {
    return Map<String, dynamic>.from(raw);
  }

  static String _string(Map<String, dynamic> m, String k) {
    final Object? v = m[k];
    if (v == null) return '';
    return v.toString();
  }

  static int? _int(Map<String, dynamic> m, String k, {String? fallbackKey}) {
    final Object? v = m[k] ?? (fallbackKey != null ? m[fallbackKey] : null);
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _nullableString(Object? v) {
    if (v == null) return null;
    final String s = v.toString();
    return s.isEmpty ? null : s;
  }

  static int? _parseGrade(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    final String s = v.toString();
    final RegExpMatch? m = RegExp(r'(\d+)').firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(1)!);
  }

  /// DB는 자유 텍스트이나 UI/쿼리는 middle·high·both를 가정.
  static String _normalizeSchoolLevel(String raw) {
    final String s = raw.trim().toLowerCase();
    switch (s) {
      case 'middle':
      case 'high':
      case 'both':
        return s;
      default:
        return 'middle';
    }
  }
}

/// Firestore `hanja_basis` (CSV 필드명: 한자, 음, 훈, …) → [HanjaTableCompanion].
abstract final class FirestoreBasisMapper {
  static String resolveBasisId(String docId, Map<String, dynamic> raw) {
    final String idField = raw['id']?.toString().trim() ?? '';
    if (idField.isNotEmpty) return idField;
    if (docId.isNotEmpty && docId.startsWith('H')) return docId;
    final String ch = raw['한자']?.toString().trim() ?? '';
    if (ch.isEmpty) return docId;
    final int? cp = ch.runes.isNotEmpty ? ch.runes.first : null;
    if (cp == null) return docId;
    return 'H${cp.toRadixString(16).toUpperCase()}';
  }

  static HanjaTableCompanion hanjaFromBasisDoc(
    String docId,
    Map<String, dynamic> raw,
  ) {
    final String id = resolveBasisId(docId, raw);
    final String character = raw['한자']?.toString().trim() ?? '';
    final String reading = raw['음']?.toString().trim() ?? '';
    final String meaning = raw['훈']?.toString().trim() ?? '';
    final String hunEum = raw['훈음']?.toString().trim() ?? '';
    final int totalStrokes =
        int.tryParse(raw['전체']?.toString().trim() ?? '') ?? 0;
    final String schoolLevel = _schoolLevelFromCategory(raw['구분']);

    return HanjaTableCompanion.insert(
      id: id,
      serverId: Value(docId.isNotEmpty ? docId : id),
      character: character.isNotEmpty ? character : '?',
      reading: reading,
      meaning: meaning.isNotEmpty ? meaning : hunEum,
      radical: '',
      radicalName: '',
      totalStrokes: totalStrokes,
      schoolLevel: schoolLevel,
      grade: const Value.absent(),
      origin: const Value.absent(),
      usageNote: const Value.absent(),
      syncStatus: const Value('synced'),
      syncRevision: const Value(0),
    );
  }

  static String _schoolLevelFromCategory(Object? v) {
    final String s = v?.toString().trim().toLowerCase() ?? '';
    if (s.contains('중')) return 'middle';
    if (s.contains('고')) return 'high';
    if (s.contains('both') || s.contains('공통') || s == 'both') return 'both';
    if (s == 'middle' || s == 'high') return s;
    return 'middle';
  }
}

/// 획 데이터 → [HanjaStrokeTableCompanion] 목록.
abstract final class FirestoreStrokeMapper {
  /// 한자 문서 안의 `strokes` 배열 (Python `stroke_entities`의 `strokes`와 동일 형태).
  static List<HanjaStrokeTableCompanion> strokesFromEmbeddedList(
    String hanjaId,
    List<dynamic> list,
  ) {
    final List<HanjaStrokeTableCompanion> out = [];
    for (var i = 0; i < list.length; i++) {
      final Object? item = list[i];
      if (item is! Map) continue;
      final Map<String, dynamic> m = Map<String, dynamic>.from(item);
      final int order = (m['order'] as num?)?.toInt() ?? (i + 1);
      final int strokeIndex = order - 1;
      final String norm = normalizePointsDynamic(m['points']);
      if (norm.isEmpty) continue;
      final String? dir = _direction(m['type']);
      out.add(
        HanjaStrokeTableCompanion.insert(
          id: '${hanjaId}_stroke_$strokeIndex',
          hanjaId: hanjaId,
          strokeIndex: strokeIndex,
          normalizedPoints: norm,
          direction: dir != null ? Value(dir) : const Value.absent(),
        ),
      );
    }
    return out;
  }

  /// 서브컬렉션 문서 한 개.
  static HanjaStrokeTableCompanion? strokeFromSubDoc(
    String hanjaId,
    String strokeDocId,
    Map<String, dynamic> m,
  ) {
    final int strokeIndex = (m['strokeIndex'] as num?)?.toInt() ??
        (((m['order'] as num?)?.toInt() ?? 1) - 1);
    String norm = m['normalizedPoints']?.toString() ?? '';
    if (norm.isEmpty) {
      norm = normalizePointsDynamic(m['points']);
    }
    if (norm.isEmpty) return null;
    final String? dir = _direction(m['type'] ?? m['direction']);
    return HanjaStrokeTableCompanion.insert(
      id: strokeDocId.contains(hanjaId) ? strokeDocId : '${hanjaId}_$strokeDocId',
      hanjaId: hanjaId,
      strokeIndex: strokeIndex,
      normalizedPoints: norm,
      direction: dir != null ? Value(dir) : const Value.absent(),
    );
  }

  static String normalizePointsDynamic(Object? points) {
    if (points is! List) return '';
    final List<String> pairs = [];
    for (final Object? p in points) {
      if (p is List && p.length >= 2) {
        final String a = (p[0] as num).toString();
        final String b = (p[1] as num).toString();
        pairs.add('$a,$b');
      } else if (p is Map) {
        final Object? x = p['x'];
        final Object? y = p['y'];
        if (x is num && y is num) {
          pairs.add('${x.toString()},${y.toString()}');
        }
      }
    }
    return pairs.join(';');
  }

  static String? _direction(Object? type) {
    if (type == null) return null;
    final String s = type.toString().trim();
    return s.isEmpty ? null : s;
  }
}

/// 단어/성어 문서 → Drift companion (한 `hanjaId`에 대해 한 행).
abstract final class FirestoreWordMapper {
  static HanjaWordTableCompanion? wordRow({
    required String wordDocId,
    required String hanjaId,
    required Map<String, dynamic> data,
  }) {
    final String wid = data['word_id']?.toString() ?? wordDocId;
    final String word = data['word']?.toString() ?? '';
    final String reading = data['reading']?.toString() ?? data['pronunciation']?.toString() ?? '';
    final String meaning = data['meaning']?.toString() ?? '';
    if (word.isEmpty) return null;
    return HanjaWordTableCompanion.insert(
      id: '${wid}__$hanjaId',
      hanjaId: hanjaId,
      word: word,
      reading: reading.isNotEmpty ? reading : word,
      meaning: meaning,
    );
  }

  static HanjaIdiomTableCompanion? idiomRow({
    required String wordDocId,
    required String hanjaId,
    required Map<String, dynamic> data,
  }) {
    final String wid = data['word_id']?.toString() ?? wordDocId;
    final String hanjaStr = data['hanja']?.toString() ?? '';
    final String word = data['word']?.toString() ?? '';
    final String reading = data['reading']?.toString() ?? data['pronunciation']?.toString() ?? '';
    final String meaning = data['meaning']?.toString() ?? '';
    if (hanjaStr.isEmpty && word.isEmpty) return null;
    return HanjaIdiomTableCompanion.insert(
      id: '${wid}__$hanjaId',
      hanjaId: hanjaId,
      idiom: hanjaStr.isNotEmpty ? hanjaStr : word,
      reading: reading.isNotEmpty ? reading : word,
      meaning: meaning,
    );
  }
}
