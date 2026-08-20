import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../features/progress/data/models/attempt.dart';
import '../../features/training/data/models/topic.dart';
import '../../features/training/data/models/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'isar_provider.dart';

// Provider to track if a specific chapter has been read
final chapterReadProvider = FutureProvider.family<bool, String>((ref, topicId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('chapter_read_$topicId') ?? false;
});


// All topics from Isar, ordered
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.topics.where().sortByOrder().findAll();
});

// All questions count
final totalQuestionsProvider = FutureProvider<int>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.questions.count();
});

// Attempts stats
class StatsData {
  final int attempted;
  final int total;
  final int correct;

  const StatsData({
    required this.attempted,
    required this.total,
    required this.correct,
  });

  double get passRate => attempted == 0 ? 0 : correct / attempted;
  double get overallProgress => total == 0 ? 0 : attempted / total;
  int get remaining => (total - attempted).clamp(0, total);
}

final statsProvider = FutureProvider<StatsData>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final total = await isar.questions.count();
  final allAttempts = await isar.attempts.where().findAll();
  // Unique questions attempted
  final attempted = allAttempts.map((a) => a.questionExternalId).toSet().length;
  final correct = allAttempts.where((a) => a.wasCorrect).length;
  return StatsData(attempted: attempted, total: total, correct: correct);
});

// Progress per topic (0.0–1.0): ratio of unique questions attempted
final topicProgressProvider = FutureProvider.family<double, String>((ref, topicExternalId) async {
  final isar = await ref.watch(isarProvider.future);
  final questions = await isar.questions
      .filter()
      .topicIdEqualTo(topicExternalId)
      .findAll();
  if (questions.isEmpty) return 0.0;
  final questionIds = questions.map((q) => q.externalId).toSet();
  final attempts = await isar.attempts.where().findAll();
  final attempted = attempts
      .where((a) => questionIds.contains(a.questionExternalId))
      .map((a) => a.questionExternalId)
      .toSet()
      .length;
  return attempted / questions.length;
});

// Questions for a specific topic
final topicQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, topicId) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.questions.filter().topicIdEqualTo(topicId).findAll();
});

// All questions (for mock test - Belgian rules: 5 serious, 45 minor)
final mockTestQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final all = await isar.questions.where().findAll();

  final serious = all.where((q) => q.isSerious).toList();
  final minor = all.where((q) => !q.isSerious).toList();

  serious.shuffle();
  minor.shuffle();

  final selectedSerious = serious.take(5).toList();
  final selectedMinor = minor.take(50 - selectedSerious.length).toList();

  final combined = [...selectedSerious, ...selectedMinor];
  combined.shuffle();
  return combined;
});

// Bookmarked questions
final bookmarkedQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return isar.questions.filter().isBookmarkedEqualTo(true).findAll();
});
