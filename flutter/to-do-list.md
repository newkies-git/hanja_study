# chusa1817 — 개선·수정·보완·추가 목록 (최신 실코드 기준)

마지막 갱신: 2026-07-26  
브랜치: `main`  
품질 상태: `flutter analyze` 0 issues / `flutter test` 15개 전체 통과

---

## 🎯 잔여 작업 우선순위 (실행 순서)

| 순위 | 영역 | 항목 | 이유 | 상태 |
|------|------|------|------|------|
| ~~P1~~ | ~~보안~~ | ~~**Firebase App Check & API Key 보안 적용**~~ | ✅ `firebase_bootstrap.dart` 토큰 오토 리프레시 구현, 콘솔 Enforce 절차 가이드 완료 | **완료** |
| ~~P1~~ | ~~통계~~ | ~~**통계 화면 실데이터 연동**~~ | ✅ 학습 이력 기반 실데이터 지표 연동 완료 | **완료** |
| ~~P1~~ | ~~복습~~ | ~~**SM-2 간격 반복 알고리즘**~~ | ✅ quality 매핑, 복습 주기 추천 및 홈 섹션 연동 완료 | **완료** |
| ~~P2~~ | ~~UX~~ | ~~**동기화 실패/오류 처리 UX**~~ | ✅ `ContentSyncProgressSection` 에러 뷰 및 `'다시 시도'` 원클릭 재시도 버튼 추가 | **완료** |
| **P1** | 온보딩 | **온보딩 콘텐츠 완성** | 신규 사용자 첫인상 (현재 레이아웃 구현됨, 실 미디어/카피 정제) | 진행 예정 |
| **P2** | 품질 | **구조적 로깅·크래시 추적** | `debugPrint` 산발적 → Firebase Crashlytics 연동 | 진행 예정 |
| **P3** | 필기 | **획순 판정 고도화 (DTW)** | 현재 좌표 정규화 기반 → DTW 및 방향 허용 오차 보정 추가 | 진행 예정 |
| **P3** | 기능 | **프로필 메인 화면** | 이름·이메일·계정 관리 통합 뷰 (`/profile`) | 진행 예정 |
| **P3** | 기능 | **즐겨찾기 UI** | DB 컬럼(`isBookmarked`) 연동 토글 및 즐겨찾기 모아보기 UI | 진행 예정 |
| **P4** | 인프라 | **Firestore 동기화 Phase 3** | 로컬 DB 수정사항 → 서버 업로드 양방향 경로 | 진행 예정 |
| **P4** | 기능 | **학습 배지·스트릭 보상** | Gamification, `daily_activity_stats` 기반 보상 UI | 진행 예정 |
| ~~-~~ | ~~기능~~ | ~~**데이터 내보내기/백업**~~ | ❌ 미지원 정책: 로컬 파일(CSV·JSON) 내보내기는 미지원하며 백업은 Firebase 온라인 싱크 전용 | **미지원 정책** |

---

## 1. 네비게이션·정보 구조 ✅ 완료

| # | 요청 내용 | 상태 | 비고 |
|---|------|------|------|
| 1 | 「학습」→「사전」 라벨 변경 | ✅ | AppShell BottomNav 및 Drawer 적용 완료 |
| 2 | 복습·통계 사이에 「퀴즈」 탭 추가 | ✅ | AppShell 퀴즈 탭 라우팅(`/quiz`) 연결 |
| 3 | 하단 「내 정보」 제거 → 아바타 팝업 「학습 설정」/「동기화」 | ✅ | `PlanSettingsScreen` & `ContentSyncScreen` 연동 |

---

## 2. 기능·PRD 대비 보완 현황

| 영역 | 내용 | 실코드 구현 상태 | 상태 |
|------|------|------------------|------|
| **획순·필기 판정** | 획순 캔버스 & 정규화 판정 | `writing_canvas_widget.dart` & `stroke_evaluator.dart` 구현 완료. DTW 고도화 남음 | P3 |
| **복습 알고리즘** | SM-2 간격 반복 알고리즘 | `recommended_review_provider.dart` 구현 완료 | ✅ 완료 |
| **복습·오답 UX** | 오답노트 전용 UI·필터 | `wrong_answer_screen.dart` (`/wrong-answers`) 구현 완료 | ✅ 완료 |
| **통계** | 실데이터 일관 지표 | `statistics_screen.dart` 연동 완료 | ✅ 완료 |
| **시험 모드** | 객관식·쓰기·타이머·범위 퀴즈 | `quiz_play_screen.dart`, `quiz_result_screen.dart` 구현 완료 | ✅ 완료 |
| **동기화 오류 UX** | 실패 아이콘 & 다시 시도 | `content_sync_progress_section.dart`, `content_sync_screen.dart` 반영 완료 | ✅ 완료 |
| **즐겨찾기** | DB 컬럼 연동 UI | `HanjaTable.isBookmarked` 존재, 카드/상세 토글 UI 추가 필요 | P3 |
| **양방향 동기화** | `SyncQueueTable` → Firestore 업로드 | 로컬 다운로드 싱크 완료, 서버 업로드 경로 구성 남음 | P4 |

