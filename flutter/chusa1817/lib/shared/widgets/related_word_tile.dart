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
    required this.meaning,
  });

  final String hanja;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HanjaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              hanja,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meaning,
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: HanjaColors.outline),
          ],
        ),
      ),
    );
  }
}
