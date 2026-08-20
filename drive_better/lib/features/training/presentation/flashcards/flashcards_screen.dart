import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/providers/training_providers.dart';
import '../../../../core/utils/explanation_formatter.dart';


// Inline color constants
class _AppColors {
  static const primary = Color(0xFF1B3A6B);
  static const accent = Color(0xFFF5A623);
  static const gotItGreen = Color(0xFF22C55E);
  static const reviewRed = Color(0xFFEF4444);
  static const gotItBg = Color(0xFFDCFCE7);
  static const reviewBg = Color(0xFFFEE2E2);
}

// Inline route constants
class _Routes {
  static String practiceRoute(String id) => '/training/practice/$id';
  static String flashcardsRoute(String id) => '/training/flashcards/$id';
  static const mockTest = '/training/mock-test';
}

class _FlashCard {
  final String id;
  final String question;
  final String answer;
  final String? explanation;

  const _FlashCard({
    required this.id,
    required this.question,
    required this.answer,
    this.explanation,
  });
}

List<_FlashCard> _buildFlashcards(String topicId) {
  return [
    const _FlashCard(
      id: 'fc1',
      question: 'What does a red circular sign indicate?',
      answer: 'A prohibition or restriction',
      explanation:
          'Red circular signs prohibit or restrict actions. Examples include speed limits and no entry signs.',
    ),
    const _FlashCard(
      id: 'fc2',
      question: 'What shape are warning signs in Belgium?',
      answer: 'Triangular with a red border',
      explanation:
          'Warning signs in Belgium are triangular with a red border. They alert drivers to hazards ahead such as bends, crossings, or junctions.',
    ),
    const _FlashCard(
      id: 'fc3',
      question: 'What does a blue circular sign mean?',
      answer: 'A mandatory positive instruction',
      explanation:
          'Blue circular signs give positive instructions — for example, "turn left" or "keep left". They must be obeyed.',
    ),
    const _FlashCard(
      id: 'fc4',
      question: 'What does a flashing amber beacon on a vehicle mean?',
      answer: 'The vehicle is a slow-moving or hazardous vehicle',
      explanation:
          'Flashing amber beacons indicate a slow-moving vehicle or one that might be a hazard — such as road maintenance vehicles or wide loads.',
    ),
    const _FlashCard(
      id: 'fc5',
      question: 'What is shown by a sign with a red triangle and a "!" symbol?',
      answer: 'A general hazard or danger ahead',
      explanation:
          'The exclamation mark inside a red triangle is a general warning sign indicating a hazard not covered by other specific signs.',
    ),
    const _FlashCard(
      id: 'fc6',
      question: 'What does a "no through road" sign look like?',
      answer: 'A rectangular blue sign with a T-bar symbol',
      explanation:
          'A blue rectangular sign showing a bar at the end of a road symbol indicates that there is no through road ahead — it is a dead end.',
    ),
    const _FlashCard(
      id: 'fc7',
      question: 'What colour are motorway signs in Belgium?',
      answer: 'Blue with white text',
      explanation:
          'Motorway signs in Belgium have a blue background with white text. Regional route signs are green, and local direction signs are white.',
    ),
    const _FlashCard(
      id: 'fc8',
      question: 'What does a yellow diamond road marking mean?',
      answer: 'School keep clear — no stopping',
      explanation:
          'Yellow zig-zag lines with a diamond marking indicate a school entrance zone. Parking or stopping is not permitted at any time.',
    ),
    const _FlashCard(
      id: 'fc9',
      question: 'What does a sign showing a red ring around two arrows facing each other mean?',
      answer: 'No overtaking',
      explanation:
          'This circular red and white sign prohibits overtaking. Drivers must not pass other moving vehicles while this sign applies.',
    ),
    const _FlashCard(
      id: 'fc10',
      question: 'What does a "give way" sign look like?',
      answer: 'An inverted red triangle (pointing downward)',
      explanation:
          'The give way sign is a downward-pointing triangle with a red border. It means you must give way to traffic on the road you are entering.',
    ),
  ];
}

