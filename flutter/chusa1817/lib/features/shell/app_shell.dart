import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_bottom_nav.dart';
import '../home/home_screen.dart';
import '../learn/learn_list_screen.dart';
import '../review/review_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';

/// 앱 메인 셸 (바텀 내비게이션 기반 화면 컨테이너).
///
/// [initialIndex]로 초기 선택 탭을 지정할 수 있다 (기본값: 0 = 홈).
///
/// 탭 구성:
///   0 = 홈 (HomeScreen)
///   1 = 학습 (LearnListScreen)
///   2 = 복습 (ReviewScreen)
///   3 = 통계 (StatisticsScreen)
///   4 = 프로필 (ProfileScreen)
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  static const List<Widget> _pages = [
    HomeScreen(),
    LearnListScreen(),
    ReviewScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: EditorialBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
