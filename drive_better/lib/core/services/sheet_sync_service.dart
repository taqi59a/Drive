import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/training/data/models/question.dart';
import '../../features/training/data/models/topic.dart';

class SheetSyncService {
  static const _sheetId = '1DD82tKvx_DbaBXEiHhRIuazkz5QZ67wFnh2sU26mgEY';
  static const _csvUrl = 'https://docs.google.com/spreadsheets/d/$_sheetId/export?format=csv';
  static const _lastSyncKey = 'sheet_last_sync';
  static const _syncIntervalHours = 24;

  final Isar _isar;
  final Dio _dio;

  SheetSyncService(this._isar)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          followRedirects: true,
          maxRedirects: 5,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 13; SM-G980F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
        ));

  Future<bool> shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final hoursSince = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(lastSync))
            .inHours;
    return hoursSince >= _syncIntervalHours;
  }

  Future<SyncResult> syncIfNeeded({bool force = false}) async {
    if (!force && !(await shouldSync())) {
      return SyncResult.skipped();
    }
    return sync();
  }

  String _getTopicName(String id) {
    const names = {
      'road_signs': 'Road Signs',
      'hazard_awareness': 'Hazard Awareness',
      'motorway_rules': 'Motorway Rules',
      'vehicle_safety': 'Vehicle Safety',
      'rules_of_road': 'Rules of the Road',
      'road_works': 'Road Works',
      'accidents': 'Accidents & First Aid',
      'environment': 'Environment & Eco',
    };
    return names[id] ?? 'General';
  }

  Future<SyncResult> sync() async {
    try {
      final response = await _dio.get<String>(_csvUrl);
      final raw = response.data;
      if (raw == null || raw.isEmpty) {
        return SyncResult.error('Empty response from Google Sheet server');
      }

      final rows = _parseCsv(raw);
      if (rows.isEmpty) {
        return SyncResult.error('No rows parsed from CSV');
      }
      final headers = rows.first;

      final questions = <Question>[];
      final topicMap = <String, _TopicAccumulator>{};

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final q = _rowToQuestion(headers, row);
        if (q == null) continue;

        questions.add(q);

        final topicName = _getTopicName(q.topicId);
        topicMap.putIfAbsent(q.topicId, () => _TopicAccumulator(q.topicId, topicName));
        topicMap[q.topicId]!.count++;
      }

      if (questions.isEmpty) return SyncResult.error('No valid questions loaded');

      await _isar.writeTxn(() async {
        // Upsert questions
        for (final q in questions) {
          final existing = await _isar.questions.filter().externalIdEqualTo(q.externalId).findFirst();
          if (existing == null) {
            await _isar.questions.put(q);
          } else {
            // Preserve user data (bookmarks, SM-2 fields)
            q.id = existing.id;
            q.isBookmarked = existing.isBookmarked;
            q.timesSeen = existing.timesSeen;
            q.timesCorrect = existing.timesCorrect;
            q.easeFactor = existing.easeFactor;
            q.dueAt = existing.dueAt;
            q.lastSeenAt = existing.lastSeenAt;
            await _isar.questions.put(q);
          }
        }

        // Upsert topics with real question counts
        for (final acc in topicMap.values) {
          final existing = await _isar.topics.filter().externalIdEqualTo(acc.id).findFirst();
          if (existing != null) {
            existing.questionCount = acc.count;
            await _isar.topics.put(existing);
          } else {
            final topic = Topic()
              ..externalId = acc.id
              ..title = acc.name
              ..description = ''
              ..order = _topicOrder(acc.id)
              ..questionCount = acc.count
              ..iconName = _topicIcon(acc.id)
              ..colorHex = _topicColor(acc.id);
            await _isar.topics.put(topic);
          }
        }
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      return SyncResult.success(questions.length);
    } on DioException catch (e) {
      final status = e.response != null ? ' (Status: ${e.response?.statusCode})' : '';
      return SyncResult.error('${e.message ?? 'Network error'}$status');
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  // ─── CSV parsing ─────────────────────────────────────────────────────────

  List<List<String>> _parseCsv(String raw) {
    final rows = <List<String>>[];
    final lines = raw.split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      rows.add(_parseCsvLine(line));
    }
    return rows;
  }

  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    var inQuotes = false;
    var current = StringBuffer();

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(current.toString().trim());
        current.clear();
      } else {
        current.write(ch);
      }
    }
    fields.add(current.toString().trim());
    return fields;
  }

  Question? _rowToQuestion(List<String> headers, List<String> row) {
    try {
      String get(String col) {
        final i = headers.indexOf(col);
        return i >= 0 && i < row.length ? row[i] : '';
      }

      final id = get('question_id');
      final topicId = get('topic_id');
      final text = get('question_text');
      if (id.isEmpty || topicId.isEmpty || text.isEmpty) return null;

      final optA = get('option_a');
      final optB = get('option_b');
      final optC = get('option_c');
      final optD = get('option_d');

      final options = <AnswerOption>[];
      if (optA.isNotEmpty) options.add(AnswerOption()..text = optA);
      if (optB.isNotEmpty) options.add(AnswerOption()..text = optB);
      if (optC.isNotEmpty) options.add(AnswerOption()..text = optC);
      if (optD.isNotEmpty) options.add(AnswerOption()..text = optD);

      final correctLetter = get('correct_answer').toUpperCase().trim();
      final correctIndex = ['A', 'B', 'C', 'D'].indexOf(correctLetter);
      if (correctIndex < 0 || correctIndex >= options.length) return null;

      final isSeriousRaw = get('is_serious').toLowerCase().trim();
      final isSerious = isSeriousRaw == 'true' || isSeriousRaw == '1';

      final q = Question()
        ..externalId = id
        ..topicId = topicId
        ..text = text
        ..options = options
        ..correctIndex = correctIndex
        ..explanation = get('explanation').isEmpty ? null : get('explanation')
        ..imageAsset = get('image_url').isEmpty ? null : get('image_url')
        ..isSerious = isSerious
        ..searchTokens = _tokenize(text)
        ..sourcePage = int.tryParse(get('source_page')) ?? 0;

      return q;
    } catch (_) {
      return null;
    }
  }

  List<String> _tokenize(String text) {
    const stopWords = {'a', 'an', 'the', 'is', 'are', 'was', 'were', 'you', 'your', 'it', 'its', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'by', 'this', 'that', 'and', 'or', 'but', 'what', 'when', 'how', 'does', 'do', 'should', 'must', 'can', 'will', 'would'};
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').split(' ').where((w) => w.length > 2 && !stopWords.contains(w)).toList();
  }

  int _topicOrder(String id) {
    const order = ['road_signs', 'hazard_awareness', 'motorway_rules', 'vehicle_safety', 'rules_of_road', 'road_works', 'accidents', 'environment'];
    final i = order.indexOf(id);
    return i >= 0 ? i + 1 : 99;
  }

  String _topicIcon(String id) {
    const icons = {
      'road_signs': 'sign_post',
      'hazard_awareness': 'warning',
      'motorway_rules': 'directions',
      'vehicle_safety': 'car_repair',
      'rules_of_road': 'rule',
      'road_works': 'construction',
      'accidents': 'local_hospital',
      'environment': 'eco',
    };
    return icons[id] ?? 'circle';
  }

  String _topicColor(String id) {
    const colors = {
      'road_signs': '#1B3A6B',
      'hazard_awareness': '#F5A623',
      'motorway_rules': '#039BE5',
      'vehicle_safety': '#43A047',
      'rules_of_road': '#8E24AA',
      'road_works': '#F4511E',
      'accidents': '#D81B60',
      'environment': '#00897B',
    };
    return colors[id] ?? '#1B3A6B';
  }
}

class _TopicAccumulator {
  final String id;
  final String name;
  int count = 0;
  _TopicAccumulator(this.id, this.name);
}

class SyncResult {
  final bool success;
  final bool skipped;
  final int questionsUpserted;
  final String? error;

  const SyncResult._({required this.success, required this.skipped, this.questionsUpserted = 0, this.error});

  factory SyncResult.success(int count) => SyncResult._(success: true, skipped: false, questionsUpserted: count);
  factory SyncResult.skipped() => SyncResult._(success: true, skipped: true);
  factory SyncResult.error(String msg) => SyncResult._(success: false, skipped: false, error: msg);

  @override
  String toString() {
    if (skipped) return 'SyncResult: skipped (not due yet)';
    if (success) return 'SyncResult: ok — $questionsUpserted questions';
    return 'SyncResult: error — $error';
  }
}
