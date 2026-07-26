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
    failed_hanja_chars: Set[str],
    attempted_hanja_chars: Set[str],
) -> None:
    """
    `attempted_hanja_chars`에 포함된 한자가 적힌 행만 갱신한다.
    - 실패: `오류` = X
    - 성공: `오류` 비움
    처리 대상이 아닌 행의 `오류` 값은 유지(분할 실행 시 다른 청크 행 보존).
    """
    if not attempted_hanja_chars:
        return
    csv_path = csv_path.resolve()
    csv_file_text = csv_path.read_text(encoding="utf-8-sig")
    rows: List[List[str]] = list(csv.reader(StringIO(csv_file_text)))
    if not rows:
        return

    header = [cell.strip() for cell in rows[0]]
    try:
        error_column_index = header.index(ERROR_HEADER)
    except ValueError:
        header.append(ERROR_HEADER)
        error_column_index = len(header) - 1
    rows[0] = header

    max_cols = len(header)
    for i in range(1, len(rows)):
        row = [cell.strip() for cell in rows[i]]
        while len(row) < max_cols:
            row.append("")
        rows[i] = row

        hanja_character = CsvHanjaCharacterSource.hanja_from_data_row(row)
        if hanja_character is None or hanja_character not in attempted_hanja_chars:
            continue
        rows[i][error_column_index] = (
            "X" if hanja_character in failed_hanja_chars else ""
        )

    with csv_path.open("w", encoding="utf-8-sig", newline="") as handle:
        csv.writer(handle).writerows(rows)
