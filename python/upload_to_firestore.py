#!/usr/bin/env python3
"""
hanja_entities / stroke_entities / word_entities JSON을 Firestore 스키마에 맞게 업로드한다.

사전 준비:
  1) Firebase 콘솔에서 서비스 계정 키 JSON을 내려받거나
  2) gcloud auth application-default login 으로 ADC 설정

실행 예:
  export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
  pip install -r requirements-firebase.txt
  python upload_to_firestore.py --project-id chusa-1817

또는:
  python upload_to_firestore.py --project-id chusa-1817 --credentials /path/to/sa.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    from google.auth.exceptions import DefaultCredentialsError
except ImportError:
    print("firebase-admin이 필요합니다: pip install -r requirements-firebase.txt", file=sys.stderr)
    sys.exit(1)

BATCH_LIMIT = 400


def _points_for_firestore(points: Any) -> list[dict[str, float]]:
    """Firestore는 배열 안에 배열을 둘 수 없어 [[x,y],...] → [{x,y},...]로 바꾼다."""
    if not isinstance(points, list):
        return []
    out: list[dict[str, float]] = []
    for p in points:
        if isinstance(p, (list, tuple)) and len(p) >= 2:
            x, y = p[0], p[1]
            if isinstance(x, (int, float)) and isinstance(y, (int, float)):
                out.append({"x": float(x), "y": float(y)})
    return out


def _strokes_for_firestore(strokes: Any) -> list[dict[str, Any]]:
    if not isinstance(strokes, list):
        return []
    result: list[dict[str, Any]] = []
    for s in strokes:
        if not isinstance(s, dict):
            continue
        d = dict(s)
        if "points" in d:
            d["points"] = _points_for_firestore(d["points"])
        result.append(d)
    return result


def _repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def _load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def _init_firestore(project_id: str, cred_path: str | None) -> firestore.Client:
    try:
        if firebase_admin._apps:
            return firestore.client()

        if cred_path:
            cred = credentials.Certificate(cred_path)
        else:
            cred = credentials.ApplicationDefault()

        firebase_admin.initialize_app(cred, {"projectId": project_id})
        return firestore.client()
    except DefaultCredentialsError:
        print(
            "인증 실패: Application Default Credentials(ADC)가 없습니다.\n"
            "  • 서비스 계정 JSON: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/xxx.json\n"
            "  • 또는 인자: python upload_to_firestore.py --credentials /path/to/xxx.json\n"
            "  • 또는 ADC: gcloud auth application-default login\n"
            "(Firebase 콘솔 → 프로젝트 설정 → 서비스 계정 → 새 비공개 키)",
            file=sys.stderr,
        )
        raise SystemExit(1) from None


def upload(
    db: firestore.Client,
    hanja_path: Path,
    stroke_path: Path,
    words_path: Path,
    content_version: int,
) -> None:
    strokes_raw = _load_json(stroke_path)
    if not isinstance(strokes_raw, list):
        raise SystemExit("stroke_entities.json은 배열이어야 합니다.")
    stroke_by_id: dict[str, dict[str, Any]] = {}
    for item in strokes_raw:
        if isinstance(item, dict) and "stroke_data_id" in item:
            stroke_by_id[str(item["stroke_data_id"])] = item

    hanjas = _load_json(hanja_path)
    if not isinstance(hanjas, list):
        raise SystemExit("hanja_entities.json은 배열이어야 합니다.")

    batch = db.batch()
    n = 0

    def commit_if_needed(force: bool = False) -> None:
        nonlocal batch, n
        if n == 0:
            return
        if force or n >= BATCH_LIMIT:
            batch.commit()
            batch = db.batch()
            n = 0

    cfg = db.collection("config").document("content")
    batch.set(cfg, {"contentVersion": content_version}, merge=True)
    n += 1
    commit_if_needed()

    for h in hanjas:
        if not isinstance(h, dict):
            continue
        doc_id = str(h.get("id") or "").strip()
        if not doc_id:
            continue
        payload = dict(h)
        sid = payload.get("stroke_data_id")
        if sid and str(sid) in stroke_by_id:
            stroke_doc = stroke_by_id[str(sid)]
            strokes = stroke_doc.get("strokes")
            if isinstance(strokes, list):
                payload["strokes"] = _strokes_for_firestore(strokes)
        ref = db.collection("hanja").document(doc_id)
        batch.set(ref, payload, merge=True)
        n += 1
        commit_if_needed()

    commit_if_needed(force=True)

    words = _load_json(words_path)
    if not isinstance(words, list):
        raise SystemExit("word_entities.json은 배열이어야 합니다.")

    batch = db.batch()
    n = 0
    for w in words:
        if not isinstance(w, dict):
            continue
        wid = str(w.get("word_id") or "").strip()
        if not wid:
            continue
        ref = db.collection("words").document(wid)
        batch.set(ref, w, merge=True)
        n += 1
        commit_if_needed()

    commit_if_needed(force=True)

    print(
        f"업로드 완료: hanja {len(hanjas)}건(획 병합), "
        f"words {len(words)}건, config/contentVersion={content_version}"
    )


def _dry_run(hanja_path: Path, stroke_path: Path, words_path: Path) -> None:
    """Firebase 연결 없이 JSON만 검사한다."""
    for path in (hanja_path, stroke_path, words_path):
        if not path.is_file():
            raise SystemExit(f"파일이 없습니다: {path}")
    hanjas = _load_json(hanja_path)
    words = _load_json(words_path)
    strokes = _load_json(stroke_path)
    if not isinstance(hanjas, list):
        raise SystemExit("hanja_entities.json: 최상위는 배열이어야 합니다.")
    if not isinstance(words, list):
        raise SystemExit("word_entities.json: 최상위는 배열이어야 합니다.")
    if not isinstance(strokes, list):
        raise SystemExit("stroke_entities.json: 최상위는 배열이어야 합니다.")
    hanja_with_stroke = sum(
        1
        for h in hanjas
        if isinstance(h, dict) and h.get("stroke_data_id")
    )
    print("[dry-run] JSON 검사 통과")
    print(f"  hanja 문서 수: {len(hanjas)} (stroke_data_id 있는 행: {hanja_with_stroke})")
    print(f"  stroke 엔트리 수: {len(strokes)}")
    print(f"  words 문서 수: {len(words)}")


def main() -> None:
    root = _repo_root()
    default_out = root / "python" / "output"

    p = argparse.ArgumentParser(
        description="JSON 엔티티 → Firestore 업로드 (Flutter 앱은 Firestore에 쓰지 않음)",
    )
    p.add_argument("--project-id", default="chusa-1817", help="GCP/Firebase 프로젝트 ID")
    p.add_argument(
        "--credentials",
        default=None,
        help="서비스 계정 JSON 경로 (미지정 시 Application Default Credentials)",
    )
    p.add_argument("--hanja", type=Path, default=default_out / "hanja_entities.json")
    p.add_argument("--stroke", type=Path, default=default_out / "stroke_entities.json")
    p.add_argument("--words", type=Path, default=default_out / "word_entities.json")
    p.add_argument("--content-version", type=int, default=1)
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Firestore 연결 없이 JSON 개수만 확인",
    )
    args = p.parse_args()

    if args.dry_run:
        _dry_run(args.hanja, args.stroke, args.words)
        return

    for path in (args.hanja, args.stroke, args.words):
        if not path.is_file():
            raise SystemExit(f"파일이 없습니다: {path}")

    print(f"Firestore 업로드 시작 — project_id={args.project_id!r}")
    print(f"  hanja: {args.hanja}")
    print(f"  stroke: {args.stroke}")
    print(f"  words: {args.words}")
    print(
        "  (Flutter 앱은 읽기만 합니다. 콘솔에 데이터가 없다면 이 스크립트를 한 번 실행했는지 확인하세요.)",
    )

    db = _init_firestore(args.project_id, args.credentials)
    upload(db, args.hanja, args.stroke, args.words, args.content_version)


if __name__ == "__main__":
    main()
