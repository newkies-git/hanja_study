import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';
import '../../../core/theme/hanja_theme.dart';

/// 연속 학습일 스트릭 뱃지.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streakDays, required this.textTheme});

  final int streakDays;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: HanjaColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('🔥', style: textTheme.headlineSmall),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays일 연속 학습 중!',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 학습을 이어가세요',
                style: textTheme.bodySmall?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '🏆',
            style: textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
