import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/ghost_button.dart';
import 'practice_result_screen.dart';
import 'widgets/practice_canvas_card.dart';
import 'widgets/practice_action_tile.dart';

/// 한자 쓰기 연습 화면.
///
/// 현재 학습 한자와 진행 획 정보를 상단에 표시하고,
/// [PracticeCanvasCard] (쓰기 캔버스)와 4개의 [PracticeActionTile]을 제공한다.
///
/// Phase 2에서 실제 터치 입력(Gesture → stroke 좌표) 및 획순 판정 엔진이 추가된다.
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _PracticeTopBar(
              lessonLabel: '제 4강',
              title: '한자정습',
              progress: 0.6,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  _buildHanjaInfoRow(context),
                  const SizedBox(height: 18),
                  const AspectRatio(
                    aspectRatio: 1,
                    child: PracticeCanvasCard(hanja: '佳', showNudge: true),
                  ),
                  const SizedBox(height: 22),
                  _buildActionGrid(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHanjaInfoRow(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '佳',
                    style: textTheme.displayMedium?.copyWith(
                      color: HanjaColors.onSurface.withValues(alpha: 0.1),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('참조', style: textTheme.labelSmall),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('아름다울 (가)', style: textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.draw,
                        size: 16,
                        color: HanjaColors.primaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '획 3 / 8',
                        style: textTheme.bodyMedium?.copyWith(
                          color: HanjaColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        GhostButton(
          label: '힌트',
          icon: Icons.lightbulb_outline,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        PracticeActionTile(
          icon: Icons.restart_alt,
          label: '초기화',
          onTap: () {},
        ),
        PracticeActionTile(
          icon: Icons.undo,
          label: '되돌리기',
          onTap: () {},
        ),
        PracticeActionTile(
          icon: Icons.visibility,
          label: '정답 보기',
          onTap: () {},
        ),
        PracticeActionTile(
          icon: Icons.arrow_forward,
          label: '완료',
          variant: PracticeActionTileVariant.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PracticeResultScreen()),
          ),
        ),
      ],
    );
  }
}

/// 쓰기 연습 상단 바 (진도 프로그레스 바 포함).
class _PracticeTopBar extends StatelessWidget {
  const _PracticeTopBar({
    required this.lessonLabel,
    required this.title,
    required this.progress,
    required this.onBack,
  });

  final String lessonLabel;
  final String title;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lessonLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: HanjaColors.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(title, style: textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 4,
            color: HanjaColors.surfaceContainerLow,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: HanjaColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
