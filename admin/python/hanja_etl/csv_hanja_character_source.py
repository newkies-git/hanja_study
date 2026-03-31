"""HANJA basis CSV 등에서 행별 선두 한자 추출."""

from __future__ import annotations

import csv
import re
from io import StringIO
from pathlib import Path
from typing import List, Optional

from hanja_etl.text_utils import CJK_RE, unique_preserve_order

_BASIS_ID_RE = re.compile(r"^H[0-9A-F]+$", re.IGNORECASE)


class CsvHanjaCharacterSource:
    """
    CSV 각 행에서 한자 열을 읽는다.

    - `id,한자,음` 형식: 첫 열이 basis ID(`H`+16진)이면 **두 번째 열**에서 한자를 취한다.
    - `한자,음` 등 ID 없는 형식: **첫 번째 열**에서 취한다 (기존 동작).
    헤더 행(`id` / `한자`로 시작하는 표준 헤더)은 건너뛴다.
    """

    def __init__(self, csv_path: Path) -> None:
        self._path = csv_path

    @staticmethod
    def _looks_like_basis_id(value: str) -> bool:
        return bool(_BASIS_ID_RE.match(value.strip()))

    @staticmethod
    def hanja_from_data_row(row: List[str]) -> Optional[str]:
        """데이터 행(헤더 아님)에서 한 글자 한자를 꺼낸다."""
        if not row or not any(c.strip() for c in row):
            return None
        row = [c.strip() for c in row]
        key0 = row[0]
        if key0.lower() == "id" or key0 == "한자":
            return None
        if len(row) >= 2 and CsvHanjaCharacterSource._looks_like_basis_id(key0):
            field = row[1]
        else:
            field = row[0]
        return CsvHanjaCharacterSource.extract_leading_hanja_from_field(field)

    @staticmethod
    def extract_leading_hanja_from_field(field: str) -> Optional[str]:
        stripped = field.strip()
        if not stripped:
            return None
        lead = stripped[0]
        if CJK_RE.match(lead):
            return lead
        match = CJK_RE.search(stripped)
        return match.group(0) if match else None

    @staticmethod
    def extract_leading_hanja_from_line(line: str) -> Optional[str]:
        """단일 텍스트 줄(쉼표 구분 미파싱) — 테스트·호환용."""
        stripped = line.strip()
        if not stripped:
            return None
        if stripped.startswith("한자,") or stripped.startswith("\ufeff한자,"):
            return None
        if stripped.lower().startswith("id,"):
            return None
        reader = csv.reader(StringIO(stripped))
        try:
            row = next(reader)
        except StopIteration:
            return None
        if not row:
            return None
        row = [c.strip() for c in row]
        if len(row) >= 2 and CsvHanjaCharacterSource._looks_like_basis_id(row[0]):
            target = row[1]
        else:
            target = row[0]
        return CsvHanjaCharacterSource.extract_leading_hanja_from_field(target)

    def load_unique_hanja_in_order(self) -> List[str]:
        if not self._path.exists():
            raise FileNotFoundError(f"CSV not found: {self._path}")

        raw = self._path.read_text(encoding="utf-8-sig")
        ordered: List[str] = []
        for row in csv.reader(StringIO(raw)):
            if not row or not any(c.strip() for c in row):
                continue
            row = [c.strip() for c in row]
            key0 = row[0].strip()
            if key0.lower() == "id" or key0 == "한자":
                continue
            if len(row) >= 2 and self._looks_like_basis_id(key0):
                field = row[1]
            else:
                field = row[0]
            ch = self.extract_leading_hanja_from_field(field)
            if ch:
                ordered.append(ch)
        return unique_preserve_order(ordered)
