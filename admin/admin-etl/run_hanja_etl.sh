#!/usr/bin/env bash
# 가상환경 활성화 → hanja_etl.py 실행 → --merge 로 파트 JSON 병합
#
# 변수(환경):
#   CSV          입력 CSV (기본: hanja_basis.csv → input/ 아래)
#   SPLIT_FILES  분할 개수 N (2 이상일 때만 --split-files)
#
# 짧은 인자(명령줄, 환경 변수보다 우선):
#   --<파일>.csv  또는 -<파일>.csv  → input/ 아래 해당 CSV
#   --<숫자>      또는 -<숫자>      → SPLIT_FILES (예: --50)
#   --시작:끝     (예: --1:10)      → 고유 한자 순서 1번부터 양 끝 포함. 생략 시 전체
#
# 나머지 인자는 hanja_etl.py 로 그대로 전달 (--limit, --output-dir 등).
#
# 예:
#   ./run_hanja_etl.sh --hanja_basis.csv --50 --1:10
#   ./run_hanja_etl.sh -hanja_basis.csv -50
#   ./run_hanja_etl.sh --hanja_basis.csv --50 --10:9   → 시작>끝 이면 Python에서 오류
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

ACTIVATE="$ROOT/.venv/bin/activate"
if [[ ! -f "$ACTIVATE" ]]; then
  echo "가상환경이 없습니다: $ROOT/.venv" >&2
  echo "다음을 실행한 뒤 다시 시도하세요:" >&2
  echo "  python3 -m venv .venv" >&2
  echo "  source .venv/bin/activate" >&2
  echo "  pip install -r requirements.txt" >&2
  echo "  python -m playwright install chromium" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ACTIVATE"

CSV_SHORT=""
SPLIT_SHORT=""
RANGE_SPEC=""
PASSTHRU=()
for a in "$@"; do
  if [[ "$a" =~ ^--[0-9]+:[0-9]+$ ]]; then
    RANGE_SPEC="${a#--}"
  elif [[ "$a" == --*.csv ]]; then
    CSV_SHORT="${a#--}"
  elif [[ "$a" =~ ^--[0-9]+$ ]]; then
    SPLIT_SHORT="${a#--}"
  elif [[ "$a" == -* && "$a" == *.csv ]]; then
    CSV_SHORT="${a#-}"
  elif [[ "$a" =~ ^-[0-9]+$ ]]; then
    SPLIT_SHORT="${a#-}"
  else
    PASSTHRU+=("$a")
  fi
done

if [[ -n "$CSV_SHORT" ]]; then
  CSV_MERGED="$ROOT/input/$(basename "$CSV_SHORT")"
elif [[ -n "${CSV:-}" ]]; then
  CSV_RAW="$CSV"
  if [[ "$CSV_RAW" == /* ]]; then
    CSV_MERGED="$CSV_RAW"
  elif [[ "$CSV_RAW" == */* ]]; then
    CSV_MERGED="$ROOT/$CSV_RAW"
  else
    CSV_MERGED="$ROOT/input/$CSV_RAW"
  fi
else
  CSV_MERGED="$ROOT/input/hanja_basis.csv"
fi
CSV="$(python3 -c "import pathlib, sys; print(pathlib.Path(sys.argv[1]).expanduser().resolve())" "$CSV_MERGED")"

if [[ -n "$SPLIT_SHORT" ]]; then
  SPLIT_USE="$SPLIT_SHORT"
else
  SPLIT_USE="${SPLIT_FILES:-}"
fi

ETL_ARGS=(--csv "$CSV")
if [[ -n "$SPLIT_USE" ]]; then
  ETL_ARGS+=(--split-files "$SPLIT_USE")
fi
if [[ -n "$RANGE_SPEC" ]]; then
  ETL_ARGS+=(--hanja-range "$RANGE_SPEC")
fi
if [[ ${#PASSTHRU[@]} -gt 0 ]]; then
  ETL_ARGS+=("${PASSTHRU[@]}")
fi

OUT_DIR_REL=""
for ((i = 0; i < ${#ETL_ARGS[@]}; i++)); do
  if [[ "${ETL_ARGS[i]}" == --output-dir && $((i + 1)) -lt ${#ETL_ARGS[@]} ]]; then
    OUT_DIR_REL="${ETL_ARGS[i + 1]}"
    break
  fi
done

if [[ -z "$OUT_DIR_REL" ]]; then
  OUT_DIR="$ROOT/output"
else
  OUT_DIR="$(python3 -c "import pathlib, sys; print(pathlib.Path(sys.argv[1]).expanduser().resolve())" "$OUT_DIR_REL")"
fi

echo "CSV=$CSV"
echo "SPLIT_FILES=${SPLIT_USE:-(미사용)}"
echo "HANJA_RANGE=${RANGE_SPEC:-(전체)}"
if ((${#PASSTHRU[@]})); then
  echo "추가 인자: ${PASSTHRU[*]}"
else
  echo "추가 인자: (없음)"
fi
echo ""
echo "== hanja_etl (스크래핑) =="
python3 "$ROOT/hanja_etl.py" "${ETL_ARGS[@]}"

echo ""
echo "== hanja_etl --merge (파트 → 단일 JSON) =="
python3 "$ROOT/hanja_etl.py" --merge --output-dir "$OUT_DIR"

echo ""
echo "완료. 출력: $OUT_DIR"
