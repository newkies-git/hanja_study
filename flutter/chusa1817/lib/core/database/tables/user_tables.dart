import 'package:drift/drift.dart';

/// 한자별 사용자 학습 진도 테이블.
///
/// 한 사용자가 한 한자에 대해 갖는 상태를 저장한다.
class UserProgressTable extends Table {
  @override
  String get tableName => 'user_progress';

  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get hanjaId => text()();

  // ── 학습 상태 ─────────────────────────────────────────────────────────────
  TextColumn get status => text().withDefault(const Constant('unseen'))();
  // 'unseen' | 'learning' | 'mastered' | 'review_needed'

  IntColumn get totalAttempts => integer().withDefault(const Constant(0))();
  IntColumn get correctAttempts => integer().withDefault(const Constant(0))();
  RealColumn get accuracyRate => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();

  // ── SM-2 복습 스케줄 필드 ─────────────────────────────────────────────────
  /// 다음 복습 예정일. null이면 아직 미학습.
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  /// SM-2 반복 횟수 (n).
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  /// SM-2 간격 (일 단위).
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  /// SM-2 난이도 계수 (2.5 기본).
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();

  // ── 동기화 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {hanjaId},  // hanjaId당 진도 1개
      ];
}

/// 개별 학습 세션 테이블.
///
/// 사용자가 시작한 학습 세션 1회의 메타 정보를 저장한다.
class StudySessionTable extends Table {
  @override
  String get tableName => 'study_session';

  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalHanja => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  TextColumn get sessionType => text()();
  // 'daily' | 'review' | 'exam' | 'free'

  // ── 동기화 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 문제 풀이(획 판정) 이력 테이블.
///
/// 세션 내 각 한자에 대한 쓰기 결과를 저장한다.
class AnswerHistoryTable extends Table {
  @override
  String get tableName => 'answer_history';

  TextColumn get id => text()();
  TextColumn get sessionId => text().references(StudySessionTable, #id)();
  TextColumn get hanjaId => text()();
  DateTimeColumn get answeredAt => dateTime()();
  BoolColumn get isCorrect => boolean()();
  RealColumn get accuracyScore => real().withDefault(const Constant(0.0))();
  // 0.0 ~ 1.0 (획 판정 정확도)
  TextColumn get strokesJson => text().nullable()();
  // 사용자가 그린 획 좌표 (JSON 직렬화, Phase 2 판정 엔진용)

  // ── 동기화 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 앱 설정 테이블 (학습 계획).
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();        // 설정 키
  TextColumn get value => text()();      // 설정 값 (JSON)
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// 서버 동기화 큐 테이블.
///
/// 오프라인 중에 발생한 변경을 큐에 쌓아두고,
/// 네트워크 연결 후 서버로 순서대로 업로드한다.
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text()();
  TextColumn get tableName_ => text()();    // 대상 테이블명
  TextColumn get rowId => text()();          // 대상 행 ID (UUID)
  TextColumn get operation => text()();      // 'insert' | 'update' | 'delete'
  TextColumn get payload => text()();        // JSON 직렬화된 변경 데이터
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // 'pending' | 'in_progress' | 'done' | 'failed'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get processedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 사용자 기본 프로필 테이블 (로컬 주 저장소).
///
/// Firebase Auth는 인증만 담당하고, 실제 이름 등은 이 DB를 우선 참조한다.
class UserProfileTable extends Table {
  @override
  String get tableName => 'user_profile';

  TextColumn get id => text()(); // Firebase UID (Primary Key)
  TextColumn get displayName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get photoUrl => text().nullable()();

  // ── 동기화 및 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 사용자 로그인 이력 테이블.
class LoginHistoryTable extends Table {
  @override
  String get tableName => 'login_history';

  TextColumn get id => text()(); // UUID
  TextColumn get userId => text()();
  DateTimeColumn get loginAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 일별 사용자 활동 및 학습 통계 테이블.
class DailyActivityStatsTable extends Table {
  @override
  String get tableName => 'daily_activity_stats';

  TextColumn get id => text()(); // date_userId 형태의 고유 키
  DateTimeColumn get date => dateTime()(); // 통계 기준 날짜 (시간 제외)
  TextColumn get userId => text()();

  // ── 활동 집계 ──────────────────────────────────────────────────────────
  IntColumn get loginCount => integer().withDefault(const Constant(0))();
  IntColumn get sessionCount => integer().withDefault(const Constant(0))();

  // ── 학습량 스냅샷 (량/횟수) ──────────────────────────────────────────────
  IntColumn get plannedCount => integer().withDefault(const Constant(0))(); // 당일 계획량
  IntColumn get inProgressCount => integer().withDefault(const Constant(0))(); // 학습 중인 한자 수
  IntColumn get completedCount => integer().withDefault(const Constant(0))(); // 완료(마스터) 한자 수

  // ── 동기화 및 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 일별 학습 대상 한자 상세 관리 테이블.
class DailyHanjaActivityTable extends Table {
  @override
  String get tableName => 'daily_hanja_activity';

  TextColumn get id => text()(); // UUID
  DateTimeColumn get date => dateTime()(); // 통계 기준 날짜 (시간 제외)
  TextColumn get userId => text()();
  TextColumn get hanjaId => text()();

  // ── 한자별 활동 상태 ──────────────────────────────────────────────────
  TextColumn get status => text().withDefault(const Constant('planned'))();
  // 'planned' | 'learning' | 'completed'

  // ── 동기화 및 메타 ──────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
