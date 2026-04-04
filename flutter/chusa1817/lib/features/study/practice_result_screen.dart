import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/providers/app_providers.dart';

/// 쓰기 연습 완료 결과 화면.
///
/// 오늘 학습한 한자 수와 획득 EXP를 표시하며,
/// 홈 또는 통계 화면으로 이동하는 CTA를 제공한다.
class PracticeResultScreen extends ConsumerWidget {
  const PracticeResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final todayCompletedAsync = ref.watch(todayCompletedCountProvider);

    return Scaffold(
      backgroundColor: HanjaColors.surfaceSoft,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _buildAppBar(context, textTheme),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  _buildResultBadge(),
                  const SizedBox(height: 32),
                  Text(
                    '오늘의 학습 완료!',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: HanjaColors.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '위대한 학문의 길에 한 걸음 더 다가섰습니다.\n꾸준함이 탁월함을 만듭니다.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: HanjaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildScoreCard(textTheme, todayCompletedAsync),
                  const SizedBox(height: 48),
                  GradientPrimaryButton(
                    label: '홈으로 돌아가기',
                    onPressed: () {
                      ref.invalidate(todayCompletedCountProvider); // 홈으로 갈 때 진도 데이터 갱신
                      context.go(AppRoutes.home);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: HanjaColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        ref.invalidate(todayCompletedCountProvider);
                         context.go('${AppRoutes.home}?tab=3');
                      },
                      child: Text(
                        '학습 통계 보기',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "The Scholar's Editorial",
          style: textTheme.titleMedium?.copyWith(
            fontFamily: 'NotoSerifKR',
            fontWeight: FontWeight.w900,
            color: HanjaColors.outline,
            letterSpacing: 0.5,
          ),
        ),
        IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.close_rounded, color: HanjaColors.onSurfaceVariant),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBadge() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer subtle pulse ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: HanjaColors.secondaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Inner shiny badge
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  HanjaColors.secondaryContainer,
                  Color(0xFF69F0AE), // Brighter pastel green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HanjaColors.secondary.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 4,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 72,
                color: HanjaColors.secondary,
              ),
            ),
          ),
          // Tiny decorative sparkles
          Positioned(
            top: 10,
            right: 20,
            child: Icon(Icons.auto_awesome, color: Colors.amber.shade400, size: 28),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Icon(Icons.auto_awesome, color: Colors.amber.shade300, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(TextTheme textTheme, AsyncValue<int> todayCompletedAsync) {
    // 실제 데이터와 경험치 경험치 연산 (임시 공식: 1자당 30 EXP)
    final int count = todayCompletedAsync.value ?? 0;
    final int exp = count * 30; 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: HanjaColors.shadow.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: HanjaColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'TODAY\'S ACHIEVEMENTS',
            style: textTheme.labelSmall?.copyWith(
              color: HanjaColors.primaryContainer,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(textTheme, '학습 완료', '$count', '字'),
              Container(
                width: 1.5,
                height: 50,
                color: HanjaColors.surfaceVariant,
              ),
              _buildStatItem(textTheme, '총 경험치', '$exp', 'EXP', isAccent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(TextTheme textTheme, String label, String value, String unit, {bool isAccent = false}) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: HanjaColors.outline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: textTheme.displayMedium?.copyWith(
                color: isAccent ? HanjaColors.secondary : HanjaColors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: textTheme.titleMedium?.copyWith(
                color: isAccent ? HanjaColors.secondary.withValues(alpha: 0.8) : HanjaColors.outline,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
