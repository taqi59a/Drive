import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/isar_service.dart';
import '../../../../core/services/claude_proxy_service.dart';
import '../../../../core/utils/fuzzy_matcher.dart';
import '../../../../core/utils/text_normalizer.dart';
import 'package:isar/isar.dart';

import '../../../../features/training/data/models/question.dart';
import '../../../../shared/providers/dio_provider.dart';

// ---------------------------------------------------------------------------
// Domain model for a matched / AI-generated answer
// ---------------------------------------------------------------------------

class ScannerAnswer {
  final String questionText;
  final String correctAnswer;
  final String explanation;
  final String topic;
  final bool fromAI;

  const ScannerAnswer({
    required this.questionText,
    required this.correctAnswer,
    required this.explanation,
    required this.topic,
    this.fromAI = false,
  });

  factory ScannerAnswer.fromQuestion(Question q) => ScannerAnswer(
        questionText: q.text,
        correctAnswer: q.options.isNotEmpty && q.correctIndex < q.options.length
            ? q.options[q.correctIndex].text
            : '',
        explanation: q.explanation ?? '',
        topic: q.topicId.replaceAll('_', ' '),
      );

  factory ScannerAnswer.fromProxy(String question, ProxyAnswer p) => ScannerAnswer(
        questionText: question,
        correctAnswer: p.answer,
        explanation: p.explanation,
        topic: 'AI Answer',
        fromAI: true,
      );
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ScannerState {
  final bool isScanning;
  final String lastOcrText;
  final ScannerAnswer? matchedAnswer;
  final double matchConfidence;
  final bool isLoading;
  final String? error;
  final ScanStatus status;

  const ScannerState({
    this.isScanning = false,
    this.lastOcrText = '',
    this.matchedAnswer,
    this.matchConfidence = 0,
    this.isLoading = false,
    this.error,
    this.status = ScanStatus.idle,
  });

  ScannerState copyWith({
    bool? isScanning,
    String? lastOcrText,
    ScannerAnswer? matchedAnswer,
    bool clearMatch = false,
    double? matchConfidence,
    bool? isLoading,
    String? error,
    bool clearError = false,
    ScanStatus? status,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      lastOcrText: lastOcrText ?? this.lastOcrText,
      matchedAnswer: clearMatch ? null : matchedAnswer ?? this.matchedAnswer,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      status: status ?? this.status,
    );
  }
}

enum ScanStatus { idle, scanning, readingText, matchFound, aiLookup, noMatch }

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class ScannerController extends StateNotifier<ScannerState> {
  ScannerController(this._proxy) : super(const ScannerState());

  final ClaudeProxyService _proxy;
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  Timer? _scanTimer;
  bool _processingFrame = false;

  void startScanning(CameraController cameraController, Size screenSize) {
    if (state.isScanning) return;
    state = state.copyWith(isScanning: true, status: ScanStatus.scanning);
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => _captureAndProcess(cameraController, screenSize),
    );
  }

  void stopScanning() {
    _scanTimer?.cancel();
    _scanTimer = null;
    state = state.copyWith(isScanning: false, status: ScanStatus.idle);
  }

  Future<void> scanManual(CameraController cameraController, Size screenSize) async {
    if (_processingFrame || !cameraController.value.isInitialized) return;
    
    // Cancel any existing timer to prevent overlapping
    _scanTimer?.cancel();
    _scanTimer = null;
    
    state = state.copyWith(isScanning: true);
    await _captureAndProcess(cameraController, screenSize);
  }

  void dismissMatch() {
    state = state.copyWith(
        clearMatch: true,
        status: state.isScanning ? ScanStatus.scanning : ScanStatus.idle);
  }

