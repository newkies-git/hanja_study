"""네이버 한자사전 페이지 텍스트에서 엔티티 파싱."""

from __future__ import annotations

import re
from typing import Dict, List, Tuple

from hanja_etl.identifiers import make_hanja_entity_id, make_stroke_entity_id, make_word_entity_id
from hanja_etl.models import HanjaEntity, WordEntity
from hanja_etl.text_utils import CJK_RE, normalize_whitespace, infer_school_level_from_text

# 본문 한자 항목의 부수 줄(획순보기와 함께 나오는 행만 — 관련 한자 부수 오매칭 방지)
_RADICAL_MAIN_LINE = re.compile(
    r"부수\s+([^\s(]+)\(([^)]+)\)\s+총\s*획수\s*(\d+)획\s*획순보기"
)
_RADICAL_FALLBACK = re.compile(
    r"부수\s+([^\s(]+)\(([^)]+)\)\s+총\s*획수\s*(\d+)획"
)

# 성어 첫 줄: 漸入佳境 점입가경 성어 읽기3급II / 佳人薄命 가인박명 유래 성어 …
_IDIOM_HEAD = re.compile(
    r"^([一-龥]+)\s+([가-힣·]+)\s+(유래\s+)?성어(?:\s+읽기[0-9급I·\s]*)?\s*$"
)

# 복합 단어 첫 줄: 評價價格 평가가격
_COMPOUND_WORD_HEAD = re.compile(r"^([一-龥]{2,})\s+([가-힣]{2,24})\s*$")

_SPLIT_VENDOR = "㈜오픈마인드인포테인먼트"


