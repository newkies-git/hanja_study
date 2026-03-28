import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../shell/app_shell.dart';

/// 쓰기 연습 완료 결과 화면.
///
/// 오늘 학습한 한자 수와 획득 EXP를 표시하며,
/// 홈 또는 통계 화면으로 이동하는 CTA를 제공한다.
class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            _buildAppBar(context, textTheme),
            const SizedBox(height: 18),
            _buildResultBadge(),
            const SizedBox(height: 18),
            Text(
              '오늘의 학습 완료!',
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(
              '위대한 학문의 길에 한 걸음 더 다가섰습니다.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: HanjaColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            _buildScoreCard(textTheme),
            const SizedBox(height: 16),
            GradientPrimaryButton(
              label: '홈으로 돌아가기',
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AppShell(initialIndex: 0),
                ),
                (route) => false,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HanjaColors.surfaceContainerHigh,
                  foregroundColor: HanjaColors.onSurface,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const AppShell(initialIndex: 2),
                  ),
                  (route) => false,
                ),
                child: Text(
                  '학습 통계 보기',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "The Scholar's Editorial",
            style: textTheme.titleLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              color: HanjaColors.primaryContainer,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildResultBadge() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: HanjaColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 128,
            height: 128,
            decoration: const BoxDecoration(
              color: HanjaColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 64,
              color: HanjaColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: HanjaColors.outlineVariant.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL CHARACTERS LEARNED',
            style: textTheme.labelMedium?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '5',
            style: textTheme.displayLarge?.copyWith(
              color: HanjaColors.primaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: HanjaColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+150 EXP',
              style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
