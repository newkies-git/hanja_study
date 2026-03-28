import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';

/// 쓰기 연습 화면의 액션 타일 스타일 열거형.
enum PracticeActionTileVariant { neutral, primary }

/// 쓰기 연습 그리드 액션 타일.
///
/// [variant]가 [PracticeActionTileVariant.primary]이면 그라디언트 배경이 적용된다.
/// 초기화, 되돌리기, 정답 보기, 완료 버튼에 사용된다.
class PracticeActionTile extends StatelessWidget {
  const PracticeActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.variant = PracticeActionTileVariant.neutral,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final PracticeActionTileVariant variant;

  bool get _isPrimary => variant == PracticeActionTileVariant.primary;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: _isPrimary ? null : HanjaColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _isPrimary
                ? const LinearGradient(
                    colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: _isPrimary ? Colors.white : HanjaColors.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: _isPrimary ? Colors.white : HanjaColors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
