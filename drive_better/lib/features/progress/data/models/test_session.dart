import 'package:isar/isar.dart';

part 'test_session.g.dart';

@collection
class TestSession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime startedAt;

  DateTime? finishedAt;
  late int totalQuestions;
  late int correctCount;
  late int durationSeconds;
  late bool passed;
  late List<String> questionIds;
}
