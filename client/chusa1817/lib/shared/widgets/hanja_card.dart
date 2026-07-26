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
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  final String hanja;
  final String reading;
  final String meaning;
  final int totalStrokes;
  final String radical;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: HanjaColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), onTap);
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                if (onBookmarkTap != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isBookmarked ? const Color(0xFFFFB300) : HanjaColors.outlineVariant,
                      ),
                      onPressed: onBookmarkTap,
                    ),
                  ),
                Column(
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
                        _InfoChip(
                          label: '$totalStrokes',
                          backgroundColor: const Color(0xFFFFE8B4), // 연한 노란색
                          textColor: const Color(0xFFE65100), // 오렌지/노란색 계열
                        ),
                        _InfoChip(
                          label: radical,
                          backgroundColor: HanjaColors.primaryFixed.withValues(alpha: 0.5), // 연한 파란색
                          textColor: HanjaColors.primaryContainer, // 파란색 계열
                        ),
                      ],
                    ),
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
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
