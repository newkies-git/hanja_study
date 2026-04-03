import 'dart:math' as math;
import 'dart:ui' show Path, PathMetric;

import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../core/utils/stroke_svg_render.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 한자 획순 애니메이션 플레이어.
///
/// [HanjaStrokeVisual]: `svg_paths`가 있으면 [viewer/stroke_entities_viewer.html] 과 동일 좌표계로
/// SVG path를 그린다. 없으면 획별 로컬 좌표를 타일 그리드에 배치한 폴리라인을 쓴다.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _strokeProgress;

  int _currentStrokeIndex = 0;
  bool _isAutoPlaying = false;

  /// [pathsInViewCoordinates] 결과 (512 공간).
  List<Path>? _svgPathsInView;

  @override
  void initState() {
    super.initState();
    _syncSvgPaths();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _setupStrokeAnimation();
    _animationController.addStatusListener(_onAnimationStatus);
  }

  void _syncSvgPaths() {
    final List<String>? svg = widget.visual.svgPaths;
    if (svg != null && svg.isNotEmpty) {
      _svgPathsInView = pathsInViewCoordinates(svg);
    } else {
      _svgPathsInView = null;
    }
  }

  void _setupStrokeAnimation() {
    _strokeProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isAutoPlaying) {
      if (_currentStrokeIndex < _strokeCount - 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _goToNextStroke();
        });
      } else {
        setState(() => _isAutoPlaying = false);
      }
    }
  }

  int get _strokeCount {
    final List<Path>? svg = _svgPathsInView;
    if (svg != null && svg.isNotEmpty) return svg.length;
    return widget.visual.polylineStrokes.length;
  }

  void _playCurrentStroke() {
    _animationController.forward(from: 0);
  }

  void _goToNextStroke() {
    if (_currentStrokeIndex < _strokeCount - 1) {
      setState(() => _currentStrokeIndex++);
      _playCurrentStroke();
    }
  }

  void _goToPrevStroke() {
    if (_currentStrokeIndex > 0) {
      setState(() => _currentStrokeIndex--);
      _animationController.value = 1.0;
    }
  }

  void _toggleAutoPlay() {
    setState(() => _isAutoPlaying = !_isAutoPlaying);
    if (_isAutoPlaying) {
      if (_currentStrokeIndex >= _strokeCount - 1) {
        setState(() => _currentStrokeIndex = 0);
      }
      _playCurrentStroke();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                    animation: _animationController,
                    builder: (context, child) {
                      if (svg != null && svg.isNotEmpty) {
                        return CustomPaint(
                          painter: _SvgStrokeReplayPainter(
                            completedPaths: svg.sublist(0, _currentStrokeIndex),
                            currentPath: svg[_currentStrokeIndex],
                            currentProgress: _strokeProgress.value,
                          ),
                        );
                      }
                      return CustomPaint(
                        painter: _StrokeReplayPainter(
                          completedStrokes:
                              polylines.sublist(0, _currentStrokeIndex),
                          currentStroke: polylines[_currentStrokeIndex],
                          currentProgress: _strokeProgress.value,
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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCurrent ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? HanjaColors.primaryContainer
                    : HanjaColors.surfaceContainerHigh,
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
              color: HanjaColors.primaryContainer,
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

/// SVG path (512 view 좌표) 재생.
class _SvgStrokeReplayPainter extends CustomPainter {
  _SvgStrokeReplayPainter({
    required this.completedPaths,
    required this.currentPath,
    required this.currentProgress,
  });

  final List<Path> completedPaths;
  final Path currentPath;
  final double currentProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = (size.shortestSide * 0.006).clamp(1.5, 4.0);
    final Paint completedPaint = Paint()
      ..color = HanjaColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Paint currentPaint = Paint()
      ..color = HanjaColors.primary
      ..strokeWidth = math.max(w + 0.8, 2.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.scale(size.width / kStrokeSvgViewBox, size.height / kStrokeSvgViewBox);
    for (final Path p in completedPaths) {
      canvas.drawPath(p, completedPaint);
    }
    canvas.drawPath(_pathPrefix(currentPath, currentProgress), currentPaint);
    canvas.restore();
  }

  Path _pathPrefix(Path source, double t) {
    final Path out = Path();
    final double clamped = t.clamp(0.0, 1.0);
    for (final PathMetric metric in source.computeMetrics()) {
      out.addPath(
        metric.extractPath(0, metric.length * clamped),
        Offset.zero,
      );
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _SvgStrokeReplayPainter old) => true;
}

/// 폴리라인 (0~1) 재생.
class _StrokeReplayPainter extends CustomPainter {
  _StrokeReplayPainter({
    required this.completedStrokes,
    required this.currentStroke,
    required this.currentProgress,
  });

  final List<List<Offset>> completedStrokes;
  final List<Offset> currentStroke;
  final double currentProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = (size.shortestSide * 0.016).clamp(2.5, 12.0);
    final Paint completedPaint = Paint()
      ..color = HanjaColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Paint currentPaint = Paint()
      ..color = HanjaColors.primary
      ..strokeWidth = math.max(w + 1.0, 3.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in completedStrokes) {
      _drawStroke(canvas, stroke, completedPaint, size);
    }
    if (currentStroke.length >= 2) {
      final int pointCount = (currentStroke.length * currentProgress).ceil().clamp(
            1,
            currentStroke.length,
          );
      _drawStroke(
        canvas,
        currentStroke.sublist(0, pointCount),
        currentPaint,
        size,
      );
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint, Size size) {
    if (points.length < 2) return;
    final Path path = Path();
    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
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
            ? HanjaColors.primaryContainer
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
