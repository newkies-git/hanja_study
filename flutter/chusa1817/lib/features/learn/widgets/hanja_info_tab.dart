import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 기본 정보 탭 화면.
/// 부수, 총획, 유래 텍스트 등을 표시한다.
class HanjaInfoTab extends StatelessWidget {
  const HanjaInfoTab({
    super.key,
    required this.radical,
    required this.radicalLabel,
    required this.totalStrokes,
    required this.originText,
  });

  final String radical;
  final String radicalLabel;
  final int totalStrokes;
  final String originText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: '부수',
                value: radical,
                subLabel: radicalLabel,
                valueColor: HanjaColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                label: '총획',
                value: '$totalStrokes',
                subLabel: '전체 획수',
                valueColor: HanjaColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: HanjaColors.outlineVariant.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            originText.isNotEmpty
                ? originText
                : '아직 유래 설명이 준비되지 않았습니다.',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// 정보 카드 (부수, 총획 등 단일 속성 표시).
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HanjaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9A9DA0),
              letterSpacing: 2.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            style: textTheme.bodySmall?.copyWith(
              color: HanjaColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