enum _SwipeDirection { none, left, right }

class FlashcardsScreen extends ConsumerStatefulWidget {
  final String topicId;
  const FlashcardsScreen({super.key, required this.topicId});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with TickerProviderStateMixin {
  List<_FlashCard>? _loadedCards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _gotItCount = 0;
  int _reviewCount = 0;
  bool _completed = false;

  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Swipe drag state
  Offset _dragOffset = Offset.zero;
  _SwipeDirection _swipeHint = _SwipeDirection.none;

  // Card exit animation
  late AnimationController _exitController;
  late Animation<Offset> _exitAnimation;
  bool _exiting = false;
  _SwipeDirection _exitDirection = _SwipeDirection.none;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_exitController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.status == AnimationStatus.completed) {
      _flipController.reverse();
      setState(() => _isFlipped = false);
    } else {
      _flipController.forward();
      setState(() => _isFlipped = true);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += Offset(details.delta.dx, details.delta.dy * 0.3);
      if (_dragOffset.dx > 30) {
        _swipeHint = _SwipeDirection.right;
      } else if (_dragOffset.dx < -30) {
        _swipeHint = _SwipeDirection.left;
      } else {
        _swipeHint = _SwipeDirection.none;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    const threshold = 80.0;

    if (_dragOffset.dx > threshold || velocity > 400) {
      _swipeCard(_SwipeDirection.right);
    } else if (_dragOffset.dx < -threshold || velocity < -400) {
      _swipeCard(_SwipeDirection.left);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _swipeHint = _SwipeDirection.none;
      });
    }
  }

  void _swipeCard(_SwipeDirection direction) async {
    final screenWidth = MediaQuery.of(context).size.width;
    _exitDirection = direction;
    _exiting = true;

    _exitAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(
        direction == _SwipeDirection.right ? screenWidth * 1.5 : -screenWidth * 1.5,
        _dragOffset.dy,
      ),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _exitController.forward(from: 0);

    if (direction == _SwipeDirection.right) {
      setState(() => _gotItCount++);
    } else {
      setState(() => _reviewCount++);
    }

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    final nextIndex = _currentIndex + 1;
    final cards = _loadedCards ?? [];
    if (nextIndex >= cards.length) {
      setState(() => _completed = true);
    } else {
      setState(() {
        _currentIndex = nextIndex;
        _isFlipped = false;
        _dragOffset = Offset.zero;
        _swipeHint = _SwipeDirection.none;
        _exiting = false;
        _exitDirection = _SwipeDirection.none;
      });
      _flipController.reset();
      _exitController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(topicQuestionsProvider(widget.topicId));
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return questionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: Text('Error loading questions: $e')),
      ),
      data: (questions) {
        if (_loadedCards == null) {
          final mapped = questions.map((q) {
            String answer = '';
            if (q.options.isNotEmpty && q.correctIndex >= 0 && q.correctIndex < q.options.length) {
              answer = q.options[q.correctIndex].text;
            } else {
              answer = 'Unknown';
            }
            return _FlashCard(
              id: q.externalId,
              question: q.text,
              answer: answer,
              explanation: q.explanation,
            );
          }).toList();

          if (mapped.isEmpty) {
            mapped.addAll(_buildFlashcards(widget.topicId));
          } else {
            mapped.shuffle();
          }

          Future.microtask(() {
            if (mounted) {
              setState(() {
                _loadedCards = mapped;
              });
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final cards = _loadedCards!;
        if (cards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l.flashcardsTitle)),
            body: const Center(child: Text('No flashcards available.')),
          );
        }

        if (_completed) {
          return _CompletionView(
            total: cards.length,
            gotIt: _gotItCount,
            review: _reviewCount,
            onRestart: () {
              setState(() {
                _loadedCards = null;
                _currentIndex = 0;
                _gotItCount = 0;
                _reviewCount = 0;
                _isFlipped = false;
                _completed = false;
                _dragOffset = Offset.zero;
                _swipeHint = _SwipeDirection.none;
                _exiting = false;
              });
              _flipController.reset();
              _exitController.reset();
            },
            onClose: () => context.pop(),
          );
        }

        final card = cards[_currentIndex];
        final progress = _currentIndex / cards.length;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text(
                  '${_currentIndex + 1} / ${cards.length}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.flashcardsTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.outlineVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_AppColors.accent),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildSwipeHintRow(l),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: _flipCard,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: AnimatedBuilder(
                        animation: _exiting ? _exitController : _flipController,
                        builder: (context, child) {
                          Offset cardOffset = _exiting
                              ? _exitAnimation.value
                              : _dragOffset;
                          double rotation = _exiting
                              ? 0
                              : _dragOffset.dx / 300 * 0.08;

                          return Transform.translate(
                            offset: cardOffset,
                            child: Transform.rotate(
                              angle: rotation,
                              child: _buildFlipCard(card),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _buildHintText(l, theme),
                _buildSwipeButtons(l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeHintRow(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: _swipeHint == _SwipeDirection.left ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _AppColors.reviewBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _AppColors.reviewRed, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      color: _AppColors.reviewRed, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    l.reviewAgain,
                    style: const TextStyle(
                      color: _AppColors.reviewRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _swipeHint == _SwipeDirection.right ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _AppColors.gotItBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _AppColors.gotItGreen, width: 1.5),
              ),
              child: Row(
                children: [
                  Text(
                    l.gotIt,
                    style: const TextStyle(
                      color: _AppColors.gotItGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      color: _AppColors.gotItGreen, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(_FlashCard card) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * math.pi;
        final isShowingFront = angle < math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isShowingFront
              ? _CardFace(
                  text: card.question,
                  isFront: true,
                  tapHint: 'Tap to reveal answer',
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _CardFace(
                    text: card.answer,
                    isFront: false,
                    explanation: card.explanation,
                    tapHint: 'Tap to see question',
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHintText(AppLocalizations l, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded,
              size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
          const SizedBox(width: 6),
          Text(
            _isFlipped
                ? 'Swipe right = Got it  ·  Swipe left = Review'
                : l.tapToFlip,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButtons(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: _SwipeButton(
              label: l.reviewAgain,
              icon: Icons.replay_rounded,
              color: _AppColors.reviewRed,
              bgColor: _AppColors.reviewBg,
              onTap: () => _swipeCard(_SwipeDirection.left),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SwipeButton(
              label: l.gotIt,
              icon: Icons.check_rounded,
              color: _AppColors.gotItGreen,
              bgColor: _AppColors.gotItBg,
              onTap: () => _swipeCard(_SwipeDirection.right),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final bool isFront;
  final String? explanation;
  final String tapHint;

  const _CardFace({
    required this.text,
    required this.isFront,
    this.explanation,
    required this.tapHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFront ? theme.colorScheme.surface : _AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isFront
                    ? _AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFront ? 'QUESTION' : 'ANSWER',
                style: TextStyle(
                  color: isFront
                      ? _AppColors.primary
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              style: TextStyle(
                color: isFront ? theme.colorScheme.onSurface : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (explanation != null && !isFront) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
              Text(
                explanation.cleanExplanation,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: isFront
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 5),
                Text(
                  tapHint,
                  style: TextStyle(
                    color: isFront
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _SwipeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final int total;
  final int gotIt;
  final int review;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const _CompletionView({
    required this.total,
    required this.gotIt,
    required this.review,
    required this.onRestart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pct = total > 0 ? (gotIt / total * 100).round() : 0;

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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.style_rounded,
                  color: _AppColors.primary,
                  size: 48,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Session Complete!',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'You knew $pct% of the cards',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 15,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatPill(
                    label: l.gotIt,
                    count: gotIt,
                    color: _AppColors.gotItGreen,
                    bgColor: _AppColors.gotItBg,
                  ),
                  const SizedBox(width: 16),
                  _StatPill(
                    label: l.reviewAgain,
                    count: review,
                    color: _AppColors.reviewRed,
                    bgColor: _AppColors.reviewBg,
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'Restart Cards',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _AppColors.primary,
                    side: const BorderSide(color: _AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
