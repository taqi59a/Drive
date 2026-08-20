// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Drive Better';

  @override
  String get home => 'Accueil';

  @override
  String get training => 'Entraînement';

  @override
  String get scan => 'Scanner';

  @override
  String get progress => 'Progression';

  @override
  String get settings => 'Paramètres';

  @override
  String get goodMorning => 'Bonjour, conducteur ! 👋';

  @override
  String get goodAfternoon => 'Bon après-midi, conducteur ! 👋';

  @override
  String get goodEvening => 'Bonsoir, conducteur ! 👋';

  @override
  String studyStreak(int days) {
    return '$days jour(s) d\'affilée';
  }

  @override
  String get questionsDone => 'Questions répondues';

  @override
  String get passRate => 'Taux de réussite';

  @override
  String get remaining => 'Restantes';

  @override
  String get overallProgress => 'Progression globale';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get continueLearning => 'Continuer l\'apprentissage';

  @override
  String get mockTest => 'Examen blanc';

  @override
  String get practice => 'Pratiquer';

  @override
  String get flashcards => 'Fiches mémo';

  @override
  String get scanQA => 'Scanner Q&R';

  @override
  String doneOf(int done, int total) {
    return '$done sur $total faites';
  }

  @override
  String get topicsTitle => 'Entraînement';

  @override
  String get searchTopics => 'Rechercher des thèmes…';

  @override
  String get startMockTest => 'Commencer l\'examen blanc';

  @override
  String get mockTestSubtitle => '50 questions · 50 minutes · Standard belge';

  @override
  String get topics => 'Thèmes';

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String questionOf(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get correct => 'Correct !';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get explanation => 'Explication';

  @override
  String get nextQuestion => 'Question suivante';

  @override
  String get viewResults => 'Voir les résultats';

  @override
  String get testComplete => 'Test terminé';

  @override
  String get yourScore => 'Votre score';

  @override
  String get passed => 'RÉUSSI';

  @override
  String get failed => 'ÉCHOUÉ';

  @override
  String get passedMessage =>
      'Félicitations ! Vous avez réussi l\'examen théorique.';

  @override
  String get failedMessage => 'Continuez à pratiquer — vous y arriverez !';

  @override
  String get accuracy => 'Précision';

  @override
  String get timeTaken => 'Temps écoulé';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get reviewAnswers => 'Revoir les réponses';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get flashcardsTitle => 'Fiches mémo';

  @override
  String get tapToFlip => 'Appuyez pour retourner';

  @override
  String get gotIt => 'Compris !';

  @override
  String get reviewAgain => 'Revoir encore';

  @override
  String get scannerTitle => 'Scanner une question';

  @override
  String get scannerHint => 'Pointez la caméra vers une question à l\'écran';

  @override
  String get scanning => 'Scan en cours…';

  @override
  String get readingText => 'Lecture du texte…';

  @override
  String get matchFound => 'Correspondance trouvée !';

  @override
  String get questionDetected => 'Question détectée';

  @override
  String get correctAnswer => 'Bonne réponse';

  @override
  String get fromQuestionBank => 'De la banque de questions';

  @override
  String get aiAnswer => 'Réponse IA';

  @override
  String get dismiss => 'Fermer';

  @override
  String get confidence => 'Confiance';

  @override
  String get progressTitle => 'Votre progression';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get allTime => 'Depuis toujours';

  @override
  String get questionsAnswered => 'Questions répondues';

  @override
  String get studyStreakDays => 'Série d\'études';

  @override
  String get dailyActivity => 'Activité quotidienne';

  @override
  String get topicMastery => 'Maîtrise des thèmes';

  @override
  String get bookmarks => 'Favoris';

  @override
  String get bookmarkedQuestions => 'Questions en favoris';

  @override
  String get noBookmarks => 'Aucun favori pour l\'instant';

  @override
  String get noBookmarksHint =>
      'Ajoutez des questions en favoris pendant la pratique pour les revoir ici.';

  @override
  String get removeBookmark => 'Retirer des favoris';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Rappel quotidien';

  @override
  String get testReminder => 'Rappel le jour de l\'examen';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get rateApp => 'Noter l\'application';

  @override
  String get clearProgress => 'Effacer toute la progression';

  @override
  String get clearProgressConfirm =>
      'Êtes-vous sûr(e) ? Toute votre progression sera supprimée et cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get onboarding1Title => 'Maîtrisez la théorie';

  @override
  String get onboarding1Subtitle =>
      'Apprenez toutes les questions du code de la route belge avec une aide intelligente basée sur l\'IA.';

  @override
  String get onboarding2Title => 'Pratiquez plus intelligemment';

  @override
  String get onboarding2Subtitle =>
      'L\'apprentissage adaptatif cible vos points faibles. Chaque mauvaise réponse est entièrement expliquée.';

  @override
  String get onboarding3Title => 'Scan instantané';

  @override
  String get onboarding3Subtitle =>
      'Pointez votre caméra vers n\'importe quelle question à l\'écran et obtenez la réponse en quelques secondes.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get cameraPermissionTitle => 'Accès à la caméra requis';

  @override
  String get cameraPermissionMessage =>
      'Drive Better a besoin d\'accéder à la caméra pour scanner les questions.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get keepItUp => 'Continuez comme ça ! 🎯';

  @override
  String get answer => 'Réponse';

  @override
  String get question => 'Question';
}
