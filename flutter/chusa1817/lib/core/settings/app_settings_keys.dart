abstract final class AppSettingsKeys {
  static const String dailyGoal = 'plan.dailyGoal';
  static const String orderIndex = 'plan.orderIndex';
  static const String schoolLevel = 'plan.schoolLevel'; // 'middle', 'high', 'all'
  static const String selectedDays = 'plan.selectedDays'; // JSON array of bools
  static const String isAscending = 'plan.isAscending'; // bool (true/false)
  static const String writingDifficulty = 'plan.writingDifficulty'; // 0=easy, 1=normal, 2=hard

  static const String onboardingCompleted = 'onboarding.completed';
  static const String lastDailyActivityRefreshedAt = 'plan.lastDailyActivityRefreshedAt'; // 'yyyy-MM-dd'
}

