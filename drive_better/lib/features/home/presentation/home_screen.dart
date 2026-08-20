import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/training_providers.dart';
import '../../../shared/providers/sheet_sync_provider.dart';
import '../../../shared/providers/streak_provider.dart';
import '../../../shared/providers/isar_provider.dart';
import '../../../core/database/db_seeder.dart';
import '../../../shared/widgets/skeleton_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuestionsAsync = ref.watch(totalQuestionsProvider);

    return totalQuestionsAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, __) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Failed to load database: $e',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.red),
            ),
          ),
        ),
      ),
      data: (total) {
        if (total == 0) {
          return const FirstTimeSyncScreen();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GreetingHeader()
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
                        _StreakWarningBanner(),
                        const SizedBox(height: 20),
                        _HeroStatsCard()
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
                        const SizedBox(height: 28),
                        _SectionLabel(label: 'Quick Actions'),
                        const SizedBox(height: 12),
                        _QuickActionsGrid(),
                        const SizedBox(height: 28),
                        _SectionLabel(label: 'Continue Learning'),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: _TopicCarousel(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Greeting Header ──────────────────────────────────────────────────────────

class _GreetingHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final dateStr = DateFormat('EEEE, d MMMM').format(now);
    final streakAsync = ref.watch(streakProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Driver! 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        streakAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (streak) {
            if (streak.streakCount == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.2),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${streak.streakCount}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _StreakWarningBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) {
        if (streak.streakCount == 0) return const SizedBox.shrink();

        final warning = !streak.studiedToday;
        final bgColor = warning 
            ? (isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0))
            : (isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : const Color(0xFFE8F5E9));
        final borderColor = warning 
            ? Colors.orange.withOpacity(0.6)
            : Colors.green.withOpacity(0.6);
        final titleColor = warning 
            ? (isDark ? Colors.orangeAccent : const Color(0xFFE65100))
            : (isDark ? Colors.greenAccent : const Color(0xFF1B5E20));

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 28),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(duration: 800.ms, curve: Curves.easeInOut),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warning ? 'Streak at risk!' : 'Streak saved!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      warning
                          ? 'Complete a lesson today or your ${streak.streakCount}-day streak will be broken!'
                          : 'You kept your ${streak.streakCount}-day streak alive today! See you tomorrow.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0);
      },
    );
  }
}

// ─── Hero Stats Card ──────────────────────────────────────────────────────────

