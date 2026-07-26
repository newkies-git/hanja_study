"""경로·URL 등 실행 설정."""

from __future__ import annotations

from pathlib import Path

PACKAGE_ROOT = Path(__file__).resolve().parent
PYTHON_ROOT = PACKAGE_ROOT.parent

NAVER_HANJA_SEARCH_URL_TEMPLATE = (
    "https://hanja.dict.naver.com/#/search?query={query}"
)

OUTPUT_DIR = PYTHON_ROOT / "output"


def ensure_output_dir() -> Path:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    return OUTPUT_DIR
