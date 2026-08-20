import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/locale_provider.dart';

import '../../../shared/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/db_seeder.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/isar_provider.dart';
import '../../../shared/providers/training_providers.dart';
import '../../../features/progress/data/models/attempt.dart';
import '../../../features/training/data/models/question.dart';
import '../../../features/training/data/models/topic.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyReminders = true;
  bool _testReminders = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textHigh = cs.onSurface;
    final textMed = cs.onSurface.withOpacity(0.6);
    final bgColor = cs.surface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: textHigh,
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          l10n?.settingsTitle ?? 'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textHigh,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Profile header ──────────────────────────────────────────────
          _ProfileHeader(textHigh: textHigh, textMed: textMed)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.06, end: 0, duration: 300.ms),

          const SizedBox(height: 24),



          // ── Appearance ──────────────────────────────────────────────────
          _SectionLabel(label: l10n?.appearance ?? 'Appearance', textMed: textMed),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme segmented button
                  Text(
                    l10n?.theme ?? 'Theme',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textHigh,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.primary,
                      selectedForegroundColor: Colors.white,
                      foregroundColor: textMed,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded, size: 16),
                        label: Text(l10n?.light ?? 'Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text(l10n?.dark ?? 'Dark'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded, size: 16),
                        label: Text(l10n?.system ?? 'System'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (modes) {
                      ref.read(themeModeProvider.notifier).setMode(modes.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                  ),
                  const SizedBox(height: 16),
                  // Language tile
                  InkWell(
                    onTap: () => _showLanguagePicker(context, locale, l10n),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.language_rounded,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.language ?? 'Language',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textHigh,
                                ),
                              ),
                              Text(
                                languageNames[locale.languageCode] ?? locale.languageCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: textMed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: textMed, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 60.ms, duration: 300.ms)
              .slideY(begin: 0.06, end: 0, delay: 60.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── Study / Notifications ────────────────────────────────────────
          _SectionLabel(label: l10n?.notifications ?? 'Study', textMed: textMed),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.alarm_rounded,
                  iconColor: AppColors.primary,
                  title: l10n?.dailyReminder ?? 'Daily reminders',
                  subtitle: 'Get reminded to study each day',
                  value: _dailyReminders,
                  textHigh: textHigh,
                  textMed: textMed,
                  onChanged: (v) => setState(() => _dailyReminders = v),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                ),
                _SwitchTile(
                  icon: Icons.assignment_rounded,
                  iconColor: AppColors.accent,
                  title: l10n?.testReminder ?? 'Test reminders',
                  subtitle: 'Remind me before scheduled tests',
                  value: _testReminders,
                  textHigh: textHigh,
                  textMed: textMed,
                  onChanged: (v) => setState(() => _testReminders = v),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 120.ms, duration: 300.ms)
              .slideY(begin: 0.06, end: 0, delay: 120.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────
          _SectionLabel(label: l10n?.about ?? 'About', textMed: textMed),
          const SizedBox(height: 8),
          _SettingsCard(
            cardColor: cardColor,
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.primary,
                  title: l10n?.version ?? 'Version',
                  trailing: Text(
                    '1.0.0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: textMed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  textHigh: textHigh,
                  textMed: textMed,
                  onTap: null,
                ),
                _divider(isDark),
                _InfoTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: l10n?.privacyPolicy ?? 'Privacy Policy',
                  textHigh: textHigh,
                  textMed: textMed,
                  onTap: () => _launch('https://drivebetter.app/privacy'),
                ),
                _divider(isDark),
                _InfoTile(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.primary,
                  title: l10n?.termsOfService ?? 'Terms of Service',
                  textHigh: textHigh,
                  textMed: textMed,
                  onTap: () => _launch('https://drivebetter.app/terms'),
                ),
                _divider(isDark),
                _InfoTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.accent,
                  title: l10n?.rateApp ?? 'Rate App',
                  textHigh: textHigh,
                  textMed: textMed,
                  onTap: () => _launch('https://apps.apple.com/app/drivebetter'),
                ),
                _divider(isDark),
                _InfoTile(
                  icon: Icons.gavel_rounded,
                  iconColor: Colors.teal,
                  title: 'Attribution & Copyright',
                  textHigh: textHigh,
                  textMed: textMed,
                  onTap: () => _showLegalDialog(context),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 180.ms, duration: 300.ms)
              .slideY(begin: 0.06, end: 0, delay: 180.ms, duration: 300.ms),

          const SizedBox(height: 32),

          // ── Danger zone ──────────────────────────────────────────────────
          _DangerButton(
            label: l10n?.clearProgress ?? 'Clear Progress',
            onTap: () => _confirmClearProgress(context, l10n),
          )
              .animate()
              .fadeIn(delay: 240.ms, duration: 300.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 56,
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
      );

  void _showLanguagePicker(
      BuildContext context, Locale current, AppLocalizations? l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LanguagePickerSheet(
        currentLocale: current,
        title: l10n?.language ?? 'Language',
        onSelect: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _launch(String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Open Link',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SelectableText(url,
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmClearProgress(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.clearProgress ?? 'Clear all progress?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n?.clearProgressConfirm ??
              'This will permanently delete your streak, scores, and history. This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final isar = await ref.read(isarProvider.future);
                // Clear attempts, questions, topics
                await isar.writeTxn(() async {
                  await isar.attempts.clear();
                  await isar.questions.clear();
                  await isar.topics.clear();
                });
                
                // Reset seed preferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('db_seed_version');
                await prefs.remove(AppConstants.prefKeyDbSeeded);
                
                // Re-seed database
                await DbSeeder(isar).seedIfNeeded();
                
                // Invalidate training/topics providers
                ref.invalidate(topicsProvider);
                ref.invalidate(totalQuestionsProvider);
                ref.invalidate(statsProvider);
                ref.invalidate(bookmarkedQuestionsProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Progress cleared and Belgian data re-seeded!',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing progress: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              l10n?.confirm ?? 'Clear',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Attribution & Copyright',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This application is an independent educational training tool. The learning content, structure, and images used in this app are inspired by and derived from the public offline training material of:',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _launch('https://www.drivinglicence-belgium.be'),
                child: const Text(
                  'drivinglicence-belgium.be',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Disclaimer & GDPR Compliance:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• All copyrights, logos, and materials belong to their respective owners.\n'
                '• This app is for personal, non-commercial exam preparation purposes.\n'
                '• GDPR: The app is completely offline and does not collect, store, or transmit any user personal data. Study history remains locally on your device.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _LanguagePickerSheet extends StatelessWidget {
  final Locale currentLocale;
  final String title;
  final ValueChanged<Locale> onSelect;

  const _LanguagePickerSheet({
    required this.currentLocale,
    required this.title,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...appSupportedLocales.map((locale) {
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                final name =
                    languageNames[locale.languageCode] ?? locale.languageCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => onSelect(locale),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.4)
                                : cs.onSurface.withOpacity(0.08),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final Color textHigh;
  final Color textMed;

  const _ProfileHeader({required this.textHigh, required this.textMed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drive Better',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Belgian Theory',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textMed;

  const _SectionLabel({required this.label, required this.textMed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textMed,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color cardColor;

  const _SettingsCard({required this.child, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Color textHigh;
  final Color textMed;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.textHigh,
    required this.textMed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textHigh,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textMed,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final Color textHigh;
  final Color textMed;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.textHigh,
    required this.textMed,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textHigh,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded,
                        color: textMed, size: 20)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.error, size: 20),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.5),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
