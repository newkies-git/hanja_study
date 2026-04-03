import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 학습 계획의 요일을 선택하는 위젯.
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final bool isSelected = selectedDays[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onDayToggled(index),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? HanjaColors.primaryContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? HanjaColors.primaryContainer
                        : HanjaColors.outlineVariant,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9A9DA0),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
