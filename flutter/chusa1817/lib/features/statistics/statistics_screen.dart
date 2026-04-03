import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';

/// 주간 학습 통계 화면.
///
/// 요일별 막대 그래프로 학습량을 시각화한다.
/// Phase 2에서 SQLite/API 기반 실제 데이터로 전환된다.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});
  static const List<String> _dayLabels = [
    '월', '화', '수', '목', '금', '토', '일',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final weeklyCountsAsync = ref.watch(weeklyStudyCountsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '학습 통계'),
        const SizedBox(height: 14),
        Text(
          '주간 활동 분석',
          style: textTheme.headlineSmall?.copyWith(
            color: HanjaColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        weeklyCountsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Text(
              '통계를 불러오지 못했습니다.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
          data: (counts) => _WeeklyBarChart(
            counts: counts,
            dayLabels: _dayLabels,
          ),
        ),
      ],
    );
  }
}

/// 주간 막대 그래프 위젯.
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({
    required this.counts,
    required this.dayLabels,
  });

  final List<int> counts;
  final List<String> dayLabels;

  static const double _maxBarHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(counts.length, (index) {
          final int max = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
          final int count = counts[index];
          final double heightFactor = max == 0 ? 0.0 : (count / max).clamp(0.0, 1.0);
          final bool isHighest = max != 0 && count == max;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: _maxBarHeight * heightFactor,
                    decoration: BoxDecoration(
                      color: HanjaColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HanjaColors.primary.withValues(
                              alpha: isHighest ? 1.0 : 0.55,
                            ),
                            HanjaColors.primaryContainer.withValues(
                              alpha: isHighest ? 1.0 : 0.55,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayLabels[index],
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
