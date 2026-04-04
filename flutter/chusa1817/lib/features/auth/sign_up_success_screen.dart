import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';

class SignUpSuccessScreen extends ConsumerWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    
    // 로컬 DB(Drift)에서 사용자 프로필 정보 구독
    final profileAsync = ref.watch(currentUserProfileProvider);
    final String displayName = profileAsync.when(
      data: (profile) => profile?.displayName ?? '선비님',
      loading: () => '선비님',
      error: (_, __) => '선비님',
    );

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: HanjaColors.outlineVariant.withAlpha(25)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: const Icon(Icons.history_edu, size: 80, color: HanjaColors.primary),
                      ),
                      Positioned(
                        bottom: -8,
                        right: -8,
                        child: Transform.rotate(
                          angle: 0.2, // 12 degrees approx
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: HanjaColors.tertiary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 5)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '印',
                                style: textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text.rich(
                    TextSpan(
                      text: '환영합니다, ',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: displayName.endsWith('님') ? '$displayName!' : '$displayName님!',
                          style: textTheme.headlineSmall?.copyWith(color: HanjaColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '새로운 배움의 여정이 시작되었습니다.',
                    style: textTheme.titleMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: GradientPrimaryButton(
                      label: '학습 시작하기',
                      onPressed: () => context.go(AppRoutes.planSettings),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: HanjaColors.primary,
                        side: BorderSide(color: HanjaColors.primary.withAlpha(50)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('홈으로 가기', style: TextStyle(fontWeight: FontWeight.w800)),
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
