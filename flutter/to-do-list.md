# chusa1817 — 개선·수정·보완·추가 목록

마지막 코드 점검: `flutter analyze` 클린, `flutter test` 전부 통과(프로젝트 로컬 기준).  
아래는 **제품 요청**, **PRD/구현 갭**, **기술 부채**를 한 파일에서 추적하기 위한 목록이다.

---

## 1. 네비게이션·정보 구조 (우선 반영)

### 1-1. 하단 탭 라벨·구성

| # | 요청 | 상태 | 비고 |
|---|------|------|------|
| 1 | **「학습」→「사전」**으로 라벨 변경 | ✅ | `editorial_bottom_nav.dart`·`editorial_drawer.dart` |
| 2 | **「복습」과 「통계」사이에 「퀴즈」** 탭 추가 | ✅ | `QuizScreen` 플레이스홀더, 탭 인덱스 0=홈…4=통계. `practice_result`의 통계 딥링크 `?tab=4` |
| 3 | 하단 **「내 정보」제거** → 아바타 팝업 **「학습 설정」** | ✅ | `EditorialTopBar` `PopupMenuButton`: 학습 설정 → `PlanSettingsScreen`. 하단·드로어에서 프로필 탭 제거 |

**참고:** `ProfileScreen`은 라우터에 없었고 탭에서만 열렸음 → 현재 UI 경로 없음. 계정 요약이 필요하면 이후 팝업에 「내 정보」 재노출 또는 `/profile` 라우트 추가 검토.

**퀴즈:** `lib/features/quiz/quiz_screen.dart` 플레이스홀더. 문항 로직·별도 `go_router` 경로는 추후.

---

## 2. 기능·PRD 대비 보완

| 영역 | 내용 | 우선순위 |
|------|------|----------|
| 획순·필기 판정 | 템플릿/좌표 기반 수준 → PRD 수준(DTW·방향·허용오차 프로파일) 고도화 | 높음 |
| 복습 알고리즘 | `recommended_review_provider` 등과 정식 **SM-2 간격** 정합성 검토·로그 | 높음 |
| 복습·오답 UX | `AnswerHistoryTable` 등과 **오답노트 전용 UI**·필터 연동 | ✅ `/wrong-answers` 구현, 복습 탭에서 진입 가능 |
| 통계 | `statistics_screen.dart` **더미/부분 실데이터** 제거·일관된 지표 | 중간 |
| 시험 모드 | PRD의 객관식·쓰기 시험 플로우 — 미구현 | ✅ 퀴즈 탭 구현(훈음 선택·한자 선택·혼합, `/quiz/play`, `/quiz/result`) |
| 단어/성어 | 한자 상세 탭 외 **목록·검색 메뉴** 확장 여부 | 중간 |
| 즐겨찾기 | DB·UI·동기화 설계 | 낮음 |
| 동기화 | `SyncQueueTable` → **로컬→Firestore** 업로드 경로 완성 | 중간 |
| 접근성 | 큰 글자·시맨틱 라벨·포커스(하단 5~6탭·드로어) | 중간 |

---

## 2-A. 퀴즈 탭 상세 구현 (현재 20% — 플레이스홀더만 존재)

> ✅ `improve_0409` 브랜치에서 기본 퀴즈 플로우 구현 완료. 아래 잔여·추가 항목.

| # | 항목 | 내용 | 상태 |
|---|------|------|------|
| 1 | 문제 유형 — 객관식(훈음 선택) | 한자 제시 → 훈·음 4지선다 | ✅ |
| 2 | 문제 유형 — 한자 선택(훈음 제시) | 훈·음 제시 → 한자 4지선다 | ✅ |
| 3 | 혼합 모드 | 두 유형을 번갈아 출제 | ✅ |
| 4 | 세션 설정 UI | 문제 수(5·10·20), 유형 선택 | ✅ |
| 5 | 결과 화면 | 정답률(원형)·오답 목록·다시 풀기·홈으로 | ✅ |
| 6 | 라우터 연결 | `/quiz/play`, `/quiz/result` | ✅ |
| 7 | 쓰기 시험 모드 | 한자를 캔버스에 직접 쓰는 시험(`WritingCanvasWidget` 재사용) | 미구현 |
| 8 | 시험 타이머 | 문제당 또는 세션 전체 제한 시간 | 미구현 |
| 9 | 범위 필터 | 학교급·급수·즐겨찾기 기반 문제 풀 선택 | 미구현 |

