# [2026-07-26] 프로젝트 분석 보고

## 1. 현황 요약
- **저장소 구조 정립**: 저장소 3대 탑레벨 디렉터리 체계 (`admin/`, `admin-etl/`, `client/`) 정립 및 마크다운 파일 내 링크 상대 경로 일괄 표준화 완료
- **Flutter 클라이언트 앱 (`client/chusa1817/`)**: Dart 소스 75+개, 16개 단위/위젯 테스트 100% Pass, `flutter analyze` 0 경고
- **어드민 백오피스 Web App (`admin/webapp/`)**: Vue 3 + Vite 6 + TypeScript, 14개 Vitest 유닛 테스트 100% Pass, 프로덕션 빌드 0에러 성공
- **Python ETL 데이터 파이프라인 (`admin-etl/`)**: 네이버 한자사전 크롤러, 1,817자 획순 SVG 정규화 및 Admin SDK 업로더 구축 완료

---

## 2. Flutter 분석 결과
- **정적 분석 (`flutter analyze`)**: **`No issues found!`** (오류/경고 0건)
- **자동화 테스트 (`flutter test`)**: **`16 / 16 Passed`** (100% 통과)
- **아키텍처 스택**: Feature-First 구조 (`lib/features/`, `lib/core/`, `lib/shared/`), Riverpod 상태 관리, Drift (SQLite) 오프라인 듀얼 DB 동기화

---

## 3. PRD 대비 구현 현황표

| 기능 / 요구사항 | PRD 정의 요약 | 구현 상태 (코드/화면/데이터 근거) | 갭·리스크 | 우선순위 |
| :--- | :--- | :--- | :--- | :--- |
| **기초 한자 1,817자 탐색** | 2000년 개정 1,800자 + 17자 급수별/부수별 검색 | **[구현 완료]** `learn_list_screen.dart`, `hanja_card.dart` | 검색 키워드 자동 완성이 필요할 수 있음 | HIGH |
| **획순 필기 채점 캔버스** | 원고지 캔버스 필기 및 획순/방향/유사도 판정 | **[구현 완료]** `writing_canvas_widget.dart`, `stroke_evaluator.dart` | 다양한 디바이스 터치 감도 미세 조절 필요 | HIGH |
| **SM-2 간격 반복 복습** | SM-2 알고리즘 기반 복습 주기 & EF 산출 | **[구현 완료]** `review_screen.dart`, `recommended_review_section.dart` | 오답 한자 재복습 덱 UX 세분화 필요 | HIGH |
| **오프라인 듀얼 DB 싱크** | Drift (SQLite) <-> Firestore 백그라운드 싱크 | **[구현 완료]** `content_sync_controller.dart`, `app_database.dart` | 오프라인 상태 지속 시 충돌 해결 정책 고도화 | HIGH |
| **음/뜻 퀴즈 플레이** | 객관식/주관식 퀴즈 세션 및 결과 산출 | **[구현 완료]** `quiz_play_screen.dart`, `quiz_result_screen.dart` | 퀴즈 난이도 설정 옵션 추가 제안 | MEDIUM |
| **사용자 프로필 & 북마크** | 프로필 관리, Streak 계산, 즐겨찾기 목록 | **[구현 완료]** `profile_screen.dart`, `toggleBookmark` | 소셜 프로필 이미지 변경 기능 제안 | MEDIUM |
| **Admin 배치 업로더** | JSON/CSV 드래그앤드롭 배치 커밋 지원 | **[구현 완료]** `admin/webapp/src/views/dashboard/DatabaseSyncView.vue` | 400개 단위 배치 업로드 안정성 보장 완료 | HIGH |

---

## 4. 아키텍처·품질 점검
- **상태 관리**: Riverpod (`StateNotifier` / `AsyncNotifier`)로 도메인 로직과 UI 분리 깔끔함
- **라우팅**: GoRouter 기반 Auth 리다이렉션 및 셸 라우트 정상 동작
- **문서화**: `docs/SPEC-client.md`, `docs/SPEC-admin.md`, `docs/SPEC-admin-etl.md` 수립 및 상대 경로 표준화 완료

---

## 5. 추가 개발 제안 (우선순위순)

### Phase 1 — 즉시 착수 (1~2주)
1. **단어/성어 학습 전용 모드 추가**: 한자 상세 탭 외에 단어/고사성어 전용 카드리스트 및 퀴즈 모드 확장
2. **획순 필기 캔버스 배속/가이드 조절 옵션**: 필기 채점 시 획 가이드 라인 굵기 및 획순 애니메이션 배속(0.5x~2.0x) 설정 기능

### Phase 2 — 단기 (2~4주)
1. **푸시 알림 리마인더 활성화**: `notification_service.dart` 기반 사용자 설정 지정 시간에 일일 학습 알림 푸시
2. **필기 인식 검색 연동**: 필기 캔버스 입력 결과를 통한 한자 검색 기능 (2차 확장)

### Phase 3 — 중기 (1~3개월)
1. **백업 및 멀티 디바이스 진도 동기화 보강**: Firestore 상의 유저별 복습 데이터 동기화 안정성 강화

---

## 6. 다음 작업 추천
- **단어/고사성어 전용 학습 모드 화면 구축**: `client/chusa1817/lib/features/learn/` 내 단어/성어 학습 뷰 추가 개발
