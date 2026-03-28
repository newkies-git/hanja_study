"""텍스트·정규식 유틸."""

from __future__ import annotations

import re
from typing import List

CJK_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
KOR_RE = re.compile(r"[가-힣]+")


def normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def unique_preserve_order(sequence: List[str]) -> List[str]:
    seen = set()
    out: List[str] = []
    for item in sequence:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def safe_element_text(element) -> str:
    if element is None:
        return ""
    return normalize_whitespace(element.get_text(" ", strip=True))


def infer_school_level_from_text(text: str) -> str:
    has_middle = "중학" in text or "중학교" in text or "중학용" in text
    has_high = "고등" in text or "고등학교" in text or "고등용" in text
    if has_middle and has_high:
        return "both"
    if has_middle:
        return "middle"
    if has_high:
        return "high"
    return "unknown"
