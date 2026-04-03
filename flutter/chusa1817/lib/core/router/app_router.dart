import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:chusa1817/features/auth/login_screen.dart';
import 'package:chusa1817/features/auth/sign_up_screen.dart';
import 'package:chusa1817/features/auth/sign_up_success_screen.dart';
import 'package:chusa1817/features/auth/reset_password_screen.dart';
import 'package:chusa1817/features/auth/reset_sent_screen.dart';
import 'package:chusa1817/features/landing/landing_screen.dart';
import 'package:chusa1817/features/learn/hanja_detail_screen.dart';
import 'package:chusa1817/features/profile/plan_settings_screen.dart';
import 'package:chusa1817/features/review/review_screen.dart';
import 'package:chusa1817/features/shell/app_shell.dart';
import 'package:chusa1817/features/onboarding/onboarding_screen.dart';
import 'package:chusa1817/features/study/practice_result_screen.dart';
import 'package:chusa1817/features/study/study_screen.dart';

import '../auth/auth_providers.dart';
import '../providers/app_providers.dart';

/// 앱 전체 라우트 테이블.
///
/// 모든 화면 이동은 이 GoRouter를 통해 선언적으로 처리한다.
/// `context.go()` — replace, `context.push()` — stack push.
final goRouterProvider = Provider<GoRouter>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  final isNonAnonymousUser = ref.watch(isNonAnonymousUserProvider);
  final onboardingCompletedAsync = ref.watch(onboardingCompletedProvider);
  final authStateChanges = ref.watch(firebaseAuthProvider).authStateChanges();

  return GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: _GoRouterRefreshNotifier(authStateChanges),
    redirect: (context, state) {
      final bool isAuthRoute = state.uri.path == AppRoutes.landing ||
          state.uri.path == AppRoutes.login ||
          state.uri.path == AppRoutes.signUp ||
          state.uri.path == AppRoutes.signUpSuccess ||
          state.uri.path == AppRoutes.resetPassword ||
          state.uri.path == AppRoutes.resetSent ||
          state.uri.path == AppRoutes.onboarding;

      // 로그인 여부는 "익명 포함" 사용자 세션 기준으로 판단한다.
      // (Firestore 규칙의 request.auth 만족을 위해 익명 세션을 기본 유지)
      if (!isSignedIn && !isAuthRoute) {
        return AppRoutes.landing;
      }

      // Landing 도착 시: 이메일 로그인 유저이거나 온보딩을 끝낸 익명 유저라면 Home으로 이동.
      if (state.uri.path == AppRoutes.landing) {
        final hasCompletedOnboarding = onboardingCompletedAsync.value ?? false;
        if (isNonAnonymousUser || hasCompletedOnboarding) {
          return AppRoutes.home;
        }
      }

      // 이메일/비밀번호로 이미 로그인한 사용자라면 로그인 화면으로 가지 않도록 한다.
      if (isNonAnonymousUser && state.uri.path == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
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
        path: AppRoutes.signUp,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUpSuccess,
        name: 'signup-success',
        builder: (context, state) => const SignUpSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetSent,
        name: 'reset-sent',
        builder: (context, state) => const ResetSentScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, state) {
          final int tab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return AppShell(initialIndex: tab);
        },
      ),
      GoRoute(
        path: '${AppRoutes.hanjaDetail}/:id',
        name: 'hanja-detail',
        builder: (_, state) {
          return HanjaDetailScreen(
            hanjaId: state.pathParameters['id'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.study}/:id',
        name: 'study',
        builder: (_, state) {
          final String meaning = state.uri.queryParameters['meaning'] ?? '';
          return StudyScreen(hanjaId: state.pathParameters['id'] ?? '', meaning: meaning);
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
});

final class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// 앱 라우트 경로 상수 모음.
abstract class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String signUpSuccess = '/signup-success';
  static const String resetPassword = '/reset-password';
  static const String resetSent = '/reset-sent';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String hanjaDetail = '/hanja';
  static const String study = '/study';
  static const String practiceResult = '/practice-result';
  static const String planSettings = '/plan-settings';
  static const String review = '/review';
}
