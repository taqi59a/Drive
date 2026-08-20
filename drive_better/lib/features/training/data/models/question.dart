import 'package:isar/isar.dart';

part 'question.g.dart';

@collection
class Question {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String externalId;

  @Index(caseSensitive: false, type: IndexType.value)
  late String topicId;

  late String text;

  @Index(type: IndexType.hashElements, caseSensitive: false)
  late List<String> searchTokens;

  late List<AnswerOption> options;

  late int correctIndex;
  String? explanation;
  String? imageAsset;
  int sourcePage = 0;

  bool isSerious = false;

  bool isBookmarked = false;
  int timesSeen = 0;
  int timesCorrect = 0;
  DateTime? lastSeenAt;
  double easeFactor = 2.5;
  DateTime? dueAt;
}

@embedded
class AnswerOption {
  late String text;
  String? imageAsset;
}
