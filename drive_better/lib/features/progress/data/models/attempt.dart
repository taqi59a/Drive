import 'package:isar/isar.dart';

part 'attempt.g.dart';

@collection
class Attempt {
  Id id = Isar.autoIncrement;

  @Index()
  late String questionExternalId;

  @Index()
  late DateTime answeredAt;

  late int chosenIndex;
  late bool wasCorrect;
  late int msToAnswer;

  @enumerated
  late AttemptMode mode;
}

enum AttemptMode { practice, mockTest, flashcard }
