import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

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
    final weeklyBreakdownAsync = ref.watch(weeklyActivityBreakdownProvider);
    final streakAsync = ref.watch(streakDaysProvider);
    final todayDoneAsync = ref.watch(todayCompletedCountProvider);
    final dailyGoalAsync = ref.watch(dailyGoalProvider);
    final totalHanjaCountAsync = ref.watch(totalHanjaCountProvider);
    final masteredHanjaCountAsync = ref.watch(masteredHanjaCountProvider);
    final learningHanjaCountAsync = ref.watch(learningHanjaCountProvider);
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
        weeklyBreakdownAsync.when(
          loading: () => const _LoadingPlaceholder(height: 180),
          error: (error, _) => _ErrorPlaceholder(message: '데이터를 불러올 수 없습니다.'),
          data: (series) => dailyGoalAsync.when(
            loading: () => const _LoadingPlaceholder(height: 180),
            error: (_, _) => _ErrorPlaceholder(message: '데이터를 불러올 수 없습니다.'),
            data: (goal) => _WeeklyMixedChartCard(
              dailyGoal: goal,
              completed: series.completed,
              learning: series.learning,
              total: series.total,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. 학습 진척도 섹션
        _buildSectionHeader(textTheme, '전체 학습 현황'),
        const SizedBox(height: 12),
        _buildProgressCard(
          context,
          textTheme,
          totalHanjaCountAsync,
          learningHanjaCountAsync,
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
    AsyncValue<int> learningCountAsync,
    AsyncValue<int> masteredCountAsync,
  ) {
    int safeValue(AsyncValue<int> v) => v.maybeWhen(data: (x) => x, orElse: () => 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
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
          Text(
            '전체 한자 학습 현황',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          totalCountAsync.when(
            data: (total) => Text(
              '총 $total자',
              style: textTheme.labelMedium?.copyWith(
                color: HanjaColors.outline,
                fontWeight: FontWeight.w700,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final total = safeValue(totalCountAsync);
              final learning = safeValue(learningCountAsync);
              final mastered = safeValue(masteredCountAsync);
              final unseen = (total - learning - mastered).clamp(0, total);
              final studied = (learning + mastered).clamp(0, total);
              final pct = total <= 0 ? 0 : ((studied / total) * 100).round();

              String countWithRatio(int count) {
                if (total <= 0) return '$count (0%)';
                final p = ((count / total) * 100).round();
                return '$count ($p%)';
              }

              Widget metric({
                required Color color,
                required String label,
                required String value,
              }) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: textTheme.labelSmall?.copyWith(
                        color: HanjaColors.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                );
              }

              final donut = SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _OverallPiePainter(
                    total: total,
                    learning: learning,
                    mastered: mastered,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total <= 0 ? '-' : '$pct%',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '누적',
                          style: textTheme.labelSmall?.copyWith(
                            color: HanjaColors.outline,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              final metrics = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  metric(
                    color: HanjaColors.primary,
                    label: '학습완료',
                    value: countWithRatio(mastered),
                  ),
                  const SizedBox(height: 10),
                  metric(
                    color: Colors.orangeAccent,
                    label: '학습중',
                    value: countWithRatio(learning),
                  ),
                  const SizedBox(height: 10),
                  metric(
                    color: HanjaColors.surfaceContainerLow,
                    label: '미진행',
                    value: countWithRatio(unseen),
                  ),
                ],
              );

              // 좁은 폭에서는 세로로 쌓아 오버플로우 방지
              final bool narrow = constraints.maxWidth < 330;
              if (narrow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donut,
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: metrics,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  donut,
                  const SizedBox(width: 16),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: metrics,
                    ),
                  ),
                ],
              );
            },
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

class _OverallPiePainter extends CustomPainter {
  _OverallPiePainter({
    required this.total,
    required this.learning,
    required this.mastered,
  });

  final int total;
  final int learning;
  final int mastered;

  @override
  void paint(Canvas canvas, Size size) {
    final int t = total <= 0 ? 1 : total;
    final int l = learning.clamp(0, t);
    final int m = mastered.clamp(0, t);
    final int remaining = (t - l - m).clamp(0, t);

    final Rect rect = Offset.zero & size;
    final Offset c = rect.center;
    final double r = math.min(size.width, size.height) / 2;
    final double stroke = r * 0.38;
    final Rect arcRect = Rect.fromCircle(center: c, radius: r - stroke / 2);

    final Paint base = Paint()
      ..color = HanjaColors.surfaceContainerLow
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // base ring
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2, false, base);

    double start = -math.pi / 2;
    void drawSeg(int v, Color color) {
      if (v <= 0) return;
      final double sweep = (v / t) * math.pi * 2;
      canvas.drawArc(
        arcRect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..isAntiAlias = true,
      );
      start += sweep;
    }

    // order: remaining (base already), learning, mastered
    if (remaining > 0) {
      // keep as base color, but redraw to preserve start position calculation
      drawSeg(remaining, HanjaColors.surfaceContainerLow);
    }
    drawSeg(l, Colors.orangeAccent);
    drawSeg(m, HanjaColors.primary);
  }

  @override
  bool shouldRepaint(covariant _OverallPiePainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.learning != learning ||
        oldDelegate.mastered != mastered;
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
class _WeeklyMixedChartCard extends StatefulWidget {
  const _WeeklyMixedChartCard({
    required this.dailyGoal,
    required this.completed,
    required this.learning,
    required this.total,
  });

  final int dailyGoal;
  final List<int> completed;
  final List<int> learning;
  final List<int> total;

  @override
  State<_WeeklyMixedChartCard> createState() => _WeeklyMixedChartCardState();
}

class _WeeklyMixedChartCardState extends State<_WeeklyMixedChartCard> {
  int? _selectedIndex;
  double? _selectedDx;

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

  void _selectAt({
    required int index,
    required double dx,
  }) {
    setState(() {
      _selectedIndex = index;
      _selectedDx = dx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int dailyGoal = widget.dailyGoal;
    final List<int> completed = widget.completed;
    final List<int> learning = widget.learning;
    final List<int> total = widget.total;

    final textTheme = Theme.of(context).textTheme;
    final dayLabels = _generateDayLabels();
    final int yMax = math.max(
      dailyGoal,
      total.isEmpty ? 0 : total.reduce(math.max),
    );
    const double chartLeftPadding = 34;
    const double chartRightPadding = 8;

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
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '※ 일별 활동(중복 가능) / 파이차트는 현재 누적 상태',
              style: textTheme.labelSmall?.copyWith(
                color: HanjaColors.outlineVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _LegendChip(
                color: HanjaColors.surfaceContainerLow,
                label: '목표',
                textTheme: textTheme,
              ),
              const SizedBox(width: 10),
              _LegendChip(
                color: HanjaColors.secondary,
                label: '학습완료',
                textTheme: textTheme,
              ),
              const SizedBox(width: 10),
              _LegendChip(
                color: Colors.orangeAccent,
                label: '학습중',
                textTheme: textTheme,
              ),
              const SizedBox(width: 10),
              _LegendChip(
                color: HanjaColors.primary,
                label: '합계',
                textTheme: textTheme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final int n = total.length;
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          if (n == 0) return;
                          final double plotLeft = chartLeftPadding;
                          final double plotRight =
                              constraints.maxWidth - chartRightPadding;
                          final double step = n <= 1
                              ? 0
                              : (plotRight - plotLeft) / (n - 1);
                          final double dx = details.localPosition.dx;
                          final int idx = step == 0
                              ? 0
                              : ((dx - plotLeft) / step).round().clamp(0, n - 1);
                          final double snapDx = plotLeft + step * idx;
                          _selectAt(index: idx, dx: snapDx);
                        },
                        child: CustomPaint(
                          painter: _WeeklyMixedChartPainter(
                            dailyGoal: dailyGoal,
                            completed: completed,
                            learning: learning,
                            total: total,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedIndex != null && _selectedDx != null)
                  Positioned(
                    left: (_selectedDx! - 46).clamp(
                      0.0,
                      (MediaQuery.of(context).size.width - 40) - 92,
                    ),
                    top: 0,
                    child: _ChartTooltip(
                      title: dayLabels[_selectedIndex!],
                      goal: dailyGoal,
                      completed: completed[_selectedIndex!],
                      learning: learning[_selectedIndex!],
                      total: total[_selectedIndex!],
                    ),
                  ),
                // Y-axis labels
                Positioned(
                  left: 0,
                  top: 6,
                  child: Text(
                    '$yMax',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 64,
                  child: Text(
                    '${(yMax / 2).round()}',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 8,
                  child: Text(
                    '0',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Origin label (x,y intersection) same as 0 here
                Positioned(
                  left: 18,
                  bottom: 8,
                  child: Text(
                    '(0)',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.outlineVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(
              left: chartLeftPadding,
              right: chartRightPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dayLabels.length, (index) {
                final bool isToday = index == dayLabels.length - 1;
                return Text(
                  dayLabels[index],
                  style: textTheme.labelSmall?.copyWith(
                    color: isToday ? HanjaColors.primary : HanjaColors.outline,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.title,
    required this.goal,
    required this.completed,
    required this.learning,
    required this.total,
  });

  final String title;
  final int goal;
  final int completed;
  final int learning;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 92,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HanjaColors.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: HanjaColors.onSurface,
                height: 1.35,
              ) ??
              const TextStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: HanjaColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text('목표 $goal'),
              Text('완료(당일) $completed'),
              Text('진행(당일) $learning'),
              Text('합계(당일) $total'),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.textTheme,
  });

  final Color color;
  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.outline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeeklyMixedChartPainter extends CustomPainter {
  _WeeklyMixedChartPainter({
    required this.dailyGoal,
    required this.completed,
    required this.learning,
    required this.total,
  });

  final int dailyGoal;
  final List<int> completed;
  final List<int> learning;
  final List<int> total;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = total.length;
    if (n < 2) return;

    // Y축 레이블 공간 확보
    final double left = 34;
    final double right = size.width - 8;
    final double top = 10;
    final double bottom = size.height - 10;

    final int maxTotal = total.isEmpty ? 0 : total.reduce(math.max);
    final int yMax = math.max(dailyGoal, maxTotal);
    final int denom = math.max(1, yMax);

    double yFor(int v) {
      final double t = (v / denom).clamp(0.0, 1.0);
      return bottom - (bottom - top) * t;
    }

    // Grid (3 lines)
    final Paint gridPaint = Paint()
      ..color = HanjaColors.surfaceContainerLow
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final double t = i / 2;
      final double y = top + (bottom - top) * t;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }

    final double step = (right - left) / (n - 1);
    final double barWidth = (step * 0.58).clamp(10.0, 26.0);

    // Bars: daily goal (constant)
    final double yGoal = yFor(dailyGoal);
    final Paint goalPaint = Paint()
      ..color = HanjaColors.surfaceContainerLow
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (int i = 0; i < n; i++) {
      final double cx = left + step * i;
      final Rect r = Rect.fromLTRB(
        cx - barWidth / 2,
        yGoal,
        cx + barWidth / 2,
        bottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(999)),
        goalPaint,
      );
    }

    Offset pt(List<int> series, int i) {
      final double cx = left + step * i;
      return Offset(cx, yFor(series[i]));
    }

    Path pathFor(List<int> series) {
      final Path p = Path()..moveTo(pt(series, 0).dx, pt(series, 0).dy);
      for (int i = 1; i < n; i++) {
        final o = pt(series, i);
        p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    void drawLine(List<int> series, Color color, double width) {
      canvas.drawPath(
        pathFor(series),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
    }

    // Lines
    final Color completedColor = HanjaColors.secondary;
    final Color learningColor = Colors.orangeAccent;
    final Color totalColor = HanjaColors.primary;

    drawLine(total, totalColor, 2.8);
    drawLine(completed, completedColor, 2.2);
    drawLine(learning, learningColor, 2.2);

    // Points (total emphasized)
    for (int i = 0; i < n; i++) {
      final bool isToday = i == n - 1;
      final Offset p = pt(total, i);
      canvas.drawCircle(
        p,
        isToday ? 4.8 : 3.8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
      canvas.drawCircle(
        p,
        isToday ? 4.8 : 3.8,
        Paint()
          ..color = totalColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isToday ? 2.2 : 1.8
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyMixedChartPainter oldDelegate) {
    if (oldDelegate.dailyGoal != dailyGoal) return true;
    bool same(List<int> a, List<int> b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    return !same(oldDelegate.completed, completed) ||
        !same(oldDelegate.learning, learning) ||
        !same(oldDelegate.total, total);
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
