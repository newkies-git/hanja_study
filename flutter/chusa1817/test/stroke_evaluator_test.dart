import 'package:chusa1817/core/study/stroke_evaluator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('동일 가이드 획을 그대로 그리면 통과', () {
    final guide = <List<Offset>>[
      [const Offset(0.1, 0.2), const Offset(0.9, 0.8)],
    ];
    final result = evaluateStrokes(
      userStrokes: guide,
      guideStrokes: guide,
    );
    expect(result.strokeCountMatch, isTrue);
    expect(result.isCorrect, isTrue);
    expect(result.overallScore, greaterThan(0.99));
  });

  test('획 개수가 다르면 불일치', () {
    final guide = <List<Offset>>[
      [const Offset(0.1, 0.2), const Offset(0.5, 0.5)],
      [const Offset(0.5, 0.5), const Offset(0.9, 0.9)],
    ];
    final user = <List<Offset>>[
      [const Offset(0.1, 0.2), const Offset(0.9, 0.9)],
    ];
    final result = evaluateStrokes(userStrokes: user, guideStrokes: guide);
    expect(result.strokeCountMatch, isFalse);
    expect(result.isCorrect, isFalse);
  });

  test('리샘플은 길이를 맞춘다', () {
    final pts = <Offset>[
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(1, 1),
    ];
    final out = resampleStroke(pts, 4);
    expect(out.length, 4);
    expect(out.first.dx, closeTo(0, 1e-6));
    expect(out.last.dx, closeTo(1, 1e-6));
    expect(out.last.dy, closeTo(1, 1e-6));
  });
}
