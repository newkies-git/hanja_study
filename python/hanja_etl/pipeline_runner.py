"""CSV에서 한자를 읽어 네이버 한자사전 스크래핑을 실행한다."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List, Sequence

from playwright.sync_api import sync_playwright

from hanja_etl.browser_context_factory import ChromiumBrowserFactory
from hanja_etl.config import ensure_output_dir
from hanja_etl.csv_hanja_character_source import CsvHanjaCharacterSource
from hanja_etl.file_io import save_json
from hanja_etl.hanja_dictionary_scrape_service import HanjaDictionaryScrapeService


class PipelineRunner:
    """CSV 파일의 한자 열만 사용해 네이버 한자사전에서 엔티티를 수집한다."""

    def __init__(self, output_dir: Path | None = None) -> None:
        self._output_dir = output_dir or ensure_output_dir()
        self._scrape = HanjaDictionaryScrapeService()

    def run_from_csv(
        self,
        csv_path: Path,
        headless: bool = True,
        throttle_ms: int = 1200,
        limit: int | None = None,
    ) -> None:
        """
        CSV 각 데이터 행의 첫 번째 필드에서 한자를 읽고
        https://hanja.dict.naver.com/#/search?query={} 로 검색해 엔티티를 만든다.
        """
        source = CsvHanjaCharacterSource(csv_path)
        characters = source.load_unique_hanja_in_order()
        if limit is not None:
            characters = characters[:limit]

        print(
            f"[CSV] {csv_path} 에서 한자 {len(characters)}자 (파일 내 고유 순서) → 네이버 사전"
        )
        with sync_playwright() as playwright:
            browser, context = ChromiumBrowserFactory.create_browser_and_context(
                playwright, headless=headless
            )
            self._scrape_naver_targets(context, characters, throttle_ms=throttle_ms)
            browser.close()

        self._print_outputs()

    def _scrape_naver_targets(
        self,
        context,
        target_chars: Sequence[str],
        throttle_ms: int,
    ) -> None:
        hanja_path = self._output_dir / "hanja_entities.json"
        stroke_path = self._output_dir / "stroke_entities.json"
        word_path = self._output_dir / "word_entities.json"

        print("[네이버 한자사전] 엔티티 생성 중...")
        naver_page = context.new_page()
        hanja_entities: List[Dict[str, Any]] = []
        stroke_entities: List[Dict[str, Any]] = []
        word_entities: List[Dict[str, Any]] = []

        total = len(target_chars)
        for index, ch in enumerate(target_chars, start=1):
            print(f"  - ({index}/{total}) {ch}")
            try:
                hanja_e, stroke_e, words = self._scrape.scrape_one_character(
                    naver_page, ch
                )
                hanja_entities.append(hanja_e.model_dump())
                stroke_entities.append(stroke_e.model_dump())
                word_entities.extend(w.model_dump() for w in words)
                naver_page.wait_for_timeout(throttle_ms)
            except Exception as exc:
                print(f"    ! 오류: {ch} -> {exc}")

        save_json(hanja_path, hanja_entities)
        save_json(stroke_path, stroke_entities)
        save_json(word_path, word_entities)

    def _print_outputs(self) -> None:
        print("\n완료")
        print(f"- {self._output_dir / 'hanja_entities.json'}")
        print(f"- {self._output_dir / 'stroke_entities.json'}")
        print(f"- {self._output_dir / 'word_entities.json'}")
