"""SVG path에서 획 좌표·방향 계산."""

from __future__ import annotations

import warnings
from math import isfinite
from typing import List

from svgpathtools import Path, parse_path

_MIN_ARC_LENGTH = 1e-9


class StrokeGeometryCalculator:
    """SVG path `d` 문자열을 샘플링하고 정규화한다."""

    def sample_path_points(self, path_d: str, sample_count: int = 24) -> List[List[float]]:
        try:
            path = parse_path(path_d)
        except Exception:
            return []
        if len(path) == 0:
            return []

        points = self._try_sample_points_by_arclength(path, sample_count)
        if points is not None:
            return points
        return self._sample_points_by_segment_parameter(path, sample_count)

    def _try_sample_points_by_arclength(
        self, path: Path, sample_count: int
    ) -> List[List[float]] | None:
        try:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", RuntimeWarning)
                total_length = path.length()
        except Exception:
            return None
        if not isfinite(total_length) or total_length < _MIN_ARC_LENGTH:
            return None

        points: List[List[float]] = []
        try:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", RuntimeWarning)
                for sample_index in range(sample_count):
                    interpolation_t = sample_index / max(sample_count - 1, 1)
                    point = path.point(interpolation_t)
                    x, y = float(point.real), float(point.imag)
                    if not (isfinite(x) and isfinite(y)):
                        return None
                    points.append([round(x, 3), round(y, 3)])
        except (RuntimeError, ValueError, ZeroDivisionError, ArithmeticError):
            return None
        return points

    def _sample_points_by_segment_parameter(
        self, path: Path, sample_count: int
    ) -> List[List[float]]:
        """전체 호장 길이가 0이거나 Path.point가 실패할 때, 세그먼트별 t를 균등 분배."""
        segments = list(path)
        segment_count = len(segments)
        points: List[List[float]] = []
        for sample_index in range(sample_count):
            pos = sample_index / max(sample_count - 1, 1)
            if pos >= 1.0:
                complex_point = segments[-1].point(1.0)
            else:
                scaled = pos * segment_count
                segment_index = min(segment_count - 1, int(scaled))
                local_t = scaled - segment_index
                if segment_index == segment_count - 1:
                    local_t = min(1.0, max(0.0, local_t))
                complex_point = segments[segment_index].point(local_t)
            points.append(
                [
                    round(float(complex_point.real), 3),
                    round(float(complex_point.imag), 3),
                ]
            )
        return points

    def normalize_to_unit_square(self, points: List[List[float]]) -> List[List[float]]:
        if not points:
            return points
        xs = [point[0] for point in points]
        ys = [point[1] for point in points]
        min_x, max_x = min(xs), max(xs)
        min_y, max_y = min(ys), max(ys)
        dx = max(max_x - min_x, 1e-6)
        dy = max(max_y - min_y, 1e-6)
        return [
            [round((x - min_x) / dx, 4), round((y - min_y) / dy, 4)]
            for x, y in points
        ]

    def infer_stroke_direction(self, points: List[List[float]]) -> str:
        if len(points) < 2:
            return ""
        x1, y1 = points[0]
        x2, y2 = points[-1]
        dx = x2 - x1
        dy = y2 - y1
        if abs(dx) > abs(dy):
            return "left_to_right" if dx >= 0 else "right_to_left"
        return "top_to_bottom" if dy >= 0 else "bottom_to_top"
