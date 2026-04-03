import 'package:flutter/material.dart';

/// 추사 1817 프로젝트의 시그니처 프리미엄 붓 아이콘.
/// 
/// 전통적인 붓(1안)과 역동적인 S자형 획(2안)이 결합되어,
/// 붓이 실제로 획을 그어 나가는 듯한 생동감을 벡터로 표현합니다.
class HanjaBrushIcon extends StatelessWidget {
  const HanjaBrushIcon({
    super.key,
    this.size = 32.0,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrushPainter(color: color),
      ),
    );
  }
}

/// 이미지의 예술적인 디테일(미세한 털 결, 두께 변화)을 반영한 벡터 페인터.
class _BrushPainter extends CustomPainter {
  _BrushPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final bristlePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ── 1. 역동적인 S자형 획 (Ink Stroke with Thickness Variation) ──────────
    // 이미지의 '통통하게 시작해서 날렵하게 빠지는' 느낌을 위해 면(Fill)으로 구성
    final strokePath = Path();
    
    // 시작점 (붓과 연결되는 지점)
    strokePath.moveTo(size.width * 0.25, size.height * 0.35);
    
    // 바깥쪽 곡선 (S의 등 부분)
    strokePath.cubicTo(
      size.width * 1.0, size.height * 0.2,   // 상단 우측 제어
      size.width * 0.4, size.height * 0.6,   // 중간 제어
      size.width * 0.85, size.height * 0.85, // 하단 끝점
    );
    
    // 안쪽 곡선 (두께감을 주며 되돌아오는 곡선)
    strokePath.quadraticBezierTo(
      size.width * 0.4, size.height * 1.0,   // 하단 꼬리 제어
      size.width * 0.2, size.height * 0.45,  // 다시 위로
    );
    
    strokePath.close();
    canvas.drawPath(strokePath, strokePaint);

    // ── 2. 미세한 털 결 (Bristle details at start) ─────────────────────────
    // 붓이 닿는 부분에서 획이 갈라지는 듯한 선 추가
    for (int i = 0; i < 3; i++) {
        final bPath = Path();
        bPath.moveTo(size.width * 0.25, size.height * 0.35);
        bPath.quadraticBezierTo(
            size.width * (0.3 + i*0.1), size.height * 0.4,
            size.width * (0.2 + i*0.05), size.height * (0.5 + i*0.1)
        );
        canvas.drawPath(bPath, bristlePaint);
    }

    // ── 3. 붓 (Detailed Brush Tip & Handle) ────────────────────────────────
    canvas.save();
    canvas.translate(size.width * 0.25, size.height * 0.35);
    canvas.rotate(-0.75); // 비스듬히 놓인 붓
    
    // 붓촉 (Brush Tip - 이미지의 뾰족하고 정교한 형태)
    final tipPath = Path();
    tipPath.moveTo(0, 0);
    tipPath.cubicTo(-9, -8, -6, -22, 0, -26); // 더 길고 뾰족하게
    tipPath.cubicTo(6, -22, 9, -8, 0, 0);
    canvas.drawPath(tipPath, fillPaint);
    
    // 붓촉 내부의 디테일 선 (이미지 상의 하이라이트/털 결)
    final detailPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(const Offset(0, -5), const Offset(0, -20), detailPaint);

    // 붓대 (Brush Handle)
    final handlePath = Path();
    handlePath.addRRect(RRect.fromLTRBR(-2.5, -45, 2.5, -24, const Radius.circular(1.5)));
    canvas.drawPath(handlePath, fillPaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
