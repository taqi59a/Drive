// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Drive Better';

  @override
  String get home => 'Home';

  @override
  String get training => 'Training';

  @override
  String get scan => 'Scan';

  @override
  String get progress => 'Progress';

  @override
  String get settings => 'Settings';

  @override
  String get goodMorning => 'Good morning, Driver! 👋';

  @override
  String get goodAfternoon => 'Good afternoon, Driver! 👋';

  @override
  String get goodEvening => 'Good evening, Driver! 👋';

  @override
  String studyStreak(int days) {
    return '$days day streak';
  }

  @override
  String get questionsDone => 'Questions Done';

  @override
  String get passRate => 'Pass Rate';

  @override
  String get remaining => 'Remaining';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get mockTest => 'Mock Test';

  @override
  String get practice => 'Practice';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get scanQA => 'Scan Q&A';

  @override
  String doneOf(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get topicsTitle => 'Training';

  @override
  String get searchTopics => 'Search topics…';

  @override
  String get startMockTest => 'Start Mock Test';

  @override
  String get mockTestSubtitle => '50 questions · 50 minutes · Belgian standard';

  @override
  String get topics => 'Topics';

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get explanation => 'Explanation';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get viewResults => 'View Results';

  @override
  String get testComplete => 'Test Complete';

  @override
  String get yourScore => 'Your Score';

  @override
  String get passed => 'PASSED';

  @override
  String get failed => 'FAILED';

  @override
  String get passedMessage => 'Congratulations! You passed the theory test.';

  @override
  String get failedMessage => 'Keep practising — you can do it!';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get timeTaken => 'Time Taken';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get tapToFlip => 'Tap to flip';

  @override
  String get gotIt => 'Got it!';

  @override
  String get reviewAgain => 'Review again';

  @override
  String get scannerTitle => 'Scan a Question';

  @override
  String get scannerHint => 'Point camera at a question on screen';

  @override
  String get scanning => 'Scanning…';

  @override
  String get readingText => 'Reading text…';

  @override
  String get matchFound => 'Match found!';

  @override
  String get questionDetected => 'Question detected';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get fromQuestionBank => 'From question bank';

  @override
  String get aiAnswer => 'AI answer';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get confidence => 'Confidence';

  @override
  String get progressTitle => 'Your Progress';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get questionsAnswered => 'Questions Answered';

  @override
  String get studyStreakDays => 'Study Streak';

  @override
  String get dailyActivity => 'Daily Activity';

  @override
  String get topicMastery => 'Topic Mastery';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get bookmarkedQuestions => 'Bookmarked Questions';

  @override
  String get noBookmarks => 'No bookmarks yet';

  @override
  String get noBookmarksHint =>
      'Bookmark questions during practice to review them here.';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get testReminder => 'Test day reminder';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get clearProgress => 'Clear All Progress';

  @override
  String get clearProgressConfirm =>
      'Are you sure? This will delete all your progress and cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get onboarding1Title => 'Master the Theory';

  @override
  String get onboarding1Subtitle =>
      'Learn all Belgian driving theory questions with smart AI-powered guidance.';

  @override
  String get onboarding2Title => 'Practice Smarter';

  @override
  String get onboarding2Subtitle =>
      'Adaptive learning focuses on your weak areas. Every wrong answer gets fully explained.';

  @override
  String get onboarding3Title => 'Instant Scan';

  @override
  String get onboarding3Subtitle =>
      'Point your camera at any question on screen and get the answer in seconds.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get cameraPermissionTitle => 'Camera Permission Required';

  @override
  String get cameraPermissionMessage =>
      'Drive Better needs camera access to scan questions.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get keepItUp => 'Keep it up! 🎯';

  @override
  String get answer => 'Answer';

  @override
  String get question => 'Question';
}
