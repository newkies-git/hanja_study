"""HANJA_1817.csv 등에서 행별 선두 한자 추출."""

from __future__ import annotations

from pathlib import Path
from typing import List, Optional

from hanja_etl.text_utils import CJK_RE, unique_preserve_order


class CsvHanjaCharacterSource:
    """
    CSV 각 행에서 '한자' 열(첫 번째 필드)의 선두 CJK 문자를 읽는다.
    헤더 행(한자,음,...)은 건너뛴다.
    """

    def __init__(self, csv_path: Path) -> None:
        self._path = csv_path

    @staticmethod
    def extract_leading_hanja_from_line(line: str) -> Optional[str]:
        stripped = line.strip()
        if not stripped:
            return None
        if stripped.startswith("한자,") or stripped.startswith("\ufeff한자,"):
            return None
        first_field = stripped.split(",", 1)[0].strip()
        if not first_field:
            return None
        # 첫 필드 선두 문자 (교육용 CSV에 포함된 확장 한자 U+20000대 등 포함)
        lead = first_field[0]
        if CJK_RE.match(lead):
            return lead
        match = CJK_RE.search(first_field)
        return match.group(0) if match else lead

    def load_unique_hanja_in_order(self) -> List[str]:
        if not self._path.exists():
            raise FileNotFoundError(f"CSV not found: {self._path}")

        raw = self._path.read_text(encoding="utf-8-sig")
        ordered: List[str] = []
        for line in raw.splitlines():
            ch = self.extract_leading_hanja_from_line(line)
            if ch:
                ordered.append(ch)
        return unique_preserve_order(ordered)
