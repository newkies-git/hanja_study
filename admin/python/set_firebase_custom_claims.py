#!/usr/bin/env python3
"""
Firebase Auth 사용자에 커스텀 클레임을 설정한다.

이 프로젝트에서는 Firestore 규칙이 admin 쓰기를 `request.auth.token.admin == true`로 제한한다.
따라서 admin 웹앱에서 CSV 업로드/수정/삭제를 하려면, 로그인 계정에 admin 클레임을 부여해야 한다.

사용 예 (admin/python 에서):
  pip install -r requirements-firebase.txt
  export GOOGLE_APPLICATION_CREDENTIALS=/절대경로/서비스계정.json

  # 이메일로 admin 부여
  python set_firebase_custom_claims.py --project-id chusa-1817 --email you@example.com --admin true

  # uid로 admin 부여
  python set_firebase_custom_claims.py --project-id chusa-1817 --uid SOME_UID --admin true

주의:
  - 클레임 변경 후, 해당 사용자는 "재로그인"해야 토큰에 반영된다.
"""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any

try:
    import firebase_admin
    from firebase_admin import auth, credentials
except ImportError:
    print("firebase-admin이 필요합니다: (admin/python에서) pip install -r requirements-firebase.txt", file=sys.stderr)
    raise SystemExit(1)


def _init(project_id: str, cred_path: str | None) -> None:
    if firebase_admin._apps:
        return
    if cred_path:
        cred = credentials.Certificate(cred_path)
    else:
        cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {"projectId": project_id})


def _parse_bool(s: str) -> bool:
    v = s.strip().lower()
    if v in ("1", "true", "t", "yes", "y", "on"):
        return True
    if v in ("0", "false", "f", "no", "n", "off"):
        return False
    raise ValueError(f"불리언 값이 아닙니다: {s!r}")


def main() -> None:
    p = argparse.ArgumentParser(description="Firebase Auth custom claims 설정")
    p.add_argument("--project-id", default="chusa-1817")
    p.add_argument("--credentials", default=None, help="서비스 계정 JSON 경로(미지정 시 ADC)")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--uid", default=None, help="대상 사용자 UID")
    g.add_argument("--email", default=None, help="대상 사용자 이메일")
    p.add_argument("--admin", default="true", help="admin 클레임(true/false)")
    args = p.parse_args()

    try:
        admin_value = _parse_bool(args.admin)
    except ValueError as e:
        print(str(e), file=sys.stderr)
        raise SystemExit(2)

    _init(args.project_id, args.credentials)

    if args.uid:
        user = auth.get_user(args.uid)
    else:
        user = auth.get_user_by_email(args.email)

    existing: dict[str, Any] = dict(user.custom_claims or {})
    existing["admin"] = admin_value
    auth.set_custom_user_claims(user.uid, existing)

    out = {
        "uid": user.uid,
        "email": user.email,
        "claims": existing,
        "note": "클레임 반영을 위해 해당 사용자는 재로그인해야 합니다.",
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

