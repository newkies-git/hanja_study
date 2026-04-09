import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 정확도(0.0~1.0)를 선형 진행 바 + 퍼센트 텍스트로 표시하는 공유 위젯.
class AccuracyProgressRow extends StatelessWidget {
  const AccuracyProgressRow({super.key, required this.accuracy});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final color = HanjaColors.forAccuracy(accuracy);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: accuracy,
              minHeight: 5,
              backgroundColor: HanjaColors.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(accuracy * 100).toInt()}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
