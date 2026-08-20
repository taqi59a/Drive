import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/training/data/models/topic.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/providers/training_providers.dart';
import '../../../../shared/widgets/skeleton_widgets.dart';

// ---------------------------------------------------------------------------
// Chapter read state provider
// ---------------------------------------------------------------------------
final allChaptersReadProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final topics = await ref.watch(topicsProvider.future);
  final result = <String, bool>{};
  for (final t in topics) {
    result[t.externalId] = prefs.getBool('chapter_read_${t.externalId}') ?? false;
  }
  return result;
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
IconData _iconFromName(String? name) {
  switch (name) {
    case 'sign_post':
      return Icons.signpost;
    case 'warning':
      return Icons.warning_amber_rounded;
    case 'directions':
      return Icons.directions;
    case 'car_repair':
      return Icons.car_repair;
    case 'rule':
      return Icons.rule;
    case 'construction':
      return Icons.construction;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'eco':
      return Icons.eco;
    case 'info':
      return Icons.info_outline_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

Color _colorFromHex(String? hex) {
  if (hex == null) return AppColors.primary;
  try {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return AppColors.primary;
  }
}

String _formatTitle(String title) {
  final lowerWords = {
    'or', 'and', 'the', 'a', 'an', 'of', 'in', 'on', 'to', 'for', 'with',
    'at', 'by'
  };
  final words = title.toLowerCase().split(' ');
  return words.asMap().entries.map((entry) {
    final word = entry.value;
    final idx = entry.key;
    if (idx == 0 || !lowerWords.contains(word)) {
      return word.isEmpty
          ? ''
          : '${word[0].toUpperCase()}${word.substring(1)}';
    }
    return word;
  }).join(' ');
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final chaptersReadAsync = ref.watch(allChaptersReadProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: topicsAsync.when(
        loading: () => const SkeletonTopicsGrid(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (topics) {
          final chaptersRead = chaptersReadAsync.valueOrNull ?? {};

          // Calculate overall progress
          final readCount =
              chaptersRead.values.where((v) => v).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, readCount, topics.length),
              _buildProgressHeader(context, theme, readCount, topics.length),
              _buildMockTestBanner(context, theme, readCount),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final topic = topics[index];
                      final isRead =
                          chaptersRead[topic.externalId] ?? false;
                      final chapterNum = index + 1;

                      return _ChapterCard(
                        topic: topic,
                        chapterNum: chapterNum,
                        isRead: isRead,
                        totalChapters: topics.length,
                      )
                          .animate(delay: (index * 50).ms)
                          .fadeIn(duration: 350.ms)
                          .slideX(
                              begin: 0.05,
                              duration: 350.ms,
                              curve: Curves.easeOut);
                    },
                    childCount: topics.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, int readCount, int totalCount) {
    final l = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l.topicsTitle,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B3A6B), Color(0xFF2A5298)],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildProgressHeader(
      BuildContext context, ThemeData theme, int readCount, int totalCount) {
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalCount == 0 ? 0.0 : readCount / totalCount;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress circle
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor:
                        AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$readCount of $totalCount chapters completed',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms),
    );
  }

  SliverToBoxAdapter _buildMockTestBanner(
      BuildContext context, ThemeData theme, int readCount) {
    final l = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: GestureDetector(
          onTap: () => context.push(Routes.mockTest),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5A623), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.timer, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.mockTest,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.mockTestSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, duration: 350.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter Card
// ---------------------------------------------------------------------------
class _ChapterCard extends ConsumerWidget {
  final Topic topic;
  final int chapterNum;
  final bool isRead;
  final int totalChapters;

  const _ChapterCard({
    required this.topic,
    required this.chapterNum,
    required this.isRead,
    required this.totalChapters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _colorFromHex(topic.colorHex);
    final icon = _iconFromName(topic.iconName);
    final progressAsync =
        ref.watch(topicProgressProvider(topic.externalId));
    final progress = progressAsync.valueOrNull ?? 0.0;
    final completed = (progress * topic.questionCount).round();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isRead
            ? Border.all(color: AppColors.success.withOpacity(0.3), width: 1.5)
            : Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : Colors.grey.shade200,
                width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () =>
              context.push(Routes.theoryRoute(topic.externalId)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Chapter icon/number
                _buildChapterBadge(color, icon, isDark),
                const SizedBox(width: 14),
                // Chapter details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter number label
                      Text(
                        'CHAPTER $chapterNum',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color.withOpacity(0.7),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Title
                      Text(
                        _formatTitle(topic.title),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Progress row
                      Row(
                        children: [
                          if (isRead) ...[
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Read',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                            if (topic.questionCount > 0) ...[
                              Text(
                                '  •  ',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                          if (topic.questionCount > 0)
                            Text(
                              '$completed/${topic.questionCount} questions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.45),
                              ),
                            ),
                          if (topic.questionCount == 0 && !isRead)
                            Text(
                              'Theory only',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.45),
                              ),
                            ),
                        ],
                      ),
                      // Progress bar
                      if (topic.questionCount > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action buttons column
                _buildActions(context, theme, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterBadge(Color color, IconData icon, bool isDark) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.success.withOpacity(0.1)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: isRead
          ? const Icon(Icons.check_rounded,
              color: AppColors.success, size: 26)
          : Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildActions(
      BuildContext context, ThemeData theme, bool isDark) {
    if (topic.questionCount == 0) {
      if (isRead) {
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 24,
        );
      }
      return Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        size: 24,
      );
    }

    if (isRead) {
      return GestureDetector(
        onTap: () => context.push(Routes.practiceRoute(topic.externalId)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDeep.withOpacity(0.4),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 2),
              Text(
                'QUIZ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      color: theme.colorScheme.onSurface.withOpacity(0.3),
      size: 24,
    );
  }
}
