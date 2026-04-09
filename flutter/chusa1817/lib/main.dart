import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/firebase/initial_content_sync.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/hanja_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  runApp(
    const ProviderScope(
      child: InitialContentSync(child: HanjaApp()),
    ),
  );
}

/// 한자정습 앱의 루트 위젯.
class HanjaApp extends StatelessWidget {
  const HanjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HanjaAppBody();
  }
}

class _HanjaAppBody extends ConsumerWidget {
  const _HanjaAppBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '추사 1817',
      debugShowCheckedModeBanner: false,
      theme:      HanjaTheme.light(),
      darkTheme:  HanjaTheme.dark(),
      themeMode:  themeMode,
      routerConfig: router,
    );
  }
}
