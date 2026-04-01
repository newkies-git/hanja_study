import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';
import '../../../shared/widgets/stroke_hint_overlay.dart';

/// 쓰기 연습 캔버스 카드.
///
/// [WonGoJiGrid] 배경 위에 참조용 한자([hanja])를 투명하게 표시하고,
/// [StrokeHintOverlay]로 현재 획 힌트를 제공한다.
///
/// [showNudge]가 true이면 상단에 "훌륭해요! 다음 획" 넛지 배너를 표시한다.
class PracticeCanvasCard extends StatelessWidget {
  const PracticeCanvasCard({
    super.key,
    required this.hanja,
    this.showNudge = false,
  });

  final String hanja;
  final bool showNudge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: HanjaColors.legacyShadow,
                blurRadius: 32,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned.fill(child: WonGoJiGrid(opacity: 0.18)),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      hanja,
                      style: textTheme.displayLarge?.copyWith(
                        color: HanjaColors.legacyNeutralIcon.withValues(alpha: 0.25),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(child: StrokeHintOverlay()),
              ],
            ),
          ),
        ),
        if (showNudge) _NudgeBanner(textTheme: textTheme),
      ],
    );
  }
}

/// 획 성공 넛지 배너.
class _NudgeBanner extends StatelessWidget {
  const _NudgeBanner({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: HanjaColors.secondary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '훌륭해요! 다음 획',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
