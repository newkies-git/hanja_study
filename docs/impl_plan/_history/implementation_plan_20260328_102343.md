# 2026-03-28 프로젝트 분석 보고 — UI 프로토타입 우선 계획

> **개발 방향**: 전체 화면 UX 흐름 완성 최우선. 더미 데이터로 모든 화면을 연결한 프로토타입을 먼저 완성한 뒤, 단계적으로 실제 엔진과 교체한다.

---

## 1. 현황 요약

| 항목 | 현황 |
|------|------|
| Dart 파일 | 26개 (core 2 / shared/widgets 9 / features 14 / main 1) |
| `flutter analyze` | ✅ No issues found |
| 미커밋 변경 | 6개 (앱이름·패키지명 변경) |
| 구현된 화면 | 11개 |
| 미구현 화면 | **10개 이상** (PRD 기준) |

---

## 2. Flutter 정적 분석 결과

```
flutter analyze --no-fatal-infos → No issues found ✅
```

### 아키텍처 잔존 이슈

| 항목 | 현황 | 권장 |
|------|------|------|
| `setState` | 4개 화면 | Phase 2에서 Riverpod 이전 |
| `MaterialPageRoute` | 8곳 직접 push | Phase 1에서 go_router 통합 |
| `flutter_riverpod` | 패키지만 추가, Provider 0개 | Phase 2 도입 |
| `drift` DB | 패키지만 추가, 스키마 없음 | Phase 3 도입 |
| 테스트 | widget_test 1개 | Phase 2에서 확대 |

---

## 3. PRD 대비 구현 현황

### 구현된 화면 (11개)

| 화면 | 상태 | 비고 |
|------|------|------|
| Landing | ✅ | |
| Login | ✅ Mock | 실 인증 없음 |
| Home | ⚠️ 골격만 | 오늘의 학습·연속일·진도 미구현 |
| LearnList | ⚠️ 더미 8자 | 필터 UI만 |
| HanjaDetail | ⚠️ 더미 | 단어탭 3개 하드코딩 |
| StudyScreen | ⚠️ UI만 | 터치 입력 없음 |
| PracticeResult | ✅ | 더미 점수 |
| Statistics | ⚠️ 더미 | 막대 하드코딩 |
| Profile | ✅ | |
| PlanSettings | ✅ | 저장 없음 |

### 미구현 화면 (프로토타입 최우선)

| 화면 | PRD 위치 | 우선순위 |
|------|----------|----------|
| 획순 애니메이션 플레이어 | HanjaDetail → 획순탭 | ⭐⭐⭐ |
| 터치 쓰기 입력 캔버스 | StudyScreen | ⭐⭐⭐ |
| 획 판정 피드백 UI | StudyScreen | ⭐⭐⭐ |
| 복습 화면 (오답노트) | 별도 탭 | ⭐⭐ |
| 단어/성어 목록 | 별도 탭 | ⭐⭐ |
| 시험 모드 | 별도 화면 | ⭐⭐ |
| 홈 — 오늘의 학습 위젯 | Home | ⭐⭐ |
| 홈 — 진도/연속일 스트릭 | Home | ⭐⭐ |
| 한자 검색 | 검색 탭·상단 바 | ⭐⭐ |
| 설정 화면 | Profile 하위 | ⭐ |

---

## 4. UI 프로토타입 3단계 로드맵

### Phase 1 — 화면 완성 (1~2주) 🔥 즉시 착수

> **목표**: 모든 PRD 화면을 더미 데이터로 연결. 기기에서 전체 UX 흐름 시연 가능.

| # | 작업 | 파일 |
|---|------|------|
| 1-1 | 터치 쓰기 입력 캔버스 | `features/study/study_screen.dart` |
| 1-2 | 획순 애니메이션 플레이어 | `features/learn/hanja_detail_screen.dart` |
| 1-3 | 홈 위젯 (진도 카드 · 스트릭 · 추천복습) | `features/home/home_screen.dart` |
| 1-4 | 복습 탭 + 오답노트 화면 Shell | `features/review/` (신규) |
| 1-5 | go_router 라우팅 통합 | `features/shell/app_shell.dart` |

**1-1 터치 쓰기 캔버스 핵심 설계**
```dart
// GestureDetector → 터치 경로를 List<Offset> stroke로 저장
// CustomPainter → stroke 목록을 Path로 렌더링
// 완료 버튼 → Mock "정답" 판정 후 PracticeResultScreen 이동
```

**1-2 획순 애니메이션 핵심 설계**
```dart
// 하드코딩 획 좌표 List<List<Offset>> strokePaths
// AnimationController + AnimatedBuilder → 획별 순차 재생
// 이전/다음 획 버튼, 자동재생 토글
```

---

### Phase 2 — 인터랙션 강화 (2~4주)

> **목표**: 입력·피드백이 살아있는 인터랙티브 프로토타입.

- 획 판정 Mock 엔진 (터치 stroke ↔ 정답 경로 DTW 유사도)
- Riverpod 상태 관리 도입 (`setState` 4곳 → Provider 이전)
- 한자 검색 기능 (음/뜻 텍스트 필터)
- 시험 모드 화면 (타이머 UI · 객관식/쓰기 선택)
- 단어/성어 목록 화면

---

### Phase 3 — 실 데이터 연동 (1~3개월)

> **목표**: 프로토타입 → Production 전환.

- Playwright 파이프라인으로 1,800자 SQLite 구축
- Drift 스키마 (`HanjaTable`, `StudyLogTable`, `ReviewScheduleTable`)
- SM-2 복습 알고리즘 구현
- 실제 획순 SVG 애니메이션 연동 (`flutter_svg`)
- Firebase Auth 실 인증

---

## 5. 다음 작업 추천 (즉시)

1. **터치 쓰기 캔버스** — `StudyScreen`에 `GestureDetector + CustomPainter`
2. **획순 애니메이션** — `HanjaDetailScreen` 획순탭에 `AnimationController` 기반 플레이어
3. **go_router 통합** — `MaterialPageRoute` 8곳 선언형 라우트로 교체
4. **홈 위젯** — 더미 진도 카드·스트릭·추천복습 섹션 추가
