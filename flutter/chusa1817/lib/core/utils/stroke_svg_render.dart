import 'dart:math' as math;
import 'dart:ui' show Path, PathMetric, Tangent;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// [viewer/stroke_entities_viewer.html] `VIEW` 및 `renderMainSvgPaths` 변환과 동일.
const double kStrokeSvgViewBox = 512;

/// 획순 UI용: `svg_paths` 우선, 없으면 폴리라인(획별 로컬 좌표).
class HanjaStrokeVisual {
  const HanjaStrokeVisual({
    this.svgPaths,
    required this.polylineStrokes,
  });

  final List<String>? svgPaths;
  final List<List<Offset>> polylineStrokes;
}

/// `stroke_geometry.normalize_to_unit_square` 는 획마다 로컬 0~1이므로,
/// 폴리라인만 합치면 겹친다. 획별로 타일 그리드에 배치한다.
List<List<Offset>> layoutPerStrokeLocalPointsAsGrid(
  List<List<Offset>> strokes, {
  double padding = 0.04,
}) {
  if (strokes.isEmpty) return strokes;
  final int n = strokes.length;
  final int cols = math.max(1, math.sqrt(n).ceil());
  final int rows = (n + cols - 1) ~/ cols;
  final double cellW = 1.0 / cols;
  final double cellH = 1.0 / rows;
  final double inner = 1.0 - 2 * padding;

  return List.generate(n, (i) {
    final int col = i % cols;
    final int row = i ~/ cols;
    final double ox = col * cellW + padding * cellW;
    final double oy = row * cellH + padding * cellH;
    final double scaleW = cellW * inner;
    final double scaleH = cellH * inner;
    return strokes[i]
        .map(
          (p) => Offset(
            ox + p.dx * scaleW,
            oy + p.dy * scaleH,
          ),
        )
        .toList();
  });
}

Rect _unionPathBounds(Iterable<Path> paths) {
  Rect? u;
  for (final Path p in paths) {
    final Rect b = p.getBounds();
    if (b.isEmpty) continue;
    u = u == null ? b : u.expandToInclude(b);
  }
  return u ?? Rect.zero;
}

/// viewer `pathPointToViewXY` / 그룹 `transform` 과 동일한 2D 아핀.
Matrix4 strokeEntityPathToViewMatrix(Rect box) {
  final double minX = box.left;
  final double maxX = box.right;
  final double minY = box.top;
  final double maxY = box.bottom;
  final double w = maxX - minX;
  final double h = maxY - minY;
  if (w <= 0 || h <= 0) return Matrix4.identity();
  final double view = kStrokeSvgViewBox;
  final double scale = math.min(view / w, view / h) * 0.92;
  final double tx = (view - w * scale) / 2 - minX * scale;
  final double ty = (view - h * scale) / 2 - minY * scale;
  final double flipY = minY + maxY;
  return Matrix4(
    scale, 0, 0, 0,
    0, -scale, 0, 0,
    0, 0, 1, 0,
    tx, ty + scale * flipY, 0, 1,
  );
}

List<Path> parseSvgPathStrings(List<String> svgPathStrings) {
  final List<Path> out = [];
  for (final String d in svgPathStrings) {
    if (d.trim().isEmpty) continue;
    out.add(parseSvgPathData(d));
  }
  return out;
}

/// 쓰기 가이드 등: view 좌표를 0~1로 나눈 폴리라인.
List<List<Offset>> sampleSvgPathsToNormalizedPolylines(
  List<String> svgPathStrings, {
  int samplesPerStroke = 24,
}) {
  final List<Path> paths = parseSvgPathStrings(svgPathStrings);
  if (paths.isEmpty) return const [];
  final Rect union = _unionPathBounds(paths);
  if (union.width < 1e-6 && union.height < 1e-6) return const [];
  final Matrix4 m = strokeEntityPathToViewMatrix(union);
  final List<List<Offset>> out = [];
  final int nSamples = math.max(2, samplesPerStroke);
  for (final Path path in paths) {
    final Path p = path.transform(m.storage);
    final List<Offset> pts = [];
    for (final PathMetric metric in p.computeMetrics()) {
      final double len = metric.length;
      if (len <= 0) continue;
      for (int i = 0; i < nSamples; i++) {
        final double t = i / (nSamples - 1);
        final Tangent? tan =
            metric.getTangentForOffset(len * t.clamp(0.0, 1.0));
        if (tan == null) continue;
        pts.add(Offset(
          tan.position.dx / kStrokeSvgViewBox,
          tan.position.dy / kStrokeSvgViewBox,
        ));
      }
    }
    if (pts.length >= 2) out.add(pts);
  }
  return out;
}

/// 획순 재생용: 변환까지 적용한 Path 목록.
List<Path> pathsInViewCoordinates(List<String> svgPathStrings) {
  final List<Path> paths = parseSvgPathStrings(svgPathStrings);
  if (paths.isEmpty) return const [];
  final Rect union = _unionPathBounds(paths);
  if (union.width < 1e-6 && union.height < 1e-6) return const [];
  final Matrix4 m = strokeEntityPathToViewMatrix(union);
  return paths.map((p) => p.transform(m.storage)).toList();
}

