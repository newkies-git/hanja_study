import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../core/utils/stroke_svg_render.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 획순 재생 팔레트: 미작성 실루엣(회색) + 필기(붉은색) + 끝난 획(검정 계열).
abstract final class _StrokeOrderNaverLikePalette {
  static const Color guideFuture = Color(0xFF9E9E9E); // 미작성 획 실루엣
  /// 지나간 획·전체 완성 후 글자(채운 느낌의 진한 선 + 보조 fill).
  static const Color strokeFinishedBlack = Color(0xFF1A1A1A);
  static const Color ink = Color(0xFFE53935);
}

const Duration _kFinalBlackDelay = Duration(milliseconds: 720);
/// 빨강 채움 완료 후 검정으로 바꾸기 전 유지 시간.
const Duration _kHoldRedFilledDelay = Duration(milliseconds: 480);
/// 검정으로 바뀐 뒤 다음 획으로 넘어가기 전(자동재생만).
const Duration _kHoldBlackFilledBeforeNext = Duration(milliseconds: 420);

/// 한자 획순 애니메이션 플레이어.
///
/// [HanjaStrokeVisual]: `svg_paths`가 있으면 [viewer/stroke_entities_viewer.html] 과 동일 좌표계로
/// SVG path를 그린다. 없으면 획별 로컬 좌표를 타일 그리드에 배치한 폴리라인을 쓴다.
///
/// 각 획은 **한 번의 진행도** 동안 현재 획은 화면에 그리지 않다가,
/// 끝(`t==1`)에서만 빨강으로 나타나고, 이후 타이머로 검정 채움으로 전환한다.
class StrokeAnimationPlayer extends StatefulWidget {
  const StrokeAnimationPlayer({
    super.key,
    required this.hanja,
    required this.visual,
  });

  final String hanja;
  final HanjaStrokeVisual visual;

  @override
  State<StrokeAnimationPlayer> createState() => _StrokeAnimationPlayerState();
}

