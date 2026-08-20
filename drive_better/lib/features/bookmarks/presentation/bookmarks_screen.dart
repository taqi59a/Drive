import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/database/isar_service.dart';
import '../../../features/training/data/models/question.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/training_providers.dart';
import '../../../shared/widgets/skeleton_widgets.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textHigh = theme.colorScheme.onSurface;
    final textMed = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final bgColor = theme.scaffoldBackgroundColor;
    final l = AppLocalizations.of(context)!;
    final bookmarksAsync = ref.watch(bookmarkedQuestionsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          color: textHigh,
        ),
        title: Text(
          l.bookmarks,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textHigh,
          ),
        ),
        actions: [
          bookmarksAsync.whenOrNull(
            data: (qs) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${qs.length}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: bookmarksAsync.when(
        loading: () => const SkeletonBookmarks(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (questions) {
          if (questions.isEmpty) {
            return _EmptyState(textHigh: textHigh, textMed: textMed);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: questions.length,
            itemBuilder: (context, i) {
              final q = questions[i];
              return _BookmarkCard(
                question: q,
                cardColor: theme.colorScheme.surface,
                textHigh: textHigh,
                textMed: textMed,
                onRemove: () => _removeBookmark(context, ref, q),
                delay: Duration(milliseconds: i * 70),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeBookmark(BuildContext context, WidgetRef ref, Question q) async {
    final isar = await IsarService.getInstance();
    await isar.writeTxn(() async {
      q.isBookmarked = false;
      await isar.questions.put(q);
    });
    ref.invalidate(bookmarkedQuestionsProvider);
    if (context.mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.removeBookmark,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.accent,
            onPressed: () async {
              await isar.writeTxn(() async {
                q.isBookmarked = true;
                await isar.questions.put(q);
              });
              ref.invalidate(bookmarkedQuestionsProvider);
            },
          ),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Bookmark card
// ---------------------------------------------------------------------------

class _BookmarkCard extends StatelessWidget {
  final Question question;
  final Color cardColor;
  final Color textHigh;
  final Color textMed;
  final VoidCallback onRemove;
  final Duration delay;

  const _BookmarkCard({
    required this.question,
    required this.cardColor,
    required this.textHigh,
    required this.textMed,
    required this.onRemove,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final correctText = question.options.isNotEmpty &&
            question.correctIndex < question.options.length
        ? question.options[question.correctIndex].text
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textHigh,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_remove_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.topicId.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    correctText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 320.ms)
        .slideX(begin: 0.06, end: 0, delay: delay, duration: 320.ms);
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final Color textHigh;
  final Color textMed;

  const _EmptyState({required this.textHigh, required this.textMed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noBookmarks,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noBookmarksHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: textMed,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