  Future<void> _captureAndProcess(CameraController camera, Size screenSize) async {
    if (_processingFrame || !camera.value.isInitialized) return;
    _processingFrame = true;

    try {
      state = state.copyWith(status: ScanStatus.readingText);
      final xFile = await camera.takePicture();
      final bytes = await xFile.readAsBytes();

      // Decode the captured image
      var decoded = img.decodeImage(bytes);
      if (decoded == null) {
        state = state.copyWith(status: ScanStatus.scanning);
        _processingFrame = false;
        return;
      }
      decoded = img.bakeOrientation(decoded);

      // viewfinder bounds calculations (matching 88% width, 65% height, shifted up 40px)
      final screenW = screenSize.width;
      final screenH = screenSize.height;
      final frameW = screenW * 0.88;
      final frameH = screenH * 0.65;
      final cx = screenW / 2;
      final cy = screenH / 2 - 40;
      final frameLeft = cx - frameW / 2;
      final frameTop = cy - frameH / 2;

      // camera preview sizing (swap dimensions for portrait)
      final previewW = camera.value.previewSize?.height ?? screenW;
      final previewH = camera.value.previewSize?.width ?? screenH;

      // FittedBox cover math
      final scale = math.max(screenW / previewW, screenH / previewH);
      final scaledW = previewW * scale;
      final scaledH = previewH * scale;
      final offsetX = (screenW - scaledW) / 2;
      final offsetY = (screenH - scaledH) / 2;

      // Map screen crop rect to normalized coordinates
      final normLeft = (frameLeft - offsetX) / scaledW;
      final normTop = (frameTop - offsetY) / scaledH;
      final normWidth = frameW / scaledW;
      final normHeight = frameH / scaledH;

      // Clamp coordinates to image pixel space
      final cropX = (normLeft * decoded.width).round().clamp(0, decoded.width - 1);
      final cropY = (normTop * decoded.height).round().clamp(0, decoded.height - 1);
      final cropW = (normWidth * decoded.width).round().clamp(1, decoded.width - cropX);
      final cropH = (normHeight * decoded.height).round().clamp(1, decoded.height - cropY);

      final cropped = img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);

      // Write cropped image to temp file for ML Kit OCR
      final tempDir = await getTemporaryDirectory();
      final croppedFile = File('${tempDir.path}/cropped_frame_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 85));

      final inputImage = InputImage.fromFilePath(croppedFile.path);
      final recognized = await _recognizer.processImage(inputImage);
      final rawText = recognized.text;

      // Delete temporary file
      try {
        await croppedFile.delete();
      } catch (_) {}

      if (rawText.trim().length < 8) {
        state = state.copyWith(
            lastOcrText: '', status: ScanStatus.scanning, clearError: true);
        _processingFrame = false;
        return;
      }

      final cleaned = TextNormalizer.fixOcrArtifacts(rawText);
      state = state.copyWith(lastOcrText: cleaned);

      // Require at least 25 characters of clean text before processing to avoid false positive triggers
      if (cleaned.length < 25) {
        state = state.copyWith(
            lastOcrText: cleaned, status: ScanStatus.scanning, clearError: true);
        _processingFrame = false;
        return;
      }

      // Resize/compress the cropped image to base64 for Claude Vision (max dimension 1024px)
      img.Image resized;
      if (cropped.width > 1024 || cropped.height > 1024) {
        if (cropped.width > cropped.height) {
          resized = img.copyResize(cropped, width: 1024);
        } else {
          resized = img.copyResize(cropped, height: 1024);
        }
      } else {
        resized = cropped;
      }
      final jpgBytes = img.encodeJpg(resized, quality: 70);
      final base64Image = base64Encode(jpgBytes);

      // 1. Fuzzy-match against Isar question bank (only if OCR text length is at least 45 to prevent false matches)
      if (cleaned.length >= 45) {
        final isar = await IsarService.getInstance();
        final questions = await isar.questions.where().findAll();

        Question? best;
        double bestScore = 0;
        for (final q in questions) {
          final s = FuzzyMatcher.score(cleaned, q.text);
          if (s > bestScore) {
            bestScore = s;
            best = q;
          }
        }

        if (bestScore >= AppConstants.ocrMatchThreshold && best != null) {
          state = state.copyWith(
            matchedAnswer: ScannerAnswer.fromQuestion(best),
            matchConfidence: bestScore,
            status: ScanStatus.matchFound,
            clearError: true,
          );
          _scanTimer?.cancel();
          _scanTimer = null;
          return;
        }
      }

      // 2. Claude proxy fallback (AI-powered, requires internet + backend)
      state = state.copyWith(status: ScanStatus.aiLookup);
      try {
        final answer = await _proxy.answer(cleaned, context: rawText, image: base64Image);
        
        if (answer.discard) {
          // If the AI tells us to discard (e.g. no computer screen with driving question detected),
          // we silently reset status to scanning and continue the loop.
          state = state.copyWith(status: ScanStatus.scanning, clearMatch: true, clearError: true);
          return;
        }

        if (answer.answer.isNotEmpty) {
          state = state.copyWith(
            matchedAnswer: ScannerAnswer.fromProxy(cleaned, answer),
            matchConfidence: answer.confidence,
            status: ScanStatus.matchFound,
            clearError: true,
          );
          _scanTimer?.cancel();
          _scanTimer = null;
          return;
        }
      } catch (_) {
        // Proxy unavailable — silently fall through to noMatch
      }

      state = state.copyWith(
          clearMatch: true, status: ScanStatus.noMatch, clearError: true);
          
      // Auto-resume auto-scanning after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (state.status == ScanStatus.noMatch) {
          startScanning(camera, screenSize);
        }
      });
    } catch (e) {
      state = state.copyWith(error: 'OCR error: $e', status: ScanStatus.scanning);
    } finally {
      _processingFrame = false;
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _recognizer.close();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final scannerControllerProvider =
    StateNotifierProvider.autoDispose<ScannerController, ScannerState>((ref) {
  final dio = ref.watch(dioProvider);
  return ScannerController(ClaudeProxyService(dio));
});
