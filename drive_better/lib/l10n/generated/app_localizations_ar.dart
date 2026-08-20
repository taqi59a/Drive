// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Drive Better';

  @override
  String get home => 'الرئيسية';

  @override
  String get training => 'التدريب';

  @override
  String get scan => 'المسح';

  @override
  String get progress => 'التقدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get goodMorning => 'صباح الخير، أيها السائق! 👋';

  @override
  String get goodAfternoon => 'مساء الخير، أيها السائق! 👋';

  @override
  String get goodEvening => 'مساء النور، أيها السائق! 👋';

  @override
  String studyStreak(int days) {
    return 'سلسلة $days يوم';
  }

  @override
  String get questionsDone => 'الأسئلة المجابة';

  @override
  String get passRate => 'نسبة النجاح';

  @override
  String get remaining => 'المتبقي';

  @override
  String get overallProgress => 'التقدم الإجمالي';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get continueLearning => 'متابعة التعلم';

  @override
  String get mockTest => 'اختبار تجريبي';

  @override
  String get practice => 'تدرّب';

  @override
  String get flashcards => 'بطاقات المراجعة';

  @override
  String get scanQA => 'مسح الأسئلة والأجوبة';

  @override
  String doneOf(int done, int total) {
    return '$done من $total مكتملة';
  }

  @override
  String get topicsTitle => 'التدريب';

  @override
  String get searchTopics => 'ابحث عن موضوع…';

  @override
  String get startMockTest => 'بدء الاختبار التجريبي';

  @override
  String get mockTestSubtitle => '٥٠ سؤالاً · ٥٠ دقيقة · المعيار البلجيكي';

  @override
  String get topics => 'المواضيع';

  @override
  String questionsCount(int count) {
    return '$count أسئلة';
  }

  @override
  String questionOf(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get correct => 'صحيح!';

  @override
  String get incorrect => 'خطأ';

  @override
  String get explanation => 'الشرح';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get viewResults => 'عرض النتائج';

  @override
  String get testComplete => 'اكتمل الاختبار';

  @override
  String get yourScore => 'نتيجتك';

  @override
  String get passed => 'ناجح';

  @override
  String get failed => 'راسب';

  @override
  String get passedMessage => 'تهانينا! لقد اجتزت اختبار النظرية.';

  @override
  String get failedMessage => 'واصل التدريب — أنت قادر على ذلك!';

  @override
  String get accuracy => 'الدقة';

  @override
  String get timeTaken => 'الوقت المستغرق';

  @override
  String get tryAgain => 'حاول مجدداً';

  @override
  String get reviewAnswers => 'مراجعة الإجابات';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get flashcardsTitle => 'بطاقات المراجعة';

  @override
  String get tapToFlip => 'اضغط للقلب';

  @override
  String get gotIt => 'فهمت!';

  @override
  String get reviewAgain => 'راجع مجدداً';

  @override
  String get scannerTitle => 'امسح سؤالاً';

  @override
  String get scannerHint => 'وجّه الكاميرا نحو سؤال على الشاشة';

  @override
  String get scanning => 'جارٍ المسح…';

  @override
  String get readingText => 'جارٍ قراءة النص…';

  @override
  String get matchFound => 'تم العثور على تطابق!';

  @override
  String get questionDetected => 'تم اكتشاف سؤال';

  @override
  String get correctAnswer => 'الإجابة الصحيحة';

  @override
  String get fromQuestionBank => 'من بنك الأسئلة';

  @override
  String get aiAnswer => 'إجابة الذكاء الاصطناعي';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get confidence => 'درجة الثقة';

  @override
  String get progressTitle => 'تقدمك';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get questionsAnswered => 'الأسئلة المجابة';

  @override
  String get studyStreakDays => 'سلسلة الدراسة';

  @override
  String get dailyActivity => 'النشاط اليومي';

  @override
  String get topicMastery => 'إتقان المواضيع';

  @override
  String get bookmarks => 'المفضلة';

  @override
  String get bookmarkedQuestions => 'الأسئلة المحفوظة';

  @override
  String get noBookmarks => 'لا توجد مفضلات بعد';

  @override
  String get noBookmarksHint => 'احفظ الأسئلة أثناء التدريب لمراجعتها هنا.';

  @override
  String get removeBookmark => 'إزالة من المفضلة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get testReminder => 'تذكير يوم الاختبار';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get clearProgress => 'مسح جميع التقدم';

  @override
  String get clearProgressConfirm =>
      'هل أنت متأكد؟ سيتم حذف جميع بياناتك ولا يمكن التراجع عن ذلك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get onboarding1Title => 'أتقن النظرية';

  @override
  String get onboarding1Subtitle =>
      'تعلّم جميع أسئلة نظرية قيادة السيارة البلجيكية بمساعدة ذكاء اصطناعي متطور.';

  @override
  String get onboarding2Title => 'تدرّب بذكاء';

  @override
  String get onboarding2Subtitle =>
      'يركّز التعلم التكيّفي على نقاط ضعفك. كل إجابة خاطئة تُشرح لك بالتفصيل.';

  @override
  String get onboarding3Title => 'مسح فوري';

  @override
  String get onboarding3Subtitle =>
      'وجّه كاميرتك نحو أي سؤال على الشاشة واحصل على الإجابة في ثوانٍ.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطّ';

  @override
  String minutes(int count) {
    return '$count د';
  }

  @override
  String get cameraPermissionTitle => 'مطلوب إذن الكاميرا';

  @override
  String get cameraPermissionMessage =>
      'يحتاج Drive Better إلى الوصول إلى الكاميرا لمسح الأسئلة.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get keepItUp => 'أحسنت! استمر 🎯';

  @override
  String get answer => 'الإجابة';

  @override
  String get question => 'السؤال';
}
