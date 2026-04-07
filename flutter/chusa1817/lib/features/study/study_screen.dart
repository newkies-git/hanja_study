import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:drift/drift.dart' show Value;

import '../../core/providers/app_providers.dart';
import '../../core/study/stroke_evaluator.dart';
import '../../core/utils/stroke_svg_render.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings_keys.dart';
import 'widgets/practice_action_tile.dart';
import 'widgets/writing_canvas_widget.dart';
import '../../core/database/app_database.dart';

/// 한자 쓰기 연습 화면.
///
/// [WritingCanvasWidget]으로 실제 터치 입력을 받고,
/// [WritingCanvasController]를 통해 초기화·되돌리기를 제어한다.
/// 획 판정은 [evaluateStrokes]로 순서·방향·형태를 검사한다.
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
  bool _showAnswerOverlay = false;
  bool _isGraded = false;
  double _accuracy = 0.0;
  bool _isLastResultCorrect = false;
  List<SingleStrokeEvaluation> _lastPerStroke = const [];
  bool _lastStrokeCountMatch = false;

  Future<void> _showScoringGuidePopup() async {
    final settings = ref.read(settingsRepositoryProvider);
    final rawDifficulty = await settings.get(AppSettingsKeys.writingDifficulty);
    final int difficulty = int.tryParse(rawDifficulty ?? '') ?? 0;

    final String difficultyLabel = switch (difficulty) {
      2 => '어려움(2)',
      1 => '보통(1)',
      _ => '쉬움(0)',
    };

    final int basePct = (_accuracy * 100).round();
    final int bonus = 15 * (3 - difficulty);
    final int adjustedPct = (basePct + bonus).clamp(0, 100);
    final int score = _scoreFromAdjustedPercent(adjustedPct);

    final int strokeN = _lastPerStroke.length;
    int passCount(bool Function(SingleStrokeEvaluation e) pick) =>
        _lastPerStroke.where(pick).length;
    String ratioLabel(int pass) {
      if (strokeN <= 0) return '-';
      final pct = ((pass / strokeN) * 100).round();
      return '$pass/$strokeN ($pct%)';
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;
        TextStyle? headerStyle = textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: HanjaColors.onSurface,
        );
        TextStyle? bodyStyle = textTheme.bodySmall?.copyWith(
          height: 1.35,
          color: HanjaColors.onSurface,
        );
        TextStyle? dimStyle = textTheme.bodySmall?.copyWith(
          height: 1.35,
          color: HanjaColors.outline,
        );

        Widget row(String left, String right) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(left, style: dimStyle),
                  Text(right, style: bodyStyle?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            );

        return AlertDialog(
          title: Text('채점 기준', style: headerStyle),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('난도: $difficultyLabel', style: bodyStyle),
                  const SizedBox(height: 8),
                  Text('일치율 산출 근거', style: headerStyle?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    '채점은 가이드 획과 사용자가 쓴 획을 비교하여 획별로 4가지 항목을 평가합니다.\n'
                    '- 시작점 일치(start)\n'
                    '- 끝점 일치(end)\n'
                    '- 방향(direction)\n'
                    '- 형태(shape: DTW 평균거리)\n\n'
                    '각 획은 통과한 항목 수 / 4 로 점수가 계산되고, 전체 일치율은 모든 획 점수의 평균(0~1)을 %로 환산한 값입니다.\n'
                    '※ 획 수가 가이드와 다르면 패널티가 적용됩니다.',
                    style: dimStyle,
                  ),
                  const SizedBox(height: 10),
                  Text('항목별 점수(통과)', style: headerStyle?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  row('획 수 일치', _lastPerStroke.isEmpty ? '-' : (_lastStrokeCountMatch ? '일치' : '불일치')),
                  row('시작점 일치', ratioLabel(passCount((e) => e.startPass))),
                  row('끝점 일치', ratioLabel(passCount((e) => e.endPass))),
                  row('방향', ratioLabel(passCount((e) => e.directionPass))),
                  row('형태(DTW)', ratioLabel(passCount((e) => e.shapePass))),
                  const SizedBox(height: 10),
                  Text(
                    '보정식: 일치율 + 15 × (3 - 난도)\n'
                    '100 초과 시 100으로 제한',
                    style: dimStyle,
                  ),
                  const SizedBox(height: 10),
                  row('일치율', '$basePct%'),
                  row('가산점', '+$bonus'),
                  row('보정 후', '$adjustedPct%'),
                  row('현재 점수(6단계)', '$score'),
                  const SizedBox(height: 12),
                  Text('6단계 점수표', style: headerStyle?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('100~91', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('90~81', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('80~71', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('70~61', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('60~51', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('50~', style: dimStyle),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('100', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('90', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('80', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('70', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('60', style: dimStyle),
                            const SizedBox(height: 4),
                            Text('50', style: dimStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _resetGradingAndInk() {
    setState(() {
      _isGraded = false;
      _accuracy = 0.0;
      _isLastResultCorrect = false;
      _showAnswerOverlay = false;
      _canvasController.reset();
    });
  }

  int _adjustedAccuracyPercent({
    required double accuracy01,
    required int difficulty,
  }) {
    // 쉬움=0, 보통=1, 어려움=2
    // adjusted = pct + 15*(3-difficulty), cap to 100
    final int pct = (accuracy01 * 100).round();
    final int adjusted = pct + (15 * (3 - difficulty));
    return adjusted.clamp(0, 100);
  }

  int _scoreFromAdjustedPercent(int adjustedPct) {
    // 100~91, 90~81, 80~71, 70~61, 60~51, 50~
    if (adjustedPct >= 91) return 100;
    if (adjustedPct >= 81) return 90;
    if (adjustedPct >= 71) return 80;
    if (adjustedPct >= 61) return 70;
    if (adjustedPct >= 51) return 60;
    return 50;
  }

  String _praiseMessageForScore(int score) {
    switch (score) {
      case 100:
        return '완벽해요! 정말 멋져요.';
      case 90:
        return '아주 좋아요! 조금만 더 하면 완벽해요.';
      case 80:
        return '좋아요! 흐름이 점점 안정적이에요.';
      case 70:
        return '괜찮아요! 꾸준히 하면 더 좋아져요.';
      case 60:
        return '잘했어요! 조금만 더 정확하게 해볼까요?';
      case 50:
      default:
        return '좋은 시작이에요! 천천히 따라 쓰면 금방 늘어요.';
    }
  }

  Future<void> _showPraisePopup({
    required int difficulty,
    required double accuracy01,
    required int adjustedPct,
    required int score,
  }) async {
    final textTheme = Theme.of(context).textTheme;
    final String difficultyLabel = switch (difficulty) {
      2 => '어려움',
      1 => '보통',
      _ => '쉬움',
    };

    final (IconData icon, Color color, String badge) = switch (score) {
      100 => (Icons.emoji_events_rounded, const Color(0xFFFFB300), 'S'),
      90 => (Icons.star_rounded, const Color(0xFFFFD54F), 'A'),
      80 => (Icons.thumb_up_rounded, const Color(0xFF66BB6A), 'B'),
      70 => (Icons.rocket_launch_rounded, const Color(0xFF42A5F5), 'C'),
      60 => (Icons.favorite_rounded, const Color(0xFFEF5350), 'D'),
      _ => (Icons.lightbulb_rounded, const Color(0xFF8D6E63), 'E'),
    };

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '채점 결과',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(icon, size: 48, color: color),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        badge,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              difficultyLabel,
              style: textTheme.labelLarge?.copyWith(
                color: HanjaColors.outline,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _praiseMessageForScore(score),
              style: textTheme.bodyMedium?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

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

  Future<void> _confirmGrade() async {
    if (_canvasController.strokeCount == 0 && !_canvasController.hasActiveStroke) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('채점 불가'),
          content: const Text('작성된 획이 없어 채점할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final List<List<Offset>> guideStrokes = (await ref
            .read(hanjaStrokePointsProvider(widget.hanjaId).future))
        .where((s) => s.length >= 2)
        .toList();
    final List<String?> directions =
        await ref.read(hanjaStrokeDirectionsProvider(widget.hanjaId).future);

    final StrokeEvaluationResult result = evaluateStrokes(
      userStrokes: _canvasController.strokes,
      guideStrokes: guideStrokes,
      strokeDirections: directions,
    );

    setState(() {
      _isGraded = true;
      _accuracy = result.overallScore;
      _isLastResultCorrect = result.isCorrect;
      _lastPerStroke = result.perStroke;
      _lastStrokeCountMatch = result.strokeCountMatch;
    });

    // 난도(쉬움/보통/어려움)를 가져와 점수 산정 및 칭찬 팝업 표시
    final settings = ref.read(settingsRepositoryProvider);
    final rawDifficulty = await settings.get(AppSettingsKeys.writingDifficulty);
    final int difficulty = int.tryParse(rawDifficulty ?? '') ?? 0;
    final int adjustedPct = _adjustedAccuracyPercent(
      accuracy01: result.overallScore,
      difficulty: difficulty,
    );
    final int score = _scoreFromAdjustedPercent(adjustedPct);
    if (!mounted) return;
    await _showPraisePopup(
      difficulty: difficulty,
      accuracy01: result.overallScore,
      adjustedPct: adjustedPct,
      score: score,
    );
  }

  Future<bool> _confirmLeaveIfInkPresent() async {
    if (_canvasController.strokeCount == 0 &&
        !_canvasController.hasActiveStroke) {
      return true;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('나가기'),
        content: const Text('필기 내용이 있습니다. 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _onBackPressed() async {
    if (await _confirmLeaveIfInkPresent()) {
      if (mounted) context.pop();
    }
  }

  Future<void> _finalizeStudy({required bool isCompleted}) async {
    if (isCompleted && _accuracy < 0.5) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('정답률 알림'),
          content: const Text('정답률이 50% 미만입니다.\n학습완료 처리하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('아니오')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('예')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final sessionId = _sessionId;
    if (sessionId != null) {
      await ref.read(studySessionRepositoryProvider).saveAnswer(
            AnswerHistoryTableCompanion.insert(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              sessionId: sessionId,
              hanjaId: widget.hanjaId,
              answeredAt: DateTime.now(),
              isCorrect: _isLastResultCorrect,
              accuracyScore: Value(_accuracy),
              strokesJson: Value(jsonEncode(_canvasController.strokes.map((s) => s.map((p) => [p.dx, p.dy]).toList()).toList())),
            ),
          );
      await ref.read(studySessionRepositoryProvider).endSession(
            sessionId,
            correctCount: _isLastResultCorrect ? 1 : 0,
          );
    }

    await ref.read(progressRepositoryProvider).upsertProgressByHanjaId(
          hanjaId: widget.hanjaId,
          studiedAt: DateTime.now(),
          isCorrect: _isLastResultCorrect,
          isBookmarked: isCompleted, // 학습완료 시 책갈피
          forceStatus: isCompleted ? 'mastered' : 'learning',
        );

    if (!mounted) return;
    
    // 다음 한자 탐색
    final todayListAsync = ref.read(todayLearningHanjaListProvider);
    final list = todayListAsync.value ?? [];
    final currentIndex = list.indexWhere((e) => e.$1.id == widget.hanjaId);
    
    if (currentIndex != -1 && currentIndex < list.length - 1) {
      final nextHanja = list[currentIndex + 1].$1;
      final meaning = '${nextHanja.meaning} ${nextHanja.reading}'.trim();
      context.pushReplacement(
        '${AppRoutes.study}/${nextHanja.id}?meaning=${Uri.encodeComponent(meaning)}',
      );
    } else {
      _navigateToPracticeResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hanjaAsync = ref.watch(hanjaByIdProvider(widget.hanjaId));
    final guideVisualAsync = ref.watch(hanjaStrokeVisualProvider(widget.hanjaId));

    if (hanjaAsync.isLoading) {
      return const Scaffold(
        backgroundColor: HanjaColors.surface,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (hanjaAsync.hasError) {
      return Scaffold(
        backgroundColor: HanjaColors.surface,
        body: SafeArea(
          child: Center(
            child: Text(
              '한자 정보를 불러오지 못했습니다.\n${hanjaAsync.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final hanjaRow = hanjaAsync.value;
    if (hanjaRow == null) {
      return const Scaffold(
        backgroundColor: HanjaColors.surface,
        body: SafeArea(
          child: Center(child: Text('해당 한자를 찾을 수 없습니다.')),
        ),
      );
    }

    final hanja = hanjaRow.character;
    final HanjaStrokeVisual? guideVisual = guideVisualAsync.value;
    final guideStrokes =
        guideVisual?.polylineStrokes.where((s) => s.length >= 2).toList();
    final int totalStrokes = guideStrokes?.length ?? hanjaRow.totalStrokes;

    List<Path>? overlayGuidePathsInView;
    List<List<Offset>>? overlayGuidePolylines;
    if (_showAnswerOverlay && guideVisual != null) {
      final List<String>? svg = guideVisual.svgPaths;
      if (svg != null && svg.isNotEmpty) {
        overlayGuidePathsInView = pathsInViewCoordinates(svg);
      } else if (guideStrokes != null && guideStrokes.isNotEmpty) {
        overlayGuidePolylines = guideStrokes;
      }
    }

    return ListenableBuilder(
      listenable: _canvasController,
      builder: (context, _) {
        final bool canPopWithoutPrompt = _canvasController.strokeCount == 0 &&
            !_canvasController.hasActiveStroke;
        return PopScope(
          canPop: canPopWithoutPrompt,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            if (await _confirmLeaveIfInkPresent()) {
              if (context.mounted) context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: HanjaColors.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _PracticeTopBar(
                    title: '추사 1817',
                    progress: totalStrokes == 0
                        ? 0.0
                        : (_canvasController.strokeCount / totalStrokes)
                            .clamp(0.0, 1.0),
                    onBack: _onBackPressed,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      children: [
                        _buildHanjaInfoRow(context, totalStrokes: totalStrokes),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: WritingCanvasWidget(
                              hanja: hanja,
                              controller: _canvasController,
                              showGuide: false,
                              guidePathsInView: overlayGuidePathsInView,
                              guideNormalizedStrokes: overlayGuidePolylines,
                            ),
                          ),
                        ),
                  if (guideVisualAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '획순 데이터를 불러오지 못했습니다.\n${guideVisualAsync.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: HanjaColors.onSurfaceVariant,
                            ),
                      ),
                    ),
                        const SizedBox(height: 22),
                        IgnorePointer(
                          ignoring: _canvasController.hasActiveStroke,
                          child: _buildActionGrid(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHanjaInfoRow(BuildContext context, {required int totalStrokes}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final hanjaAsync = ref.watch(hanjaByIdProvider(widget.hanjaId));
    final meaning = hanjaAsync.value == null
        ? widget.meaning
        : '${hanjaAsync.value!.meaning} (${hanjaAsync.value!.reading})';

    return Row(
      children: [
        Expanded(
          child: Column(
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
        ),
        GhostButton(
          label: '정답 보기',
          icon: _showAnswerOverlay ? Icons.visibility : Icons.visibility_off,
          onPressed: _toggleAnswerOverlay,
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // 상단 행: 기본 도구 및 확인 버튼 (항상 노출)
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: PracticeActionTile(
                  icon: Icons.restart_alt,
                  onTap: () {
                    setState(() {
                      _isGraded = false;
                      _canvasController.reset();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PracticeActionTile(
                  icon: Icons.undo,
                  onTap: _canvasController.undo,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PracticeActionTile(
                  icon: Icons.lightbulb_outline,
                  onTap: _showHint,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: PracticeActionTile(
                  icon: _isGraded ? Icons.refresh_rounded : null,
                  label: _isGraded ? '다시' : '채점',
                  variant: PracticeActionTileVariant.primary,
                  onTap: _isGraded ? _resetGradingAndInk : _confirmGrade,
                ),
              ),
            ),
          ],
        ),
        
        // 하단 행: 처리 버튼 (확인 버튼을 누른 후에만 노출)
        if (_isGraded) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showScoringGuidePopup,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '일치율',
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: HanjaColors.onSurface,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(_accuracy * 100).toStringAsFixed(2)} %',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: HanjaColors.onSurface,
                                    letterSpacing: -0.2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: HanjaColors.outlineVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: PracticeActionTile(
                    icon: Icons.check_circle_rounded,
                    label: '완료',
                    variant: PracticeActionTileVariant.primary,
                    onTap: () => _finalizeStudy(isCompleted: true),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: PracticeActionTile(
                    icon: Icons.arrow_forward_rounded,
                    label: '다음',
                    variant: PracticeActionTileVariant.primary,
                    onTap: () => _finalizeStudy(isCompleted: false),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 학습 화면 상단 한자 썸네일 카드.
/// 쓰기 연습 상단 바 (진도 프로그레스 바 포함).
class _PracticeTopBar extends StatelessWidget {
  const _PracticeTopBar({
    required this.title,
    required this.progress,
    required this.onBack,
  });

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
                    child: Center(
                      child: Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          color: HanjaColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // 좌측 하단 버튼과 균형을 맞추기 위한 여백
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
