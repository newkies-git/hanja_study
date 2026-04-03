import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 관련 단어 목록 타일.
///
/// 기존 private `_RelatedWordTile`을 public으로 승격하여
/// 단어 목록 화면(Phase 2)에서도 재사용 가능하게 한다.
class RelatedWordTile extends StatelessWidget {
  const RelatedWordTile({
    super.key,
    required this.hanja,
    required this.reading,
    required this.meaning,
    this.category,
  });

  final String hanja;
  final String reading;
  final String meaning;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          // 은은한 섀도우만 남기고 테두리 제거 (이미지 반영)
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: [단어 | (독음)]
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hanja,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: HanjaColors.primary,
                    fontSize: 16,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                // 수직 구분선
                Container(
                  width: 1.2,
                  height: 12,
                  color: const Color(0xFFD1D3D5),
                ),
                const SizedBox(width: 8),
                Text(
                  '($reading)',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF9A9DA0),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: category == '성어'
                          ? HanjaColors.tertiaryContainer.withValues(alpha: 0.1)
                          : HanjaColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category!,
                      style: textTheme.labelSmall?.copyWith(
                        color: category == '성어' ? HanjaColors.tertiary : HanjaColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 하단: 뜻풀이
            Text(
              meaning,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF212529),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
