"""
한자 ETL 진입점.

CSV 경로는 `--csv`로 넘기거나, 생략 시 프롬프트에서 입력한다.
CSV의 한자 열( basis 형식이면 ID 다음 열)을 읽어
https://hanja.dict.naver.com/#/search?query={} 로 네이버 한자사전 엔티티를 수집한다.

준비 (python 디렉터리에서)
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt
  python -m playwright install chromium

분할 실행: `--split-files N`(N>=2)로 한자 목록을 N개 파트로 나눠
`hanja_entities.part000.json` … 저장. 모든 파트가 준비되면
`python hanja_etl.py --merge` 로 단일 JSON으로 병합.

실행 후 입력 CSV에 `오류` 열을 두고, 스크래핑 예외가 난 한자 행에는 `X`를 쓴다(성공 행은 비움).

주의: 사이트 DOM 변경 시 selector·정규식 보정 필요. robots/약관 준수.

산출물은 **JSON 배열**: `hanja_entities.json`→**hanja_extend**, `stroke_entities.json`→**hanja_stroke**,
`word_entities.json`→**hanja_word**. `hanja_basis`는 별도 CSV.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from hanja_etl.config import ensure_output_dir
from hanja_etl.pipeline_runner import PipelineRunner, merge_split_outputs


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


def _parse_hanja_range(spec: str) -> tuple[int, int]:
    """1-based inclusive START:END."""
    parts = spec.strip().split(":", 1)
    if len(parts) != 2 or not parts[0].strip() or not parts[1].strip():
        print(
            "--hanja-range 는 START:END 형식(1부터, 양 끝 포함)이어야 합니다.",
            file=sys.stderr,
        )
        sys.exit(1)
    try:
        start = int(parts[0].strip())
        end = int(parts[1].strip())
    except ValueError:
        print("--hanja-range 의 시작·끝은 정수여야 합니다.", file=sys.stderr)
        sys.exit(1)
    if start < 1 or end < 1:
        print("--hanja-range: 시작·끝은 1 이상이어야 합니다.", file=sys.stderr)
        sys.exit(1)
    if start > end:
        print("--hanja-range: 시작이 끝보다 클 수 없습니다.", file=sys.stderr)
        sys.exit(1)
    return start, end


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="CSV 한자 → 네이버 한자사전 스크래핑 (--csv 미지정 시 경로를 프롬프트로 입력)"
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=None,
        help="입력 CSV 경로 (미지정 시 대화형 입력). --merge 시 불필요",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="앞에서부터 N글자만 처리 (--hanja-range 적용 후)",
    )
    parser.add_argument(
        "--hanja-range",
        type=str,
        default=None,
        metavar="START:END",
        help="CSV 고유 한자 순서 1번부터 번호, 양 끝 포함(예: 1:10). 미지정이면 전체",
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
    parser.add_argument(
        "--split-files",
        type=int,
        default=None,
        metavar="N",
        help="한자 목록을 N개 파일로 나눠 저장 (N>=2, *.partNNN.json). 병합은 --merge",
    )
    parser.add_argument(
        "--chunk-index",
        type=int,
        default=None,
        metavar="K",
        help="0..N-1. 해당 파트만 처리(멀티 프로세스용). --split-files 필수",
    )
    parser.add_argument(
        "--merge",
        action="store_true",
        help="output-dir 안의 *.partNNN.json을 hanja_entities.json 등 단일 파일로 병합",
    )
    return parser.parse_args()


def main() -> None:
    args = _parse_args()
    output_directory = args.output_dir
    if output_directory is not None:
        output_directory.mkdir(parents=True, exist_ok=True)
    else:
        output_directory = ensure_output_dir()

    if args.merge:
        merge_split_outputs(output_directory)
        return

    if args.chunk_index is not None and args.split_files is None:
        print("--chunk-index 는 --split-files 와 함께 사용하세요.", file=sys.stderr)
        sys.exit(1)
    if args.split_files is not None and args.split_files < 2:
        print("--split-files N 은 2 이상이어야 합니다. 단일 파일은 옵션을 빼고 실행하세요.", file=sys.stderr)
        sys.exit(1)

    if args.csv is not None:
        csv_path = args.csv.expanduser().resolve()
    else:
        csv_path = _prompt_csv_path()
    if not csv_path.is_file():
        print(f"파일을 찾을 수 없습니다: {csv_path}", file=sys.stderr)
        sys.exit(1)

    hanja_range = None
    if args.hanja_range is not None:
        hanja_range = _parse_hanja_range(args.hanja_range)

    runner = PipelineRunner(output_dir=output_directory)
    runner.run_from_csv(
        csv_path=csv_path,
        headless=not args.no_headless,
        limit=args.limit,
        hanja_range=hanja_range,
        split_files=args.split_files,
        chunk_index=args.chunk_index,
    )


if __name__ == "__main__":
    main()
