/// 한자 학습 상태 상수.
///
/// DB 컬럼 `user_progress.status` 및 `daily_hanja_activity.status`에
/// 저장되는 문자열 값과 1:1 대응한다.
abstract final class StudyStatus {
  static const String unseen = 'unseen';
  static const String learning = 'learning';
  static const String mastered = 'mastered';
  /// Deprecated: SM-2 적용 후 오답 시 [learning]으로 대체됨. 기존 DB 데이터 호환용으로만 유지.
  @Deprecated('Use learning instead')
  static const String reviewNeeded = 'review_needed';
  static const String planned = 'planned';
}
