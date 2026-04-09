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
/// - v3: 사용자 스코프 필드 (`user_progress.user_id`)
/// - v4: `hanja_stroke_svg_paths` (Firestore `svg_paths` 캐시, 획순 뷰어 좌표계)
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
  HanjaStrokeSvgPathsTable,
  HanjaWordTable,
  HanjaIdiomTable,
  // 사용자 데이터
  UserProgressTable,
  StudySessionTable,
  AnswerHistoryTable,
  AppSettingsTable,
  SyncQueueTable,
  UserProfileTable,
  LoginHistoryTable,
  DailyActivityStatsTable,
  DailyHanjaActivityTable,
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
  int get schemaVersion => 11;

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

          // v2 → v3: 사용자 스코프 필드 추가 (멀티 유저 대비)
          if (from < 3) {
            await m.addColumn(userProgressTable, userProgressTable.userId);
          }

          // v3 → v4: 획순 SVG 경로 캐시 (stroke_entities_viewer.html / svg_paths)
          if (from < 4) {
            await m.createTable(hanjaStrokeSvgPathsTable);
          }

          // v4 → v5: 사용자 프로필 테이블 추가
          if (from < 5) {
            await m.createTable(userProfileTable);
          }

          // v5 → v6: 로그인 이력 및 일별 활동 통계 테이블 추가
          if (from < 6) {
            await m.createTable(loginHistoryTable);
            await m.createTable(dailyActivityStatsTable);
          }

          // v6 → v7: 일별 한자 상세 활동 테이블 추가
          if (from < 7) {
            await m.createTable(dailyHanjaActivityTable);
          }

          // v7 → v8: 용어 통일 (completed → mastered)
          if (from < 8) {
            // daily_hanja_activity: 과거 'completed' 상태를 'mastered'로 통일
            await customStatement(
              "UPDATE daily_hanja_activity SET status = 'mastered' WHERE status = 'completed';",
            );
            // user_progress: 과거 'completed' 상태가 있었다면 'mastered'로 통일
            await customStatement(
              "UPDATE user_progress SET status = 'mastered' WHERE status = 'completed';",
            );
          }

          // v8 → v9: 일별(mastered) 기록과 누적(user_progress) 상태를 정합화
          if (from < 9) {
            // 과거에는 daily_hanja_activity에 mastered가 찍혔지만 user_progress는 learning으로 남는 케이스가 있었다.
            // 일별 mastered가 존재하는 hanja는 누적도 mastered로 승격한다.
            await customStatement(
              "UPDATE user_progress "
              "SET status = 'mastered' "
              "WHERE status != 'mastered' "
              "AND hanja_id IN (SELECT DISTINCT hanja_id FROM daily_hanja_activity WHERE status = 'mastered');",
            );
          }

          // v9 → v10: daily_hanja_activity 중복 정리 (hanjaId 당 최신 1건만 유지)
          if (from < 10) {
            await customStatement(
              "DELETE FROM daily_hanja_activity AS d1 "
              "WHERE d1.id != ("
              "  SELECT d2.id "
              "  FROM daily_hanja_activity AS d2 "
              "  WHERE d2.hanja_id = d1.hanja_id "
              "  ORDER BY d2.updated_at DESC, d2.date DESC, d2.id DESC "
              "  LIMIT 1"
              ");",
            );
          }

          // v10 → v11: 성능 인덱스 추가
          if (from < 11) {
            // user_progress — 복습 스케줄 및 상태 필터에 사용
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_user_progress_next_review_at ON user_progress(next_review_at);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_user_progress_status ON user_progress(status);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_user_progress_last_studied_at ON user_progress(last_studied_at);',
            );
            // daily_hanja_activity — 날짜·상태 필터에 사용
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_daily_hanja_activity_date ON daily_hanja_activity(date);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_daily_hanja_activity_status ON daily_hanja_activity(status);',
            );
            // daily_activity_stats — (userId, date) 복합 조회에 사용
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_daily_activity_stats_user_date ON daily_activity_stats(user_id, date);',
            );
            // 콘텐츠 테이블 — hanjaId FK 조회에 사용
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_hanja_stroke_hanja_id ON hanja_stroke(hanja_id);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_hanja_word_hanja_id ON hanja_word(hanja_id);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_hanja_idiom_hanja_id ON hanja_idiom(hanja_id);',
            );
            // hanja_basis — 독음 정렬/검색에 사용
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_hanja_basis_reading ON hanja_basis(reading);',
            );
          }
        },

        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA cache_size = -64000'); // 64 MB 페이지 캐시
          await customStatement('PRAGMA temp_store = MEMORY');
          await customStatement('PRAGMA auto_vacuum = INCREMENTAL');
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

