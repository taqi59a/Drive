import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/training_providers.dart';


class TheoryScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TheoryScreen({super.key, required this.topicId});

  @override
  ConsumerState<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends ConsumerState<TheoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedBottom = false;
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Consider "reached bottom" when within 100px of the end
      if (currentScroll >= maxScroll - 100 && !_reachedBottom) {
        setState(() => _reachedBottom = true);
        _markChapterRead();
      }
    }
  }

  Future<void> _markChapterRead() async {
    if (_markedRead) return;
    _markedRead = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chapter_read_${widget.topicId}', true);
    ref.invalidate(chapterReadProvider(widget.topicId));
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return topicsAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error loading theory: $e')),
      ),
      data: (topics) {
        final topicIndex =
            topics.indexWhere((t) => t.externalId == widget.topicId);
        if (topicIndex == -1) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Topic not found.')),
          );
        }

        final topic = topics[topicIndex];
        final nextTopic =
            topicIndex + 1 < topics.length ? topics[topicIndex + 1] : null;
        final chapterNumber = topicIndex + 1;
        final hasHtml =
            topic.contentHtml != null && topic.contentHtml!.isNotEmpty;
        final hasContent = topic.content != null && topic.content!.isNotEmpty;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top header bar
                _buildTopBar(context, theme, chapterNumber, topics.length),
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chapter title card
                        _buildChapterHeader(
                            context, theme, topic.title, chapterNumber, isDark),
                        // Theory content
                        if (hasHtml)
                          _buildHtmlContent(context, theme, topic.contentHtml!)
                        else if (hasContent)
                          _buildPlainContent(context, theme, topic.content!)
                        else
                          _buildEmptyContent(theme),
                        const SizedBox(height: 24),
                        // Bottom action card
                        _buildActionCard(
                          context,
                          theme,
                          isDark,
                          topic,
                          nextTopic,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(
      BuildContext context, ThemeData theme, int chapterNum, int totalChapters) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded, size: 22),
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              Expanded(
                child: Text(
                  'Chapter $chapterNum of $totalChapters',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance the close button
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: chapterNum / totalChapters,
              minHeight: 5,
              backgroundColor: theme.colorScheme.outlineVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(BuildContext context, ThemeData theme,
      String title, int chapterNum, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A6B), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'CHAPTER $chapterNum',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatTitle(title),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                'Theory Lesson',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05);
  }

  Widget _buildHtmlContent(
      BuildContext context, ThemeData theme, String htmlContent) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HtmlWidget(
        htmlContent,
        customStylesBuilder: (element) {
          final tag = element.localName;

          // Style headings
          if (tag == 'h1') {
            return {
              'font-size': '22px',
              'font-weight': '800',
              'color': isDark ? '#E0E0E0' : '#1B3A6B',
              'margin-top': '24px',
              'margin-bottom': '12px',
            };
          }
          if (tag == 'h2') {
            return {
              'font-size': '18px',
              'font-weight': '700',
              'color': isDark ? '#BDBDBD' : '#2A5298',
              'margin-top': '20px',
              'margin-bottom': '10px',
            };
          }
          if (tag == 'h3') {
            return {
              'font-size': '16px',
              'font-weight': '700',
              'color': isDark ? '#9E9E9E' : '#3B5998',
              'margin-top': '16px',
              'margin-bottom': '8px',
            };
          }

          // Style paragraphs
          if (tag == 'p') {
            return {
              'font-size': '15px',
              'margin-bottom': '10px',
              'color': isDark ? '#D0D0D0' : '#333333',
            };
          }

          // Style lists
          if (tag == 'li') {
            return {
              'font-size': '15px',
              'margin-bottom': '4px',
              'color': isDark ? '#D0D0D0' : '#333333',
            };
          }

          // Style info boxes
          if (element.className.contains('box-blue')) {
            return {
              'background-color': isDark ? '#1A2744' : '#EBF5FF',
              'border-left': '4px solid #2A5298',
              'padding': '12px 16px',
              'margin': '12px 0',
              'border-radius': '8px',
            };
          }

          // Style tables
          if (tag == 'table' &&
              element.className.contains('lesson-detail-table')) {
            return {
              'margin': '12px 0',
            };
          }

          // Style images
          if (tag == 'img') {
            return {
              'max-width': '100%',
              'border-radius': '12px',
              'margin': '8px 0',
            };
          }

          // Bold / strong
          if (tag == 'strong') {
            return {
              'font-weight': '700',
              'color': isDark ? '#FFFFFF' : '#1B3A6B',
            };
          }

          // Horizontal rule
          if (tag == 'hr') {
            return {
              'margin': '20px 0',
              'border-top': isDark
                  ? '1px solid #333333'
                  : '1px solid #E0E0E0',
            };
          }

          return null;
        },
        customWidgetBuilder: (element) {
          // Custom handling for images with asset: prefix
          if (element.localName == 'img') {
            final src = element.attributes['src'] ?? '';
            if (src.startsWith('asset:')) {
              final assetPath = src.substring(6); // Remove 'asset:' prefix
              
              // Check if the image is inside a table to prevent layout collapse
              bool isInsideTable = false;
              var parent = element.parent;
              while (parent != null) {
                if (parent.localName == 'table') {
                  isInsideTable = true;
                  break;
                }
                parent = parent.parent;
              }

              if (isInsideTable) {
                return Image.asset(
                  assetPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 240,
                      ),
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return null;
        },
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          height: 1.7,
          color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF333333),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildPlainContent(
      BuildContext context, ThemeData theme, String content) {
    final isDark = theme.brightness == Brightness.dark;

    // Convert === markers to proper formatting
    final sections = content.split('\n');
    final widgets = <Widget>[];

    for (final line in sections) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // === Title === → Heading
      if (trimmed.startsWith('===') && trimmed.endsWith('===')) {
        final heading = trimmed.replaceAll('===', '').trim();
        if (heading.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                heading,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1B3A6B),
                  height: 1.3,
                ),
              ),
            ),
          );
        }
      }
      // Bullet point
      else if (trimmed.startsWith('•') || trimmed.startsWith('–')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  •  ',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(1).trim(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular paragraph
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              trimmed,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                height: 1.7,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildEmptyContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.menu_book_outlined,
                size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'No theory content available for this chapter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic topic,
    dynamic nextTopic,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chapter Complete! 🎉',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Test your knowledge with practice questions, or continue to the next lesson.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          // Primary: Practice Questions
          if (topic.questionCount > 0)
            _buildActionButton(
              context,
              label: 'Practice Questions (${topic.questionCount})',
              icon: Icons.quiz_rounded,
              isPrimary: true,
              onTap: () =>
                  context.push(Routes.practiceRoute(topic.externalId)),
            ),
          if (topic.questionCount > 0 && nextTopic != null)
            const SizedBox(height: 10),
          // Secondary: Next Chapter
          if (nextTopic != null)
            _buildActionButton(
              context,
              label: 'Next: ${_formatTitle(nextTopic.title)}',
              icon: Icons.arrow_forward_rounded,
              isPrimary: false,
              onTap: () => context
                  .pushReplacement(Routes.theoryRoute(nextTopic.externalId)),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E2B3D) : const Color(0xFFF0F4FA)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? Colors.white
                  : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isPrimary
                      ? Colors.white
                      : AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTitle(String title) {
    // Convert "THE ROAD OR CARRIAGEWAY" to "The Road or Carriageway"
    final lowerWords = {'or', 'and', 'the', 'a', 'an', 'of', 'in', 'on', 'to', 'for', 'with', 'at', 'by'};
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
}
