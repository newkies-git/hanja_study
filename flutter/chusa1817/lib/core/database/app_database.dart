import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/content_tables.dart';
import 'tables/user_tables.dart';

part 'app_database.g.dart';

/// 앱 전체 로컬 SQLite 데이터베이스.
///
/// **로컬 우선(Local-First)** 전략 (PRD5):
/// - 모든 읽기/쓰기는 먼저 이 DB에 반영한다.
/// - Phase 3에서 [SyncQueueTable]을 통해 서버와 동기화한다.
///
/// **DB 스키마 버전 이력 (PRD6)**:
/// - v1: `hanja`, `hanja_stroke`, `hanja_word`, `hanja_idiom` + 사용자 테이블 (콘텐츠 FK)
/// - v2: `hanja` → `hanja_basis` 이름 변경, `hanja_extend`·`content_config` 추가, 콘텐츠 FK 제거
/// - v3+: (예정) 오답노트, 학습 통계, 동기화 메타 강화
///
/// **중요**: migration은 "삭제-재생성" 방식을 절대 사용하지 않는다.
/// 사용자의 학습 진도, 오답, 북마크는 핵심 자산이므로 파괴적 변경 금지.
///
/// 코드 생성: `flutter pub run build_runner build --delete-conflicting-outputs`
@DriftDatabase(tables: [
  // 콘텐츠 (Firestore: hanja_basis, hanja_extend, hanja_stroke, hanja_word, config/content)
  HanjaTable,
  HanjaExtendTable,
  ContentConfigTable,
  HanjaStrokeTable,
  HanjaWordTable,
  HanjaIdiomTable,
  // 사용자 데이터
  UserProgressTable,
  StudySessionTable,
  AnswerHistoryTable,
  AppSettingsTable,
  SyncQueueTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  /// DB 스키마 버전.
  ///
  /// 앱 버전과 별도로 관리한다 (PRD6).
  /// 새 테이블/컬럼 추가 시 이 값을 올리고, [migration]의 [onUpgrade]에
  /// 해당 버전 분기를 반드시 추가해야 한다.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        /// 최초 설치 시: 모든 테이블을 한 번에 생성한다.
        onCreate: (m) async {
          await m.createAll();
        },

        /// 버전 업그레이드 시 누적형 migration.
        ///
        /// **규칙 (PRD6)**:
        /// - 각 케이스는 반드시 이전 버전에서 다음 버전으로의 변경만 담당한다.
        /// - 사용자가 v1에서 v4로 바로 업그레이드할 수 있으므로
        ///   모든 중간 단계가 순서대로 실행되어야 한다.
        /// - 기존 데이터를 삭제·재생성하지 말 것.
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement('PRAGMA foreign_keys = OFF');
            await customStatement('ALTER TABLE hanja RENAME TO hanja_basis');
            await m.createTable(hanjaExtendTable);
            await m.createTable(contentConfigTable);
            await customStatement('PRAGMA foreign_keys = ON');
          }

          // v2 → v3: 오답노트 테이블 추가 (예정)
          // if (from < 3) {
          //   await m.createTable(wrongNotesTable);
          // }

          // v3 → v4: 학습 통계 테이블 추가 (예정)
          // if (from < 4) {
          //   await m.createTable(studyStatsTable);
          // }

          // v4 → v5: 서버 동기화 메타 필드 강화 (예정)
          // if (from < 5) {
          //   await m.addColumn(userProgressTable, userProgressTable.serverId);
          //   await m.addColumn(studySessionTable, studySessionTable.rowVersion);
          // }
        },

        /// DB 열기 직전 실행.
        ///
        /// 1. WAL 모드: 읽기/쓰기 동시 처리 성능 향상.
        /// 2. 외래키 제약: 참조 무결성 보장.
        /// 3. (Phase 3) 서버 동기화 프로토콜 버전 검사 위치.
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA foreign_keys = ON');

          // migration이 적용되어 정상적으로 DB가 열렸음을 확인.
          // Phase 3에서 서버 동기화 버전 검사를 이 위치에 추가한다:
          // if (details.wasCreated) { /* 최초 생성 로직 */ }
          // if (details.hadUpgrade) { /* 업그레이드 후 처리 */ }
        },
      );
}

/// SQLite 파일을 앱 문서 디렉터리에 생성한다.
///
/// DB 파일명: `chusa_1817.db`
/// 위치: `getApplicationDocumentsDirectory()` (플랫폼별 영구 저장소)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbDir = await getApplicationDocumentsDirectory();
    final File dbFile = File(p.join(dbDir.path, 'chusa_1817.db'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