---

## 2-B. 신규 기능 보완

| 영역 | 내용 | 우선순위 |
|------|------|----------|
| 다크 모드 | `ThemeData` 다크 정의 + `app_settings`에 테마 키 추가. 현재 라이트 전용 | 중간 |
| 푸시 알림 | Firebase Cloud Messaging(FCM) 연동: 일일 학습 리마인더, 복습 due 알림. `app_settings`의 `selectedDays` 기반 스케줄 | 중간 |
| 학습 목록 페이지네이션 | `learn_list_screen.dart`가 전체 한자를 메모리에 적재 → Drift `limit/offset` 또는 `ScrollController` 기반 무한 스크롤로 교체 | ✅ 페이지 크기 30 고정(daily goal 분리), 범위 표시(`1–30 / 1817`) 개선 |
| 멀티 디바이스 동기화 | `sync_queue` 테이블 로직 완성 + Firestore `/users/{uid}/progress` 업로드·다운로드 경로 구현 (Phase 3) | 낮음 |
| 오프라인 UX | 네트워크 없을 때 동기화·인증 실패 시 토스트/배너 안내. `connectivity_plus` 패키지 활용 검토 | 중간 |
| 프로필 화면 재노출 | `EditorialTopBar` 팝업에 「내 정보」 재추가 또는 `/profile` 라우트 구현 (이름·이메일·계정 관리) | 낮음 |
| 학습 배지·스트릭 보상 | 연속 학습일·목표 달성 시 인앱 배지 표시(gamification). `daily_activity_stats` 활용 | 낮음 |
| 데이터 내보내기/백업 | 학습 기록 CSV 또는 JSON 내보내기. 앱 재설치 시 복구 시나리오 | 낮음 |

---

## 3. 품질·유지보수

| 항목 | 내용 |
|------|------|
| 테스트 | 위젯·통합: 퀴즈/탭 추가 후 `AppShell`·`EditorialBottomNav` 인덱스 테스트 보강 |
| 의존성 | `pubspec` 상위 호환(riverpod, drift, go_router 등) 주기적 점검·changelog |
| 중복 문자열 | 탭/드로어 라벨이 `editorial_bottom_nav`·`editorial_drawer`에 **이중 정의** → 통합 상수 또는 ARB 로컬라이즈 전 단계로 정리 |
| Firestore 레거시 경로 정리 | `firestore_paths.dart` 레거시 상수(`hanja/words` 등) 제거. `upload_to_firestore.py` 주석 및 경로 정정 | 
| 구조적 로깅·크래시 추적 | `firebase_crashlytics` 또는 `sentry` 연동. 현재 `print`/`debugPrint` 산발적 사용 → 레벨별 로거로 교체 |
| 테스트 커버리지 확대 | 현재 7개 파일(핵심 로직 위주). 추가 대상: `home_screen`, `study_screen`, `auth_controller`, 퀴즈 구현 후 `quiz_screen` |
| 온보딩 콘텐츠 완성 | `onboarding_screen.dart` 3개 페이지 텍스트·이미지가 플레이스홀더 수준 → 실제 앱 소개 문구·스크린샷으로 교체 |

---

## 4. 완료 시 체크

- [ ] `flutter analyze` / `dart run custom_lint`(설정된 경우)
- [ ] `flutter test`
- [ ] `?tab=` 로 홈 진입 시 올바른 탭(퀴즈 포함) 노출
- [ ] (선택) `docs/impl_plan/implementation_plan.md` 및 워크스루 갱신 후 `/sync_docs`

---

## 참고 경로

- 앱: `flutter/chusa1817/`
- 라우터: `lib/core/router/app_router.dart`
- 셸·탭: `lib/features/shell/app_shell.dart`  
- 기획 단일본: `docs/PRD.md`
