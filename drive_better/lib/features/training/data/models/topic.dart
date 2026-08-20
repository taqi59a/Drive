import 'package:isar/isar.dart';

part 'topic.g.dart';

@collection
class Topic {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String externalId;

  late String title;
  String? description;
  late int order;
  late int questionCount;
  String? iconName;
  String? colorHex;
  String? content;
  String? contentHtml;
}
