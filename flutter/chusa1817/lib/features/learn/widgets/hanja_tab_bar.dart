import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 한자 상세 화면 탭 열거형.
enum HanjaDetailTab { info, strokes, words }

/// 중간의 탭 바를 표시한다.
class HanjaTabBar extends StatelessWidget {
  const HanjaTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final HanjaDetailTab activeTab;
  final ValueChanged<HanjaDetailTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DetailTab(
          label: '기본 정보',
          isSelected: activeTab == HanjaDetailTab.info,
          onTap: () => onTabChanged(HanjaDetailTab.info),
        ),
        const Spacer(),
        _DetailTab(
          label: '획순 보기',
          isSelected: activeTab == HanjaDetailTab.strokes,
          onTap: () => onTabChanged(HanjaDetailTab.strokes),
        ),
        const Spacer(),
        _DetailTab(
          label: '관련 단어',
          isSelected: activeTab == HanjaDetailTab.words,
          onTap: () => onTabChanged(HanjaDetailTab.words),
        ),
      ],
    );
  }
}

/// 탭 선택 버튼.
class _DetailTab extends StatelessWidget {
  const _DetailTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = isSelected
        ? HanjaColors.primary
        : const Color(0xFFC3C5D7); // 옅은 회색/파란색 톤

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? HanjaColors.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foregroundColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 15,
              ),
        ),
      ),
    );
  }
}
