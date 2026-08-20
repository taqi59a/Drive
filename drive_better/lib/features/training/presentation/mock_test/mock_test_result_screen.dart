import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mock_test_session.dart';

// ---------------------------------------------------------------------------
// Inline constants
// ---------------------------------------------------------------------------
class _AppColors {
  static const primary = Color(0xFF1B3A6B);
  static const accent = Color(0xFFF5A623);
}

class _Routes {
  static const mockTest = '/training/mock-test';
  static const topics = '/training';
}

// ---------------------------------------------------------------------------
// Result Screen
// ---------------------------------------------------------------------------
class MockTestResultScreen extends ConsumerStatefulWidget {
  final dynamic session;

  const MockTestResultScreen({super.key, required this.session});

  @override
  ConsumerState<MockTestResultScreen> createState() =>
      _MockTestResultScreenState();
}

class _MockTestResultScreenState extends ConsumerState<MockTestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  MockTestSession? get _session =>
      widget.session is MockTestSession ? widget.session as MockTestSession : null;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ringController.forward();
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  List<String> _areasToImprove(MockTestSession s) {
    final buckets = <String, List<bool>>{
      'Road Signs': [],
      'Hazard Awareness': [],
      'Motorway Rules': [],
      'Vehicle Safety': [],
      'Rules of the Road': [],
      'Road Works': [],
      'Accidents & First Aid': [],
      'Environment & Eco': [],
    };

    final topicNames = {
      'road_signs': 'Road Signs',
      'hazard_awareness': 'Hazard Awareness',
      'motorway_rules': 'Motorway Rules',
      'vehicle_safety': 'Vehicle Safety',
      'rules_of_road': 'Rules of the Road',
      'road_works': 'Road Works',
      'accidents': 'Accidents & First Aid',
      'environment': 'Environment & Eco',
    };

    for (int i = 0; i < s.questions.length; i++) {
      final q = s.questions[i];
      final correct = s.answers[i] == q.correctIndex;
      final tName = topicNames[q.topicId];
      if (tName != null && buckets.containsKey(tName)) {
        buckets[tName]!.add(correct);
      }
    }

    return buckets.entries
        .where((e) {
          final attempts = e.value.length;
          if (attempts == 0) return false;
          final wrong = e.value.where((b) => !b).length;
          return (wrong / attempts) > 0.3; // >30% wrong answers in topic
        })
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = _session;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No session data found.')),
      );
    }

    final pct = (s.score / s.total * 100).round();
    final passed = s.score >= 41;
    final incorrect = s.total - s.correctCount;
    final areas = _areasToImprove(s);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Score ring
              Center(
                child: AnimatedBuilder(
                  animation: _ringAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(180, 180),
                      painter: _ScoreRingPainter(
                        progress: _ringAnimation.value * (s.score / s.total),
                        passed: passed,
                      ),
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${s.score}/${s.total}',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Points',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // PASSED / FAILED badge
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: (passed
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828))
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    passed ? l.passed : l.failed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      delay: 600.ms,
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(delay: 600.ms),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  passed ? l.passedMessage : l.failedMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // Stats row
              Row(
                children: [
                  _StatCard(
                    label: l.correct,
                    value: '${s.correctCount}',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: l.incorrect,
                    value: '$incorrect',
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFC62828),
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: l.timeTaken,
                    value: _formatTime(s.secondsTaken),
                    icon: Icons.timer_outlined,
                    color: _AppColors.primary,
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Accuracy
              _InfoTile(
                icon: Icons.analytics_outlined,
                label: l.accuracy,
                value: '$pct%',
                color: _AppColors.accent,
              ).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: 10),

              // Score breakdown card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_turned_in_outlined,
                            color: _AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Score Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total points', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                        Text('${s.score} / 50', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Minor mistakes (1 pt deduction)', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                        Text('${s.minorWrong}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Serious mistakes (5 pt deduction)', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                        Text('${s.seriousWrong}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: s.seriousWrong >= 2 ? const Color(0xFFC62828) : null)),
                      ],
                    ),
                    if (s.seriousWrong >= 2) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF5350), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Failed: 2 or more serious mistakes.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFC62828),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 950.ms),
              const SizedBox(height: 10),

              // Areas to improve
              if (areas.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: _AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Areas to Improve',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...areas.map(
                        (area) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                area,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.87),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 16),

              // Buttons
              ElevatedButton.icon(
                onPressed: () => context.pushReplacement(_Routes.mockTest),
                icon: const Icon(Icons.refresh),
                label: Text(
                  l.tryAgain,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showReviewSheet(context, s),
                icon: const Icon(Icons.list_alt),
                label: Text(
                  l.reviewAnswers,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _AppColors.primary,
                  side: const BorderSide(color: _AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ).animate().fadeIn(delay: 1150.ms).slideY(begin: 0.1),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(_Routes.topics),
                child: Text(
                  l.backToHome,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, MockTestSession s) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Answer Review',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: s.questions.length,
                  itemBuilder: (_, i) {
                    final q = s.questions[i];
                    final selected = s.answers[i];
                    final isCorrect = selected == q.correctIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Q${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isCorrect
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: isCorrect
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            q.text,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Correct: ${q.options[q.correctIndex].text}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isCorrect && selected != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Your answer: ${q.options[selected].text}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFC62828),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score Ring Painter
// ---------------------------------------------------------------------------
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final bool passed;

  _ScoreRingPainter({required this.progress, required this.passed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
