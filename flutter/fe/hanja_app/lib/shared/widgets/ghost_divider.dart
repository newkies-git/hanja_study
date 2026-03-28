import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 섹션 구분을 위한 Ghost 스타일 구분선.
///
/// 디자인 시스템의 "Ghost Border" 규칙 (outlineVariant 20% opacity)을 따르며,
/// 시각적으로 느껴지지만 눈에 띄지 않는 수준의 구분을 제공한다.
class GhostDivider extends StatelessWidget {
  const GhostDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: HanjaColors.outlineVariant.withValues(alpha: 0.2),
    );
  }
}