/// `stroke_entities.json` 등에서 획 `points`가 **첫 점과 마지막 점이 같음**(닫힌 폴리라인)일 때 true.
///
/// 좌표는 0~1 정규화 기준. (ref/viewer/stroke_entities.json 전체 19,682획 검증: 위 조건 100%.)
bool normalizedPolylineIsClosedLoop(
  List<Offset> points, {
  double eps = 1e-5,
}) {
  if (points.length < 3) return false;
  final Offset a = points.first;
  final Offset b = points.last;
  return (a.dx - b.dx).abs() < eps && (a.dy - b.dy).abs() < eps;
}

/// [normalizedPolylineIsClosedLoop]일 때 [PaintingStyle.fill]에 쓸 닫힌 Path.
/// 마지막 점이 시작과 중복이면 생략하고 [Path.close]로 닫는다.
Path normalizedClosedPolylineToFillPath(List<Offset> points, Size size) {
  final Path path = Path();
  if (!normalizedPolylineIsClosedLoop(points)) return path;
  final int n = points.length;
  final double w = size.width;
  final double h = size.height;
  final int lastVert = n - 2;
  path.moveTo(points[0].dx * w, points[0].dy * h);
  for (int i = 1; i <= lastVert; i++) {
    path.lineTo(points[i].dx * w, points[i].dy * h);
  }
  path.close();
  return path;
}

/// view 좌표(예: 512 박스) Path의 **모든** contour가 시작점≈끝점이면 면 fill에 적합.
bool pathAllContoursEndpointsMeet(
  Path path, {
  double tolerance = 2.5,
}) {
  bool any = false;
  for (final PathMetric m in path.computeMetrics()) {
    any = true;
    final double len = m.length;
    if (len < 1e-6) return false;
    final Offset? a = m.getTangentForOffset(0)?.position;
    final Offset? b = m.getTangentForOffset(len)?.position;
    if (a == null || b == null) return false;
    if ((a - b).distance > tolerance) return false;
  }
  return any;
}

/// 열린 획 **중심선**을 [strokeWidth] 두께의 닫힌 리본(폴리곤)으로 바꾼다.
///
/// 단일 곡선만 있을 때 `PaintingStyle.fill`로 칠하면 “붓으로 채운” 것과 비슷한 면이 된다.
/// (원본 path가 면이 아니면 fill만으로는 채울 수 없어, 법선 방향으로 오프셋을 쌓는 방식.)
Path pathCenterlineToFilledRibbonPath(Path centerline, double strokeWidth) {
  final double half = strokeWidth * 0.5;
  final Path outline = Path();
  for (final PathMetric metric in centerline.computeMetrics()) {
    final double len = metric.length;
    if (len < 1e-6) continue;
    final int steps = math.max(8, (len / 2.0).ceil()).clamp(8, 400);
    final List<Offset> left = <Offset>[];
    final List<Offset> right = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      final double d = len * (i / steps);
      final Tangent? tan = metric.getTangentForOffset(d);
      if (tan == null) continue;
      final Offset dir = tan.vector;
      final double mag = dir.distance;
      if (mag < 1e-9) continue;
      final Offset n = Offset(-dir.dy, dir.dx) / mag;
      final Offset p = tan.position;
      left.add(p + n * half);
      right.add(p - n * half);
    }
    if (left.length < 2) continue;
    outline.moveTo(left.first.dx, left.first.dy);
    for (int i = 1; i < left.length; i++) {
      outline.lineTo(left[i].dx, left[i].dy);
    }
    outline.lineTo(right.last.dx, right.last.dy);
    for (int i = right.length - 2; i >= 0; i--) {
      outline.lineTo(right[i].dx, right[i].dy);
    }
    outline.close();
  }
  return outline;
}

/// 리본 끝 단면을 둥글게 보이게 시작·끝에 반원을 덧칠한다.
void paintFilledStrokeRoundCaps(
  Canvas canvas,
  Path centerline,
  double strokeWidth,
  Paint fillPaint,
) {
  final double r = strokeWidth * 0.5;
  final Paint cap = Paint()
    ..color = fillPaint.color
    ..style = PaintingStyle.fill
    ..isAntiAlias = fillPaint.isAntiAlias;
  for (final PathMetric metric in centerline.computeMetrics()) {
    final double len = metric.length;
    if (len < 1e-6) continue;
    final Tangent? t0 = metric.getTangentForOffset(0);
    final Tangent? t1 = metric.getTangentForOffset(len);
    if (t0 != null) {
      canvas.drawCircle(t0.position, r, cap);
    }
    if (t1 != null) {
      canvas.drawCircle(t1.position, r, cap);
    }
  }
}

/// 중심선을 실제 fill 면으로 그린다 ([pathCenterlineToFilledRibbonPath] + 끝 캡).
void paintPathCenterlineAsFilledStroke(
  Canvas canvas,
  Path centerline,
  double strokeWidth,
  Color color,
) {
  final Paint fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawPath(
    pathCenterlineToFilledRibbonPath(centerline, strokeWidth),
    fill,
  );
  paintFilledStrokeRoundCaps(canvas, centerline, strokeWidth, fill);
}

/// 닫힌 윤곽이면 [path]를 그대로 fill, 아니면 중심선 리본 fill.
void paintPathFillOrCenterlineRibbon(
  Canvas canvas,
  Path path,
  double ribbonStrokeWidth,
  Color color,
) {
  if (pathAllContoursEndpointsMeet(path)) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  } else {
    paintPathCenterlineAsFilledStroke(
      canvas,
      path,
      ribbonStrokeWidth,
      color,
    );
  }
}