---

## 2-A. 퀴즈 탭 ✅ 전체 완료

| # | 항목 | 구현 코드 | 상태 |
|---|------|-----------|------|
| 1 | 훈음 선택 (4지선다) | `quiz_play_screen.dart` | ✅ 완료 |
| 2 | 한자 선택 (4지선다) | `quiz_play_screen.dart` | ✅ 완료 |
| 3 | 혼합 모드 | `quiz_models.dart` | ✅ 완료 |
| 4 | 세션 설정 UI (문제 수·유형) | `quiz_screen.dart` | ✅ 완료 |
| 5 | 결과 화면 (정답률·오답 목록) | `quiz_result_screen.dart` | ✅ 완료 |
| 6 | 라우터 연결 `/quiz/play`, `/quiz/result` | `app_router.dart` | ✅ 완료 |
| 7 | 쓰기 시험 모드 (`WritingCanvasWidget` + 채점) | `quiz_play_screen.dart` | ✅ 완료 |
| 8 | 문제당 타이머 (없음·10·15·20초, 자동 미응답) | `quiz_play_screen.dart` | ✅ 완료 |
| 9 | 범위 필터 (전체·중학·고등 `schoolLevel`) | `quiz_screen.dart` | ✅ 완료 |

---

## 2-B. 신규 기능 및 정책

| 영역 | 내용 | 실코드 구현 상태 | 상태 |
|------|------|------------------|------|
| **다크/라이트 모드** | `ThemeData` dark + `hanja_theme.dart` | 구현 완료 | ✅ 완료 |
| **로컬 푸시 알림** | 일일 학습 리마인더 (요일·시각 설정) | `notification_service.dart` & `plan_settings_screen.dart` 구현 완료 | ✅ 완료 |
| **학습 목록 필터/페이지** | 부수·획수·교육등급 필터링 | `learn_list_screen.dart` 구현 완료 | ✅ 완료 |
| **Firebase App Check** | Token Auto-Refresh & Debug Provider | `firebase_bootstrap.dart` 구현 완료 | ✅ 완료 |
| **멀티 디바이스 동기화** | Firestore 양방향 업로드 | Phase 3 예정 | P4 |
| **프로필 화면** | 이름·이메일·계정 관리 `/profile` | `plan_settings_screen.dart` 활용 중, 독립 프로필 뷰 추가 예정 | P3 |
| **데이터 내보내기/백업** | CSV·JSON 내보내기 | ❌ 미지원 정책: 온라인 클라우드 싱크 전용 | 미지원 정책 |

---

## 3. 품질 및 자동화 테스트 현황 ✅

| 항목 | 실코드 검증 상태 |
|------|------------------|
| **정적 분석 (`flutter analyze`)** | **`No issues found!`** (경고/오류 0건) |
| **자동화 테스트 (`flutter test`)** | **총 15개 단위/위젯 테스트 통과** |
| - 획순 유사도 및 정규화 | `stroke_evaluator_test.dart`, `stroke_coordinate_utils_test.dart` ✅ |
| - SM-2 복습 추천 | `recommended_review_provider_test.dart` ✅ |
| - DB 및 리포지토리 | `local_hanja_repository_test.dart` ✅ |
| - 학습 리스트 / 랜딩 뷰 | `learn_list_screen_test.dart`, `landing_screen_test.dart` ✅ |
| - 라우터 리다이렉트 | `app_router_test.dart` ✅ |
| - 동기화 프로그레스 & 에러 뷰 | `content_sync_progress_section_test.dart` ✅ |

---

## 4. 참고 경로

- **앱 소스 루트**: `flutter/chusa1817/`
- **라우터 설정**: `lib/core/router/app_router.dart`
- **셸 & 탭 UI**: `lib/features/shell/app_shell.dart`
- **동기화 컨트롤러**: `lib/core/firebase/content_sync_controller.dart`
- **통합 기획 명세**: `docs/PRD.md`
