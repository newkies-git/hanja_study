import 'package:flutter/material.dart';

import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/won_go_ji_grid.dart';

/// 터치 입력 기반 한자 쓰기 캔버스.
///
/// [GestureDetector]로 사용자 터치 경로를 [List<List<Offset>>] stroke 목록으로 저장하고,
/// [CustomPainter]로 실시간 렌더링한다.
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

  void _onPanStart(DragStartDetails details) {
    widget.controller._startStroke(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    widget.controller._updateStroke(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    widget.controller._endStroke();
    setState(() {});
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
        child: GestureDetector(
          // 수직 스크롤 간섭을 막기 위해 모든 드래그 축을 캔버스에서 명시적으로 제어
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onVerticalDragStart: (_) {}, // 수직 드래그가 상위 ListView로 전달되지 않도록 가로챔
          onVerticalDragUpdate: (_) {},
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // 배경 원고지 그리드
              const Positioned.fill(child: WonGoJiGrid(opacity: 0.18)),
              // 가이드 한자 (반투명)
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
              // 사용자 획 렌더링
              Positioned.fill(
                child: CustomPaint(
                  painter: _StrokePainter(
                    strokes: widget.controller.strokes,
                    currentStroke: widget.controller._currentStroke,
                    guideNormalizedStrokes: widget.guideNormalizedStrokes,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 쓰기 캔버스 외부 제어 컨트롤러.
///
/// [reset]으로 전체 초기화, [undo]로 마지막 획 되돌리기를 제공한다.
class WritingCanvasController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  /// 완료된 stroke 목록 (읽기 전용).
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  /// 입력된 획 수.
  int get strokeCount => _strokes.length;

  void _startStroke(Offset position) {
    _currentStroke = [position];
  }

  void _updateStroke(Offset position) {
    _currentStroke.add(position);
  }

  void _endStroke() {
    if (_currentStroke.length > 1) {
      _strokes.add(List.of(_currentStroke));
    }
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
    final guides = guideNormalizedStrokes;
    if (guides != null && guides.isNotEmpty) {
      for (final stroke in guides) {
        _drawNormalizedStroke(canvas, stroke, size);
      }
    }

    for (final List<Offset> stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, _strokePaint);
  }

  void _drawNormalizedStroke(Canvas canvas, List<Offset> points, Size size) {
    if (points.length < 2) return;
    final Path path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    canvas.drawPath(path, _guidePaint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
