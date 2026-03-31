/// Firestore 컬렉션·문서 경로 상수.
///
/// 관리 웹 업로드·Firestore 규칙과 동일한 컬렉션 이름을 쓴다.
///
/// - [configContentPath]: `contentVersion` (int) 등 — `config/content`
/// - [hanjaBasisCollection]: 기준 CSV 마스터
/// - [hanjaExtendCollection]: ETL 확장 필드 (`hanja_entities` 계열)
/// - [hanjaStrokeCollection]: 획 문서 (`stroke_entities` 계열, 문서 ID = `stroke_data_id`)
/// - [hanjaWordCollection]: 단어·성어 (`word_entities` / `hanja_word` 계열)
abstract final class FirestorePaths {
  static const String configCollection = 'config';
  static const String contentDocument = 'content';

  static String get configContentPath => '$configCollection/$contentDocument';

  static const String hanjaBasisCollection = 'hanja_basis';
  static const String hanjaExtendCollection = 'hanja_extend';
  static const String hanjaStrokeCollection = 'hanja_stroke';
  static const String hanjaWordCollection = 'hanja_word';

  /// 로컬 SQLite `content_config` 행 PK (Firestore `config/content` 대응).
  static const String localContentConfigRowId = contentDocument;
}
