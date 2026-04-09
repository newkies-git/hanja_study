import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';

/// ALL-CAPS 태그 + 한국어 제목으로 구성된 섹션 헤더.
///
/// 복습·퀴즈·퀴즈 결과 화면에서 공통으로 사용한다.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.tagColor = HanjaColors.primaryContainer,
  });

  final String tag;
  final String title;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tag,
          style: textTheme.labelSmall?.copyWith(
            color: tagColor,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
