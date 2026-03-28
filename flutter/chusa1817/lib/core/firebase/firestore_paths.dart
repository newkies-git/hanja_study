/// Firestore 컬렉션·문서 경로 상수.
///
/// 서버에 동일한 구조로 업로드해야 앱과 맞습니다.
///
/// - [configContent]: `contentVersion` (int) 등 메타
/// - [hanja]: 한자 본문. 문서 ID = `id` 필드와 동일 권장
/// - `hanja/{id}/strokes/{n}`: 획 데이터 (선택, 본문에 `strokes` 배열이 없을 때)
/// - [words]: 단어/성어 (`word_entities.json`과 동일 필드)
abstract final class FirestorePaths {
  static const String configCollection = 'config';
  static const String contentDocument = 'content';

  static String get configContentPath => '$configCollection/$contentDocument';

  static const String hanjaCollection = 'hanja';
  static const String wordsCollection = 'words';

  /// `hanja/{hanjaId}` 아래 획 서브컬렉션 이름.
  static const String strokesSubcollection = 'strokes';
}