class _StrokeAnimationPlayerState extends State<StrokeAnimationPlayer>
    with TickerProviderStateMixin {
  late final AnimationController _strokeDrawController;
  late final Animation<double> _drawProgress;

  int _currentStrokeIndex = 0;
  bool _isAutoPlaying = false;
  bool _entireCharacterBlack = false;
  Timer? _finalBlackTimer;
  /// 채움까지 끝난 뒤, 빨강 유지 → 이 값이 true이면 현재 획도 검정 채움으로 표시.
  bool _currentStrokeSettledBlack = false;
  Timer? _postFillPhaseTimer;

  /// [pathsInViewCoordinates] 결과 (512 공간).
  List<Path>? _svgPathsInView;

  late final Listenable _paintListenable;

  @override
  void initState() {
    super.initState();
    _syncSvgPaths();
    _strokeDrawController = AnimationController(
      vsync: this,
      // 기존(윤곽 780ms + 채움 520ms) 합산 근사치
      duration: const Duration(milliseconds: 1300),
    );
    _drawProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _strokeDrawController,
        curve: const Cubic(0.33, 0.0, 0.2, 1.0),
      ),
    );
    _strokeDrawController.addStatusListener(_onStrokeDrawStatus);
    _paintListenable = _strokeDrawController;
  }

  void _syncSvgPaths() {
    final List<String>? svg = widget.visual.svgPaths;
    if (svg != null && svg.isNotEmpty) {
      _svgPathsInView = pathsInViewCoordinates(svg);
    } else {
      _svgPathsInView = null;
    }
  }

  void _onStrokeDrawStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _startPostFillPhase();
    }
  }

  void _cancelPostFillPhaseTimer() {
    _postFillPhaseTimer?.cancel();
    _postFillPhaseTimer = null;
  }

  void _startPostFillPhase() {
    _cancelPostFillPhaseTimer();
    _postFillPhaseTimer = Timer(_kHoldRedFilledDelay, () {
      if (!mounted) return;
      setState(() => _currentStrokeSettledBlack = true);
      _postFillPhaseTimer = Timer(_kHoldBlackFilledBeforeNext, () {
        if (!mounted) return;
        final bool isLast = _currentStrokeIndex >= _strokeCount - 1;
        if (isLast) {
          _scheduleEntireCharacterBlack();
          if (_isAutoPlaying) {
            setState(() => _isAutoPlaying = false);
          }
        } else if (_isAutoPlaying) {
          _goToNextStroke();
        }
      });
    });
  }

  void _cancelFinalBlackTimer() {
    _finalBlackTimer?.cancel();
    _finalBlackTimer = null;
  }

  void _resetEntireCharacterBlack() {
    _cancelFinalBlackTimer();
    _cancelPostFillPhaseTimer();
    if (_entireCharacterBlack || _currentStrokeSettledBlack) {
      setState(() {
        _entireCharacterBlack = false;
        _currentStrokeSettledBlack = false;
      });
    } else {
      _entireCharacterBlack = false;
      _currentStrokeSettledBlack = false;
    }
  }

  void _scheduleEntireCharacterBlack() {
    _cancelFinalBlackTimer();
    _finalBlackTimer = Timer(_kFinalBlackDelay, () {
      if (!mounted) return;
      setState(() {
        _entireCharacterBlack = true;
        _currentStrokeSettledBlack = false;
      });
    });
  }

  int get _strokeCount {
    final List<Path>? svg = _svgPathsInView;
    if (svg != null && svg.isNotEmpty) return svg.length;
    return widget.visual.polylineStrokes.length;
  }

  void _playCurrentStroke() {
    _cancelPostFillPhaseTimer();
    _cancelFinalBlackTimer();
    if (_entireCharacterBlack || _currentStrokeSettledBlack) {
      setState(() {
        _entireCharacterBlack = false;
        _currentStrokeSettledBlack = false;
      });
    } else {
      _entireCharacterBlack = false;
      _currentStrokeSettledBlack = false;
    }
    _strokeDrawController.forward(from: 0);
  }

  void _goToNextStroke() {
    if (_currentStrokeIndex < _strokeCount - 1) {
      _cancelPostFillPhaseTimer();
      _cancelFinalBlackTimer();
      setState(() {
        _entireCharacterBlack = false;
        _currentStrokeSettledBlack = false;
        _currentStrokeIndex++;
      });
      _playCurrentStroke();
    }
  }

  void _goToPrevStroke() {
    if (_currentStrokeIndex > 0) {
      _cancelPostFillPhaseTimer();
      _cancelFinalBlackTimer();
      setState(() {
        _entireCharacterBlack = false;
        _currentStrokeIndex--;
        _currentStrokeSettledBlack = true;
      });
      _strokeDrawController.value = 1.0;
    }
  }

  void _toggleAutoPlay() {
    setState(() => _isAutoPlaying = !_isAutoPlaying);
    if (_isAutoPlaying) {
      _resetEntireCharacterBlack();
      if (_currentStrokeIndex >= _strokeCount - 1) {
        setState(() => _currentStrokeIndex = 0);
      }
      _playCurrentStroke();
    } else {
      _strokeDrawController.stop();
      _cancelFinalBlackTimer();
      _cancelPostFillPhaseTimer();
    }
  }

  @override
  void dispose() {
    _cancelPostFillPhaseTimer();
    _cancelFinalBlackTimer();
    _strokeDrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    if (_strokeCount == 0) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Text('표시할 획순 데이터가 없습니다.'),
        ),
      );
    }
    final bool isFirst = _currentStrokeIndex == 0;
    final bool isLast = _currentStrokeIndex == _strokeCount - 1;

    final List<Path>? svg = _svgPathsInView;
    final List<List<Offset>> polylines = widget.visual.polylineStrokes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                const Positioned.fill(child: WonGoJiGrid(opacity: 0.14)),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _paintListenable,
                    builder: (context, child) {
                      if (svg != null && svg.isNotEmpty) {
                        return CustomPaint(
                          painter: _SvgStrokeReplayPainter(
                            entireCharacterBlack: _entireCharacterBlack,
                            currentStrokeSettledBlack: _currentStrokeSettledBlack,
                            allPathsWhenFinal: svg,
                            futurePaths: svg.sublist(_currentStrokeIndex + 1),
                            completedPaths: svg.sublist(0, _currentStrokeIndex),
                            currentPath: svg[_currentStrokeIndex],
                            drawProgress: _drawProgress.value,
                          ),
                        );
                      }
                      return CustomPaint(
                        painter: _StrokeReplayPainter(
                          entireCharacterBlack: _entireCharacterBlack,
                          currentStrokeSettledBlack: _currentStrokeSettledBlack,
                          allStrokesWhenFinal: polylines,
                          futureStrokes:
                              polylines.sublist(_currentStrokeIndex + 1),
                          completedStrokes:
                              polylines.sublist(0, _currentStrokeIndex),
                          currentStroke: polylines[_currentStrokeIndex],
                          drawProgress: _drawProgress.value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(_strokeCount, (index) {
            final bool isCompleted = index < _currentStrokeIndex;
            final bool isCurrent = index == _currentStrokeIndex;
            final bool currentInkPhase = isCurrent &&
                !_currentStrokeSettledBlack &&
                !_entireCharacterBlack;
            final Color dotColor = _entireCharacterBlack
                ? _StrokeOrderNaverLikePalette.strokeFinishedBlack
                : (isCompleted ||
                        (isCurrent && _currentStrokeSettledBlack)
                    ? _StrokeOrderNaverLikePalette.strokeFinishedBlack
                    : (currentInkPhase
                        ? _StrokeOrderNaverLikePalette.ink
                        : HanjaColors.surfaceContainerHigh));
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: currentInkPhase ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            '${_currentStrokeIndex + 1} / $_strokeCount 획',
            style: textTheme.titleSmall?.copyWith(
              color: _entireCharacterBlack ||
                      _currentStrokeSettledBlack
                  ? _StrokeOrderNaverLikePalette.strokeFinishedBlack
                  : HanjaColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              icon: Icons.skip_previous,
              onPressed: isFirst ? null : _goToPrevStroke,
              tooltip: '이전 획',
            ),
            const SizedBox(width: 12),
            _ControlButton(
              icon: _isAutoPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: _toggleAutoPlay,
              tooltip: _isAutoPlaying ? '일시정지' : '자동재생',
              isPrimary: true,
            ),
            const SizedBox(width: 12),
            _ControlButton(
              icon: Icons.skip_next,
              onPressed: isLast ? null : _goToNextStroke,
              tooltip: '다음 획',
            ),
          ],
        ),
      ],
    );
  }
}

