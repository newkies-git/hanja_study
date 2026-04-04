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
    this.icon,
    this.label,
    required this.onTap,
    this.variant = PracticeActionTileVariant.neutral,
    this.subLabel,
  }) : assert(icon != null || label != null, 'Icon or Label must be provided');

  final IconData? icon;
  final String? label;
  final String? subLabel; // 아이콘 아래 추가 표시용 (정답률 등)
  final VoidCallback onTap;
  final PracticeActionTileVariant variant;

  bool get _isPrimary => variant == PracticeActionTileVariant.primary;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: _isPrimary ? Colors.white : HanjaColors.onSurface,
                    size: 24,
                  ),
                if (icon != null && label != null)
                  const SizedBox(height: 4),
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      color: _isPrimary ? Colors.white : HanjaColors.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (subLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subLabel!,
                    style: TextStyle(
                      color: _isPrimary 
                          ? Colors.white.withValues(alpha:0.8) 
                          : HanjaColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
