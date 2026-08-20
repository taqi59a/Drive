import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/training/data/models/question.dart';
import '../../features/training/data/models/topic.dart';
import '../../features/progress/data/models/attempt.dart';
import '../constants/app_constants.dart';
import '../utils/text_normalizer.dart';

class DbSeeder {
  const DbSeeder(this._isar);
  final Isar _isar;

  // Bump this version to force a re-seed when asset JSON changes
  static const int _seedVersion = 24;
  static const String _seedVersionKey = 'db_seed_version';

  Future<void> seedIfNeeded({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final seededVersion = prefs.getInt(_seedVersionKey) ?? 0;
    if (!force && seededVersion >= _seedVersion) return;

    // Clear existing data to make sure no legacy/previous data remains
    await _isar.writeTxn(() async {
      await _isar.questions.clear();
      await _isar.topics.clear();
      await _isar.attempts.clear();
    });

    await _seedTopics();
    await _seedQuestions();

    await prefs.setInt(_seedVersionKey, _seedVersion);
    // Keep legacy flag for compatibility
    await prefs.setBool(AppConstants.prefKeyDbSeeded, true);
  }

  Future<void> _seedTopics() async {
    final raw = await rootBundle.loadString(AppConstants.seedTopicsPath);
    final List<dynamic> data = json.decode(raw);

    await _isar.writeTxn(() async {
      for (final e in data) {
        final externalId = e['id'] as String;
        // Try to find existing by externalId to preserve Isar id
        final existing = await _isar.topics
            .filter()
            .externalIdEqualTo(externalId)
            .findFirst();
        final t = existing ?? Topic();
        t
          ..externalId = externalId
          ..title = e['title'] as String
          ..description = e['description'] as String?
          ..order = e['order'] as int
          ..questionCount = e['questionCount'] as int? ?? 0
          ..iconName = e['iconName'] as String?
          ..colorHex = e['colorHex'] as String?
          ..content = e['content'] as String?
          ..contentHtml = e['contentHtml'] as String?;
        await _isar.topics.put(t);
      }
    });
  }

  Future<void> _seedQuestions() async {
    final raw = await rootBundle.loadString(AppConstants.seedQuestionsPath);
    final List<dynamic> data = json.decode(raw);

    await _isar.writeTxn(() async {
      for (final e in data) {
        final externalId = e['id'] as String;
        final existing = await _isar.questions
            .filter()
            .externalIdEqualTo(externalId)
            .findFirst();

        final optList = (e['options'] as List<dynamic>)
            .map((o) => AnswerOption()
              ..text = o['text'] as String
              ..imageAsset = o['imageAsset'] as String?)
            .toList();

        final q = existing ?? Question();
        // Preserve user progress fields if existing
        q
          ..externalId = externalId
          ..topicId = e['topicId'] as String
          ..text = e['text'] as String
          ..options = optList
          ..correctIndex = e['correctIndex'] as int
          ..explanation = e['explanation'] as String?
          ..imageAsset = e['imageAsset'] as String?
          ..isSerious = e['isSerious'] as bool? ?? false
          ..sourcePage = e['sourcePage'] as int? ?? 0
          ..searchTokens = TextNormalizer.tokenize(e['text'] as String);
        await _isar.questions.put(q);
      }
    });
  }
}
