import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';

/// 수치나 특정 값을 설정할 때 사용하는 둥근 그라데이션 카드 범용 UI
class SelectableValueCard extends StatelessWidget {
  const SelectableValueCard({
    super.key,
    required this.valueLabel,
    required this.unitLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String valueLabel;
  final String? unitLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? null : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HanjaColors.outlineVariant),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                  )
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valueLabel,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : HanjaColors.onSurface,
                ),
              ),
              if (unitLabel != null && unitLabel!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  unitLabel!,
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 2.2,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF9A9DA0),
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}
