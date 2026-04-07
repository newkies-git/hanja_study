import '../app_database.dart';

/// 한자 콘텐츠 Repository 인터페이스.
///
/// UI는 이 추상 계층만 바라본다.
/// Phase 1: [LocalHanjaRepository] (로컬 DB)
/// Phase 3: [RemoteHanjaRepository] (서버) 또는 양쪽을 합친 구현체로 교체 가능.
abstract class HanjaRepository {
  /// ID로 단일 한자를 조회한다.
  Future<HanjaTableData?> fetchById(String id);

  /// 학교급 (middle | high) 기준으로 목록을 반환한다.
  Future<List<HanjaTableData>> fetchByLevel(String level);

  /// 로컬에 동기화된 한자 전체(가나다순 정렬). 학습 탭 목록용.
  Future<List<HanjaTableData>> fetchAllOrderedByReading();

  /// 음/뜻으로 검색한다.
  Future<List<HanjaTableData>> search(String query);

  /// 한자를 로컬 DB에 삽입 또는 갱신한다.
  Future<void> upsert(HanjaTableCompanion data);

  /// 해당 한자의 획순 좌표 목록을 획 순서대로 반환한다.
  Future<List<HanjaStrokeTableData>> fetchStrokes(String hanjaId);

  /// Firestore `svg_paths` 동기화본. 없으면 null.
  Future<List<String>?> fetchStrokeSvgPaths(String hanjaId);

  /// 관련 단어 목록을 반환한다.
  Future<List<HanjaWordTableData>> fetchWords(String hanjaId);

  /// 성어/숙어 목록을 반환한다.
  Future<List<HanjaIdiomTableData>> fetchIdioms(String hanjaId);

  /// 로컬 DB에 있는 한자의 총 갯수를 조회한다.
  Future<int> fetchTotalCount();

  /// 아직 학습하지 않았거나('unseen') 오늘 공부하지 않은 다음 한자를 가져온다.
  Future<HanjaTableData?> fetchNextToLearn({int orderIndex = 0, bool isAscending = true});
}

/// 사용자 진도 Repository 인터페이스.
abstract class ProgressRepository {
  /// 특정 한자의 학습 진도를 반환한다.
  Future<UserProgressTableData?> fetchProgress(String hanjaId);

  /// 복습이 필요한 한자 목록을 반환한다 (nextReviewAt <= now).
  Future<List<UserProgressTableData>> fetchDueForReview();

  /// 예정된 복습 목록을 반환한다 (nextReviewAt > now).
  Future<List<UserProgressTableData>> fetchUpcomingForReview({int limit = 20});

  /// 오늘의 학습 완료 수를 반환한다.
  Future<int> fetchTodayCompletedCount();

  /// 최근 N일(오늘 포함)의 일자별 학습한 한자 수를 반환한다.
  ///
  /// 반환값은 `DateTime(year, month, day)`를 key로 한다.
  Future<Map<DateTime, int>> fetchDailyStudyCounts({int days = 7});

  /// 연속 학습일 수를 반환한다.
  Future<int> fetchStreakDays();

  /// 즐겨찾기된 한자 목록을 반환한다.
  Future<List<UserProgressTableData>> fetchBookmarked();

  /// 진도를 저장하거나 갱신한다.
  Future<void> saveProgress(UserProgressTableCompanion data);

  /// 즐겨찾기를 토글한다.
  Future<void> toggleBookmark(String hanjaId);

  /// 특정 한자에 대한 진도를 "있으면 갱신, 없으면 생성"한다.
  Future<void> upsertProgressByHanjaId({
    required String hanjaId,
    required DateTime studiedAt,
    required bool isCorrect,
    bool? isBookmarked,
    String? forceStatus,
  });

  /// 마스터한 한자의 총 갯수를 조회한다.
  Future<int> fetchMasteredCount();

  /// 학습중(learning) 한자의 총 갯수를 조회한다.
  Future<int> fetchLearningCount();

  /// 오늘 학습할/학습한 한자 목록을 반환한다.
  ///
  /// [dailyGoal] 만큼의 한자를 포함하며, 오늘 이미 학습한 한자와 다음에 학습할 한자를 조합한다.
  Future<List<(HanjaTableData hanja, String status, bool isBookmarked)>> fetchTodayLearningHanja({
    int dailyGoal = 5,
    int orderIndex = 0,
    bool isAscending = true,
    String schoolLevel = 'all', // 'middle' | 'high' | 'all'
  });

  /// 최근 N일(오늘 포함) 일별 상태별(learning/completed) 활동 수를 반환한다.
  ///
  /// 반환 Map의 key는 `DateTime(year, month, day)`이고,
  /// value는 `(completedCount, learningCount)` 튜플이다. (planned는 제외)
  Future<Map<DateTime, (int completed, int learning)>> fetchDailyActivityStatusCounts({
    int days = 7,
  });

  /// 오답률이 높은(정확도가 낮은) 한자 목록을 반환한다 (오늘 학습하지 않은 것 위주).
  Future<List<UserProgressTableData>> fetchTopErrorProneHanja({int limit = 10});

  /// [샘플 데이터 생성] 추천 복습 섹션을 테스트하기 위해 가상의 오답 데이터를 생성한다.
  Future<void> seedSampleReviewHanja();
}

/// 학습 세션 Repository 인터페이스.
abstract class StudySessionRepository {
  /// 새 세션을 시작하고 ID를 반환한다.
  Future<String> startSession(String sessionType);

  /// 세션을 완료 처리한다.
  Future<void> endSession(String sessionId, {required int correctCount});

  /// 특정 세션의 답변 이력을 저장한다.
  Future<void> saveAnswer(AnswerHistoryTableCompanion data);

  /// 최근 N개의 세션을 반환한다.
  Future<List<StudySessionTableData>> fetchRecentSessions(int limit);
}

/// 앱 설정 Repository 인터페이스.
abstract class SettingsRepository {
  /// 설정 값을 읽는다.
  Future<String?> get(String key);

  /// 설정 값을 저장한다.
  Future<void> set(String key, String value);
}

/// 사용자 프로필 Repository 인터페이스.
abstract class UserRepository {
  /// ID로 사용자 프로필을 조회한다.
  Future<UserProfileTableData?> fetchById(String id);

  /// 프로필을 저장하거나 갱신한다.
  Future<void> upsert(UserProfileTableCompanion data);

  /// 특정 이메일로 사용자 프로필을 조회한다.
  Future<UserProfileTableData?> fetchByEmail(String email);
}

/// 사용자 활동 및 통계 Repository 인터페이스.
abstract class ActivityRepository {
  /// 로그인을 기록하고 당일 로그인 횟수를 업데이트한다.
  Future<void> recordLogin(String userId);

  /// 특정 날짜의 활동 통계를 가져온다.
  Future<DailyActivityStatsTableData?> fetchDailyStats(String userId, DateTime date);

  /// 특정 날짜의 학습 통계(량)를 업데이트한다.
  Future<void> updateDailyStudyStats({
    required String userId,
    required DateTime date,
    int? planned,
    int? inProgress,
    int? completed,
  });

  /// 최근 N일간의 활동 통계 목록을 가져온다.
  Future<List<DailyActivityStatsTableData>> fetchRecentStats(String userId, {int days = 7});
}