/// SVG path (512 view 좌표) 재생: 회색 가이드 + 현재 획은 완료 시점에만 빨강.
class _SvgStrokeReplayPainter extends CustomPainter {
  _SvgStrokeReplayPainter({
    required this.entireCharacterBlack,
    required this.currentStrokeSettledBlack,
    required this.allPathsWhenFinal,
    required this.futurePaths,
    required this.completedPaths,
    required this.currentPath,
    required this.drawProgress,
  });

  final bool entireCharacterBlack;
  final bool currentStrokeSettledBlack;
  final List<Path> allPathsWhenFinal;
  final List<Path> futurePaths;
  final List<Path> completedPaths;
  final Path currentPath;
  final double drawProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = (size.shortestSide * 0.006).clamp(1.5, 4.0);
    final double filledBlackW = (w * 3.9).clamp(w * 2.8, 17.0);

    if (entireCharacterBlack) {
      canvas.save();
      canvas.scale(size.width / kStrokeSvgViewBox, size.height / kStrokeSvgViewBox);
      for (final Path p in allPathsWhenFinal) {
        paintPathFillOrCenterlineRibbon(
          canvas,
          p,
          filledBlackW,
          _StrokeOrderNaverLikePalette.strokeFinishedBlack,
        );
      }
      canvas.restore();
      return;
    }

    final Paint futurePaint = Paint()
      ..color = _StrokeOrderNaverLikePalette.guideFuture.withValues(alpha: 0.22)
      ..strokeWidth = w * 0.95
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    final double sx = size.width / kStrokeSvgViewBox;
    final double sy = size.height / kStrokeSvgViewBox;
    canvas.scale(sx, sy);

    for (final Path p in futurePaths) {
      canvas.drawPath(p, futurePaint);
    }
    for (final Path p in completedPaths) {
      paintPathFillOrCenterlineRibbon(
        canvas,
        p,
        filledBlackW,
        _StrokeOrderNaverLikePalette.strokeFinishedBlack,
      );
    }

    final double t = drawProgress.clamp(0.0, 1.0);
    final bool currentDrawDone = t >= 1.0;

