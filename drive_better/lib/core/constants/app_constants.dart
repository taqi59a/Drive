class AppConstants {
  AppConstants._();

  static const String appName = 'Drive Better';
  static const int belgianPassThresholdPoints = 41;
  static const int belgianMockTestQuestions = 50;
  static const int belgianMockTestDurationSeconds = 15;
  static const double ocrMatchThreshold = 0.85;
  static const String seedQuestionsPath = 'assets/seed/questions.json';
  static const String seedTopicsPath = 'assets/seed/topics.json';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyOnboardingDone = 'onboarding_done';
  static const String prefKeyDbSeeded = 'db_seeded';
  static const String prefKeyStreak = 'study_streak';
  static const String prefKeyLastStudyDate = 'last_study_date';
}
