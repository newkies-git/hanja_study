import 'package:go_router/go_router.dart';

import 'package:chusa1817/features/auth/login_screen.dart';
import 'package:chusa1817/features/landing/landing_screen.dart';
import 'package:chusa1817/features/learn/hanja_detail_screen.dart';
import 'package:chusa1817/features/profile/plan_settings_screen.dart';
import 'package:chusa1817/features/review/review_screen.dart';
import 'package:chusa1817/features/shell/app_shell.dart';
import 'package:chusa1817/features/study/practice_result_screen.dart';
import 'package:chusa1817/features/study/study_screen.dart';

/// 앱 전체 라우트 테이블.
///
/// 모든 화면 이동은 이 GoRouter를 통해 선언적으로 처리한다.
/// `context.go()` — replace, `context.push()` — stack push.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
    GoRoute(
      path: AppRoutes.landing,
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (_, state) {
        final int tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return AppShell(initialIndex: tab);
      },
    ),
    GoRoute(
      path: '${AppRoutes.hanjaDetail}/:id',
      name: 'hanja-detail',
      builder: (_, state) {
        final String hanja = state.pathParameters['id'] ?? '佳';
        final String meaning = state.uri.queryParameters['meaning'] ?? '';
        final String radical = state.uri.queryParameters['radical'] ?? '人';
        final String radicalLabel = state.uri.queryParameters['radicalLabel'] ?? '';
        final int totalStrokes =
            int.tryParse(state.uri.queryParameters['totalStrokes'] ?? '8') ?? 8;
        return HanjaDetailScreen(
          hanja: hanja,
          meaning: meaning,
          radical: radical,
          radicalLabel: radicalLabel,
          totalStrokes: totalStrokes,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.study}/:hanja',
      name: 'study',
      builder: (_, state) {
        final String hanja = state.pathParameters['hanja'] ?? '佳';
        final String meaning = state.uri.queryParameters['meaning'] ?? '';
        return StudyScreen(hanja: hanja, meaning: meaning);
      },
    ),
    GoRoute(
      path: AppRoutes.practiceResult,
      name: 'practice-result',
      builder: (context, state) => const PracticeResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.planSettings,
      name: 'plan-settings',
      builder: (context, state) => const PlanSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.review,
      name: 'review',
      builder: (context, state) => const ReviewScreen(),
    ),
  ],
);

/// 앱 라우트 경로 상수 모음.
abstract class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String hanjaDetail = '/hanja';
  static const String study = '/study';
  static const String practiceResult = '/practice-result';
  static const String planSettings = '/plan-settings';
  static const String review = '/review';
}
