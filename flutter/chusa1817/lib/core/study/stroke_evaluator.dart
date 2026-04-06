import 'dart:math' as math;

import 'package:flutter/material.dart';

// 후순위: google_mlkit_digital_ink_recognition 등 Digital Ink는
// “어떤 글자인가” 자유 인식·검색용으로만 두고, 획순 채점과 같은 파이프라인에 넣지 않는다.

/// 획순·방향·형태 채점 임계값 (초급/중급 프로필 확장 시 여기서 조정).
class StrokeEvaluationThresholds {
  const StrokeEvaluationThresholds({
    this.endpointTolerance = 0.18,
    this.directionMaxRadians = math.pi / 4,
    this.dtwMeanDistanceMax = 0.12,
    this.resamplePointCount = 32,
  });

  /// 정규화 좌표에서 시작/끝점 허용 오차 (대략 10~20%).
  final double endpointTolerance;

  /// 가이드 획 주축 대비 사용자 획 시작→끝 벡터 각도 허용.
  final double directionMaxRadians;

  /// 리샘플 후 DTW 평균 거리 상한.
  final double dtwMeanDistanceMax;

  final int resamplePointCount;
}

class SingleStrokeEvaluation {
  const SingleStrokeEvaluation({
    required this.strokeIndex,
    required this.shapePass,
    required this.directionPass,
    required this.startPass,
    required this.endPass,
    required this.meanDtwDistance,
  });

  final int strokeIndex;
  final bool shapePass;
  final bool directionPass;
  final bool startPass;
  final bool endPass;
  final double meanDtwDistance;

  bool get allPassed =>
      shapePass && directionPass && startPass && endPass;
}

class StrokeEvaluationResult {
  const StrokeEvaluationResult({
    required this.strokeCountMatch,
    required this.perStroke,
    required this.overallScore,
    required this.isCorrect,
  });

  final bool strokeCountMatch;
  final List<SingleStrokeEvaluation> perStroke;

  /// 0~1 (획 수 불일치 시 패널티 반영).
  final double overallScore;

  final bool isCorrect;
}

/// 가이드 폴리라인(0~1)과 사용자 획을 비교해 순서·방향·형태를 평가한다.
StrokeEvaluationResult evaluateStrokes({
  required List<List<Offset>> userStrokes,
  required List<List<Offset>> guideStrokes,
  List<String?> strokeDirections = const [],
  StrokeEvaluationThresholds thresholds = const StrokeEvaluationThresholds(),
}) {
  final List<List<Offset>> user = userStrokes
      .where((s) => s.length >= 2)
      .map((s) => s.map(_clampUnit).toList())
      .toList();
  final List<List<Offset>> guide = guideStrokes
      .where((s) => s.length >= 2)
      .map((s) => s.map(_clampUnit).toList())
      .toList();

  final bool countMatch = user.length == guide.length && guide.isNotEmpty;
  if (guide.isEmpty) {
    return const StrokeEvaluationResult(
      strokeCountMatch: false,
      perStroke: [],
      overallScore: 0,
      isCorrect: false,
    );
  }

  if (!countMatch) {
    final int n = math.min(user.length, guide.length);
    final List<SingleStrokeEvaluation> partial = [];
    for (int i = 0; i < n; i++) {
      partial.add(
        _evaluateOneStroke(
          strokeIndex: i,
          userStroke: user[i],
          guideStroke: guide[i],
          directionHint: i < strokeDirections.length ? strokeDirections[i] : null,
          thresholds: thresholds,
        ),
      );
    }
    final double avgMini = partial.isEmpty
        ? 0.0
        : partial.map(_miniScoreForStroke).reduce((a, b) => a + b) /
            partial.length;
    final double countRatio =
        (user.length / guide.length).clamp(0.0, 1.0);
    return StrokeEvaluationResult(
      strokeCountMatch: false,
      perStroke: partial,
      overallScore: (avgMini * countRatio).clamp(0.0, 1.0),
      isCorrect: false,
    );
  }

  final List<SingleStrokeEvaluation> results = [];
  for (int i = 0; i < guide.length; i++) {
    results.add(
      _evaluateOneStroke(
        strokeIndex: i,
        userStroke: user[i],
        guideStroke: guide[i],
        directionHint: i < strokeDirections.length ? strokeDirections[i] : null,
        thresholds: thresholds,
      ),
    );
  }

  final bool allOk = results.every((e) => e.allPassed);
  final double overallScore = results.isEmpty
      ? 0.0
      : results.map(_miniScoreForStroke).reduce((a, b) => a + b) /
          results.length;

  return StrokeEvaluationResult(
    strokeCountMatch: true,
    perStroke: results,
    overallScore: overallScore.clamp(0.0, 1.0),
    isCorrect: allOk,
  );
}

double _miniScoreForStroke(SingleStrokeEvaluation e) {
  int n = 0;
  if (e.shapePass) n++;
  if (e.directionPass) n++;
  if (e.startPass) n++;
  if (e.endPass) n++;
  return n / 4.0;
}

