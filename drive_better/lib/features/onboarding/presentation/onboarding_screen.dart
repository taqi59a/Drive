import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPageData> _pages(AppLocalizations l) => [
    _OnboardingPageData(
      icon: Icons.directions_car_rounded,
      iconColor: const Color(0xFF2D5BB8),
      title: l.onboarding1Title,
      subtitle: l.onboarding1Subtitle,
    ),
    _OnboardingPageData(
      icon: Icons.auto_stories_rounded,
      iconColor: const Color(0xFF7C3AED),
      title: l.onboarding2Title,
      subtitle: l.onboarding2Subtitle,
    ),
    _OnboardingPageData(
      icon: Icons.camera_alt_rounded,
      iconColor: AppColors.accent,
      title: l.onboarding3Title,
      subtitle: l.onboarding3Subtitle,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(Routes.home);
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pages = _pages(l);
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                  Colors.white,
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 20),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isLast ? 0.0 : 1.0,
                      child: TextButton(
                        onPressed: isLast ? null : _onGetStarted,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.85),
                        ),
                        child: Text(
                          l.skip,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: pages[index],
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // Dot indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _currentPage
                              ? AppColors.accent
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLast
                        ? FilledButton(
                            key: const ValueKey('get_started'),
                            onPressed: _onGetStarted,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
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
                            child: Text(l.getStarted),
                          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0)
                        : FilledButton(
                            key: const ValueKey('next'),
                            onPressed: _onNext,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(l.next),
                          ).animate().fadeIn(duration: 300.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 64,
              color: data.iconColor,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 80.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.6,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, delay: 150.ms, duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
