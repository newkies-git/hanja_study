import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 원고지 밖으로 나간 터치: [kWritingCanvasBoundaryHysteresis]만큼 여유를 둔 뒤,
/// 그 밖이면 획을 강제 종료한다 (clamp로 계속 이어 쓰기와 구분되는 교육용 경계 정책).
const double kWritingCanvasBoundaryHysteresis = 12.0;

/// 터치 입력 기반 한자 쓰기 캔버스.
///
/// [Listener]로 포인터를 받고 [RepaintBoundary]로 필기 영역만 리페인트한다.
/// 좌표는 0~1 정규화해 [WritingCanvasController]에 저장하며, 가이드 폴리라인과 동일 규약이다.
///
/// 외부에서 [WritingCanvasController]를 통해 초기화·되돌리기를 제어한다.
class WritingCanvasWidget extends StatefulWidget {
  const WritingCanvasWidget({
    super.key,
    required this.hanja,
    required this.controller,
    this.showGuide = true,
    this.guideNormalizedStrokes,
  });

  final String hanja;
  final WritingCanvasController controller;

  /// true이면 반투명 가이드 한자를 배경에 표시한다.
  final bool showGuide;

  /// 정답(가이드) 획 좌표 (0~1 정규화). 있으면 배경에 옅게 렌더링한다.
  final List<List<Offset>>? guideNormalizedStrokes;

  @override
  State<WritingCanvasWidget> createState() => _WritingCanvasWidgetState();
}

class _WritingCanvasWidgetState extends State<WritingCanvasWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _handlePointerDown(PointerDownEvent event, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final Offset local = event.localPosition;
    if (!_isStrictlyInsidePaper(local, size)) return;
    widget.controller._startStroke(_toNormalized(local, size));
    setState(() {});
  }

  void _handlePointerMove(PointerMoveEvent event, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (!widget.controller._hasOpenStroke) return;
    final Offset local = event.localPosition;
    if (!_isInsideLooseBounds(local, size, kWritingCanvasBoundaryHysteresis)) {
      HapticFeedback.lightImpact();
      widget.controller._endStrokeDueToBoundaryExit();
      setState(() {});
      return;
    }
    widget.controller._updateStroke(_toNormalized(local, size));
    setState(() {});
  }

  void _handlePointerUpOrCancel(PointerEvent event, Size size) {
    if (!widget.controller._hasOpenStroke) return;
    widget.controller._endStroke();
    setState(() {});
  }

  static bool _isStrictlyInsidePaper(Offset local, Size size) {
    return local.dx >= 0 &&
        local.dx <= size.width &&
        local.dy >= 0 &&
        local.dy <= size.height;
  }

  static bool _isInsideLooseBounds(Offset local, Size size, double h) {
    return local.dx >= -h &&
        local.dx <= size.width + h &&
        local.dy >= -h &&
        local.dy <= size.height + h;
  }

  static Offset _toNormalized(Offset local, Size size) {
    return Offset(local.dx / size.width, local.dy / size.height);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: HanjaColors.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: HanjaColors.shadow,
            blurRadius: 32,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Size size = Size(constraints.maxWidth, constraints.maxHeight);
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _handlePointerDown(e, size),
              onPointerMove: (e) => _handlePointerMove(e, size),
              onPointerUp: (e) => _handlePointerUpOrCancel(e, size),
              onPointerCancel: (e) => _handlePointerUpOrCancel(e, size),
              child: Stack(
                children: [
                  const Positioned.fill(child: WonGoJiGrid(opacity: 0.18)),
                  if (widget.showGuide)
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          widget.hanja,
                          style: textTheme.displayLarge?.copyWith(
                            color: HanjaColors.neutralIcon.withValues(alpha: 0.15),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _StrokePainter(
                          strokes: widget.controller.strokes,
                          currentStroke: widget.controller._currentStroke,
                          guideNormalizedStrokes: widget.guideNormalizedStrokes,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 쓰기 캔버스 외부 제어 컨트롤러.
///
/// 모든 획 좌표는 **0~1 정규화**(캔버스 로컬 / 크기)이며, 가이드 [fitStrokesToUnitSquare] 결과와 같은 축이다.
class WritingCanvasController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  /// 완료된 stroke 목록 (읽기 전용). 좌표는 0~1.
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  /// 입력된 획 수.
  int get strokeCount => _strokes.length;

  /// 현재 획을 그리는 중인지 (포인터가 내려간 뒤 아직 끝나지 않음).
  bool get hasActiveStroke => _currentStroke.isNotEmpty;

  bool get _hasOpenStroke => _currentStroke.isNotEmpty;

  void _startStroke(Offset normalized) {
    _currentStroke = [normalized];
    notifyListeners();
  }

  void _updateStroke(Offset normalized) {
    _currentStroke.add(normalized);
  }

  void _endStroke() {
    if (_currentStroke.length > 1) {
      _strokes.add(
        _currentStroke
            .map(
              (p) => Offset(
                p.dx.clamp(0.0, 1.0),
                p.dy.clamp(0.0, 1.0),
              ),
            )
            .toList(),
      );
    }
    _currentStroke = [];
    notifyListeners();
  }

  /// 원고지 밖(hysteresis 밖) 이탈 시 호출: 짧은 획은 버린다.
  void _endStrokeDueToBoundaryExit() {
    _currentStroke = [];
    notifyListeners();
  }

  /// 마지막 획을 제거한다.
  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
      notifyListeners();
    }
  }

  /// 모든 획을 초기화한다.
  void reset() {
    _strokes.clear();
    _currentStroke = [];
    notifyListeners();
  }
}

/// stroke 경로를 캔버스에 그리는 [CustomPainter].
class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.strokes,
    required this.currentStroke,
    required this.guideNormalizedStrokes,
  });

  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final List<List<Offset>>? guideNormalizedStrokes;

  static final Paint _strokePaint = Paint()
    ..color = HanjaColors.primary
    ..strokeWidth = 14
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  static final Paint _guidePaint = Paint()
    ..color = HanjaColors.primaryContainer.withValues(alpha: 0.22)
    ..strokeWidth = 12
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final guides = guideNormalizedStrokes;
    if (guides != null && guides.isNotEmpty) {
      for (final stroke in guides) {
        _drawNormalizedStroke(canvas, stroke, size);
      }
    }

    for (final List<Offset> stroke in strokes) {
      _drawNormalizedPolyline(canvas, stroke, size, _strokePaint);
    }
    if (currentStroke.isNotEmpty) {
      _drawNormalizedPolyline(canvas, currentStroke, size, _strokePaint);
    }
  }

  void _drawNormalizedStroke(Canvas canvas, List<Offset> points, Size size) {
    _drawNormalizedPolyline(canvas, points, size, _guidePaint);
  }

  void _drawNormalizedPolyline(
    Canvas canvas,
    List<Offset> points,
    Size size,
    Paint paint,
  ) {
    if (points.length < 2) return;
    final Path path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.guideNormalizedStrokes != guideNormalizedStrokes;
  }
}
