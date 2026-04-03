import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 기본 정보 탭 화면.
/// 부수, 총획, 유래 텍스트 등을 표시한다.
class HanjaInfoTab extends StatelessWidget {
  const HanjaInfoTab({
    super.key,
    required this.originText,
  });

  final String originText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
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
