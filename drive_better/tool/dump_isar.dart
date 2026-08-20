import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import '../lib/features/training/data/models/question.dart';
import '../lib/features/training/data/models/topic.dart';

void main() async {
  final tempDir = Directory('tool/temp_db');
  if (!tempDir.existsSync()) {
    tempDir.createSync(recursive: true);
  }
  
  final pulledDb = File('../default.isar');
  if (pulledDb.existsSync()) {
    pulledDb.copySync('tool/temp_db/default.isar');
    print('Copied default.isar to temp folder.');
  } else {
    print('Error: default.isar not found at ${pulledDb.absolute.path}!');
    return;
  }
  
  print('Opening Isar database...');
  // Initialize Isar. Note that since we run this as a standalone script on Windows,
  // Isar will automatically look for and download isar.dll if needed.
  final isar = await Isar.open(
    [QuestionSchema, TopicSchema],
    directory: 'tool/temp_db',
  );
  
  print('Fetching topics...');
  final topics = await isar.topics.where().findAll();
  print('Found ${topics.length} topics.');
  
  final topicsList = topics.map((t) => {
    'id': t.externalId,
    'title': t.title,
    'description': t.description,
    'order': t.order,
    'questionCount': t.questionCount,
    'iconName': t.iconName,
    'colorHex': t.colorHex,
  }).toList();
  
  print('Fetching questions...');
  final questions = await isar.questions.where().findAll();
  print('Found ${questions.length} questions.');
  
  final questionsList = questions.map((q) => {
    'id': q.externalId,
    'topicId': q.topicId,
    'text': q.text,
    'options': q.options.map((o) => {
      'text': o.text,
      'imageAsset': o.imageAsset,
    }).toList(),
    'correctIndex': q.correctIndex,
    'explanation': q.explanation,
    'imageAsset': q.imageAsset,
    'sourcePage': q.sourcePage,
  }).toList();
  
  final topicsFile = File('tool/extracted_topics.json');
  topicsFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(topicsList));
  print('Saved topics to ${topicsFile.path}');
  
  final questionsFile = File('tool/extracted_questions.json');
  questionsFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(questionsList));
  print('Saved questions to ${questionsFile.path}');
  
  await isar.close();
  print('Done successfully!');
}
