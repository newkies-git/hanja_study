# [2026-07-26] 프로젝트 분석 보고 및 개발 제안

본 보고서는 `hanja_study` (한자정습, 앱 명칭: `chusa1817`) 프로젝트의 전체 코드베이스, PRD 기획 요구사항 대비 구현 현황, 빌드 및 테스트 상태, 아키텍처 품질을 점검하고 향후 추가 개발 방향을 제안합니다.

---

## 1. 현황 요약

- **프로젝트 개요**: 한국 중·고등학교 교육용 기초 한자 1,800자를 대상으로 하는 **한자 학습 모바일 앱(추사1817)** 및 파이프라인/어드민 시스템
- **코드베이스 스냅샷**:
  - **Flutter 클라이언트**: `flutter/chusa1817` (Dart 소스 파일 50여 개)
  - **어드민 & 파이프라인**: `admin/` (Vue 어드민 UI, Python 한자 데이터 수집·정제 스크립트)
  - **기획 문서**: `docs/PRD.md` (통합 요구사항), `docs/SM-2.md` (간격 반복 알고리즘 명세)
- **Git 상태**: Working tree clean (최근 커밋: `138cab1 fix: correct SM-2 progress and cut list/sync load`)

---

## 2. Flutter 분석 결과

### 정적 분석 (`flutter analyze --no-fatal-infos`)
- **결과**: `No issues found!` (경고/에러 0건)
- **품질**: 린트 룰 준수 및 타입 안전성 양호

### 자동화 테스트 (`flutter test`)
- **결과**: **11개 테스트 항목 전체 통과 (Pass)**
- **주요 검증 영역**:
  - 획순 유사도 평가 로직 (`stroke_evaluator_test.dart`)
  - 획 좌표 정규화 유틸리티 (`stroke_coordinate_utils_test.dart`)
  - SM-2 알고리즘 기반 복습 한자 추천 프로바이더 (`recommended_review_provider_test.dart`)
  - 한자 학습 리스트 화면 위젯 테스트 (`learn_list_screen_test.dart`)

---

## 3. PRD 대비 구현 현황표

| 기능 (요구사항 ID/영역) | PRD 정의 요약 | 구현 상태 (코드/화면/데이터 근거) | 갭·리스크 | 우선순위 |
| :--- | :--- | :--- | :--- | :--- |
| **8.1 한자 정보 조회** | 음/뜻/부수/총획/학습상태 검색 및 상세 보기 | **[구현 완료]** [learn_list_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/learn/learn_list_screen.dart) 및 [hanja_detail_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/learn/hanja_detail_screen.dart) | 필기인식 검색(2차 확장안) 미구현 (1차 미포함) | HIGH |
| **8.2 획순 애니메이션** | 획순 재생, 한 획씩 재생, 획 번호 및 가이드 표시 | **[구현 완료]** [stroke_animation_player.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/study/widgets/stroke_animation_player.dart) | 배속 조절 UI 미세 튜닝 필요 | HIGH |
| **8.3 획순 필기 학습 & 채점** | 원고지 판에 필기 후 획순/방향/유사도 실시간 판정 | **[구현 완료]** [writing_canvas_widget.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/study/widgets/writing_canvas_widget.dart) & [stroke_evaluator.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/study/stroke_evaluator.dart) | 다양한 터치 입력/스타일러스 입력 감도 튜닝 여지 | HIGH |
| **8.4 퀴즈 및 테스트** | 한자 음/뜻 퀴즈 플레이 및 결과 산출 | **[구현 완료]** [quiz_play_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/quiz/quiz_play_screen.dart) & [quiz_result_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/quiz/quiz_result_screen.dart) | 퀴즈 문제 모드(단어/성어 확장) 다변화 | MEDIUM |
| **8.5 복습 (SM-2 알고리즘)** | SM-2 복습 주기 계산 및 추천 복습 한자제시 | **[구현 완료]** [recommended_review_section.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/home/widgets/recommended_review_section.dart) & [review_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/review/review_screen.dart) | 최근 진행도 보정 완료 (`138cab1`) | HIGH |
| **8.6 사용자 인증 & 오프라인 싱크** | Firebase Auth 로그인, Drift 로컬 DB <-> Firestore 오프라인 싱크 | **[구현 완료]** [auth_controller.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/auth/auth_controller.dart) & [content_sync_controller.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/firebase/content_sync_controller.dart) | 네트워크 단절 시 동기화 재시도 UX 보강 | HIGH |
| **8.7 단어/성어 학습 연계** | 관련 단어, 고사성어 정보 연계 학습 | **[부분 구현]** 한자 상세 페이지 [hanja_words_tab.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/learn/widgets/hanja_words_tab.dart) 탭에 렌더링 | 단어/성어 전용 학습 모드 UI 추가 필요 | MEDIUM |
| **8.8 일일 학습 알림** | 로컬 푸시 알림을 통한 학습 리마인더 | **[부분 구현]** [notification_service.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/notifications/notification_service.dart) 구조 마련 | 프로필 설정 뷰에서 알림 시간 지정 UI 연결 | LOW |

