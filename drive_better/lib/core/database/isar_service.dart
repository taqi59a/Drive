import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/training/data/models/question.dart';
import '../../features/training/data/models/topic.dart';
import '../../features/progress/data/models/attempt.dart';
import '../../features/progress/data/models/test_session.dart';

class IsarService {
  IsarService._();
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [QuestionSchema, TopicSchema, AttemptSchema, TestSessionSchema],
      directory: dir.path,
    );
    return _instance!;
  }
}
