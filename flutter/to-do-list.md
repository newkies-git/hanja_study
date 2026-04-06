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
| 복습·오답 UX | `AnswerHistoryTable` 등과 **오답노트 전용 UI**·필터 연동 | 중간 |
| 통계 | `statistics_screen.dart` **더미/부분 실데이터** 제거·일관된 지표 | 중간 |
| 시험 모드 | PRD의 객관식·쓰기 시험 플로우 — 미구현 | 낮음(단계적) |
| 단어/성어 | 한자 상세 탭 외 **목록·검색 메뉴** 확장 여부 | 중간 |
| 즐겨찾기 | DB·UI·동기화 설계 | 낮음 |
| 동기화 | `SyncQueueTable` → **로컬→Firestore** 업로드 경로 완성 | 중간 |
| 접근성 | 큰 글자·시맨틱 라벨·포커스(하단 5~6탭·드로어) | 중간 |

---

## 3. 품질·유지보수

| 항목 | 내용 |
|------|------|
| 테스트 | 위젯·통합: 퀴즈/탭 추가 후 `AppShell`·`EditorialBottomNav` 인덱스 테스트 보강 |
| 의존성 | `pubspec` 상위 호환(riverpod, drift, go_router 등) 주기적 점검·changelog |
| 중복 문자열 | 탭/드로어 라벨이 `editorial_bottom_nav`·`editorial_drawer`에 **이중 정의** → 통합 상수 또는 ARB 로컬라이즈 전 단계로 정리 |

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
