---
description: 프로젝트를 분석하고 보완사항을 찾고, 추가 개발을 제안한다
---

# 프로젝트 분석 & 개발 제안 워크플로우

매 개발 사이클 시작 전, 현재 프로젝트 상태를 점검하고 다음 작업 방향을 도출한다.

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- Flutter 앱(단일 패키지): `flutter/chusa1817` (`chusa1817`, 추사1817)
- 문서: `docs/` — PRD·구현 계획·워크스루는 아래 경로 참조
- Python·스크립트·도구: `python/` (배치·Firebase Admin 등, 워크스페이스에 따라 상이)

**PRD·기획 문서:** `docs/PRD.md` (통합본, 본문 §1–§23 + 부록 A–F)  
상충 시 동일 파일 내 **본문이 부록보다 우선**하고, 버전·날짜는 YAML `version` 필드를 따른다.

**구현 계획 동기화:** 에이전트 작업 공간의 `implementation_plan.md` 초안을 작성한 뒤, `/sync_docs`로 `docs/impl_plan/`에 반영한다 (`sync_docs.md` 참고).

---

## 수행 절차

### 1. 현재 상태 스냅샷
// turbo
```bash
# Dart 소스 목록(요약)
find /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib \
  -name "*.dart" | sort

# 최근 커밋
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA log --oneline -10

# 작업 트리
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status --short
```

### 2. Flutter 정적 분석
// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817
flutter analyze --no-fatal-infos 2>&1
```
경고·힌트·info가 있으면 심각도와 파일 위치를 목록화한다.  
`pubspec.yaml`에 `custom_lint` / `riverpod_lint`가 있으면 필요 시 `dart run custom_lint`로 보강한다.

### 3. PRD 대비 구현 현황 점검

1. `docs/PRD.md`를 읽고 **기능·비기능 요구사항**을 목록으로 추출한다 (부록과 본문이 겹치면 본문 우선, 중복은 병합).
2. Flutter 소스는 주로 `lib/features/`, `lib/core/`, `lib/shared/`를 대조한다.
3. 아래 표는 **실제 조사 결과로 채운다**. 예시 행에 고정하지 말 것.

| 기능(또는 요구 ID) | PRD 정의 요약 | 구현 상태(코드/화면/데이터 근거) | 갭·리스크 | 우선순위 |
|--------------------|---------------|--------------------------------|-----------|----------|
| … | … | … | … | HIGH/MEDIUM/LOW |

**코드 탐색 힌트 (필요 시):**  
`app_router.dart`, `app_database.dart`, `*_repository*`, `*_screen.dart`, Firestore·동기화 관련 `lib/core/firebase/` 등.

### 4. 아키텍처·품질 점검

다음을 **현재 코드 기준**으로 확인하고, 개선점을 짧게 기록한다.

**상태 관리**
- `flutter_riverpod`: `lib/core/providers/`, `*Controller*`, `*providers.dart` 등에서 Provider/Notifier 사용 패턴
- UI와 도메인 로직 분리 여부, 테스트 가능한 단위인지

**라우팅**
- `go_router` (`lib/core/router/app_router.dart`): named route, redirect, 뒤로가기·딥링크 일관성

**데이터·동기화**
- Drift: `app_database.dart`, 테이블·마이그레이션, Repository 인터페이스
- Firebase(Firestore/Auth 등): 부트스트랩, 오프라인·초기 동기화 흐름

**테스트**
// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817
flutter test 2>&1
```
실패·스킵·느린 스위트가 있으면 원인 후보를 적는다.

### 5. 분석 보고서 작성

1~4단계 결과를 종합하여 **에이전트 작업 공간의** `implementation_plan.md`에 아래 구조로 기록한다.  
(이후 `/sync_docs`로 `docs/impl_plan/implementation_plan.md` 및 `_history/`에 버전 저장.)

```markdown
# [YYYY-MM-DD] 프로젝트 분석 보고

## 1. 현황 요약
## 2. Flutter 분석 결과
## 3. PRD 대비 구현 현황표
## 4. 아키텍처·품질 이슈
## 5. 추가 개발 제안 (우선순위순)
   ### Phase 1 — 즉시 착수 (1~2주)
   ### Phase 2 — 단기 (2~4주)
   ### Phase 3 — 중기 (1~3개월)
## 6. 다음 작업 추천
```

`walkthrough.md`를 이번 분석에서 갱신할 필요가 있으면 같은 흐름으로 작성·동기화한다.

### 6. 문서 동기화 및 커밋

분석·보고서 작성이 끝나면 아래를 순서대로 실행한다.

1. `/sync_docs` — `implementation_plan.md`(및 필요 시 `walkthrough.md`)를 `docs/impl_plan/`, `docs/work_through/`에 반영
2. `/git_commit_push` — 변경사항 커밋·푸시 (문서 중심이면 커밋 type: `docs`)

## 관련 워크플로우

- `/sync_docs` — impl_plan / work_through 버전 관리
- `/git_commit_push` — 커밋·푸시