class NaverHanjaTextParser:
    """inner_text(줄바꿈 유지) 기반 파서."""

    def build_hanja_entity(self, character: str, page_text: str) -> HanjaEntity:
        reading = ""
        meaning = ""

        pattern_after_char = rf"{re.escape(character)}\s+([가-힣]+)\s+([가-힣]+)"
        match = re.search(pattern_after_char, page_text)
        if match:
            meaning = match.group(1)
            reading = match.group(2)

        if not reading:
            match2 = re.search(
                r"([가-힣]{1,12})\s+([가-힣]{1,6})\s+부수", page_text
            )
            if match2:
                meaning = match2.group(1)
                reading = match2.group(2)

        radical = ""
        radical_meaning = ""
        stroke_count = 0
        grade_level = ""

        radical_match = _RADICAL_MAIN_LINE.search(page_text)
        if not radical_match:
            radical_match = _RADICAL_FALLBACK.search(page_text)
        if radical_match:
            radical = (radical_match.group(1) or "").strip()
            radical_meaning = (radical_match.group(2) or "").strip()
            stroke_count = int(radical_match.group(3))

        if not stroke_count:
            stroke_count_match = re.search(r"총\s*획수\s*(\d+)획", page_text)
            if stroke_count_match:
                stroke_count = int(stroke_count_match.group(1))

        grade_match = re.search(r"(준?특?[\d]+급|준[\d]+급)", page_text)
        if grade_match:
            grade_level = grade_match.group(1)

        school_level = infer_school_level_from_text(page_text)

        origin_note = ""
        shape_explanation = ""
        if "한자 유래" in page_text or "의 한자 유래" in page_text:
            origin_match = re.search(
                r"(?:의\s*)?한자 유래\s*\n(.+?)(?:\n\n|\n\[한자로드|\n오픈사전|\Z)",
                page_text,
                re.DOTALL,
            )
            if origin_match:
                origin_note = normalize_whitespace(origin_match.group(1))
                if len(origin_note) > 800:
                    origin_note = origin_note[:800] + "…"
                shape_explanation = origin_note[:200]

        return HanjaEntity(
            id=make_hanja_entity_id(character),
            char=character,
            reading=reading,
            meaning=meaning,
            radical=radical,
            radical_meaning=radical_meaning,
            stroke_count=stroke_count,
            school_level=school_level,
            grade_level=grade_level,
            category="from_csv_naver",
            shape_explanation=shape_explanation,
            origin_note=origin_note,
            difficulty=0,
            stroke_data_id=make_stroke_entity_id(character),
        )

    def _slice_word_idiom_section(self, page_text: str) -> str:
        section_head_match = re.search(r"단어·성어\s+[\d,]+", page_text)
        if not section_head_match:
            return ""
        start = section_head_match.end()
        rest = page_text[start:]
        section_end_match = re.search(
            r"(?:^|\n)단어·성어\s+더보기|(?:^|\n)[^\n]*의 한자 유래\n",
            rest,
        )
        if section_end_match:
            return rest[: section_end_match.start()]
        return rest

    @staticmethod
    def _meaning_from_block_lines(lines: List[str], start: int) -> str:
        parts: List[str] = []
        for line in lines[start:]:
            stripped_line = line.strip()
            if not stripped_line:
                if parts:
                    break
                continue
            if "단어장에 저장" in stripped_line:
                continue
            if stripped_line == _SPLIT_VENDOR:
                break
            if re.fullmatch(r"\d+\.", stripped_line):
                continue
            parts.append(stripped_line)
        return normalize_whitespace(" ".join(parts))[:2500]

    def build_word_entities(self, character: str, page_text: str) -> List[WordEntity]:
        section = self._slice_word_idiom_section(page_text)
        if not section.strip():
            return []

        blocks = section.split(_SPLIT_VENDOR)
        collected: List[WordEntity] = []

        for block in blocks:
            block = block.strip()
            if not block:
                continue
            lines = [
                line.rstrip() for line in block.splitlines() if line.strip()
            ]

            head_idx = 0
            while head_idx < len(lines):
                candidate_line = lines[head_idx]
                if "단어장에 저장" in candidate_line or candidate_line.startswith(
                    "오픈사전"
                ):
                    head_idx += 1
                    continue
                break
            if head_idx >= len(lines):
                continue

            head = lines[head_idx].strip()

            idiom_match = _IDIOM_HEAD.match(head)
            if idiom_match:
                idiom_hanja_text = idiom_match.group(1).strip()
                idiom_reading_text = idiom_match.group(2).strip()
                if character not in idiom_hanja_text:
                    continue
                meaning = self._meaning_from_block_lines(lines, head_idx + 1)
                collected.append(
                    self._make_word_entity(
                        idiom_reading_text,
                        idiom_hanja_text,
                        meaning,
                        "성어",
                        character,
                    )
                )
                continue

            compound_match = _COMPOUND_WORD_HEAD.match(head)
            if compound_match:
                compound_hanja_text = compound_match.group(1).strip()
                compound_reading_text = compound_match.group(2).strip()
                if character not in compound_hanja_text:
                    continue
                if len(compound_hanja_text) < 2:
                    continue
                meaning = self._meaning_from_block_lines(lines, head_idx + 1)
                if not meaning:
                    continue
                collected.append(
                    self._make_word_entity(
                        compound_reading_text,
                        compound_hanja_text,
                        meaning,
                        "단어",
                        character,
                    )
                )

        deduplicated_by_key: Dict[Tuple[str, str, str], WordEntity] = {}
        for item in collected:
            deduplicated_by_key[(item.word, item.hanja, item.entry_type)] = item
        return list(deduplicated_by_key.values())

    def _make_word_entity(
        self,
        word: str,
        hanja: str,
        meaning: str,
        entry_type: str,
        head_character: str,
    ) -> WordEntity:
        related = [glyph for glyph in hanja if CJK_RE.match(glyph)]
        return WordEntity(
            word_id=make_word_entity_id(word, hanja, entry_type),
            hanja_id=make_hanja_entity_id(head_character),
            word=word,
            hanja=hanja,
            meaning=meaning,
            related_hanja=related,
            school_recommended=False,
            entry_type=entry_type,
        )
