import 'package:drift/drift.dart';

/// 한자 기본 정보 테이블 (1,800자 콘텐츠).
///
/// 초기값은 앱 번들 JSON → SQLite import로 주입.
/// Phase 3에서 서버 동기화 시 [serverId], [syncStatus] 사용.
class HanjaTable extends Table {
  @override
  String get tableName => 'hanja';

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
  TextColumn get hanjaId => text().references(HanjaTable, #id)();
  IntColumn get strokeIndex => integer()();              // 0-based 획 순서
  TextColumn get normalizedPoints => text()();           // "x1,y1;x2,y2;..."
  TextColumn get direction => text().nullable()();       // 획 방향 힌트

  @override
  Set<Column> get primaryKey => {id};
}

/// 관련 단어 테이블.
class HanjaWordTable extends Table {
  @override
  String get tableName => 'hanja_word';

  TextColumn get id => text()();
  TextColumn get hanjaId => text().references(HanjaTable, #id)();
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
  TextColumn get hanjaId => text().references(HanjaTable, #id)();
  TextColumn get idiom => text()();                     // 성어 (佳人薄命)
  TextColumn get reading => text()();
  TextColumn get meaning => text()();
  TextColumn get origin => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
