import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

/// 앱 진입 랜딩 화면.
///
/// 비회원 학습 시작과 로그인 두 가지 CTA를 제공한다.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.list, color: HanjaColors.onSurface),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "The Scholar's Editorial",
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: HanjaColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: HanjaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Welcome to Learning',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  'Master the art of Hanja with our curated educational journal interface.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: HanjaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('${AppRoutes.home}?tab=1'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: HanjaColors.primaryContainer,
                      side: BorderSide(
                        color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('학습 시작하기'),
                  ),
                ),
                const SizedBox(height: 12),
                GradientPrimaryButton(
                  label: '로그인',
                  onPressed: () => context.push(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
