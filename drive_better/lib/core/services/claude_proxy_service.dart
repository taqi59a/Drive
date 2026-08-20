import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ProxyAnswer {
  final String answer;
  final String explanation;
  final double confidence;
  final bool discard;
  final String? discardReason;

  const ProxyAnswer({
    required this.answer,
    required this.explanation,
    required this.confidence,
    this.discard = false,
    this.discardReason,
  });

  factory ProxyAnswer.fromJson(Map<String, dynamic> json) => ProxyAnswer(
        answer: json['answer'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        discard: json['discard'] as bool? ?? false,
        discardReason: json['reason'] as String?,
      );
}

class ClaudeProxyService {
  ClaudeProxyService(this._dio);
  final Dio _dio;

  static final _headers = {
    'Authorization': 'Bearer ${AppConfig.appToken}',
    'Content-Type': 'application/json',
  };

  String get _base => AppConfig.proxyBaseUrl;

  /// Ask Claude a question (camera Q&A fallback).
  Future<ProxyAnswer> answer(String question, {String? context, String? image}) async {
    final res = await _dio.post(
      '$_base/v1/answer',
      data: {
        'question': question,
        if (context != null) 'context': context,
        if (image != null) 'image': image,
      },
      options: Options(headers: _headers),
    );
    return ProxyAnswer.fromJson(res.data as Map<String, dynamic>);
  }

  /// Get an AI-generated explanation for a question/answer pair.
  Future<String> explain({
    required String question,
    required String correctAnswer,
    String? wrongAnswer,
  }) async {
    final res = await _dio.post(
      '$_base/v1/explain',
      data: {
        'question': question,
        'correctAnswer': correctAnswer,
        if (wrongAnswer != null) 'wrongAnswer': wrongAnswer,
      },
      options: Options(headers: _headers),
    );
    final data = res.data as Map<String, dynamic>;
    return data['explanation'] as String? ?? '';
  }

  /// Health check — returns true if proxy is reachable.
  Future<bool> isHealthy() async {
    try {
      final res = await _dio.get(
        '$_base/health',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
