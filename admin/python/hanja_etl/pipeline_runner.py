"""CSV에서 한자를 읽어 네이버 한자사전 스크래핑을 실행한다."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, List, Sequence, Set, Tuple

from playwright.sync_api import sync_playwright

from hanja_etl.browser_context_factory import ChromiumBrowserFactory
from hanja_etl.config import ensure_output_dir
from hanja_etl.csv_error_column import update_csv_errors
from hanja_etl.csv_hanja_character_source import CsvHanjaCharacterSource
from hanja_etl.file_io import load_json, save_json
from hanja_etl.hanja_dictionary_scrape_service import HanjaDictionaryScrapeService

_PART_SUFFIX_RE = re.compile(r"\.part(\d+)\.json$")


def split_into_n_chunks(items: List[str], n: int) -> List[List[str]]:
    """순서 유지. n개 청크에 가능한 한 균등 분배."""
    if n < 1:
        raise ValueError("n must be >= 1")
    if not items:
        return [[] for _ in range(n)]
    if n == 1:
        return [list(items)]
    base, rem = divmod(len(items), n)
    out: List[List[str]] = []
    start = 0
    for i in range(n):
        size = base + (1 if i < rem else 0)
        out.append(items[start : start + size])
        start += size
    return out


def merge_split_outputs(output_dir: Path) -> None:
    """
    `*.partNNN.json`을 번호 순으로 이어 `hanja_entities.json` 등 단일 파일로 만든다.
    """
    output_dir = output_dir.resolve()
    bases = ("hanja_entities", "stroke_entities", "word_entities")
    for output_stem in bases:
        paths = sorted(
            output_dir.glob(f"{output_stem}.part*.json"),
            key=lambda path: _part_index_from_name(path.name),
        )
        if not paths:
            print(f"[merge] 건너뜀 (파트 없음): {output_stem}")
            continue
        merged: List[Any] = []
        for path in paths:
            chunk = load_json(path)
            if not isinstance(chunk, list):
                raise TypeError(f"{path}는 JSON 배열이어야 합니다.")
            merged.extend(chunk)
        out_path = output_dir / f"{output_stem}.json"
        save_json(out_path, merged)
        print(f"[merge] {len(paths)}개 파트 → {out_path} ({len(merged)}건)")


def _part_index_from_name(filename: str) -> int:
    suffix_match = _PART_SUFFIX_RE.search(filename)
    return int(suffix_match.group(1)) if suffix_match else -1


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
        hanja_range: tuple[int, int] | None = None,
        split_files: int | None = None,
        chunk_index: int | None = None,
    ) -> None:
        """
        CSV에서 한자를 읽어 네이버 한자사전에서 엔티티를 수집한다.
        `hanja_range`가 있으면 고유 순서 기준 1부터 번호로 [시작, 끝] 양 끝 포함 슬라이스 후 `limit` 적용.
        `split_files`>=2이면 한자 목록을 그만큼 나눠 `*.partNNN.json`으로 저장한다.
        `chunk_index`를 주면 해당 파트만 처리(멀티 프로세스용).
        """
        source = CsvHanjaCharacterSource(csv_path)
        characters = source.load_unique_hanja_in_order()
        if hanja_range is not None:
            start_1, end_1 = hanja_range
            characters = characters[start_1 - 1 : end_1]
        if limit is not None:
            characters = characters[:limit]

        print(
            f"[CSV] {csv_path} 에서 한자 {len(characters)}자 (파일 내 고유 순서) → 네이버 사전"
        )

        use_parts = split_files is not None and split_files >= 2
        if use_parts:
            chunks = split_into_n_chunks(characters, split_files)
            if chunk_index is not None:
                if not (0 <= chunk_index < split_files):
                    raise ValueError(
                        f"chunk_index는 0 이상 {split_files - 1} 이하여야 합니다."
                    )
                work: List[tuple[int, List[str]]] = [
                    (chunk_index, chunks[chunk_index])
                ]
            else:
                work = [
                    (chunk_index, character_chunk)
                    for chunk_index, character_chunk in enumerate(chunks)
                ]
        else:
            if chunk_index is not None:
                raise ValueError("chunk_index는 --split-files 와 함께만 사용할 수 있습니다.")
            work = [(0, characters)]

        failed_hanja_chars: Set[str] = set()
        attempted_hanja_chars: Set[str] = set()
        with sync_playwright() as playwright:
            browser, context = ChromiumBrowserFactory.create_browser_and_context(
                playwright, headless=headless
            )
            for part_idx, character_chunk in work:
                if not character_chunk:
                    print(f"[파트 {part_idx:03d}] 한자 0건 — 건너뜀")
                    continue
                label = f"part {part_idx:03d}" if use_parts else "단일"
                print(f"[{label}] {len(character_chunk)}자 처리")
                part_failed_chars, part_attempted_chars = self._scrape_naver_targets(
                    context,
                    character_chunk,
                    throttle_ms=throttle_ms,
                    part_index=part_idx if use_parts else None,
                )
                failed_hanja_chars |= part_failed_chars
                attempted_hanja_chars |= part_attempted_chars
            browser.close()

        update_csv_errors(csv_path, failed_hanja_chars, attempted_hanja_chars)
        if failed_hanja_chars:
            print(f"[CSV] 오류 표시 {len(failed_hanja_chars)}자 → {csv_path}")

        if use_parts:
            self._print_outputs_parts()
        else:
            self._print_outputs()

    def _scrape_naver_targets(
        self,
        context,
        target_chars: Sequence[str],
        throttle_ms: int,
        part_index: int | None = None,
    ) -> Tuple[Set[str], Set[str]]:
        if part_index is not None:
            tag = f".part{part_index:03d}"
            hanja_path = self._output_dir / f"hanja_entities{tag}.json"
            stroke_path = self._output_dir / f"stroke_entities{tag}.json"
            word_path = self._output_dir / f"word_entities{tag}.json"
        else:
            hanja_path = self._output_dir / "hanja_entities.json"
            stroke_path = self._output_dir / "stroke_entities.json"
            word_path = self._output_dir / "word_entities.json"

        print("[네이버 한자사전] 엔티티 생성 중...")
        naver_page = context.new_page()
        hanja_entities: List[Dict[str, Any]] = []
        stroke_entities: List[Dict[str, Any]] = []
        word_entities: List[Dict[str, Any]] = []
        failed_hanja_chars: Set[str] = set()
        attempted_hanja_chars: Set[str] = set()

        total = len(target_chars)
        for index, hanja_character in enumerate(target_chars, start=1):
            print(f"  - ({index}/{total}) {hanja_character}")
            attempted_hanja_chars.add(hanja_character)
            try:
                hanja_entity, stroke_entity, word_entity_list = (
                    self._scrape.scrape_one_character(naver_page, hanja_character)
                )
                hanja_entities.append(hanja_entity.model_dump())
                stroke_entities.append(stroke_entity.model_dump())
                word_entities.extend(
                    word.model_dump() for word in word_entity_list
                )
                naver_page.wait_for_timeout(throttle_ms)
            except Exception as error:
                failed_hanja_chars.add(hanja_character)
                print(f"    ! 오류: {hanja_character} -> {error}")

        save_json(hanja_path, hanja_entities)
        save_json(stroke_path, stroke_entities)
        save_json(word_path, word_entities)
        return failed_hanja_chars, attempted_hanja_chars

    def _print_outputs(self) -> None:
        print("\n완료")
        print(f"- {self._output_dir / 'hanja_entities.json'}")
        print(f"- {self._output_dir / 'stroke_entities.json'}")
        print(f"- {self._output_dir / 'word_entities.json'}")

    def _print_outputs_parts(self) -> None:
        print("\n파트 파일 저장 완료 (병합 전)")
        print(f"- {self._output_dir}/hanja_entities.partNNN.json")
        print(f"- {self._output_dir}/stroke_entities.partNNN.json")
        print(f"- {self._output_dir}/word_entities.partNNN.json")
        print("병합: python hanja_etl.py --merge [--output-dir ...]")