---

## 4. 아키텍처·품질 이슈

1. **상태 관리 (`flutter_riverpod`)**:
   - `lib/core/providers/`, `*Controller*` 패턴으로 UI 뷰와 도메인/데이터 로직의 분리가 우수함.
2. **라우팅 (`go_router`)**:
   - [app_router.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/router/app_router.dart)에 Auth 상태 기반 리다이렉트와 셸 라우트가 잘 정의되어 있음.
3. **데이터 & 동기화 (Drift + Firestore)**:
   - Drift 로컬 DB 기반의 Offline-First 아키텍처가 구현되어 응답성이 뛰어남.
   - 초기 데이터 싱크(`initial_content_sync.dart`) 진행도 상태 관리가 명확함.
4. **테스트 상태**:
   - 핵심 수학/유사도 로직에 대한 단편적 유닛 테스트는 잘 갖춰져 있으나, Firestore 싱크 컨트롤러 및 통합 시나리오 테스트 추가 필요.

---

## 5. 추가 개발 제안 (우선순위순)

### Phase 1 — 즉시 착수 (1~2주)
1. **단위 테스트 및 모킹 테스트 커버리지 확대**
   - `ContentSyncController` 및 Auth 상태 변화에 따른 라우터 리다이렉트 테스트 작성
2. **초기 콘텐츠 동기화 UX 개선**
   - [content_sync_progress_section.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/shared/widgets/content_sync_progress_section.dart) 프로그레스 뷰의 애니메이션 연출 및 동기화 실패 시 재시도 버튼 추가

### Phase 2 — 단기 (2~4주)
1. **단어 및 고사성어 학습 모드 확장**
   - 한자 1자 단위를 넘어 관련 단어/고사성어 카드를 연속 학습하는 퀴즈/쓰기 모드 구축
2. **일일 복습 푸시 알림 연동**
   - `plan_settings_screen.dart`에 `NotificationService` 기반 학습 시간 설정 및 로컬 푸시 예약 기능 연결
3. **획순 채점 알림/사운드 피드백 보강**
   - 필기 획 성공/실패 시의 햅틱 및 시각 피드백 연출 강화

### Phase 3 — 중기 (1~3개월)
1. **스토어 출시 준비 (Google Play / App Store)**
   - [android-chusa1817-play-release.md](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/android-chusa1817-play-release.md) 기반 앱 서명, 스토어 메타데이터/스크린샷 준비 및 배포 파이프라인 정비
2. **어드민 웹 UI 통합 관리 강화**
   - 어드민 시스템(`admin/frontend`)을 통해 신규 고사성어 및 단어 데이터 정제/업데이트 자동화

---

## 6. 다음 작업 추천

1. **문서 동기화 및 기록 커밋**: `/sync_docs` 및 `/git_commit_push` 실행
2. **Phase 1 구현 착수**: 동기화 실패 재시도 처리 및 테스트 커버리지 보강 작업 진행
