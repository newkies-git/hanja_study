import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_bottom_nav.dart';
import '../home/home_screen.dart';
import '../learn/learn_list_screen.dart';
import '../review/review_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/editorial_drawer.dart';
import '../../core/auth/auth_providers.dart';

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
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
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
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
      });
    }
  }

  void _onNavigationItemTap(int index) {
    setState(() => _selectedIndex = index);
    if (context.mounted && Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context); // Drawer 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      appBar: null, // EditorialTopBar는 각 페이지 내부에 위치함
      drawer: EditorialDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationItemTap,
        userName: user?.displayName ?? '추사학도',
        userEmail: user?.email ?? 'scholar@chusa1817.app',
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: EditorialBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