class _HeroStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    return statsAsync.when(
      loading: () => const SkeletonStatsCard(),
      error: (_, __) => _buildCard(context, null),
      data: (stats) => _buildCard(context, stats),
    );
  }

  Widget _buildCard(BuildContext context, StatsData? stats) {
    final attempted = stats?.attempted ?? 0;
    final total = stats?.total ?? 0;
    final passRate = stats?.passRate ?? 0;
    final progress = stats?.overallProgress ?? 0;
    final remaining = stats?.remaining ?? 0;
    final pct = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      attempted > 0 ? 'On a roll!' : 'Start studying!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                attempted > 0 ? 'Keep it up! 🎯' : 'Tap to begin 🚀',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatItem(
                label: 'Questions Done',
                value: '$attempted',
                total: '/$total',
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              _StatItem(
                label: 'Pass Rate',
                value: '${(passRate * 100).toInt()}%',
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              _StatItem(
                label: 'Remaining',
                value: '$remaining',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? total;

  const _StatItem({
    required this.label,
    required this.value,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (total != null)
                Text(
                  total!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ─── Quick Actions Grid ───────────────────────────────────────────────────────

class _QuickActionsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction(
        label: 'Mock Test',
        icon: Icons.timer_rounded,
        color: AppColors.primary,
        bgColor: AppColors.primary.withOpacity(0.08),
        onTap: () => context.go(Routes.mockTest),
      ),
      _QuickAction(
        label: 'Practice',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFF7C3AED).withOpacity(0.08),
        onTap: () => context.go(Routes.topics),
      ),
      _QuickAction(
        label: 'Flashcards',
        icon: Icons.layers_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFF059669).withOpacity(0.08),
        onTap: () => context.go(Routes.topics),
      ),
      _QuickAction(
        label: 'Scan Q&A',
        icon: Icons.document_scanner_rounded,
        color: AppColors.accent,
        bgColor: AppColors.accent.withOpacity(0.08),
        onTap: () => context.go(Routes.scanner),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions
          .asMap()
          .entries
          .map(
            (entry) => _QuickActionCard(action: entry.value)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 160 + entry.key * 60), duration: 350.ms)
                .slideY(
                  begin: 0.12,
                  end: 0,
                  delay: Duration(milliseconds: 160 + entry.key * 60),
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: action.color.withOpacity(0.1),
        highlightColor: action.color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Topic Carousel ───────────────────────────────────────────────────────────

class _TopicCarousel extends ConsumerWidget {
  static Color _colorFromHex(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  static IconData _iconFromName(String? name) {
    switch (name) {
      case 'sign_post': return Icons.signpost;
      case 'warning': return Icons.warning_amber_rounded;
      case 'directions': return Icons.directions;
      case 'car_repair': return Icons.car_repair;
      case 'rule': return Icons.rule;
      case 'construction': return Icons.construction;
      case 'local_hospital': return Icons.local_hospital;
      case 'eco': return Icons.eco;
      default: return Icons.menu_book_rounded;
    }
  }

  static String _formatTitle(String title) {
    final lowerWords = {
      'or', 'and', 'the', 'a', 'an', 'of', 'in', 'on', 'to', 'for', 'with',
      'at', 'by'
    };
    final words = title.toLowerCase().split(' ');
    return words.asMap().entries.map((entry) {
      final word = entry.value;
      final idx = entry.key;
      if (idx == 0 || !lowerWords.contains(word)) {
        return word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}';
      }
      return word;
    }).join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    return topicsAsync.when(
      loading: () => const SkeletonTopicCarousel(),
      error: (_, __) => const SizedBox.shrink(),
      data: (topics) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final hasQuestions = topic.questionCount > 0;

          final progressAsync = hasQuestions
              ? ref.watch(topicProgressProvider(topic.externalId))
              : const AsyncValue.data(0.0);
          final progress = progressAsync.valueOrNull ?? 0.0;

          final isReadAsync = ref.watch(chapterReadProvider(topic.externalId));
          final isRead = isReadAsync.valueOrNull ?? false;

          final color = _colorFromHex(topic.colorHex);
          final bgColor = color.withValues(alpha: 0.1);
          final icon = _iconFromName(topic.iconName);

          final itemProgress = hasQuestions ? progress : (isRead ? 1.0 : 0.0);
          final pct = (itemProgress * 100).toInt();
          final cs = Theme.of(context).colorScheme;

          final doneText = hasQuestions
              ? '${(progress * topic.questionCount).round()} of ${topic.questionCount} done'
              : (isRead ? 'Theory Read' : 'Theory Unread');

          return GestureDetector(
            onTap: () {
              if (!hasQuestions || !isRead) {
                context.push(Routes.theoryRoute(topic.externalId));
              } else {
                context.push(Routes.practiceRoute(topic.externalId));
              }
            },
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: pct > 0
                              ? AppColors.success.withValues(alpha: 0.12)
                              : cs.onSurface.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pct > 0
                                ? AppColors.success
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTitle(topic.title),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doneText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: itemProgress,
                      minHeight: 6,
                      backgroundColor: bgColor,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 350 + index * 80), duration: 350.ms)
                .slideX(
                  begin: 0.1,
                  end: 0,
                  delay: Duration(milliseconds: 350 + index * 80),
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }
}

class FirstTimeSyncScreen extends ConsumerWidget {
  const FirstTimeSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1E1E2E),
                    const Color(0xFF151522),
                  ]
                : [
                    AppColors.primary.withOpacity(0.06),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Icon Illustration
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_download_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),

                // Welcome Header
                Text(
                  'Welcome to Drive Better! 🚗',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),
                const SizedBox(height: 8),

                // Description
                Text(
                  'To begin preparing for your Belgian Driving Theory Test, let\'s download the official questions bank from the database server.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: cs.onSurface.withOpacity(0.65),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0, delay: 300.ms),
                const SizedBox(height: 28),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252538) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, Icons.menu_book_rounded, '320 Belgian Theory Questions', 'Strictly aligned with Belgian traffic regulations (Zone 30, priority-to-the-right, etc.).'),
                      const SizedBox(height: 16),
                      _buildInfoRow(context, Icons.star_rounded, 'Serious Violations Scoring', 'Points-based mock test system: -5 points for serious mistakes, -1 for minor.'),
                      const SizedBox(height: 16),
                      _buildInfoRow(context, Icons.image_rounded, 'Visual Situations & Signs', 'Practice with real-world road sign SVGs and traffic scenarios.'),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, delay: 400.ms),
                const SizedBox(height: 32),

                // Status Message and Loading Progress
                if (syncState.isSyncing || syncState.statusMessage != null) ...[
                  SelectableText(
                    syncState.statusMessage ?? 'Preparing sync...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: syncState.statusMessage?.startsWith('✗') == true
                          ? Colors.red
                          : AppColors.primary,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 16),
                  if (syncState.isSyncing)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ).animate().fadeIn(),
                  const SizedBox(height: 24),
                ],

                // Action Button
                if (!syncState.isSyncing)
                  FilledButton(
                    onPressed: () {
                      ref.read(syncProvider.notifier).forceSync();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    child: Text(
                      syncState.statusMessage?.startsWith('✗') == true
                          ? 'Retry Download'
                          : 'Download Questions Bank',
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String desc) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
