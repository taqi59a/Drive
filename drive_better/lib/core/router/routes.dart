class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String topics = '/training';
  static const String theory = '/training/theory/:topicId';
  static const String mockTest = '/training/mock-test';
  static const String mockTestResult = '/training/mock-test/result';
  static const String flashcards = '/training/flashcards/:topicId';
  static const String scanner = '/scan';
  static const String progress = '/progress';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';

  static String theoryRoute(String topicId) => '/training/theory/$topicId';
  static String practiceRoute(String topicId) => '/training/practice/$topicId';
  static String flashcardsRoute(String topicId) => '/training/flashcards/$topicId';
}
