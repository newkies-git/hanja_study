import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 앱 전체 하단 내비게이션 바.
///
/// 선택된 탭은 [primaryFixed] 배경으로 강조된다.
/// Material 3의 tonal layering 원칙에 따라 그림자 대신 배경 색 변화로 깊이를 표현한다.
class EditorialBottomNav extends StatelessWidget {
  const EditorialBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home, label: '홈'),
    _NavItem(icon: Icons.menu_book, label: '학습'),
    _NavItem(icon: Icons.analytics, label: '통계'),
    _NavItem(icon: Icons.person, label: '내 정보'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _items.length; i++)
                _NavButton(
                  item: _items[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onItemSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 바텀 내비게이션 아이템 데이터 클래스.
class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// 바텀 내비게이션 단일 버튼.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = isSelected
        ? HanjaColors.primaryContainer
        : const Color(0xFF9A9DA0);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: isSelected
              ? HanjaColors.primaryFixed.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: foregroundColor),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
