import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/training_providers.dart';
import '../../../shared/providers/streak_provider.dart';


// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum _DateRange { thisWeek, thisMonth, allTime }

const _barData = [14, 28, 9, 42, 35, 51, 38]; // Mon–Sun
const _barLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  _DateRange _selectedRange = _DateRange.thisWeek;
  int? _touchedBarIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textHigh = theme.colorScheme.onSurface;
    final textMed = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final cardColor = theme.colorScheme.surface;
    final bgColor = theme.scaffoldBackgroundColor;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          l.progressTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textHigh,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.bookmarks),
            icon: Icon(Icons.bookmark_rounded,
                color: AppColors.primary, size: 18),
            label: Text(
              l.bookmarks,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // ── Date range chips ───────────────────────────────────────────
          _DateRangeSelector(
            selected: _selectedRange,
            onChanged: (r) => setState(() => _selectedRange = r),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0, duration: 300.ms),

          const SizedBox(height: 20),

          // ── Stats row ──────────────────────────────────────────────────
          ref.watch(statsProvider).when(
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.quiz_rounded,
                    label: l.questionsAnswered,
                    value: '${stats.attempted}',
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primary.withValues(alpha: 0.1),
                    cardColor: cardColor,
                    textHigh: textHigh,
                    textMed: textMed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.track_changes_rounded,
                    label: l.passRate,
                    value: stats.attempted == 0 ? '—' : '${(stats.passRate * 100).round()}%',
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withValues(alpha: 0.1),
                    cardColor: cardColor,
                    textHigh: textHigh,
                    textMed: textMed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ref.watch(streakProvider).maybeWhen(
                    data: (streak) => _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: l.studyStreakDays,
                      value: '${streak.streakCount}',
                      iconColor: AppColors.accent,
                      bgColor: AppColors.accent.withValues(alpha: 0.1),
                      cardColor: cardColor,
                      textHigh: textHigh,
                      textMed: textMed,
                    ),
                    orElse: () => _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: l.studyStreakDays,
                      value: '—',
                      iconColor: AppColors.accent,
                      bgColor: AppColors.accent.withValues(alpha: 0.1),
                      cardColor: cardColor,
                      textHigh: textHigh,
                      textMed: textMed,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 350.ms)
              .slideY(begin: 0.1, end: 0, delay: 80.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Bar chart ──────────────────────────────────────────────────
          _SectionHeader(
            title: l.dailyActivity,
            subtitle: l.questionsAnswered,
            textHigh: textHigh,
            textMed: textMed,
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.spot != null &&
                          event is! FlPointerExitEvent) {
                        _touchedBarIndex =
                            response!.spot!.touchedBarGroupIndex;
                      } else {
                        _touchedBarIndex = null;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()}',
                        GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 30 || value == 60) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.plusJakartaSans(
                              color: textMed,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _barLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _barLabels[idx],
                            style: GoogleFonts.plusJakartaSans(
                              color: textMed,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 15,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_barData.length, (i) {
                  final isTouched = _touchedBarIndex == i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _barData[i].toDouble(),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isTouched
                              ? [AppColors.accent, AppColors.accentLight]
                              : [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
            ),
          )
              .animate()
              .fadeIn(delay: 160.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 160.ms, duration: 400.ms),

          const SizedBox(height: 28),

          // ── Topic mastery ──────────────────────────────────────────────
          _SectionHeader(
            title: l.topicMastery,
            subtitle: l.questionsAnswered,
            textHigh: textHigh,
            textMed: textMed,
          ),
          const SizedBox(height: 12),
          ref.watch(topicsProvider).when(
            loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
            data: (topics) => Column(
              children: List.generate(topics.length, (i) {
                final topic = topics[i];
                final progressAsync = ref.watch(topicProgressProvider(topic.externalId));
                final progress = progressAsync.valueOrNull ?? 0.0;
                return _TopicMasteryCard(
                  topic: topic.title,
                  progress: progress,
                  cardColor: cardColor,
                  textHigh: textHigh,
                  textMed: textMed,
                  delay: Duration(milliseconds: 240 + i * 60),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _DateRangeSelector extends StatelessWidget {
  final _DateRange selected;
  final ValueChanged<_DateRange> onChanged;

  const _DateRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ranges = [
      (_DateRange.thisWeek, l.thisWeek),
      (_DateRange.thisMonth, l.thisMonth),
      (_DateRange.allTime, l.allTime),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ranges.map((r) {
          final isSelected = selected == r.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                r.$2,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(r.$1),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.outlineVariant,
              ),
              showCheckmark: false,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;
  final Color cardColor;
  final Color textHigh;
  final Color textMed;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
    required this.cardColor,
    required this.textHigh,
    required this.textMed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textHigh,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textMed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textHigh;
  final Color textMed;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.textHigh,
    required this.textMed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textHigh,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: textMed,
          ),
        ),
      ],
    );
  }
}

class _TopicMasteryCard extends StatelessWidget {
  final String topic;
  final double progress;
  final Color cardColor;
  final Color textHigh;
  final Color textMed;
  final Duration delay;

  const _TopicMasteryCard({
    required this.topic,
    required this.progress,
    required this.cardColor,
    required this.textHigh,
    required this.textMed,
    required this.delay,
  });

  Color get _barColor {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.6) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textHigh,
                ),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 350.ms)
        .slideX(begin: 0.05, end: 0, delay: delay, duration: 350.ms);
  }
}
