# 2026-04-04 프로젝트 분석 보고

## 1. 현황 요약

| 항목 | 상태 |
|------|------|
| 프로젝트명 | Chusa1817 (Flutter 앱, `flutter/chusa1817/`) |
| 최신 커밋 | `5fc1a3b` — fix(flutter): stabilize project with passing tests and zero lint warnings |
| 미해결 변경사항 | **없음** (워킹트리 클린) |
| 기술 스택 | Flutter · Riverpod · Drift(SQLite v7) · Firebase Auth + Firestore · go_router |
| DB 스키마 버전 | **v7** (누적형 migration 완비) |
| Dart 파일 수 | 70개 |

---

## 2. Flutter 분석 결과

### 2-1. 정적 분석 (`flutter analyze`)
- **결과: No issues found (0 오류, 0 경고, 0 힌트)**
- riverpod_lint 커스텀 린트 포함 완전 클린 상태

### 2-2. 테스트 (`flutter test`)
- **결과: All tests passed (7개 테스트)**
  - `landing_screen_test.dart`
  - `learn_list_screen_test.dart`
  - `local_hanja_repository_test.dart`
  - `recommended_review_provider_test.dart`
  - `stroke_coordinate_utils_test.dart`
  - `widget_test.dart` 포함

### 2-3. 패키지 업데이트 가용
30개 패키지에 신규 버전 존재 (dependency constraints에 막혀 자동 적용 불가)
주요 항목: `flutter_riverpod` 3.1→3.3, `drift` 2.31→2.32, `go_router` 17.1→17.2

---

## 3. PRD 대비 구현 현황

| 기능 | PRD 정의 | 구현 여부 | 비고 | 우선순위 |
|------|----------|-----------|------|----------|
| 한자 목록 조회 | ✅ | ✅ 실데이터 (Firestore 동기화) | `learn_list_screen.dart` | — |
| 한자 상세 정보 | ✅ | ✅ 실데이터 | `hanja_detail_screen.dart` | — |
| 획순 애니메이션 | ✅ | ✅ SVG 경로 재생 | `stroke_animation_player.dart` | — |
| 터치 쓰기 입력 | ✅ | ✅ 캔버스 구현 | `writing_canvas_widget.dart` | — |
| 획 판정 엔진 | ✅ | ⚠️ 부분 구현 | DTW/Hausdorff 미적용, 템플릿 기반 | HIGH |
| SM-2 복습 알고리즘 | ✅ | ⚠️ 유사 구현 | `recommended_review_provider` 존재, 정식 SM-2 간격 미적용 | HIGH |
| 오답노트 | ✅ | ⚠️ 데이터 계층만 | `AnswerHistoryTable` 있으나 UI 미구현 | MEDIUM |
| 복습 화면 | ✅ | ⚠️ 껍데기 | `review_screen.dart` 존재, 실 데이터 연동 미완 | HIGH |
| 통계 화면 | ✅ | ⚠️ 부분 실데이터 | `statistics_screen.dart`, 일부 더미 잔존 | MEDIUM |
| 홈 대시보드 | ✅ | ✅ 완성 | 반원 게이지, 학습 그리드, 추천複습 | — |
| Firebase 인증 | ✅ | ✅ | Google/Email 로그인, 비밀번호 재설정 | — |
| SQLite (Drift) | ✅ | ✅ v7 | 누적형 migration, WAL 모드, FK 활성화 | — |
| 시험 모드 | ✅ | ❌ 미구현 | PRD 8.6 요구 | LOW |
| 단어/성어 화면 | ✅ | ⚠️ 탭 내부만 | 별도 전용 메뉴 없음 | MEDIUM |
| 즐겨찾기 | ✅ | ❌ 미구현 | DB 필드 없음 | LOW |
| 서버 동기화 | PRD6 | ⚠️ 단방향 | Firestore→로컬 가능, 로컬→서버 미구현 | MEDIUM |
| Admin CMS | ✅ | ⚠️ UI 초기 | admin 프론트엔드 로그인 화면까지만 | LOW |

---

## 4. 아키텍처 보완사항

### 4-1. 상태 관리
- **Riverpod 실사용 파일**: 20개 이상 (auth_providers, app_providers, content_sync 등)
- `setState` 사용 파일: 12개 — **완전히 정상 범위**
  - `study_screen`, `stroke_animation_player`, `writing_canvas_widget` (캔버스/애니메이션 로컬 상태)
  - `hanja_detail_screen`, `learn_list_screen` (페이지/탭 로컬 상태)
  - auth/onboarding 화면 (폼 로컬 상태)
  - → 비즈니스 로직이 아닌 위젯 로컬 상태에 한정, **문제 없음**

### 4-2. 라우팅
- `go_router`를 `app_router.dart`에서 중앙 관리 ✅
- `MaterialPageRoute` / `Navigator.push` 직접 호출: **0건** ✅ (grep 결과 없음)
- 딥링크, 인증 Guard 일관성 양호

