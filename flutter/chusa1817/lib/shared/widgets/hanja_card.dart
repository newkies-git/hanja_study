import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';

/// 한자와 뜻을 보여주는 기본 범용 카드 UI
class HanjaCard extends StatelessWidget {
  const HanjaCard({
    super.key,
    required this.hanja,
    required this.reading,
    required this.meaning,
    required this.totalStrokes,
    required this.radical,
    required this.onTap,
  });

  final String hanja;
  final String reading;
  final String meaning;
  final int totalStrokes;
  final String radical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), onTap);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hanja,
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reading,
                  style: textTheme.titleMedium?.copyWith(
                    color: HanjaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: HanjaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoChip(label: '$totalStrokes획'),
                    _InfoChip(label: '부수 $radical'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: HanjaColors.primaryFixed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: HanjaColors.primaryContainer,
        ),
      ),
    );
  }
}
