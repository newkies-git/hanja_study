import 'package:drift/drift.dart';

/// 한자 기본 정보 테이블.
///
/// Firestore `hanja_basis` + `hanja_extend` 동기화 결과를 담는다 (문서 `id` = PK).
class HanjaTable extends Table {
  @override
  String get tableName => 'hanja_basis';

  // ── 식별자 ────────────────────────────────────────────────────────────────
  TextColumn get id => text()();                         // UUID
  TextColumn get serverId => text().nullable()();        // 서버 공통 ID

  // ── 핵심 콘텐츠 ───────────────────────────────────────────────────────────
  TextColumn get character => text()();                  // 漢字 (한자 글자)
  TextColumn get reading => text()();                    // 독음 (가, 나 …)
  TextColumn get meaning => text()();                    // 뜻 (아름다울)
  TextColumn get radical => text()();                    // 부수 (人, 木 …)
  TextColumn get radicalName => text()();                // 부수명 (사람 인)
  IntColumn get totalStrokes => integer()();             // 총획수
  TextColumn get schoolLevel => text()();               // 'middle' | 'high'
  IntColumn get grade => integer().nullable()();        // 교육용 급수
  TextColumn get origin => text().nullable()();         // 유래 설명
  TextColumn get usageNote => text().nullable()();      // 쓰임 주석

  // ── 동기화 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  // 'local_only' | 'pending' | 'synced' | 'deleted'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 한자 획순 좌표 테이블.
///
/// 1획 = 1행. [normalizedPoints]는 `0.1,0.2;0.3,0.4` 형식의 직렬화된 좌표열.
/// Phase 3에서 SVG 파이프라인 데이터로 교체.
class HanjaStrokeTable extends Table {
  @override
  String get tableName => 'hanja_stroke';

  TextColumn get id => text()();
  TextColumn get hanjaId => text()();
  IntColumn get strokeIndex => integer()();              // 0-based 획 순서
  TextColumn get normalizedPoints => text()();           // "x1,y1;x2,y2;..."
  TextColumn get direction => text().nullable()();       // 획 방향 힌트

  @override
  Set<Column> get primaryKey => {id};
}

/// Firestore `hanja_stroke` 문서의 `svg_paths` (글자 전체 좌표계, viewer와 동일).
///
/// `points`는 획별 로컬 0~1(`stroke_geometry.normalize_to_unit_square`)이라
/// 단순 합성 시 겹쳐 보이므로, 획순 표시는 이 경로를 우선한다.
class HanjaStrokeSvgPathsTable extends Table {
  @override
  String get tableName => 'hanja_stroke_svg_paths';

  TextColumn get hanjaId => text()();
  TextColumn get pathsJson => text()();

  @override
  Set<Column> get primaryKey => {hanjaId};
}

/// Firestore `hanja_extend` 문서 스냅샷 (원본 JSON 보존).
class HanjaExtendTable extends Table {
  @override
  String get tableName => 'hanja_extend';

  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Firestore `config/content` 로컬 캐시 (버전 비교용).
class ContentConfigTable extends Table {
  @override
  String get tableName => 'content_config';

  /// 고정 키 `content` (Firestore 경로 `config/content` 와 대응).
  TextColumn get id => text()();
  IntColumn get contentVersion => integer().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 관련 단어 테이블.
class HanjaWordTable extends Table {
  @override
  String get tableName => 'hanja_word';

  TextColumn get id => text()();
  TextColumn get hanjaId => text()();
  TextColumn get word => text()();                      // 단어 (佳人)
  TextColumn get reading => text()();                   // 독음 (가인)
  TextColumn get meaning => text()();                   // 의미 (아름다운 사람)
  TextColumn get example => text().nullable()();        // 예문

  @override
  Set<Column> get primaryKey => {id};
}

/// 성어/숙어 테이블.
class HanjaIdiomTable extends Table {
  @override
  String get tableName => 'hanja_idiom';

  TextColumn get id => text()();
  TextColumn get hanjaId => text()();
  TextColumn get idiom => text()();                     // 성어 (佳人薄命)
  TextColumn get reading => text()();
  TextColumn get meaning => text()();
  TextColumn get origin => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