### 4-3. 데이터 레이어
- Drift DB 파일: `app_database.dart` + `.g.dart` + `tables/` — **완비** ✅
- Repository 인터페이스: `repository_interfaces.dart` → `local_repositories.dart` — **추상화 완비** ✅
- Firestore 동기화: `content_sync_controller.dart` (초기 콘텐츠 단방향 동기화)
- **보완 필요**: `SyncQueueTable` 존재하나 실 동기화 로직(로컬→서버 업로드) 미완

### 4-4. 테스트 커버리지
- 현재 6개 파일, 7개 케이스 — **핵심 유닛 테스트 위주**
- Widget 통합 테스트 0건
- Provider 통합 테스트 부족

---

## 5. 추가 개발 제안 (우선순위순)

### Phase 1 — 즉시 착수 (1~2주)

#### 1-A. 획 판정 엔진 고도화 (`HIGH`)
- 현재: 시각적 캔버스 입력만. 실제 정답 획 데이터와 비교 로직 없음
- 목표: Hausdorff Distance 또는 DTW 기반 획 유사도 채점 구현
- 파일: `writing_canvas_widget.dart` → `StrokeJudgeService` 신규
- **선행 조건**: Firestore의 `normalized_points` 데이터가 모든 한자에 채워져 있는지 확인

#### 1-B. 복습 화면 실데이터 연동 (`HIGH`)
- `review_screen.dart` 껍데기 → `AnswerHistoryTable` + `UserProgressTable` 기반 리스트 연동
- SM-2 공식 간격(EF, repetition, interval) 필드를 `UserProgressTable`에 추가 (schema v8)
- 스케줄링 Provider 구현

#### 1-C. 오답노트 UI (`MEDIUM`)
- `AnswerHistoryTable` 데이터를 시각화하는 전용 탭/화면
- `wrong_stroke_orders`, `error_code` 기반 분석 카드

---

### Phase 2 — 단기 (2~4주)

#### 2-A. 시험 모드 (`MEDIUM`)
- PRD 9.5 기반: 객관식(뜻→한자, 음→뜻) + 직접 쓰기형 혼합
- `PracticeResultScreen` 재활용, 오답 자동 노트화

#### 2-B. 단어/성어 전용 메뉴 (`MEDIUM`)
- 현재 `hanja_detail` 탭 내부로만 접근 가능
- BottomNav에 "단어" 탭 추가 또는 Drawer 메뉴 강화

#### 2-C. 즐겨찾기 기능 (`LOW`)
- `UserProgressTable`에 `is_bookmarked` 컬럼 추가 (schema v8 혹은 별도 `BookmarkTable`)
- 홈에서 즐겨찾기 섹션 노출

#### 2-D. 통계 화면 실데이터 완성 (`MEDIUM`)
- 더미 제거, `DailyActivityStatsTable`·`DailyHanjaActivityTable` 데이터 실연동
- 주간/월간 학습 히스토그램 위젯

---

### Phase 3 — 중기 (1~3개월)

#### 3-A. 로컬→서버 동기화 (`MEDIUM`)
- `SyncQueueTable` 실 사용: 오답, 진도 변경 시 큐에 적재
- Firestore 양방향 동기화 완성
- 충돉 해결 규칙 (last-write-wins 또는 서버 우선)

#### 3-B. Admin CMS 완성 (`LOW`)
- 현재 로그인 UI까지만 구현된 상태
- 한자 정보 등록/수정, 획순 데이터 업로드, 품질 검수 기능

#### 3-C. 패키지 메이저 업그레이드 (`LOW`)
- `flutter_riverpod` 3.3, `go_router` 17.2, `google_sign_in` 7.x 등
- 브레이킹 체인지 검토 필요 (`flutter pub outdated` 확인)

#### 3-D. 필기 인식 검색 / OCR 카메라 (`LOW`)
- PRD Phase 2 범위
- On-device ML 또는 서버형 필기 평가 도입

---

## 6. 다음 작업 추천

> **지금 바로 착수할 수 있는 최우선 작업:**

1. **`StrokeJudgeService` 구현** — 획 판정 로직 없이는 핵심 학습 UX가 미완
2. **`review_screen.dart` 실데이터 연동** — SM-2 스케줄링 + `UserProgressTable` 기반 복습 큐
3. **`AnswerHistoryTable` 오답노트 UI** — 데이터는 쌓이고 있으나 화면 없음

> **주의 사항:**
> - DB schema v8 변경 시 `onUpgrade` 분기를 반드시 누적 추가해야 함 (PRD6 원칙)
> - `SyncQueueTable`은 이미 설계되어 있으므로 Phase 3 동기화 착수 시 큰 리팩터링 없이 진행 가능
