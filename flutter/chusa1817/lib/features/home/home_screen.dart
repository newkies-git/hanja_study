import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

import 'widgets/today_progress_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/recommended_review_section.dart';

/// 홈 화면.
///
/// 오늘의 학습 진도 카드, 연속 학습일 스트릭 뱃지,
/// 추천 복습 섹션을 DB/Provider 기반으로 표시한다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final dailyGoalAsync = ref.watch(dailyGoalProvider);
    final todayDoneAsync = ref.watch(todayCompletedCountProvider);
    final streakDaysAsync = ref.watch(streakDaysProvider);
    final reviewHanjaAsync = ref.watch(recommendedReviewHanjaProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const EditorialTopBar(title: '추사 1817'),
        const SizedBox(height: 14),
        if (dailyGoalAsync.isLoading || todayDoneAsync.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (dailyGoalAsync.hasError || todayDoneAsync.hasError)
          Center(
            child: Text(
              '진도를 불러오지 못했습니다.\n'
              '${dailyGoalAsync.error ?? ''}\n'
              '${todayDoneAsync.error ?? ''}',
              textAlign: TextAlign.center,
            ),
          )
        else
          TodayProgressCard(
            goal: dailyGoalAsync.value ?? 5,
            done: todayDoneAsync.value ?? 0,
            textTheme: textTheme,
            onTap: () => context.go('${AppRoutes.home}?tab=1'),
          ),
        const SizedBox(height: 14),
        if (streakDaysAsync.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(),
            ),
          )
        else if (streakDaysAsync.hasError)
          Center(
            child: Text(
              '스트릭을 불러오지 못했습니다.\n${streakDaysAsync.error}',
              textAlign: TextAlign.center,
            ),
          )
        else
          StreakBadge(
            streakDays: streakDaysAsync.value ?? 0,
            textTheme: textTheme,
          ),
        const SizedBox(height: 22),
        if (reviewHanjaAsync.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(),
            ),
          )
        else if (reviewHanjaAsync.hasError)
          Center(
            child: Text(
              '추천 복습을 불러오지 못했습니다.\n${reviewHanjaAsync.error}',
              textAlign: TextAlign.center,
            ),
          )
        else
          RecommendedReviewSection(
            hanjaList: (reviewHanjaAsync.value ?? const [])
                .map((row) => {'hanjaId': row.$1, 'hanja': row.$2, 'meaning': row.$3})
                .toList(),
            textTheme: textTheme,
            onStudyTap: (hanjaId, meaning) => context.push(
              '${AppRoutes.study}/$hanjaId?meaning=${Uri.encodeComponent(meaning)}',
            ),
          ),
        const SizedBox(height: 22),
        GradientPrimaryButton(
          label: '학습 이어가기',
          onPressed: () => context.go('${AppRoutes.home}?tab=1'),
        ),
      ],
    );
  }
}
