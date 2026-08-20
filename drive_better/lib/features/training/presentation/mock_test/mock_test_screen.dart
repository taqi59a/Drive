import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/question_image_widget.dart';
import '../../../../core/database/isar_service.dart';
import '../../../../features/progress/data/models/attempt.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/providers/training_providers.dart';
import 'mock_test_session.dart';

// ---------------------------------------------------------------------------
// Inline constants
// ---------------------------------------------------------------------------
class _AppColors {
  static const primary = Color(0xFF1B3A6B);
  static const accent = Color(0xFFF5A623);
}

class _Routes {
  static const mockTestResult = '/training/mock-test/result';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
// Wrapper: loads questions from Isar, then starts the test
class MockTestScreen extends ConsumerWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(mockTestQuestionsProvider);
    return questionsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (isarQuestions) {
        // Convert Isar Question → _Question for the existing UI
        if (isarQuestions.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Loading questions…', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => context.pop(), child: const Text('Go Back')),
                ],
              ),
            ),
          );
        }
        final questions = isarQuestions.map((q) => MockTestQuestion(
            externalId: q.externalId,
            text: q.text,
            options: q.options.map((o) => MockTestAnswerOption(text: o.text)).toList(),
            correctIndex: q.correctIndex,
            explanation: q.explanation,
            imageAsset: q.imageAsset,
            topicId: q.topicId,
            isSerious: q.isSerious,
          )).toList();
        return _MockTestSession(questions: questions);
      },
    );
  }
}

class _MockTestSession extends ConsumerStatefulWidget {
  final List<MockTestQuestion> questions;
  const _MockTestSession({required this.questions});

  @override
  ConsumerState<_MockTestSession> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends ConsumerState<_MockTestSession> {
  static const int _questionDurationSeconds = 15;

  int _currentIndex = 0;
  late final List<int?> _answers;
  late int _secondsLeft;
  Timer? _timer;
  bool _submitted = false;

  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.questions.length, null);
    _secondsLeft = _questionDurationSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _handleTimeOut();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerDisplay {
    return '00:${_secondsLeft.toString().padLeft(2, '0')}';
  }

  bool get _isTimeCritical => _secondsLeft <= 3;

  void _selectAnswer(int index) {
    setState(() => _answers[_currentIndex] = index);
  }

  void _goNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _secondsLeft = _questionDurationSeconds;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTimeOut() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _secondsLeft = _questionDurationSeconds;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();

    int points = 50;
    int correctCount = 0;
    int minorWrong = 0;
    int seriousWrong = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final answer = _answers[i];
      final isCorrect = answer == q.correctIndex;
      if (isCorrect) {
        correctCount++;
      } else {
        if (q.isSerious) {
          seriousWrong++;
          points -= 5;
        } else {
          minorWrong++;
          points -= 1;
        }
      }
    }
    points = points.clamp(0, 50);

    final secondsTaken = (widget.questions.length * _questionDurationSeconds) - 
        ((widget.questions.length - 1 - _currentIndex) * _questionDurationSeconds + _secondsLeft);

    _recordAttempts(secondsTaken);

    final session = MockTestSession(
      score: points,
      total: widget.questions.length,
      secondsTaken: secondsTaken,
      answers: List<int?>.from(_answers),
      questions: widget.questions,
      correctCount: correctCount,
      minorWrong: minorWrong,
      seriousWrong: seriousWrong,
    );

    if (mounted) {
      context.pushReplacement(_Routes.mockTestResult, extra: session);
    }
  }

  Future<void> _recordAttempts(int totalSeconds) async {
    final isar = await IsarService.getInstance();
    final now = DateTime.now();
    final perQ = totalSeconds > 0
        ? (totalSeconds * 1000 / widget.questions.length).round()
        : 0;
    final attempts = <Attempt>[];
    for (int i = 0; i < widget.questions.length; i++) {
      final chosen = _answers[i];
      if (chosen == null) continue;
      final q = widget.questions[i];
      if (q.externalId.isEmpty) continue;
      attempts.add(Attempt()
        ..questionExternalId = q.externalId
        ..answeredAt = now
        ..chosenIndex = chosen
        ..wasCorrect = chosen == q.correctIndex
        ..msToAnswer = perQ
        ..mode = AttemptMode.mockTest);
    }
    if (attempts.isNotEmpty) {
      await isar.writeTxn(() => isar.attempts.putAll(attempts));
      ref.invalidate(statsProvider);
    }
  }

  Future<bool> _onWillPop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Mock Test?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLast = _currentIndex == widget.questions.length - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop() && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: _AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final ok = await _onWillPop();
              if (ok && context.mounted) context.pop();
            },
          ),
          title: Text(
            l.mockTest,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            // Timer
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isTimeCritical
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: _isTimeCritical
                    ? Border.all(color: Colors.red.shade300, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _isTimeCritical ? Colors.red.shade200 : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timerDisplay,
                    style: TextStyle(
                      color: _isTimeCritical ? Colors.red.shade200 : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            // Question count
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 4),
                child: Text(
                  '${_currentIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress strip
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              minHeight: 3,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isTimeCritical ? Colors.red.shade300 : _AppColors.accent,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return _MockQuestionPage(
                    question: widget.questions[index],
                    questionNumber: index + 1,
                    selectedAnswer: _answers[index],
                    onAnswerTap: (i) {
                      _selectAnswer(i);
                    },
                  );
                },
              ),
            ),
            // Bottom navigation
            Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLast ? () => _submit() : _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast
                            ? const Color(0xFF2E7D32)
                            : _AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLast ? 'Submit Test' : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock question page
// ---------------------------------------------------------------------------
class _MockQuestionPage extends StatelessWidget {
  final MockTestQuestion question;
  final int questionNumber;
  final int? selectedAnswer;
  final ValueChanged<int> onAnswerTap;

  const _MockQuestionPage({
    required this.question,
    required this.questionNumber,
    required this.selectedAnswer,
    required this.onAnswerTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $questionNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.text,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                QuestionImageWidget(
                  code: question.imageAsset,
                  questionText: question.text,
                  topicId: question.topicId,
                  height: 150,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(question.options.length, (i) {
            final labels = ['A', 'B', 'C', 'D'];
            final isSelected = selectedAnswer == i;

            return GestureDetector(
              onTap: () => onAnswerTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _AppColors.primary.withValues(alpha: 0.06)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _AppColors.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _AppColors.primary
                            : _AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : _AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[i].text,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.87),
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: _AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
