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
