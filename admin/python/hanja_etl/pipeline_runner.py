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
    for base in bases:
        paths = sorted(
            output_dir.glob(f"{base}.part*.json"),
            key=lambda p: _part_index_from_name(p.name),
        )
        if not paths:
            print(f"[merge] 건너뜀 (파트 없음): {base}")
            continue
        merged: List[Any] = []
        for path in paths:
            chunk = load_json(path)
            if not isinstance(chunk, list):
                raise TypeError(f"{path}는 JSON 배열이어야 합니다.")
            merged.extend(chunk)
        out_path = output_dir / f"{base}.json"
        save_json(out_path, merged)
        print(f"[merge] {len(paths)}개 파트 → {out_path} ({len(merged)}건)")


def _part_index_from_name(filename: str) -> int:
    m = _PART_SUFFIX_RE.search(filename)
    return int(m.group(1)) if m else -1


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
                work = [(i, chs) for i, chs in enumerate(chunks)]
        else:
            if chunk_index is not None:
                raise ValueError("chunk_index는 --split-files 와 함께만 사용할 수 있습니다.")
            work = [(0, characters)]

        failed_chars: Set[str] = set()
        processed_chars: Set[str] = set()
        with sync_playwright() as playwright:
            browser, context = ChromiumBrowserFactory.create_browser_and_context(
                playwright, headless=headless
            )
            for part_idx, chs in work:
                if not chs:
                    print(f"[파트 {part_idx:03d}] 한자 0건 — 건너뜀")
                    continue
                label = f"part {part_idx:03d}" if use_parts else "단일"
                print(f"[{label}] {len(chs)}자 처리")
                part_failed, part_ok = self._scrape_naver_targets(
                    context,
                    chs,
                    throttle_ms=throttle_ms,
                    part_index=part_idx if use_parts else None,
                )
                failed_chars |= part_failed
                processed_chars |= part_ok
            browser.close()

        update_csv_errors(csv_path, failed_chars, processed_chars)
        if failed_chars:
            print(f"[CSV] 오류 표시 {len(failed_chars)}자 → {csv_path}")

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
        failed: Set[str] = set()
        processed: Set[str] = set()

        total = len(target_chars)
        for index, ch in enumerate(target_chars, start=1):
            print(f"  - ({index}/{total}) {ch}")
            processed.add(ch)
            try:
                hanja_e, stroke_e, words = self._scrape.scrape_one_character(
                    naver_page, ch
                )
                hanja_entities.append(hanja_e.model_dump())
                stroke_entities.append(stroke_e.model_dump())
                word_entities.extend(w.model_dump() for w in words)
                naver_page.wait_for_timeout(throttle_ms)
            except Exception as exc:
                failed.add(ch)
                print(f"    ! 오류: {ch} -> {exc}")

        save_json(hanja_path, hanja_entities)
        save_json(stroke_path, stroke_entities)
        save_json(word_path, word_entities)
        return failed, processed

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
