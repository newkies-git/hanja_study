"""페이지 DOM에서 획순 SVG를 읽어 StrokeEntity를 만든다."""

from __future__ import annotations

from typing import List

from playwright.sync_api import Page

from hanja_etl.identifiers import make_stroke_entity_id
from hanja_etl.models import StrokeEntity, StrokeStep
from hanja_etl.naver_dictionary_browser_client import NaverHanjaDictionaryBrowserClient
from hanja_etl.stroke_geometry import StrokeGeometryCalculator
class StrokeEntityExtractor:
    def __init__(self, geometry: StrokeGeometryCalculator | None = None) -> None:
        self._geometry = geometry or StrokeGeometryCalculator()

    def extract_from_page(
        self,
        page: Page,
        character: str,
        total_strokes: int,
        browser_client: NaverHanjaDictionaryBrowserClient | None = None,
    ) -> StrokeEntity:
        client = browser_client or NaverHanjaDictionaryBrowserClient(page)

        svg_paths: List[str] = []
        if client.open_stroke_order_modal():
            try:
                svg_paths = client.get_ordered_stroke_svg_path_commands()
            finally:
                client.close_stroke_order_modal()

        if total_strokes > 0 and len(svg_paths) > total_strokes:
            svg_paths = svg_paths[:total_strokes]

        strokes: List[StrokeStep] = []
        for index, d in enumerate(svg_paths, start=1):
            points = self._geometry.sample_path_points(d)
            points = self._geometry.normalize_to_unit_square(points)
            strokes.append(
                StrokeStep(
                    order=index,
                    points=points,
                    start_hint=points[0] if points else [],
                    end_hint=points[-1] if points else [],
                    direction=self._geometry.infer_stroke_direction(points),
                    type="",
                )
            )

        effective_total = total_strokes if total_strokes > 0 else len(strokes)

        return StrokeEntity(
            stroke_data_id=make_stroke_entity_id(character),
            char=character,
            total_strokes=effective_total,
            strokes=strokes,
            svg_paths=svg_paths,
        )
