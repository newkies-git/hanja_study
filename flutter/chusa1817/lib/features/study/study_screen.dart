import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../core/router/app_router.dart';
import 'widgets/practice_action_tile.dart';
import 'widgets/writing_canvas_widget.dart';

/// 한자 쓰기 연습 화면.
///
/// [WritingCanvasWidget]으로 실제 터치 입력을 받고,
/// [WritingCanvasController]를 통해 초기화·되돌리기를 제어한다.
/// 획 판정은 Phase 2 엔진 연동 전까지 Mock으로 처리한다.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, this.hanja = '佳', this.meaning = '아름다울 (가)'});

  final String hanja;
  final String meaning;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final WritingCanvasController _canvasController = WritingCanvasController();
  static const int _totalStrokes = 8;

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }

  void _onComplete() {
    context.push(AppRoutes.practiceResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: _canvasController,
              builder: (context, child) => _PracticeTopBar(
                lessonLabel: '제 4강',
                title: '추사 1817',
                progress: (_canvasController.strokeCount / _totalStrokes).clamp(0.0, 1.0),
                onBack: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  _buildHanjaInfoRow(context),
                  const SizedBox(height: 18),
                  AspectRatio(
                    aspectRatio: 1,
                    child: WritingCanvasWidget(
                      hanja: widget.hanja,
                      controller: _canvasController,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildActionGrid(),
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
                    widget.hanja,
                    style: textTheme.displayMedium?.copyWith(
                      color: HanjaColors.onSurface.withValues(alpha: 0.08),
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
                  Text(widget.meaning, style: textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  ListenableBuilder(
                    listenable: _canvasController,
                    builder: (context, child) => Row(
                      children: [
                        const Icon(
                          Icons.draw,
                          size: 16,
                          color: HanjaColors.primaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '획 ${_canvasController.strokeCount} / $_totalStrokes',
                          style: textTheme.bodyMedium?.copyWith(
                            color: HanjaColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildActionGrid() {
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
          onTap: _canvasController.reset,
        ),
        PracticeActionTile(
          icon: Icons.undo,
          label: '되돌리기',
          onTap: _canvasController.undo,
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
          onTap: _onComplete,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            color: HanjaColors.surfaceContainerLow,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
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
