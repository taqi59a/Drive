import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/progress/data/models/attempt.dart';
import '../../../../features/training/data/models/question.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/providers/training_providers.dart';
import '../../../../shared/providers/streak_provider.dart';
import '../../../../shared/widgets/skeleton_widgets.dart';
import '../../../../shared/widgets/question_image_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/explanation_formatter.dart';


class _AppColors {
  static const primary = AppColors.primary;
}

// ---------------------------------------------------------------------------
// Practice Screen
// ---------------------------------------------------------------------------
class PracticeScreen extends ConsumerWidget {
  final String topicId;

  const PracticeScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(topicQuestionsProvider(topicId));
    return questionsAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const SkeletonQuestion()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (questions) {
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Practice')),
            body: const Center(child: Text('No questions for this topic yet.')),
          );
        }
        return _PracticeSession(allQuestions: questions, topicId: topicId);
      },
    );
  }
}

class _PracticeSession extends ConsumerStatefulWidget {
  final List<Question> allQuestions;
  final String topicId;

  const _PracticeSession({required this.allQuestions, required this.topicId});

  @override
  ConsumerState<_PracticeSession> createState() => _PracticeSessionState();
}

class _PracticeSessionState extends ConsumerState<_PracticeSession> {
  late final List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _isAnswerChecked = false;
  int _score = 0;
  bool _completed = false;
  DateTime _questionStart = DateTime.now();

  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Shuffle and cap at 15 questions per session
    final shuffled = List<Question>.from(widget.allQuestions)..shuffle();
    _questions = shuffled.take(15).toList();
  }

  Future<void> _toggleBookmark(Question q) async {
    final isar = await IsarService.getInstance();
    await isar.writeTxn(() async {
      q.isBookmarked = !q.isBookmarked;
      await isar.questions.put(q);
    });
    ref.invalidate(bookmarkedQuestionsProvider);
    setState(() {});
  }

  void _onAnswerTap(int index) {
    if (_isAnswerChecked) return;
    setState(() {
      _selectedAnswer = index;
    });
  }

  Future<void> _recordAttempt(
      Question q, int chosen, bool correct, int ms) async {
    final isar = await IsarService.getInstance();
    final attempt = Attempt()
      ..questionExternalId = q.externalId
      ..answeredAt = DateTime.now()
      ..chosenIndex = chosen
      ..wasCorrect = correct
      ..msToAnswer = ms
      ..mode = AttemptMode.practice;
    await isar.writeTxn(() => isar.attempts.put(attempt));
    ref.invalidate(statsProvider);
    ref.invalidate(topicProgressProvider(q.topicId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_completed) {
      return _CompletionScreen(
        score: _score,
        total: _questions.length,
        topicId: widget.topicId,
        onRetry: () {
          setState(() {
            _currentIndex = 0;
            _selectedAnswer = null;
            _isCorrect = null;
            _isAnswerChecked = false;
            _score = 0;
            _completed = false;
            _questionStart = DateTime.now();
          });
          _pageController.jumpToPage(0);
        },
        onBack: () => context.pop(),
      );
    }

    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, progress),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _QuestionPage(
                    question: _questions[index],
                    selectedAnswer: index == _currentIndex ? _selectedAnswer : null,
                    isChecked: index == _currentIndex ? _isAnswerChecked : false,
                    onAnswerTap: _onAnswerTap,
                  );
                },
              ),
            ),
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final question = _questions[_currentIndex];
    
    if (!_isAnswerChecked) {
      final isEnabled = _selectedAnswer != null;
      final buttonColor = isEnabled ? AppColors.success : (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
      final textColor = isEnabled ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade500);
      final shadowColor = isEnabled ? const Color(0xFF1B9B6A) : Colors.transparent;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  final correct = _selectedAnswer == question.correctIndex;
                  final ms = DateTime.now().difference(_questionStart).inMilliseconds;
                  setState(() {
                    _isAnswerChecked = true;
                    _isCorrect = correct;
                    if (correct) _score++;
                  });
                  _recordAttempt(question, _selectedAnswer!, correct, ms);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (isEnabled)
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                'CHECK',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final correct = _isCorrect ?? false;
    final panelBg = correct 
        ? (isDark ? const Color(0xFF143026) : const Color(0xFFD7F5EB))
        : (isDark ? const Color(0xFF381A1A) : const Color(0xFFFEECEC));
    final titleColor = correct ? const Color(0xFF1B9B6A) : const Color(0xFFD83A3A);
    final buttonColor = correct ? AppColors.success : AppColors.error;
    final buttonShadow = correct ? const Color(0xFF1B9B6A) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: correct ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: titleColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                correct ? 'You are correct!' : 'Correct Answer:',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: titleColor,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 6),
            Text(
              question.options[question.correctIndex].text,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          if (question.explanation != null && question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation.cleanExplanation,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              if (_currentIndex >= _questions.length - 1) {
                ref.read(streakProvider.notifier).recordStudySession();
                setState(() => _completed = true);
                return;
              }
              setState(() {
                _currentIndex++;
                _selectedAnswer = null;
                _isCorrect = null;
                _isAnswerChecked = false;
                _questionStart = DateTime.now();
              });
              _pageController.nextPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: buttonShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentIndex >= _questions.length - 1 ? 'SEE RESULTS' : 'CONTINUE',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _buildHeader(BuildContext context, double progress) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleBookmark(_questions[_currentIndex]),
                child: Icon(
                  _questions[_currentIndex].isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _questions[_currentIndex].isBookmarked
                      ? AppColors.accent
                      : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  l.questionOf(_currentIndex + 1, _questions.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B3A6B),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.outlineVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(_AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Question Page
// ---------------------------------------------------------------------------
class _QuestionPage extends StatelessWidget {
  final Question question;
  final int? selectedAnswer;
  final bool isChecked;
  final ValueChanged<int> onAnswerTap;

  const _QuestionPage({
    required this.question,
    required this.selectedAnswer,
    required this.isChecked,
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
          // Question card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionImageWidget(
                  code: question.imageAsset,
                  questionText: question.text,
                  topicId: question.topicId,
                  height: 150,
                ),
                const SizedBox(height: 12),
                Text(
                  question.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05, duration: 300.ms, curve: Curves.easeOut),
          const SizedBox(height: 24),
          // Answer options
          ...List.generate(question.options.length, (i) {
            return _AnswerTile(
              index: i,
              optionText: question.options[i].text,
              selectedAnswer: selectedAnswer,
              correctIndex: question.correctIndex,
              isChecked: isChecked,
              onTap: () => onAnswerTap(i),
            )
                .animate(delay: (i * 60 + 150).ms)
                .fadeIn(duration: 250.ms)
                .slideX(begin: 0.05, duration: 250.ms, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Answer Tile
// ---------------------------------------------------------------------------
class _AnswerTile extends StatelessWidget {
  final int index;
  final String optionText;
  final int? selectedAnswer;
  final int correctIndex;
  final bool isChecked;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.index,
    required this.optionText,
    required this.selectedAnswer,
    required this.correctIndex,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labels = ['A', 'B', 'C', 'D'];
    final isSelected = selectedAnswer == index;
    final isCorrect = index == correctIndex;

    Color borderColor;
    Color bgColor;
    Color textColor;
    Color labelBg;
    Color shadowColor;

    if (!isChecked) {
      if (isSelected) {
        borderColor = AppColors.primaryLight;
        bgColor = AppColors.primary.withOpacity(0.06);
        textColor = isDark ? Colors.white : AppColors.primary;
        labelBg = AppColors.primaryLight;
        shadowColor = AppColors.primary.withOpacity(0.2);
      } else {
        borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        bgColor = isDark ? AppColors.darkSurface : Colors.white;
        textColor = isDark ? AppColors.darkTextHigh : AppColors.lightTextHigh;
        labelBg = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        shadowColor = isDark ? Colors.black26 : Colors.grey.shade200;
      }
    } else {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.successLight;
        textColor = const Color(0xFF1B5E20);
        labelBg = AppColors.success;
        shadowColor = const Color(0xFF1B9B6A).withOpacity(0.4);
      } else if (isSelected) {
        borderColor = AppColors.error;
        bgColor = AppColors.errorLight;
        textColor = const Color(0xFFB71C1C);
        labelBg = AppColors.error;
        shadowColor = const Color(0xFFC62828).withOpacity(0.4);
      } else {
        borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        bgColor = isDark ? AppColors.darkSurface : Colors.white;
        textColor = isDark ? AppColors.darkTextLow : AppColors.lightTextLow;
        labelBg = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        shadowColor = Colors.transparent;
      }
    }

    return GestureDetector(
      onTap: isChecked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: GoogleFonts.plusJakartaSans(
                    color: (isSelected || (isChecked && isCorrect))
                        ? Colors.white
                        : (isDark ? AppColors.darkTextMed : AppColors.primary),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            if (isChecked && isCorrect)
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            if (isChecked && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completion Screen
// ---------------------------------------------------------------------------
class _CompletionScreen extends ConsumerWidget {
  final int score;
  final int total;
  final String topicId;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _CompletionScreen({
    required this.score,
    required this.total,
    required this.topicId,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pct = (score / total * 100).round();
    final passed = pct >= 86;

    // Find next topic for "Continue to Next Chapter"
    final topicsAsync = ref.watch(topicsProvider);
    final nextTopic = topicsAsync.whenOrNull(
      data: (topics) {
        final idx = topics.indexWhere((t) => t.externalId == topicId);
        if (idx != -1 && idx + 1 < topics.length) {
          return topics[idx + 1];
        }
        return null;
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: _AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score/$total',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.primary,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                passed ? '🎉 Great Job!' : 'Keep Practising',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'You answered $score out of $total questions correctly.'
                    : 'You got $score out of $total. Review the material and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const Spacer(),
              // Next Chapter button (if available and passed)
              if (nextTopic != null && passed) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop(); // Pop practice
                    context.push('/training/theory/${nextTopic.externalId}');
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Next Chapter',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l.tryAgain,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: _AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l.backToHome,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
