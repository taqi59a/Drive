// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Drive Better';

  @override
  String get home => 'Start';

  @override
  String get training => 'Training';

  @override
  String get scan => 'Scannen';

  @override
  String get progress => 'Voortgang';

  @override
  String get settings => 'Instellingen';

  @override
  String get goodMorning => 'Goedemorgen, bestuurder! 👋';

  @override
  String get goodAfternoon => 'Goedemiddag, bestuurder! 👋';

  @override
  String get goodEvening => 'Goedenavond, bestuurder! 👋';

  @override
  String studyStreak(int days) {
    return '$days dag(en) op rij';
  }

  @override
  String get questionsDone => 'Vragen gedaan';

  @override
  String get passRate => 'Slagingspercentage';

  @override
  String get remaining => 'Nog te doen';

  @override
  String get overallProgress => 'Totale voortgang';

  @override
  String get quickActions => 'Snelle acties';

  @override
  String get continueLearning => 'Verder leren';

  @override
  String get mockTest => 'Oefenexamen';

  @override
  String get practice => 'Oefenen';

  @override
  String get flashcards => 'Flashkaarten';

  @override
  String get scanQA => 'Vraag & antwoord scannen';

  @override
  String doneOf(int done, int total) {
    return '$done van $total gedaan';
  }

  @override
  String get topicsTitle => 'Training';

  @override
  String get searchTopics => 'Zoek onderwerpen…';

  @override
  String get startMockTest => 'Oefenexamen starten';

  @override
  String get mockTestSubtitle => '50 vragen · 50 minuten · Belgische standaard';

  @override
  String get topics => 'Onderwerpen';

  @override
  String questionsCount(int count) {
    return '$count vragen';
  }

  @override
  String questionOf(int current, int total) {
    return 'Vraag $current van $total';
  }

  @override
  String get correct => 'Goed!';

  @override
  String get incorrect => 'Fout';

  @override
  String get explanation => 'Uitleg';

  @override
  String get nextQuestion => 'Volgende vraag';

  @override
  String get viewResults => 'Bekijk resultaten';

  @override
  String get testComplete => 'Test afgerond';

  @override
  String get yourScore => 'Jouw score';

  @override
  String get passed => 'GESLAAGD';

  @override
  String get failed => 'GEZAKT';

  @override
  String get passedMessage =>
      'Gefeliciteerd! Je hebt het theorie-examen gehaald.';

  @override
  String get failedMessage => 'Blijf oefenen — je komt er wel!';

  @override
  String get accuracy => 'Nauwkeurigheid';

  @override
  String get timeTaken => 'Bestede tijd';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get reviewAnswers => 'Antwoorden bekijken';

  @override
  String get backToHome => 'Terug naar start';

  @override
  String get flashcardsTitle => 'Flashkaarten';

  @override
  String get tapToFlip => 'Tik om om te draaien';

  @override
  String get gotIt => 'Begrepen!';

  @override
  String get reviewAgain => 'Nogmaals bekijken';

  @override
  String get scannerTitle => 'Scan een vraag';

  @override
  String get scannerHint => 'Richt de camera op een vraag op het scherm';

  @override
  String get scanning => 'Bezig met scannen…';

  @override
  String get readingText => 'Tekst lezen…';

  @override
  String get matchFound => 'Overeenkomst gevonden!';

  @override
  String get questionDetected => 'Vraag gedetecteerd';

  @override
  String get correctAnswer => 'Juist antwoord';

  @override
  String get fromQuestionBank => 'Uit de vragenbank';

  @override
  String get aiAnswer => 'AI-antwoord';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get confidence => 'Zekerheid';

  @override
  String get progressTitle => 'Jouw voortgang';

  @override
  String get thisWeek => 'Deze week';

  @override
  String get thisMonth => 'Deze maand';

  @override
  String get allTime => 'Alle tijd';

  @override
  String get questionsAnswered => 'Beantwoorde vragen';

  @override
  String get studyStreakDays => 'Studiedagen op rij';

  @override
  String get dailyActivity => 'Dagelijkse activiteit';

  @override
  String get topicMastery => 'Beheersing per onderwerp';

  @override
  String get bookmarks => 'Bladwijzers';

  @override
  String get bookmarkedQuestions => 'Opgeslagen vragen';

  @override
  String get noBookmarks => 'Nog geen bladwijzers';

  @override
  String get noBookmarksHint =>
      'Sla vragen op tijdens het oefenen om ze hier te bekijken.';

  @override
  String get removeBookmark => 'Bladwijzer verwijderen';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get appearance => 'Weergave';

  @override
  String get theme => 'Thema';

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String get system => 'Systeem';

  @override
  String get language => 'Taal';

  @override
  String get notifications => 'Meldingen';

  @override
  String get dailyReminder => 'Dagelijkse herinnering';

  @override
  String get testReminder => 'Herinnering op examendag';

  @override
  String get about => 'Over';

  @override
  String get version => 'Versie';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get termsOfService => 'Gebruiksvoorwaarden';

  @override
  String get rateApp => 'App beoordelen';

  @override
  String get clearProgress => 'Alle voortgang wissen';

  @override
  String get clearProgressConfirm =>
      'Weet je het zeker? Al je voortgang wordt verwijderd en dit kan niet ongedaan worden gemaakt.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get onboarding1Title => 'Beheers de theorie';

  @override
  String get onboarding1Subtitle =>
      'Leer alle Belgische verkeerstheorievragen met slimme AI-begeleiding.';

  @override
  String get onboarding2Title => 'Oefen slimmer';

  @override
  String get onboarding2Subtitle =>
      'Adaptief leren richt zich op jouw zwakke punten. Elk fout antwoord wordt volledig uitgelegd.';

  @override
  String get onboarding3Title => 'Direct scannen';

  @override
  String get onboarding3Subtitle =>
      'Richt je camera op een vraag op het scherm en krijg binnen enkele seconden het antwoord.';

  @override
  String get getStarted => 'Aan de slag';

  @override
  String get next => 'Volgende';

  @override
  String get skip => 'Overslaan';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get cameraPermissionTitle => 'Cameratoegang vereist';

  @override
  String get cameraPermissionMessage =>
      'Drive Better heeft cameratoegang nodig om vragen te scannen.';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get keepItUp => 'Ga zo door! 🎯';

  @override
  String get answer => 'Antwoord';

  @override
  String get question => 'Vraag';
}
