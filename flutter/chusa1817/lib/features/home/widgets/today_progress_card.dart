import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 오늘의 학습 진도 카드 (Integrated with TodayHanjaGrid).
class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({
    super.key,
    required this.goal,
    required this.done,
    required this.textTheme,
    required this.onTap,
    this.hanjaGrid,
  });

  final int goal;
  final int done;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final Widget? hanjaGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HanjaColors.primary, HanjaColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: HanjaColors.primary.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 학습 진도 및 목표 (왼쪽)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 학습 진도',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '목표까지 ${goal - done}자 남았습니다',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 2. 수치 및 게이지 (오른쪽)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$done / $goal',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 50,
                      height: 25,
                      child: CustomPaint(
                        painter: _SemicircleGaugePainter(
                          progress: (done / goal).clamp(0.0, 1.0),
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (hanjaGrid != null) ...[
              const SizedBox(height: 16),
              hanjaGrid!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SemicircleGaugePainter extends CustomPainter {
  _SemicircleGaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 11.0;
    final Offset center = Offset(size.width / 2, size.height);
    final double radius = size.width / 2 - strokeWidth / 2;
    
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // 1. 배경 아크 (회색조)
    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // 2. 진행 그라데이션 아크 (적-황-청)
    if (progress > 0) {
      final Paint fgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 0.5
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: const [Colors.red, Colors.yellow, Colors.blue],
          stops: const [0.0, 0.5, 1.0],
          startAngle: math.pi,
          endAngle: math.pi * 2,
        ).createShader(rect);

      // SweepGradient matches 0 to 2pi. To show only half, we need an offset or just draw partial.
      // Actually SweepGradient centers at center of rect.
      canvas.drawArc(rect, math.pi, math.pi * progress, false, fgPaint);
    }

    // 3. 바늘 (Pointer)
    final double needleAngle = math.pi + (math.pi * progress);
    final double needleLength = radius + 3;
    
    final Paint needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final Offset needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // 바늘을 그린다 (중심에서 끝점까지)
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // 바늘 중심 점 (작은 원)
    final Paint centerPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(center, 4.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _SemicircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
