import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 현재 획 순서에 대한 시각적 힌트 오버레이.
///
/// [CustomPaint] 기반으로, 쓰기 연습 캔버스 위에 겹쳐 표시한다.
/// 실제 서비스에서는 [StrokeHintPainter]의 좌표를 획 데이터(`StrokeData`)로
/// 대체하여 동적 힌트를 구현한다.
class StrokeHintOverlay extends StatelessWidget {
  const StrokeHintOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StrokeHintPainter());
  }
}

class _StrokeHintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint completedStrokePaint = Paint()
      ..color = HanjaColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint currentStrokePaint = Paint()
      ..color = HanjaColors.primary
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x1 = size.width * 0.30;
    final double x2 = size.width * 0.55;
    final double yTop1 = size.height * 0.25;
    final double yBot1 = size.height * 0.75;

    canvas.drawLine(Offset(x1, yTop1), Offset(x1, yBot1), completedStrokePaint);
    canvas.drawLine(
      Offset(x2, size.height * 0.30),
      Offset(x2, size.height * 0.70),
      currentStrokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
