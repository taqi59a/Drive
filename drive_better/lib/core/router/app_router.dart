import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/training/presentation/topics/topics_screen.dart';
import '../../features/training/presentation/practice/practice_screen.dart';
import '../../features/training/presentation/mock_test/mock_test_screen.dart';
import '../../features/training/presentation/mock_test/mock_test_result_screen.dart';
import '../../features/training/presentation/flashcards/flashcards_screen.dart';
import '../../features/camera_qa/presentation/scanner_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/training/presentation/theory/theory_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../constants/app_constants.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.home,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;
    if (!onboardingDone && state.matchedLocation != Routes.onboarding) {
      return Routes.onboarding;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: Routes.bookmarks,
      builder: (_, __) => const BookmarksScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.topics,
            builder: (_, __) => const TopicsScreen(),
            routes: [
              GoRoute(
                path: 'practice/:topicId',
                builder: (_, state) => PracticeScreen(topicId: state.pathParameters['topicId']!),
              ),
              GoRoute(
                path: 'theory/:topicId',
                builder: (_, state) => TheoryScreen(topicId: state.pathParameters['topicId']!),
              ),
              GoRoute(
                path: 'mock-test',
                builder: (_, __) => const MockTestScreen(),
                routes: [
                  GoRoute(
                    path: 'result',
                    builder: (_, state) => MockTestResultScreen(
                      session: state.extra as dynamic,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'flashcards/:topicId',
                builder: (_, state) => FlashcardsScreen(topicId: state.pathParameters['topicId']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.scanner, builder: (_, __) => const ScannerScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.progress,
            builder: (_, __) => const ProgressScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: Routes.settings, builder: (_, __) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);
