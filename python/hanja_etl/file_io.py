"""JSON 등 파일 입출력."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def save_json(path: Path, data: Any) -> None:
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
