// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Drive Better';

  @override
  String get home => 'Startseite';

  @override
  String get training => 'Training';

  @override
  String get scan => 'Scannen';

  @override
  String get progress => 'Fortschritt';

  @override
  String get settings => 'Einstellungen';

  @override
  String get goodMorning => 'Guten Morgen, Fahrer! 👋';

  @override
  String get goodAfternoon => 'Guten Tag, Fahrer! 👋';

  @override
  String get goodEvening => 'Guten Abend, Fahrer! 👋';

  @override
  String studyStreak(int days) {
    return '$days Tag(e) am Stück';
  }

  @override
  String get questionsDone => 'Fragen beantwortet';

  @override
  String get passRate => 'Erfolgsquote';

  @override
  String get remaining => 'Verbleibend';

  @override
  String get overallProgress => 'Gesamtfortschritt';

  @override
  String get quickActions => 'Schnellzugriff';

  @override
  String get continueLearning => 'Weiterlernen';

  @override
  String get mockTest => 'Probeprüfung';

  @override
  String get practice => 'Üben';

  @override
  String get flashcards => 'Lernkarten';

  @override
  String get scanQA => 'Frage & Antwort scannen';

  @override
  String doneOf(int done, int total) {
    return '$done von $total erledigt';
  }

  @override
  String get topicsTitle => 'Training';

  @override
  String get searchTopics => 'Themen suchen…';

  @override
  String get startMockTest => 'Probeprüfung starten';

  @override
  String get mockTestSubtitle => '50 Fragen · 50 Minuten · Belgischer Standard';

  @override
  String get topics => 'Themen';

  @override
  String questionsCount(int count) {
    return '$count Fragen';
  }

  @override
  String questionOf(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String get correct => 'Richtig!';

  @override
  String get incorrect => 'Falsch';

  @override
  String get explanation => 'Erklärung';

  @override
  String get nextQuestion => 'Nächste Frage';

  @override
  String get viewResults => 'Ergebnisse ansehen';

  @override
  String get testComplete => 'Test abgeschlossen';

  @override
  String get yourScore => 'Dein Ergebnis';

  @override
  String get passed => 'BESTANDEN';

  @override
  String get failed => 'NICHT BESTANDEN';

  @override
  String get passedMessage =>
      'Herzlichen Glückwunsch! Du hast die Theorieprüfung bestanden.';

  @override
  String get failedMessage => 'Weiter üben — du schaffst das!';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get timeTaken => 'Benötigte Zeit';

  @override
  String get tryAgain => 'Nochmal versuchen';

  @override
  String get reviewAnswers => 'Antworten überprüfen';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get flashcardsTitle => 'Lernkarten';

  @override
  String get tapToFlip => 'Tippen zum Umdrehen';

  @override
  String get gotIt => 'Verstanden!';

  @override
  String get reviewAgain => 'Nochmal durchgehen';

  @override
  String get scannerTitle => 'Frage scannen';

  @override
  String get scannerHint => 'Kamera auf eine Frage auf dem Bildschirm richten';

  @override
  String get scanning => 'Scanne…';

  @override
  String get readingText => 'Text wird gelesen…';

  @override
  String get matchFound => 'Treffer gefunden!';

  @override
  String get questionDetected => 'Frage erkannt';

  @override
  String get correctAnswer => 'Richtige Antwort';

  @override
  String get fromQuestionBank => 'Aus der Fragenbank';

  @override
  String get aiAnswer => 'KI-Antwort';

  @override
  String get dismiss => 'Schließen';

  @override
  String get confidence => 'Sicherheit';

  @override
  String get progressTitle => 'Dein Fortschritt';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get allTime => 'Gesamt';

  @override
  String get questionsAnswered => 'Beantwortete Fragen';

  @override
  String get studyStreakDays => 'Lernserie';

  @override
  String get dailyActivity => 'Tägliche Aktivität';

  @override
  String get topicMastery => 'Themenkenntnisse';

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String get bookmarkedQuestions => 'Gespeicherte Fragen';

  @override
  String get noBookmarks => 'Noch keine Lesezeichen';

  @override
  String get noBookmarksHint =>
      'Speichere Fragen beim Üben als Lesezeichen, um sie hier zu wiederholen.';

  @override
  String get removeBookmark => 'Lesezeichen entfernen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get theme => 'Design';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get language => 'Sprache';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get dailyReminder => 'Tägliche Erinnerung';

  @override
  String get testReminder => 'Erinnerung am Prüfungstag';

  @override
  String get about => 'Über die App';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get clearProgress => 'Gesamten Fortschritt löschen';

  @override
  String get clearProgressConfirm =>
      'Bist du sicher? Dein gesamter Fortschritt wird gelöscht und kann nicht wiederhergestellt werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get onboarding1Title => 'Theorie meistern';

  @override
  String get onboarding1Subtitle =>
      'Lerne alle belgischen Theoriefragen mit intelligenter KI-Unterstützung.';

  @override
  String get onboarding2Title => 'Klüger üben';

  @override
  String get onboarding2Subtitle =>
      'Adaptives Lernen konzentriert sich auf deine Schwachstellen. Jede falsche Antwort wird vollständig erklärt.';

  @override
  String get onboarding3Title => 'Sofort scannen';

  @override
  String get onboarding3Subtitle =>
      'Richte deine Kamera auf eine beliebige Frage auf dem Bildschirm und erhalte die Antwort in Sekunden.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get next => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String minutes(int count) {
    return '$count Min.';
  }

  @override
  String get cameraPermissionTitle => 'Kamerazugriff erforderlich';

  @override
  String get cameraPermissionMessage =>
      'Drive Better benötigt Zugriff auf die Kamera, um Fragen zu scannen.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get keepItUp => 'Weiter so! 🎯';

  @override
  String get answer => 'Antwort';

  @override
  String get question => 'Frage';
}
