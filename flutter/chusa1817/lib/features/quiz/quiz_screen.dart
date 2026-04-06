import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';

/// 퀴즈(객관식·뜻 맞추기 등) 전용 탭.
///
/// 콘텐츠·문항 로직은 추후 연동. 현재는 IA·내비게이션 자리 확보용 플레이스홀더다.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const EditorialTopBar(title: '퀴즈'),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 56,
                color: HanjaColors.neutralIcon.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                '퀴즈 모드 준비 중',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: HanjaColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '뜻·음·획순 등 문제 유형과 PRD 시험 모드 요구사항에 맞춰\n추가할 예정입니다.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
