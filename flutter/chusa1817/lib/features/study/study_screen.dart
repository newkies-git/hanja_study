import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:drift/drift.dart' show Value;

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../core/router/app_router.dart';
import 'widgets/practice_action_tile.dart';
import 'widgets/writing_canvas_widget.dart';
import '../../core/database/app_database.dart';

/// 한자 쓰기 연습 화면.
///
/// [WritingCanvasWidget]으로 실제 터치 입력을 받고,
/// [WritingCanvasController]를 통해 초기화·되돌리기를 제어한다.
/// 획 판정은 Phase 2 엔진 연동 전까지 Mock으로 처리한다.
class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({
    super.key,
    required this.hanjaId,
    this.meaning = '',
  });

  final String hanjaId;
  final String meaning;

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  final WritingCanvasController _canvasController = WritingCanvasController();
  String? _sessionId;
  bool _showAnswerOverlay = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(studySessionRepositoryProvider);
      final id = await repo.startSession('review');
      if (!mounted) return;
      setState(() => _sessionId = id);
    });
  }

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }

  void _navigateToPracticeResult() {
    context.push(AppRoutes.practiceResult);
  }

  void _showHint() {
    setState(() => _showAnswerOverlay = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showAnswerOverlay = false);
    });
  }

  void _toggleAnswerOverlay() {
    setState(() => _showAnswerOverlay = !_showAnswerOverlay);
  }

  Future<void> _gradeAndSave() async {
    final guideStrokesAsync = ref.read(hanjaStrokePointsProvider(widget.hanjaId));
    final guideStrokes = guideStrokesAsync.valueOrNull?.where((s) => s.length >= 2).toList() ?? const [];

    final int expected = guideStrokes.length;
    final int actual = _canvasController.strokeCount;
    final bool isCorrect = expected > 0 && actual == expected;

    final sessionId = _sessionId;
    if (sessionId != null) {
      await ref.read(studySessionRepositoryProvider).saveAnswer(
            AnswerHistoryTableCompanion.insert(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              sessionId: sessionId,
              hanjaId: widget.hanjaId,
              answeredAt: DateTime.now(),
              isCorrect: isCorrect,
              accuracyScore: Value(expected == 0 ? 0.0 : (actual / expected).clamp(0.0, 1.0)),
              strokesJson: Value(jsonEncode(_canvasController.strokes.map((s) => s.map((p) => [p.dx, p.dy]).toList()).toList())),
            ),
          );
      await ref.read(studySessionRepositoryProvider).endSession(
            sessionId,
            correctCount: isCorrect ? 1 : 0,
          );
    }

    await ref.read(progressRepositoryProvider).upsertProgressByHanjaId(
          hanjaId: widget.hanjaId,
          studiedAt: DateTime.now(),
          isCorrect: isCorrect,
        );

    if (!mounted) return;
    _navigateToPracticeResult();
  }

  @override
  Widget build(BuildContext context) {
    final hanjaAsync = ref.watch(hanjaByIdProvider(widget.hanjaId));
    final hanja = hanjaAsync.value?.character ?? '';
    final guideStrokesAsync = ref.watch(hanjaStrokePointsProvider(widget.hanjaId));
    final guideStrokes =
        guideStrokesAsync.valueOrNull?.where((s) => s.length >= 2).toList();
    final int totalStrokes =
        guideStrokes?.length ?? (hanjaAsync.value?.totalStrokes ?? 0);

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
                progress: totalStrokes == 0
                    ? 0.0
                    : (_canvasController.strokeCount / totalStrokes).clamp(0.0, 1.0),
                onBack: () => context.pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  _buildHanjaInfoRow(context, totalStrokes: totalStrokes),
                  const SizedBox(height: 18),
                  AspectRatio(
                    aspectRatio: 1,
                    child: WritingCanvasWidget(
                      hanja: hanja,
                      controller: _canvasController,
                      guideNormalizedStrokes: _showAnswerOverlay ? guideStrokes : null,
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

  Widget _buildHanjaInfoRow(BuildContext context, {required int totalStrokes}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final hanjaAsync = ref.watch(hanjaByIdProvider(widget.hanjaId));
    final hanja = hanjaAsync.value?.character ?? '';
    final meaning = hanjaAsync.value == null
        ? widget.meaning
        : '${hanjaAsync.value!.meaning} (${hanjaAsync.value!.reading})';

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    hanja,
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
                  Text(meaning, style: textTheme.headlineSmall),
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
                          '획 ${_canvasController.strokeCount} / ${totalStrokes == 0 ? '-' : totalStrokes}',
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
          onPressed: _showHint,
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
          onTap: _toggleAnswerOverlay,
        ),
        PracticeActionTile(
          icon: Icons.arrow_forward,
          label: '완료',
          variant: PracticeActionTileVariant.primary,
          onTap: _gradeAndSave,
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
