#!/usr/bin/env python3
"""
Firebase Auth 사용자에게 admin 커스텀 클레임을 설정하는 스크립트.

사용법:
  export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
  python set_firebase_custom_claims.py --project-id chusa-1817 --email admin@example.com --admin true
"""

import argparse
import sys
import firebase_admin
from firebase_admin import auth, credentials


def main():
    parser = argparse.ArgumentParser(description="Set custom user claims for Firebase Auth.")
    parser.add_argument("--project-id", required=True, help="Firebase Project ID")
    parser.add_argument("--email", required=True, help="User email address")
    parser.add_argument("--admin", choices=["true", "false"], default="true", help="Set admin claim")

    args = parser.parse_args()
    is_admin = args.admin.lower() == "true"

    if not firebase_admin._apps:
        firebase_admin.initialize_app(options={"projectId": args.project_id})

    try:
        user = auth.get_user_by_email(args.email)
        claims = user.custom_claims or {}
        if is_admin:
            claims["admin"] = True
        else:
            claims.pop("admin", None)

        auth.set_custom_user_claims(user.uid, claims)
        print(f"✅ 성공: 사용자 '{args.email}' (UID: {user.uid}) 에게 custom_claims={claims} 가 적용되었습니다.")
        print("💡 앱/어드민 웹에서 기존 토큰을 강제 갱신(getIdToken(true))하거나 로그아웃 후 재로그인하면 반영됩니다.")
    except Exception as e:
        print(f"❌ 실패: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
