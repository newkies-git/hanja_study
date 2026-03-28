import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../study/study_screen.dart';

/// 홈 화면.
///
/// 학습 시작 CTA와 연습 바로가기 버튼을 중심으로 구성된다.
/// Phase 2에서 오늘의 학습 진도, 추천 한자, 연속 학습일 위젯이 추가된다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: "The Scholar's Editorial"),
        const SizedBox(height: 10),
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
        Column(
          children: [
            SizedBox(
              height: 56,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
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
              label: '연습 바로가기',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudyScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
