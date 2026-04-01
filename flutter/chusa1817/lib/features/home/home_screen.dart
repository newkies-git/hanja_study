import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

/// 홈 화면.
///
/// 오늘의 학습 진도 카드, 연속 학습일 스트릭 뱃지,
/// 추천 복습 섹션을 더미 데이터로 표시한다.
/// Phase 3에서 Drift DB 및 Riverpod Provider로 실데이터 교체.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _todayGoal = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final todayDoneAsync = ref.watch(todayCompletedCountProvider);
    final streakDaysAsync = ref.watch(streakDaysProvider);
    final reviewHanjaAsync = ref.watch(recommendedReviewHanjaProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const EditorialTopBar(title: '추사 1817'),
        const SizedBox(height: 14),
        _TodayProgressCard(
          goal: _todayGoal,
          done: todayDoneAsync.value ?? 0,
          textTheme: textTheme,
          onTap: () => context.go('${AppRoutes.home}?tab=1'),
        ),
        const SizedBox(height: 14),
        _StreakBadge(streakDays: streakDaysAsync.value ?? 0, textTheme: textTheme),
        const SizedBox(height: 22),
        _RecommendedReviewSection(
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

/// 오늘의 학습 진도 카드.
class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.goal,
    required this.done,
    required this.textTheme,
    required this.onTap,
  });

  final int goal;
  final int done;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double progress = done / goal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HanjaColors.primary, HanjaColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33003078),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'TODAY',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 2.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$done / $goal 자',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '오늘의 학습',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '목표까지 ${goal - done}자 남았습니다',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 연속 학습일 스트릭 뱃지.
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakDays, required this.textTheme});

  final int streakDays;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: HanjaColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('🔥', style: textTheme.headlineSmall),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays일 연속 학습 중!',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 학습을 이어가세요',
                style: textTheme.bodySmall?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '🏆',
            style: textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

/// 추천 복습 한자 섹션.
class _RecommendedReviewSection extends StatelessWidget {
  const _RecommendedReviewSection({
    required this.hanjaList,
    required this.textTheme,
    required this.onStudyTap,
  });

  final List<Map<String, String>> hanjaList;
  final TextTheme textTheme;
  final void Function(String hanjaId, String meaning) onStudyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW',
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primaryContainer,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 추천 복습',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...hanjaList.map((item) {
          final String hanjaId = item['hanjaId']!;
          final String hanja = item['hanja']!;
          final String meaning = item['meaning']!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onStudyTap(hanjaId, meaning),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: HanjaColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            hanja,
                            style: textTheme.titleLarge?.copyWith(
                              color: HanjaColors.primaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meaning,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '쓰기 연습',
                              style: textTheme.bodySmall?.copyWith(
                                color: HanjaColors.primaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: HanjaColors.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
