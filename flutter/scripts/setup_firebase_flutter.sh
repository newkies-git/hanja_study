#!/usr/bin/env bash
# Flutter 앱 chusa1817을 Firebase 프로젝트 chusa-1817에 연결하는 로컬 절차.
# 위치: flutter/scripts/ (저장소 루트는 본 파일 기준 ../.. 로 계산)
# 대화형 단계(firebase login, flutterfire)를 안내하고, 가능한 것만 자동화한다.
# 실행 cwd는 어디든 가능하며, 단계마다 필요한 디렉터리로 명시적으로 이동한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# flutter/scripts → 저장소 루트
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ADMIN="$REPO_ROOT/admin"
FIRESTORE_DIR="$ADMIN/firestore"
APP="$REPO_ROOT/flutter/chusa1817"

echo "== HANJA / Firebase 프로젝트 chusa-1817 + 앱 chusa1817 =="
echo "REPO_ROOT=$REPO_ROOT"
echo "FIRESTORE_DIR=$FIRESTORE_DIR (firebase.json, firestore.rules, .firebaserc)"
echo "APP=$APP"
echo

if [[ ! -d "$APP" ]]; then
  echo "[오류] Flutter 앱 디렉터리가 없습니다: $APP" >&2
  exit 1
fi
if [[ ! -d "$FIRESTORE_DIR" ]]; then
  echo "[오류] Firestore CLI 루트가 없습니다: $FIRESTORE_DIR" >&2
  exit 1
fi

cd "$REPO_ROOT"
echo "[작업 기준] 저장소 루트로 이동: $(pwd)"
echo

if ! command -v firebase >/dev/null 2>&1; then
  echo "[필수] Firebase CLI가 없습니다. 설치 후 다시 실행하세요."
  echo "  macOS (Homebrew): brew install firebase-cli"
  echo "  또는 npm:          npm install -g firebase-tools"
  echo "  문서: https://firebase.google.com/docs/cli"
  exit 1
fi

echo "[1/4] Firebase 로그인 (브라우저) — 현재 디렉터리: $(pwd)"
firebase login

echo
echo "[2/4] Firestore 규칙 배포 — 디렉터리 이동: $FIRESTORE_DIR"
cd "$FIRESTORE_DIR"
echo "  → $(pwd)"
firebase deploy --only firestore:rules --project chusa-1817
echo "[2/4] 완료 후 저장소 루트로 복귀"
cd "$REPO_ROOT"
echo "  → $(pwd)"

echo
echo "[3/4] FlutterFire CLI (현재 디렉터리: $(pwd))"
if ! command -v flutterfire >/dev/null 2>&1; then
  echo "PATH에 pub-cache bin 추가: export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
  dart pub global activate flutterfire_cli
fi

echo
echo "[4/4] firebase_options.dart 및 google-services.json — Flutter 앱 디렉터리로 이동"
cd "$APP"
echo "  → $(pwd)"
export PATH="${PATH}:${HOME}/.pub-cache/bin"
flutterfire configure \
  --project=chusa-1817 \
  --yes \
  --platforms=android,ios \
  --android-package-name=com.basis.hanja.chusa1817 \
  --ios-bundle-id=com.basis.hanja.chusa1817 \
  --overwrite-firebase-options \
  --android-out=android/app/google-services.json

echo
echo "완료. 현재 셸 디렉터리: $(pwd) (바로 다음에 flutter run 가능)"
echo "다음을 확인하세요."
echo "  - Firebase 콘솔: Authentication → 익명 로그인 사용 설정 (현재 Firestore 규칙이 auth 요구)"
echo "  - Firestore 데이터: admin/admin-etl/upload_to_firestore.py (서비스 계정 또는 ADC)"
