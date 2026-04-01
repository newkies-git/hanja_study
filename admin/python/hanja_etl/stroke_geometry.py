"""SVG path에서 획 좌표·방향 계산."""

from __future__ import annotations

from typing import List

from svgpathtools import parse_path


class StrokeGeometryCalculator:
    """SVG path `d` 문자열을 샘플링하고 정규화한다."""

    def sample_path_points(self, path_d: str, sample_count: int = 24) -> List[List[float]]:
        path = parse_path(path_d)
        points: List[List[float]] = []
        for sample_index in range(sample_count):
            interpolation_t = sample_index / max(sample_count - 1, 1)
            point = path.point(interpolation_t)
            points.append([round(float(point.real), 3), round(float(point.imag), 3)])
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
