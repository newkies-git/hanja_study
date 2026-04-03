import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 상단의 원고지 배경을 가진 큰 한자 렌더링 컨테이너
class HanjaHeroSection extends StatelessWidget {
  const HanjaHeroSection({
    super.key,
    required this.hanja,
    required this.meaning,
  });

  final String hanja;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: 320,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: WonGoJiGrid(opacity: 0.12)),
                  Center(
                    child: Text(
                      hanja,
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 120,
                        color: HanjaColors.primary,
                        height: 1,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 14,
                    right: 14,
                    child: Icon(Icons.star, color: HanjaColors.tertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '뜻과 음',
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.neutralIcon,
            letterSpacing: 3.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meaning,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 40,
            color: HanjaColors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