SingleStrokeEvaluation _evaluateOneStroke({
  required int strokeIndex,
  required List<Offset> userStroke,
  required List<Offset> guideStroke,
  required String? directionHint,
  required StrokeEvaluationThresholds thresholds,
}) {
  final List<Offset> u = resampleStroke(userStroke, thresholds.resamplePointCount);
  final List<Offset> g = resampleStroke(guideStroke, thresholds.resamplePointCount);

  final double startDist = (u.first - g.first).distance;
  final double endDist = (u.last - g.last).distance;
  final bool startPass = startDist <= thresholds.endpointTolerance;
  final bool endPass = endDist <= thresholds.endpointTolerance;

  final double meanDtw = dtwMeanDistance(u, g);
  final bool shapePass = meanDtw <= thresholds.dtwMeanDistanceMax;

  final bool directionPass = _directionMatches(
    userStroke,
    guideStroke,
    directionHint,
    thresholds.directionMaxRadians,
  );

  return SingleStrokeEvaluation(
    strokeIndex: strokeIndex,
    shapePass: shapePass,
    directionPass: directionPass,
    startPass: startPass,
    endPass: endPass,
    meanDtwDistance: meanDtw,
  );
}

Offset _clampUnit(Offset p) {
  return Offset(p.dx.clamp(0.0, 1.0), p.dy.clamp(0.0, 1.0));
}

/// 아크 길이 기준 균일 리샘플.
List<Offset> resampleStroke(List<Offset> points, int targetCount) {
  if (points.isEmpty) return [];
  if (points.length == 1 || targetCount < 2) {
    return List<Offset>.filled(math.max(2, targetCount), points.first);
  }

  final List<double> segLen = [];
  double total = 0;
  for (int i = 1; i < points.length; i++) {
    final double d = (points[i] - points[i - 1]).distance;
    segLen.add(d);
    total += d;
  }
  if (total < 1e-9) {
    return List<Offset>.filled(targetCount, points.first);
  }

  final List<Offset> out = [];
  for (int k = 0; k < targetCount; k++) {
    final double targetDist = total * k / (targetCount - 1);
    double acc = 0;
    int j = 0;
    while (j < segLen.length && acc + segLen[j] < targetDist) {
      acc += segLen[j];
      j++;
    }
    if (j >= segLen.length) {
      out.add(points.last);
    } else {
      final double t = segLen[j] <= 1e-9
          ? 0.0
          : (targetDist - acc) / segLen[j];
      final Offset a = points[j];
      final Offset b = points[j + 1];
      out.add(Offset(
        a.dx + (b.dx - a.dx) * t,
        a.dy + (b.dy - a.dy) * t,
      ));
    }
  }
  return out;
}

double dtwMeanDistance(List<Offset> a, List<Offset> b) {
  final int n = a.length;
  final int m = b.length;
  if (n == 0 || m == 0) return double.infinity;

  final List<List<double>> dp =
      List.generate(n + 1, (_) => List<double>.filled(m + 1, double.infinity));
  dp[0][0] = 0;

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      final double cost = (a[i - 1] - b[j - 1]).distance;
      final double v = math.min(
        dp[i - 1][j],
        math.min(dp[i][j - 1], dp[i - 1][j - 1]),
      );
      dp[i][j] = cost + v;
    }
  }

  return dp[n][m] / (n + m);
}

bool _directionMatches(
  List<Offset> user,
  List<Offset> guide,
  String? hint,
  double maxRadians,
) {
  if (user.length < 2 || guide.length < 2) return false;

  final Offset ug = user.last - user.first;
  final Offset gg = guide.last - guide.first;
  if (ug.distance < 1e-6 || gg.distance < 1e-6) return false;

  double angleBetween(Offset u, Offset v) {
    final double dot = (u.dx * v.dx + u.dy * v.dy) / (u.distance * v.distance);
    return math.acos(dot.clamp(-1.0, 1.0));
  }

  if (hint != null && hint.trim().isNotEmpty) {
    final String h = hint.trim().toLowerCase();
    if (_hintImpliesHorizontal(h) && !_isMostlyHorizontal(ug, maxRadians)) {
      return false;
    }
    if (_hintImpliesVertical(h) && !_isMostlyVertical(ug, maxRadians)) {
      return false;
    }
  }

  return angleBetween(ug, gg) <= maxRadians;
}

bool _hintImpliesHorizontal(String h) {
  return h.contains('横') || h.contains('horizontal') || h == 'h';
}

bool _hintImpliesVertical(String h) {
  return h.contains('竖') || h.contains('vertical') || h == 'v';
}

bool _isMostlyHorizontal(Offset u, double maxRadians) {
  final double a = u.direction;
  return a.abs() <= maxRadians || (math.pi - a.abs()) <= maxRadians;
}

bool _isMostlyVertical(Offset u, double maxRadians) {
  final double a = u.direction;
  return (a - math.pi / 2).abs() <= maxRadians ||
      (a + math.pi / 2).abs() <= maxRadians;
}
