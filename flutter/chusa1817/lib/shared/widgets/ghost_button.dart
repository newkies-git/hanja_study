import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 보조 액션용 Ghost 스타일 아웃라인 버튼.
///
/// 디자인 시스템의 "Ghost Border" (15% opacity outline) 규칙을 따른다.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: HanjaColors.onSurface),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: HanjaColors.surfaceContainerLow,
        foregroundColor: HanjaColors.onSurface,
        side: BorderSide(
          color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
