import 'package:flutter/material.dart';

import 'core/theme/hanja_theme.dart';
import 'features/landing/landing_screen.dart';

void main() {
  runApp(const HanjaApp());
}

/// 한자정습 앱의 루트 위젯.
///
/// [HanjaTheme.light()]로 전역 테마를 설정하고
/// [LandingScreen]을 초기 화면으로 지정한다.
class HanjaApp extends StatelessWidget {
  const HanjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한자정습',
      debugShowCheckedModeBanner: false,
      theme: HanjaTheme.light(),
      home: const LandingScreen(),
    );
  }
}
