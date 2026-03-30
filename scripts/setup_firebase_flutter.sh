#!/usr/bin/env bash
# Flutter 앱 chusa1817을 Firebase 프로젝트 chusa-1817에 연결하는 로컬 절차.
# 이 스크립트는 대화형 단계(firebase login, flutterfire)를 안내하고, 가능한 것만 자동화한다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/flutter/chusa1817"

echo "== HANJA / Firebase 프로젝트 chusa-1817 + 앱 chusa1817 =="
echo "ROOT=$ROOT"
echo "APP=$APP"
echo

if ! command -v firebase >/dev/null 2>&1; then
  echo "[필수] Firebase CLI가 없습니다. 설치 후 다시 실행하세요."
  echo "  macOS (Homebrew): brew install firebase-cli"
  echo "  또는 npm:          npm install -g firebase-tools"
  echo "  문서: https://firebase.google.com/docs/cli"
  exit 1
fi

echo "[1/4] Firebase 로그인 (브라우저)"
firebase login

echo
echo "[2/4] 이 저장소에서 Firestore 규칙 배포 (Firebase projectId: chusa-1817)"
(cd "$ROOT" && firebase deploy --only firestore:rules --project chusa-1817)

echo
echo "[3/4] FlutterFire CLI"
if ! command -v flutterfire >/dev/null 2>&1; then
  echo "PATH에 pub-cache bin 추가: export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
  dart pub global activate flutterfire_cli
fi

echo
echo "[4/4] firebase_options.dart 및 google-services.json 생성"
export PATH="${PATH}:${HOME}/.pub-cache/bin"
cd "$APP"
flutterfire configure \
  --project=chusa-1817 \
  --yes \
  --platforms=android,ios \
  --android-package-name=com.basis.hanja.chusa1817 \
  --ios-bundle-id=com.basis.hanja.chusa1817 \
  --overwrite-firebase-options \
  --android-out=android/app/google-services.json

echo
echo "완료. 다음을 확인하세요."
echo "  - Firebase 콘솔: Authentication → 익명 로그인 사용 설정 (현재 Firestore 규칙이 auth 요구)"
echo "  - Firestore 데이터: python/upload_to_firestore.py (서비스 계정 또는 ADC)"
echo "  - flutter/chusa1817 에서: flutter run"
