import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 관련 단어 목록 타일.
///
/// 기존 private `_RelatedWordTile`을 public으로 승격하여
/// 단어 목록 화면(Phase 2)에서도 재사용 가능하게 한다.
class RelatedWordTile extends StatefulWidget {
  const RelatedWordTile({
    super.key,
    required this.hanja,
    required this.reading,
    required this.meaning,
    this.category,
    this.isCompact = false,
  });

  final String hanja;
  final String reading;
  final String meaning;
  final String? category;
  final bool isCompact;

  @override
  State<RelatedWordTile> createState() => _RelatedWordTileState();
}

class _RelatedWordTileState extends State<RelatedWordTile> {
  bool _isVisible = false; // 기본값 숨김 상태로 변경

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isCompact ? 16 : 12),
      child: Container(
        width: double.infinity,
        padding: widget.isCompact 
            ? const EdgeInsets.symmetric(vertical: 4, horizontal: 0)
            : const EdgeInsets.all(16),
        decoration: widget.isCompact 
            ? null 
            : BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
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
            // 상단: [단어] [눈 버튼] ----- [배지]
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.hanja,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: HanjaColors.primary,
                            fontSize: 16,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 눈(Visibility) 토글 버튼
                      GestureDetector(
                        onTap: () => setState(() => _isVisible = !_isVisible),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            _isVisible ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: HanjaColors.outlineVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.category != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.category == '성어'
                          ? HanjaColors.tertiaryContainer.withValues(alpha: 0.1)
                          : HanjaColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.category!,
                      style: textTheme.labelSmall?.copyWith(
                        color: widget.category == '성어' ? HanjaColors.tertiary : HanjaColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4), // 2 -> 4 여백 확대
            // 독음 (한자 어휘 아래 + 보이기/숨기기 연동)
            Text(
              _isVisible ? widget.reading : '???',
              style: textTheme.titleSmall?.copyWith(
                color: _isVisible ? const Color(0xFF9A9DA0) : HanjaColors.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
                fontSize: 14, // 12 -> 14 상향
              ),
            ),
            const SizedBox(height: 6),
            // 하단: 뜻풀이
            Text(
              widget.meaning,
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
