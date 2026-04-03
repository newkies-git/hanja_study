import 'package:flutter/material.dart';

/// 추사 1817 프로젝트의 시그니처 프리미엄 붓 아이콘.
/// 
/// 전통적인 붓(1안)과 역동적인 S자형 획(2안)이 결합되어,
/// 붓이 실제로 획을 그어 나가는 듯한 생동감을 벡터로 표현합니다.
class HanjaBrushIcon extends StatelessWidget {
  const HanjaBrushIcon({
    super.key,
    this.size = 32.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brush_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
