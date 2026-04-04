import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 학습 계획의 요일을 선택하는 위젯 (Premium Style - Fits in one row).
class PlanDaySelector extends StatelessWidget {
  const PlanDaySelector({
    super.key,
    required this.selectedDays,
    required this.dayLabels,
    required this.onDayToggled,
  });

  final List<bool> selectedDays;
  final List<String> dayLabels;
  final void Function(int index) onDayToggled;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final bool isSelected = selectedDays[index];
        return Flexible(
          child: GestureDetector(
            onTap: () => onDayToggled(index),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index == 6 ? 0 : 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : HanjaColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : HanjaColors.outlineVariant.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HanjaColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : HanjaColors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
