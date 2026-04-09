/// 한자 학습 상태 상수.
///
/// DB 컬럼 `user_progress.status` 및 `daily_hanja_activity.status`에
/// 저장되는 문자열 값과 1:1 대응한다.
abstract final class StudyStatus {
  static const String unseen = 'unseen';
  static const String learning = 'learning';
  static const String mastered = 'mastered';
  static const String reviewNeeded = 'review_needed';
  static const String planned = 'planned';
  /// [mastered]의 레거시 별칭 — DB 마이그레이션 v8에서 통일됨.
  static const String completed = 'completed';
}
