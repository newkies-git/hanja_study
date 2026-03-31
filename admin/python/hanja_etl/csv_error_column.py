"""CSV `오류` 열: 스크래핑 실패 한자 행에 `X` 표시."""

from __future__ import annotations

import csv
from io import StringIO
from pathlib import Path
from typing import List, Set

from hanja_etl.csv_hanja_character_source import CsvHanjaCharacterSource

ERROR_HEADER = "오류"


def update_csv_errors(
    csv_path: Path,
    failed_chars: Set[str],
    processed_chars: Set[str],
) -> None:
    """
    `processed_chars`에 포함된 한자가 적힌 행만 갱신한다.
    - 실패: `오류` = X
    - 성공: `오류` 비움
    처리 대상이 아닌 행의 `오류` 값은 유지(분할 실행 시 다른 청크 행 보존).
    """
    if not processed_chars:
        return
    csv_path = csv_path.resolve()
    raw = csv_path.read_text(encoding="utf-8-sig")
    rows: List[List[str]] = list(csv.reader(StringIO(raw)))
    if not rows:
        return

    header = [c.strip() for c in rows[0]]
    try:
        err_idx = header.index(ERROR_HEADER)
    except ValueError:
        header.append(ERROR_HEADER)
        err_idx = len(header) - 1
    rows[0] = header

    max_cols = len(header)
    for i in range(1, len(rows)):
        row = [c.strip() for c in rows[i]]
        while len(row) < max_cols:
            row.append("")
        rows[i] = row

        h = CsvHanjaCharacterSource.hanja_from_data_row(row)
        if h is None or h not in processed_chars:
            continue
        rows[i][err_idx] = "X" if h in failed_chars else ""

    with csv_path.open("w", encoding="utf-8-sig", newline="") as handle:
        csv.writer(handle).writerows(rows)
