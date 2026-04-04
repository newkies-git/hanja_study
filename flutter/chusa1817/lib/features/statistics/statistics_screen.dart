import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';

/// 주간 학습 통계 화면.
///
/// 요일별 막대 그래프로 학습량을 시각화하며,
/// 전체 진척도와 복습 현황을 종합적으로 제공한다.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 데이터 프로바이더 구독
    final weeklyCountsAsync = ref.watch(weeklyStudyCountsProvider);
    final streakAsync = ref.watch(streakDaysProvider);
    final todayDoneAsync = ref.watch(todayCompletedCountProvider);
    final dailyGoalAsync = ref.watch(dailyGoalProvider);
    final totalHanjaCountAsync = ref.watch(totalHanjaCountProvider);
    final masteredHanjaCountAsync = ref.watch(masteredHanjaCountProvider);
    final dueForReviewAsync = ref.watch(dueForReviewHanjaProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const EditorialTopBar(title: '학습 통계'),
        const SizedBox(height: 18),

        // 1. 요약 섹션 (연속 학습일 & 오늘 성과)
        _buildSummaryRow(
          context,
          textTheme,
          streakAsync,
          todayDoneAsync,
          dailyGoalAsync,
        ),
        const SizedBox(height: 18),

        // 2. 주간 활동 그래프 섹션
        _buildSectionHeader(textTheme, '주간 활동 분석'),
        const SizedBox(height: 12),
        weeklyCountsAsync.when(
          loading: () => const _LoadingPlaceholder(height: 180),
          error: (error, _) => _ErrorPlaceholder(message: '데이터를 불러올 수 없습니다.'),
          data: (counts) => _WeeklyBarChartCard(counts: counts),
        ),
        const SizedBox(height: 24),

        // 3. 학습 진척도 섹션
        _buildSectionHeader(textTheme, '전체 학습 현황'),
        const SizedBox(height: 12),
        _buildProgressCard(
          context,
          textTheme,
          totalHanjaCountAsync,
          masteredHanjaCountAsync,
        ),
        const SizedBox(height: 24),

        // 4. 복습 현황 섹션
        _buildSectionHeader(textTheme, '복습 관리'),
        const SizedBox(height: 12),
        _buildReviewStatusCard(context, textTheme, dueForReviewAsync),
      ],
    );
  }

  Widget _buildSectionHeader(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.headlineSmall?.copyWith(
        color: HanjaColors.onSurface,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    TextTheme textTheme,
    AsyncValue<int> streak,
    AsyncValue<int> todayDone,
    AsyncValue<int> goal,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatSummaryCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orangeAccent,
            label: '연속 학습',
            value: streak.when(
              data: (v) => '$v일',
              loading: () => '...',
              error: (_, _) => '0일',
            ),
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatSummaryCard(
            icon: Icons.stars_rounded,
            iconColor: HanjaColors.primary,
            label: '오늘의 목표',
            value: todayDone.when(
              data: (done) => goal.when(
                data: (g) => '$done / $g',
                loading: () => '$done / -',
                error: (_, _) => '$done / 5',
              ),
              loading: () => '...',
              error: (_, _) => '0 / 5',
            ),
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    TextTheme textTheme,
    AsyncValue<int> totalCountAsync,
    AsyncValue<int> masteredCountAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: HanjaColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 한자 마스터',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              masteredCountAsync.when(
                data: (mastered) => totalCountAsync.when(
                  data: (total) => Text(
                    '$mastered / $total 자',
                    style: textTheme.bodySmall?.copyWith(
                      color: HanjaColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final double progress = masteredCountAsync.maybeWhen(
              data: (mastered) => totalCountAsync.maybeWhen(
                data: (total) => total > 0 ? (mastered / total).clamp(0.0, 1.0) : 0.0,
                orElse: () => 0.0,
              ),
              orElse: () => 0.0,
            );

            return Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: HanjaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 12,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [HanjaColors.secondary, HanjaColors.secondaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Text(
            '학습 데이터 동기화를 통해 전체 목표를 달성해 보세요!',
            style: textTheme.bodySmall?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStatusCard(
    BuildContext context,
    TextTheme textTheme,
    AsyncValue<List<dynamic>> dueReview,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HanjaColors.primary, HanjaColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.history_edu_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '복습 대기 한자',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                dueReview.when(
                  data: (list) => Text(
                    '${list.length} 글자',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  loading: () => const Text('...', style: TextStyle(color: Colors.white)),
                  error: (_, _) => const Text('0 글자', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}

/// 요약 정보용 작은 카드 위젯.
class _StatSummaryCard extends StatelessWidget {
  const _StatSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: HanjaColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: HanjaColors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: HanjaColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 고도화된 주간 활동 카드.
class _WeeklyBarChartCard extends StatelessWidget {
  const _WeeklyBarChartCard({required this.counts});
  final List<int> counts;

  List<String> _generateDayLabels() {
    final DateTime now = DateTime.now();
    final List<String> labels = [];
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add(weekdays[date.weekday - 1]);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayLabels = _generateDayLabels();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: HanjaColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 7일 활동량',
                style: textTheme.labelLarge?.copyWith(
                  color: HanjaColors.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.info_outline_rounded, size: 16, color: HanjaColors.outlineVariant),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(counts.length, (index) {
              final int max = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
              final int count = counts[index];
              final double heightFactor = max == 0 ? 0.0 : (count / max).clamp(0.0, 1.0);
              final bool isToday = index == counts.length - 1; // 마지막 요소가 오늘 성과라고 가정

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 100 * heightFactor + 4, // 최소 높이 보장
                        decoration: BoxDecoration(
                          color: isToday ? HanjaColors.primary : HanjaColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                          gradient: isToday
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayLabels[index],
                        style: textTheme.labelSmall?.copyWith(
                          color: isToday ? HanjaColors.primary : HanjaColors.outline,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: HanjaColors.error, size: 32),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
