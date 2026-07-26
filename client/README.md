# Flutter 모바일 클라이언트 앱 (`client/`)

HANJA 저장소의 **한자 학습 모바일 클라이언트 애플리케이션 (추사 1817 - `chusa1817`)** 및 관련 CLI 스크립트 디렉터리입니다.

---

## 📁 디렉터리 구조

| 경로 | 역할 및 구성 |
| :--- | :--- |
| **[`chusa1817/`](chusa1817/README.md)** | **Flutter 프로젝트 루트** (Riverpod, Drift, GoRouter, Firebase App Check) |
| **[`scripts/`](scripts/setup_firebase_flutter.sh)** | `setup_firebase_flutter.sh` (Firebase 프로젝트 구성 및 App Check 자동화 스크립트) |
| **[`to-do-list.md`](to-do-list.md)** | 클라이언트 개발 현황 점검 및 기능 로드맵 |

---

## 🚀 빠른 실행 및 가이드

### 1. Flutter 앱 실행 (`client/chusa1817/`)
```bash
# 디렉터리 이동 및 의존성 설치
cd client/chusa1817
flutter pub get

# 정적 분석 및 테스트 실행 (16개 100% 통과)
flutter analyze --no-fatal-infos
flutter test

# 디바이스/에뮬레이터 앱 실행
flutter run
```

### 2. Firebase 프로젝트 & App Check 자동 설정
```bash
# 저장소 루트에서 원클릭 설정 스크립트 실행
./client/scripts/setup_firebase_flutter.sh
```

---

## 📚 관련 명세 문서
- **모바일 클라이언트 상세 기능 명세서**: [`docs/SPEC-client.md`](../docs/SPEC-client.md)
- **Android 에뮬레이터 실행 가이드**: [`client/android_emulator_guide.md`](android_emulator_guide.md)
- **클라이언트 개발 로드맵**: [`client/to-do-list.md`](to-do-list.md)
- **저장소 마스터 안내서**: [`README.md`](../README.md)
