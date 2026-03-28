import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/hanja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  runApp(const ProviderScope(child: HanjaApp()));
}

/// 한자정습 앱의 루트 위젯.
///
/// [HanjaTheme.light()]로 전역 테마를 설정하고
/// [appRouter]를 통해 선언형 라우팅을 사용한다.
class HanjaApp extends StatelessWidget {
  const HanjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '추사 1817',
      debugShowCheckedModeBanner: false,
      theme: HanjaTheme.light(),
      routerConfig: appRouter,
    );
  }
}

