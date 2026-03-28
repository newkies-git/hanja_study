import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 원고지(Won-go-ji) 격자 배경 위젯.
///
/// 쓰기 연습 캔버스와 한자 상세 화면에서 가이드 배경으로 사용된다.
/// [opacity]로 격자선의 투명도를 조절한다 (기본값 0.2).
class WonGoJiGrid extends StatelessWidget {
  const WonGoJiGrid({super.key, this.opacity = 0.2});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WonGoJiGridPainter(opacity));
  }
}

class _WonGoJiGridPainter extends CustomPainter {
  _WonGoJiGridPainter(this.opacity);

  final double opacity;

  static const double _step = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = HanjaColors.outlineVariant.withValues(alpha: opacity)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += _step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += _step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WonGoJiGridPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
