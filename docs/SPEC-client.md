# [SPEC-client] Flutter 모바일 클라이언트 앱 기능 명세서

## 1. 개요 (Overview)
- **모듈명**: `client`
- **구분**: 한자 학습 모바일 애플리케이션 (추사 1817 - `chusa1817`)
- **기술 스택**: Flutter 3.x, Dart 3.x, Riverpod (State Management), Drift (SQLite ORM), GoRouter, Firebase Auth, Cloud Firestore, Firebase App Check (Play Integrity / DeviceCheck)
- **목적**: 한국 교육용 기초 한자 1,817자를 효율적으로 습득할 수 있도록 획순 필기 채점, SM-2 알고리즘 기반 간격 반복 복습, 음/뜻 퀴즈, 오프라인 데이터 동기화 및 사용자 프로필/북마크 기능 제공

---

## 2. 모듈 구성 및 경로 (Directory Structure)

```text
client/
├── chusa1817/                      # Flutter 프로젝트 루트
│   ├── lib/
│   │   ├── core/                   # 인증, 테마, 라우터, 오프라인 동기화, 알림 서비스
│   │   ├── features/               # 기능별 모듈
│   │   │   ├── auth/               # 로그인, 회원가입, 비밀번호 재설정
│   │   │   ├── home/               # 홈 화면, 오늘 공부할 한자, Streak 연속 학습 카드
│   │   │   ├── learn/              # 한자 1,817자 탐색, 급수별 필터, 상세 보기 및 획순
│   │   │   ├── study/              # 획순 필기 연습 캔버스 & 실시간 채점 엔진
│   │   │   ├── review/             # SM-2 알고리즘 간격 반복 복습 및 오답 노트
│   │   │   ├── quiz/               # 음/뜻 객관식 & 주관식 퀴즈 플레이
│   │   │   ├── profile/            # 프로필, 목표 학습량 설정, 북마크 목록, 오프라인 싱크
│   │   │   └── statistics/         # 일간/주간 학습 통계 그래프
│   │   └── shared/                 # 에디토리얼 테마 위젯, 한자 카드, 버튼, 캔버스 그리드
│   ├── test/                       # 유닛 & 위젯 테스트 수트 (16개 100% 통과)
│   └── pubspec.yaml                # 의존성 및 패키지 설정
└── scripts/                        # 로컬 개발 및 Firebase 연동 CLI 쉘 스크립트
    └── setup_firebase_flutter.sh   # Firebase 프로젝트 설정 및 App Check 구성 스크립트
```

---

## 3. 상세 기능 명세 (Functional Specifications)

### 3.1 회원가입 및 사용자 인증 (`features/auth/` & `core/auth/`)
- **Firebase Auth 통합**: 이메일/비밀번호 가입 및 로그인, 익명 로그인(Guest) 지원
- **비밀번호 재설정**: 이메일 재설정 링크 발송 및 완료 안내 (`reset_password_screen.dart`)
- **온보딩 웰컴 화면 (`features/onboarding/`)**: 일일 한자 목표 수(5/10/15자) 및 학습 목표 설정

### 3.2 1,817자 학습 탐색 (`features/learn/`)
- **한자 격자 목록 (`learn_list_screen.dart`)**:
  - 교육용 기초 한자 1,817자 그리드 배치
  - 급수별(8급~1급), 부수별, 음/뜻 키워드 검색
- **한자 상세 뷰 (`hanja_detail_screen.dart`)**:
  - 한자 대형 렌더링, 부수/총획/급수 표출
  - **획순 애니메이션 플레이어 (`stroke_animation_player.dart`)**: 획순 순서 재생, 일시정지, 한 획씩 넘기기
  - **관련 어휘 탭 (`hanja_words_tab.dart`)**: 해당 한자가 쓰인 7,000+ 단어 및 1,000+ 고사성어 목록
  - **북마크 토글 (`toggleBookmark`)**: 별표 아이콘 클릭을 통한 즐겨찾기 등록/해제

### 3.3 획순 필기 학습 & 실시간 채점 엔진 (`features/study/`)
- **원고지 필기 캔버스 (`writing_canvas_widget.dart`)**:
  - 터치 및 스타일러스 펜 입력을 지원하는 CustomPainter 캔버스
  - 획 가이드 라인 및 획순 번호 힌트 레이어
- **실시간 획순 채점기 (`stroke_evaluator.dart`)**:
  - 정규화된 획 좌표(`[{x, y}, ...]`) 기반 실시간 순서, 방향, 유사도 산출
  - 획별 성공/실패 시각 가이딩 feedback

### 3.4 SM-2 알고리즘 간격 반복 복습 (`features/review/`)
- **SM-2 Spaced Repetition 알고리즘**:
  - 답변 난이도(Again, Hard, Good, Easy / 0~5점) 평가에 따른 복습 주기(Interval), Easily Factor(EF), 반복 횟수 계산
- **추천 복습 세션 (`recommended_review_section.dart`)**: 오늘 복습이 필요한 한자 자동 카드 덱 구성
- **오답 노트 (`wrong_answer_screen.dart`)**: 연습 및 퀴즈에서 틀린 한자 모아보기 및 재학습

### 3.5 음/뜻 퀴즈 플레이 (`features/quiz/`)
- **퀴즈 세션 (`quiz_play_screen.dart`)**: 4지선다형 객관식 음/뜻 퀴즈 및 정답 제출
- **결과 산출 (`quiz_result_screen.dart`)**: 획득 점수, 소요 시간, 맞힌 문제 분석 및 오답 자동 저장

### 3.6 사용자 프로필 & 오프라인 싱크 (`features/profile/` & `core/firebase/`)
- **프로필 관리 화면 (`profile_screen.dart`)**:
  - 사용자 정보, 학습 일수 연속 계산(Streak Badge), 일일 목표 변경 (`plan_settings_screen.dart`)
  - 북마크 한자 모아보기
- **오프라인 듀얼 DB 동기화 (`ContentSyncController` / `Drift` <-> `Firestore`)**:
  - 최초 앱 실행 시 Firestore로부터 최신 1,817자 마스터 DB 오프라인 Drift SQLite 동기화
  - 오프라인 환경에서도 학습 진행도, 복습 기록, 북마크가 유지되며 네트워크 복구 시 백그라운드 자동 동기화

---

## 4. 검증 및 테스트 명령 (Verification Guide)

```bash
# 1. 의존성 다운로드
cd client/chusa1817
flutter pub get

# 2. 정적 코드 분석
flutter analyze --no-fatal-infos

# 3. 유닛 & 위젯 테스트 실행 (16개 100% 통과)
flutter test

# 4. 앱 실행
flutter run
```
