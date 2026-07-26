import 'dart:math' as math;

import 'package:flutter/material.dart';

/// [viewer/stroke_entities_viewer.html] 과 동일한 좌표 규약.
/// - 공통 viewBox: `VIEW = 512`
/// - bbox 기준 `scale = min(VIEW/w, VIEW/h) * 0.92`
/// - `flipY = minY + maxY` 후 `y_view = ty + scale * (flipY - py)` (SVG의 `scale(1,-1)`와 동일)
const double kStrokeEntitiesViewBox = 512;
const double kStrokeEntitiesViewBoxScalePad = 0.92;

/// Firestore `strokes[].points`는 보통 격자 좌표(예: 0~512)이며 Y는 글자 데이터 기준(위쪽이 큼)일 수 있다.
/// [StrokeAnimationPlayer]는 0~1·캔버스 Y 아래 방향이므로, 격자 데이터일 때만 뷰어와 같은 변환을 적용한다.
List<List<Offset>> fitStrokesToUnitSquare(
  List<List<Offset>> strokes, {
  double padding = 0.06,
}) {
  if (strokes.isEmpty) return strokes;

  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;
  for (final s in strokes) {
    for (final p in s) {
      minX = math.min(minX, p.dx);
      minY = math.min(minY, p.dy);
      maxX = math.max(maxX, p.dx);
      maxY = math.max(maxY, p.dy);
    }
  }

  final double w = maxX - minX;
  final double h = maxY - minY;
  if (w <= 0 || h <= 0) return strokes;

  if (!_needsGridToUnitMapping(strokes) &&
      maxX <= 1.0 &&
      maxY <= 1.0 &&
      minX >= -0.001 &&
      minY >= -0.001) {
    return strokes;
  }

  return _mapGridPointsLikeStrokeEntitiesViewer(
    strokes,
    minX: minX,
    minY: minY,
    maxX: maxX,
    maxY: maxY,
    padding: padding,
  );
}

/// `stroke_entities_viewer.html` 의 `renderMainSvgPaths` / `pathPointToViewXY` 와 동일한 매핑 후
/// [0, kStrokeEntitiesViewBox] → [padding, 1-padding] 로 선형 축소(여백만 추가).
List<List<Offset>> _mapGridPointsLikeStrokeEntitiesViewer(
  List<List<Offset>> strokes, {
  required double minX,
  required double minY,
  required double maxX,
  required double maxY,
  required double padding,
}) {
  final double w = maxX - minX;
  final double h = maxY - minY;
  final double view = kStrokeEntitiesViewBox;
  final double scale =
      math.min(view / w, view / h) * kStrokeEntitiesViewBoxScalePad;
  final double tx = (view - w * scale) / 2 - minX * scale;
  final double ty = (view - h * scale) / 2 - minY * scale;
  final double flipY = minY + maxY;

  final double inner = 1.0 - 2 * padding;

  return strokes
      .map(
        (s) => s
            .map(
              (p) {
                final double xView = tx + scale * p.dx;
                final double yView = ty + scale * (flipY - p.dy);
                final double nx = (xView / view) * inner + padding;
                final double ny = (yView / view) * inner + padding;
                return Offset(nx, ny);
              },
            )
            .toList(),
      )
      .toList();
}

bool _needsGridToUnitMapping(List<List<Offset>> strokes) {
  for (final s in strokes) {
    for (final p in s) {
      if (p.dx.abs() > 1.02 || p.dy.abs() > 1.02) return true;
      if (p.dx < -0.01 || p.dy < -0.01) return true;
    }
  }
  return false;
}
