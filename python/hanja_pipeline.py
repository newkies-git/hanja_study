"""
한자 ETL 진입점.

실행 시 프롬프트에 CSV 경로(또는 파일명)를 입력한다.
CSV 첫 번째 필드의 선두 한자만 읽어
https://hanja.dict.naver.com/#/search?query={} 로 네이버 한자사전 엔티티를 수집한다.

준비 (python 디렉터리에서)
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt
  python -m playwright install chromium

터미널에서 `python` 명령이 없으면 venv 활성화 후 `python`을 쓰거나 `python3 hanja_pipeline.py`를 사용한다.

주의: 사이트 DOM 변경 시 selector·정규식 보정 필요. robots/약관 준수.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from hanja_etl.config import ensure_output_dir
from hanja_etl.pipeline_runner import PipelineRunner


def _prompt_csv_path() -> Path:
    """표준 입력에서 CSV 파일 경로(또는 파일명)를 받는다."""
    try:
        raw = input("CSV 파일 경로 또는 파일명을 입력하세요: ").strip()
    except EOFError:
        print("입력이 없습니다.", file=sys.stderr)
        sys.exit(1)
    if not raw:
        print("파일 경로를 입력해야 합니다.", file=sys.stderr)
        sys.exit(1)
    return Path(raw).expanduser().resolve()


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="CSV 한자 열 → 네이버 한자사전 스크래핑 (CSV 경로는 실행 시 프롬프트로 입력)"
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="앞에서부터 N글자만 처리 (디버그용)",
    )
    parser.add_argument(
        "--no-headless",
        action="store_true",
        help="Chromium을 화면에 띄워 실행",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="JSON 출력 디렉터리 (기본: python/output)",
    )
    return parser.parse_args()


def main() -> None:
    args = _parse_args()
    out = args.output_dir
    if out is not None:
        out.mkdir(parents=True, exist_ok=True)
    else:
        out = ensure_output_dir()

    csv_path = _prompt_csv_path()
    if not csv_path.is_file():
        print(f"파일을 찾을 수 없습니다: {csv_path}", file=sys.stderr)
        sys.exit(1)

    runner = PipelineRunner(output_dir=out)
    runner.run_from_csv(
        csv_path=csv_path,
        headless=not args.no_headless,
        limit=args.limit,
    )


if __name__ == "__main__":
    main()