    if (currentStrokeSettledBlack && currentDrawDone) {
      paintPathFillOrCenterlineRibbon(
        canvas,
        currentPath,
        filledBlackW,
        _StrokeOrderNaverLikePalette.strokeFinishedBlack,
      );
    } else if (currentDrawDone && !currentStrokeSettledBlack) {
      paintPathFillOrCenterlineRibbon(
        canvas,
        currentPath,
        filledBlackW,
        _StrokeOrderNaverLikePalette.ink,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SvgStrokeReplayPainter old) => true;
}

/// 폴리라인 (0~1) 재생: 회색 가이드 + 현재 획은 완료 시점에만 빨강.
class _StrokeReplayPainter extends CustomPainter {
  _StrokeReplayPainter({
    required this.entireCharacterBlack,
    required this.currentStrokeSettledBlack,
    required this.allStrokesWhenFinal,
    required this.futureStrokes,
    required this.completedStrokes,
    required this.currentStroke,
    required this.drawProgress,
  });

  final bool entireCharacterBlack;
  final bool currentStrokeSettledBlack;
  final List<List<Offset>> allStrokesWhenFinal;
  final List<List<Offset>> futureStrokes;
  final List<List<Offset>> completedStrokes;
  final List<Offset> currentStroke;
  final double drawProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = (size.shortestSide * 0.016).clamp(2.5, 12.0);
    final double filledBlackW = (w * 2.8).clamp(w * 2.0, 26.0);

    if (entireCharacterBlack) {
      for (final List<Offset> stroke in allStrokesWhenFinal) {
        _paintPolylineFillOrRibbon(
          canvas,
          stroke,
          size,
          filledBlackW,
          _StrokeOrderNaverLikePalette.strokeFinishedBlack,
        );
      }
      return;
    }

    final Paint futurePaint = Paint()
      ..color = _StrokeOrderNaverLikePalette.guideFuture.withValues(alpha: 0.22)
      ..strokeWidth = w * 0.95
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in futureStrokes) {
      _drawStroke(canvas, stroke, futurePaint, size);
    }
    for (final stroke in completedStrokes) {
      _paintPolylineFillOrRibbon(
        canvas,
        stroke,
        size,
        filledBlackW,
        _StrokeOrderNaverLikePalette.strokeFinishedBlack,
      );
    }

    if (currentStroke.length < 2) return;

    final double t = drawProgress.clamp(0.0, 1.0);
    final bool currentDrawDone = t >= 1.0;

    if (currentStrokeSettledBlack && currentDrawDone) {
      _paintPolylineFillOrRibbon(
        canvas,
        currentStroke,
        size,
        filledBlackW,
        _StrokeOrderNaverLikePalette.strokeFinishedBlack,
      );
    } else if (currentDrawDone && !currentStrokeSettledBlack) {
      _paintPolylineFillOrRibbon(
        canvas,
        currentStroke,
        size,
        filledBlackW,
        _StrokeOrderNaverLikePalette.ink,
      );
    }
  }

  Path _polylineToPath(List<Offset> points, Size size) {
    final Path path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    return path;
  }

  /// 닫힌 JSON 폴리라인이면 진짜 polygon fill, 아니면 중심선 리본.
  void _paintPolylineFillOrRibbon(
    Canvas canvas,
    List<Offset> stroke,
    Size size,
    double ribbonWidth,
    Color color,
  ) {
    if (stroke.length < 2) return;
    if (normalizedPolylineIsClosedLoop(stroke)) {
      final Path p = normalizedClosedPolylineToFillPath(stroke, size);
      canvas.drawPath(
        p,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    } else {
      paintPathCenterlineAsFilledStroke(
        canvas,
        _polylineToPath(stroke, size),
        ribbonWidth,
        color,
      );
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint, Size size) {
    if (points.length < 2) return;
    final Path path = _polylineToPath(points, size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokeReplayPainter old) => true;
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary
            ? _StrokeOrderNaverLikePalette.ink
            : HanjaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16), // 타원형 느낌을 위해 반경 조정
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // 높이 축소 및 가로 확장
            child: Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : (onPressed != null ? HanjaColors.onSurface : HanjaColors.outlineVariant),
              size: isPrimary ? 28 : 22,
            ),
          ),
        ),
      ),
    );
  }
}
