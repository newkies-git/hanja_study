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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: HanjaColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: HanjaColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 (타이틀 + 배지 및 게이지)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '오늘의 학습 진도',
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 1/10 배지 (헤더로 이동)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$done / $goal',
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '목표까지 ${goal - done}자 남았습니다',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 2. 게이지 (우측)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 80,
                    height: 48,
                    child: CustomPaint(
                      painter: _SemicircleGaugePainter(
                        progress: (done / goal).clamp(0.0, 1.0),
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
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
    // 진행 아크의 두께가 반지름의 1/2이 되게 설정
    final double radius = size.width / 2; 
    final double strokeWidth = radius / 2; // 스피드 게이지 두께 최적화
    final Offset center = Offset(size.width / 2, size.height);
    
    // 실제 드로잉을 위한 조정된 반지름 (스트로크의 절반만큼 안쪽으로)
    final double drawingRadius = radius - strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: drawingRadius);

    // 1. 배경 아크 (약간의 투명감)
    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt; // 라운드 처리 제거

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // 2. 진행 그라데이션 아크 (적-황-청 스펙트럼)
    if (progress > 0) {
      final Paint fgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt // 라운드 처리 제거
        ..shader = SweepGradient(
          colors: const [Colors.red, Colors.orange, Colors.yellow, Colors.blue],
          stops: const [0.0, 0.33, 0.66, 1.0],
          startAngle: math.pi,
          endAngle: math.pi * 2,
        ).createShader(rect);

      canvas.drawArc(rect, math.pi, math.pi * progress, false, fgPaint);
    }

    // 3. 바늘 (Pointer)
    final double needleAngle = math.pi + (math.pi * progress);
    final double needleLength = radius + 1;
    
    final Paint needlePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.9)
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    final Offset needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    
    // 바늘 중심
    final Paint centerPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(center, 5.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _SemicircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
