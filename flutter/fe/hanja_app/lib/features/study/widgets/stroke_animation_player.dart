import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 한자 획순 애니메이션 플레이어.
///
/// [strokes]로 전달된 획 좌표 목록을 순서대로 애니메이션 재생한다.
/// 이전/다음 획 버튼, 자동재생(토글), 재생 속도를 지원한다.
///
/// Phase 3에서 [strokes]를 실제 SVG 파이프라인 데이터로 교체한다.
class StrokeAnimationPlayer extends StatefulWidget {
  const StrokeAnimationPlayer({
    super.key,
    required this.hanja,
    required this.strokes,
  });

  final String hanja;

  /// 획별 좌표 목록. 각 항목이 하나의 획이다.
  final List<List<Offset>> strokes;

  @override
  State<StrokeAnimationPlayer> createState() => _StrokeAnimationPlayerState();
}

class _StrokeAnimationPlayerState extends State<StrokeAnimationPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _strokeProgress;

  int _currentStrokeIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _setupStrokeAnimation();
    _animationController.addStatusListener(_onAnimationStatus);
  }

  void _setupStrokeAnimation() {
    _strokeProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isAutoPlaying) {
      if (_currentStrokeIndex < widget.strokes.length - 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _goToNextStroke();
        });
      } else {
        setState(() => _isAutoPlaying = false);
      }
    }
  }

  void _playCurrentStroke() {
    _animationController.forward(from: 0);
  }

  void _goToNextStroke() {
    if (_currentStrokeIndex < widget.strokes.length - 1) {
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
      if (_currentStrokeIndex >= widget.strokes.length - 1) {
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
    final bool isFirst = _currentStrokeIndex == 0;
    final bool isLast = _currentStrokeIndex == widget.strokes.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 캔버스
        AspectRatio(
          aspectRatio: 1.3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                const Positioned.fill(child: WonGoJiGrid(opacity: 0.14)),
                // 완료된 획 (불투명)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => CustomPaint(
                      painter: _StrokeReplayPainter(
                        completedStrokes: widget.strokes.sublist(0, _currentStrokeIndex),
                        currentStroke: widget.strokes[_currentStrokeIndex],
                        currentProgress: _strokeProgress.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // 획 번호 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.strokes.length, (index) {
            final bool isCompleted = index < _currentStrokeIndex;
            final bool isCurrent = index == _currentStrokeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
        // 획 정보
        Center(
          child: Text(
            '${_currentStrokeIndex + 1} / ${widget.strokes.length} 획',
            style: textTheme.titleSmall?.copyWith(
              color: HanjaColors.primaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // 컨트롤 버튼
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

/// 획순 재생 CustomPainter.
class _StrokeReplayPainter extends CustomPainter {
  _StrokeReplayPainter({
    required this.completedStrokes,
    required this.currentStroke,
    required this.currentProgress,
  });

  final List<List<Offset>> completedStrokes;
  final List<Offset> currentStroke;
  final double currentProgress;

  static final Paint _completedPaint = Paint()
    ..color = HanjaColors.primary.withValues(alpha: 0.55)
    ..strokeWidth = 12
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  static final Paint _currentPaint = Paint()
    ..color = HanjaColors.primary
    ..strokeWidth = 14
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // 완료된 획 그리기
    for (final stroke in completedStrokes) {
      _drawStroke(canvas, stroke, _completedPaint, size);
    }
    // 현재 획 (progress 기반 부분 그리기)
    if (currentStroke.length >= 2) {
      final int pointCount = (currentStroke.length * currentProgress).ceil()
          .clamp(1, currentStroke.length);
      _drawStroke(canvas, currentStroke.sublist(0, pointCount), _currentPaint, size);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint, Size size) {
    if (points.length < 2) return;
    final Path path = Path();
    // 정규화된 0~1 좌표를 실제 크기로 변환
    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokeReplayPainter old) => true;
}

/// 획순 플레이어 컨트롤 버튼.
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
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
