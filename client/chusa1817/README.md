# 추사 1817 (chusa1817) — Flutter 학습 클라이언트 앱

한국 중·고등학교 교육용 기초 한자 1,800자 완학을 위한 **필기 채점 & 간격 반복(SM-2) 모바일 학습 클라이언트 앱**입니다.

---

## 🛠️ 기술 스택 (Tech Stack)

- **Framework**: Flutter (Dart 3)
- **State Management**: `flutter_riverpod` (AsyncNotifier / Provider)
- **Router**: `go_router` ([app_router.dart](lib/core/router/app_router.dart))
- **Database (Offline-First)**:
  - Local: Drift (SQLite) ([app_database.dart](lib/core/database/app_database.dart))
  - Remote: Firebase Cloud Firestore & Auth ([content_sync_controller.dart](lib/core/firebase/content_sync_controller.dart))
- **Security**: Firebase App Check (`PlayIntegrity` / `DeviceCheck` / `DebugProvider`)

---

## 🚀 빠른 시작 (Getting Started)

### 1. 패키지 설치
```bash
cd client/chusa1817
flutter pub get
```

### 2. 정적 분석 및 테스트 실행
```bash
flutter analyze --no-fatal-infos
flutter test
```

### 3. 디바이스/에뮬레이터 실행
```bash
flutter run
```

---

## 📁 주요 폴더 구조

```text
lib/
 ├─ core/             # 공통 DB, Auth, Router, Firebase, Theme, Study Evaluator
 ├─ features/         # 기능별 화면 & 컨트롤러
 │   ├─ auth/         # 로그인 / 회원가입 / 비밀번호 재설정
 │   ├─ home/         # 메인 홈, 오늘의 학습, 추천 복습
 │   ├─ learn/        # 한자 목록 및 상세 (음/뜻/부수/획순 SVG/단어)
 │   ├─ study/        # 획순 필기 캔버스 & 실시간 채점
 │   ├─ quiz/         # 퀴즈 플레이 & 결과
 │   ├─ review/       # SM-2 기반 추천 복습 & 오답 노트
 │   ├─ statistics/   # 학습 통계
 │   └─ profile/      # 데이터 동기화 & 학습 플랜 설정
 └─ shared/           # 공통 원고지/에디토리얼 UI 컴포넌트
```

상세 기획은 [`docs/PRD.md`](../../docs/PRD.md) 및 [`docs/implementation_plan.md`](../../docs/implementation_plan.md)를 참고하세요.
