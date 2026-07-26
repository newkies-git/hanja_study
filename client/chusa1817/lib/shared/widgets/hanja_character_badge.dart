import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/hanja_colors.dart';

/// 한자 한 글자를 둥근 사각형 배지로 표시하는 공유 위젯.
///
/// 리뷰 카드·오답노트·퀴즈 결과 등 여러 화면에서 동일하게 사용한다.
class HanjaCharacterBadge extends StatelessWidget {
  const HanjaCharacterBadge({
    super.key,
    required this.character,
    this.size = 56,
  });

  final String character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HanjaColors.primaryFixed,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: Text(
          character,
          style: GoogleFonts.notoSerif(
            fontSize: size * 0.44,
            color: HanjaColors.primaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
