import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 상단의 원고지 배경을 가진 큰 한자 렌더링 컨테이너
class HanjaHeroSection extends StatelessWidget {
  const HanjaHeroSection({
    super.key,
    required this.hanja,
    required this.meaning,
    required this.radical,
    required this.totalStrokes,
  });

  final String hanja;
  final String meaning;
  final String radical;
  final int totalStrokes;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 좌측: 한자 카드 ──────────────────────────────────────────
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: HanjaColors.outlineVariant.withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: WonGoJiGrid(opacity: 0.15)),
                    Center(
                      child: Text(
                        hanja,
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 90,
                          color: HanjaColors.primary,
                          height: 1,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(Icons.star, color: HanjaColors.tertiary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── 우측: 정보 그리드 ──────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // 뜻과 음 상자
                Expanded(
                  flex: 2,
                  child: _InfoBox(
                    label: '뜻과 음',
                    value: meaning,
                    valueStyle: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: HanjaColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 부수 / 총획 (2열 분할)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          label: '부수',
                          value: radical,
                          valueStyle: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: HanjaColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoBox(
                          label: '총획',
                          value: '$totalStrokes',
                          valueStyle: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: HanjaColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 그리드 내의 개별 상자 위젯.
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HanjaColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // 레이블 영역 (연회색 배경)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F5), // HanjaColors.surfaceContainerLow 추천
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: const Color(0xFF9A9DA0),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          // 값 영역
          Expanded(
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: valueStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
