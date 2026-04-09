import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/route_builders.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';

import 'widgets/today_progress_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/recommended_review_section.dart';
import 'widgets/today_hanja_grid.dart';

/// 홈 화면.
///
/// 오늘의 학습 진도 카드, 오늘 학습할 한자 그리드,
/// 연속 학습일 스트릭 뱃지, 추천 복습 섹션을 표시한다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final dailyGoalAsync = ref.watch(dailyGoalProvider);
    final todayDoneAsync = ref.watch(todayCompletedCountProvider);
    final streakDaysAsync = ref.watch(streakDaysProvider);
    final reviewHanjaAsync = ref.watch(recommendedReviewHanjaProvider);
    final nextToLearnAsync = ref.watch(nextHanjaToLearnProvider);
    final todayHanjaListAsync = ref.watch(todayLearningHanjaListProvider);

    // AppShell의 단일 Scaffold에서 drawer를 열어야 하므로 여기서는 Scaffold를 쓰지 않는다.
    // (중첩 Scaffold면 Scaffold.of(context)가 내부를 잡아 햄버거가 동작하지 않음)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // FAB과 겹치지 않도록 하단 여유
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
            onTap: () {
              final hanja = nextToLearnAsync.value;
              if (hanja != null) {
                context.push(RouteBuilders.hanjaDetail(hanja.id));
              } else {
                context.go('${AppRoutes.home}?tab=1');
              }
            },
            hanjaGrid: todayHanjaListAsync.when(
              data: (list) => TodayHanjaGrid(
                hanjaList: list,
                onTap: (id, _) {
                  final row = list.firstWhere((e) => e.$1.id == id).$1;
                  context.push(RouteBuilders.hanjaDetail(row.id));
                },
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              error: (error, _) => const SizedBox.shrink(),
            ),
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
              hanjaList: (reviewHanjaAsync.value ?? const <(String, String, String, String)>[])
                  .map((row) => {'hanjaId': row.$1, 'hanja': row.$2, 'meaning': row.$3, 'subInfo': row.$4})
                  .toList(),
              textTheme: textTheme,
              onStudyTap: (hanjaId, _) => context.push('${AppRoutes.hanjaDetail}/$hanjaId'),
              onSeedTap: () async {
                await ref.read(progressRepositoryProvider).seedSampleReviewHanja();
                ref.invalidate(recommendedReviewHanjaProvider);
              },
            ),
        ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            backgroundColor: HanjaColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text(
              '학습 이어가기',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onPressed: () {
              final hanja = nextToLearnAsync.value;
              if (hanja != null) {
                context.push(RouteBuilders.hanjaDetail(hanja.id));
              } else {
                context.go('${AppRoutes.home}?tab=1');
              }
            },
          ),
        ),
      ],
    );
  }
}
