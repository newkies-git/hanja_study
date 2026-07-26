import 'package:flutter/material.dart';

List<Offset> parseNormalizedPoints(String raw) {
  if (raw.trim().isEmpty) return const [];

  final points = <Offset>[];
  final segments = raw.split(';');
  for (final segment in segments) {
    final pair = segment.split(',');
    if (pair.length != 2) continue;
    final dx = double.tryParse(pair[0].trim());
    final dy = double.tryParse(pair[1].trim());
    if (dx == null || dy == null) continue;
    points.add(Offset(dx, dy));
  }
  return points;
}

