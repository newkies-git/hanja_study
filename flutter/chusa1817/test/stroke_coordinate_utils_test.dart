import 'package:chusa1817/core/utils/stroke_coordinate_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('0~1 좌표는 그대로 둔다', () {
    final strokes = <List<Offset>>[
      [const Offset(0.1, 0.2), const Offset(0.9, 0.8)],
    ];
    final out = fitStrokesToUnitSquare(strokes);
    expect(out, strokes);
  });

  test('격자 좌표(예: 1096)는 단위 정사각형으로 맞춘다', () {
    final strokes = <List<Offset>>[
      [const Offset(0, 0), const Offset(1096, 0), const Offset(1096, 1096)],
    ];
    final out = fitStrokesToUnitSquare(strokes);
    for (final s in out) {
      for (final p in s) {
        expect(p.dx, inInclusiveRange(0.0, 1.0));
        expect(p.dy, inInclusiveRange(0.0, 1.0));
      }
    }
  });
}
