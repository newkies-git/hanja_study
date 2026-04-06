import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/hanja_colors.dart';

/// 프리미엄 에디토리얼 사이드 드로어.
///
/// Glassmorphism 효과와 세련된 브랜드 요소를 적용하여
/// 앱 전체의 디자인 일관성을 유지한다.
class EditorialDrawer extends StatelessWidget {
  const EditorialDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.userName = '추사학도',
    this.userEmail = 'scholar@chusa1817.app',
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: Colors.transparent, // Glassmorphism을 위해 투명화
      child: Stack(
        children: [
          // 1. 배경 이미지 및 블러 효과
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),

          // 2. 콘텐츠 영역
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더: 사용자 프로필 섹션
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: HanjaColors.primaryFixed.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0] : 'C',
                            style: textTheme.headlineMedium?.copyWith(
                              color: HanjaColors.primaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                const SizedBox(height: 20),

                // 메뉴 아이템 리스트
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _DrawerMenuItem(
                        icon: Icons.home_outlined,
                        label: '홈',
                        isSelected: selectedIndex == 0,
                        onTap: () => onItemSelected(0),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.menu_book_outlined,
                        label: '사전',
                        isSelected: selectedIndex == 1,
                        onTap: () => onItemSelected(1),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.replay_circle_filled_outlined,
                        label: '복습 노트',
                        isSelected: selectedIndex == 2,
                        onTap: () => onItemSelected(2),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.quiz_outlined,
                        label: '퀴즈',
                        isSelected: selectedIndex == 3,
                        onTap: () => onItemSelected(3),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.analytics_outlined,
                        label: '학습 통계',
                        isSelected: selectedIndex == 4,
                        onTap: () => onItemSelected(4),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About 추사1817',
                        isSelected: false,
                        onTap: () {
                          final ScaffoldState? scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.isDrawerOpen ?? false) {
                            Navigator.of(context).pop();
                          }
                          context.push(AppRoutes.about);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 메뉴 아이템 위젯.
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48, // 프리미엄 42px 규격을 상회하는 클릭 영역 확보
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
