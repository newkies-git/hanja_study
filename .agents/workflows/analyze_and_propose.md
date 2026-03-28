---
description: 프로젝트를 분석하고 보완사항을 찾고, 추가 개발을 제안한다
---

# 프로젝트 분석 & 개발 제안 워크플로우

매 개발 사이클 시작 전, 현재 프로젝트 상태를 점검하고 다음 작업 방향을 도출한다.

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- Flutter 앱: `flutter/fe/hanja_app/lib/`
- 문서: `docs/`
- Python 파이프라인: `python/`

---

## 수행 절차

### 1. 현재 상태 스냅샷
// turbo
```bash
# 파일 구조 요약
find /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/fe/hanja_app/lib \
  -name "*.dart" | sort

# 최근 커밋 이력
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA log --oneline -10

# 미해결 변경사항
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status --short
```

### 2. Flutter 정적 분석
// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/fe/hanja_app
flutter analyze --no-fatal-infos 2>&1
```
оценить경고·힌트가 있으면 목록화한다.

### 3. PRD 대비 구현 현황 점검

아래 PRD 파일을 읽어 기능 요구사항 목록을 추출한다.
- `docs/PRD.md`
- `docs/PRD3.md`

현재 Flutter 소스(`lib/features/`)와 대조하여 아래 표를 작성한다.

| 기능 | PRD 정의 | 구현 여부 | 우선순위 |
|------|----------|-----------|----------|
| 한자 목록 조회 | ✅ | 더미 데이터 | HIGH |
| 한자 상세 정보 | ✅ | 더미 데이터 | HIGH |
| 획순 애니메이션 | ✅ | 미구현 | HIGH |
| 터치 쓰기 입력 | ✅ | 미구현 | HIGH |
| 획 판정 엔진 | ✅ | 미구현 | HIGH |
| SM-2 복습 알고리즘 | ✅ | 미구현 | MEDIUM |
| 오답노트 | ✅ | 미구현 | MEDIUM |
| 통계 (실데이터) | ✅ | 더미 | MEDIUM |
| 로그인/인증 | ✅ | Mock only | HIGH |
| SQLite 연동 | ✅ | 미구현 | HIGH |

### 4. 아키텍처 보완사항 점검

다음 항목을 코드에서 확인하고 문제점을 기록한다.

**상태 관리**
- `flutter_riverpod` 패키지는 추가되었으나 실제 Provider가 0개인지 확인
- `setState` 사용 위치가 feature 화면에만 한정되는지 확인

**라우팅**
- `go_router` 패키지 추가됨 → `MaterialPageRoute` 직접 push 코드 잔존 여부 확인
- 딥링크, 뒤로가기 처리 일관성 점검

**데이터 레이어**
- `drift` 패키지 추가됨 → Database 스키마 파일(`*.drift`, `*_db.dart`) 존재 여부 확인
- API Repository 추상화 클래스 유무 확인

**테스트**
// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/fe/hanja_app
flutter test 2>&1
```
테스트 커버리지 수준과 실패 항목 기록.

### 5. 분석 보고서 작성

위 1~4 단계 결과를 종합하여 아래 구조로 `implementation_plan.md`(brain)에 기록한다.

```markdown
# [날짜] 프로젝트 분석 보고

## 1. 현황 요약
## 2. Flutter 분석 결과
## 3. PRD 대비 구현 현황표
## 4. 아키텍처 보완사항
## 5. 추가 개발 제안 (우선순위순)
   ### Phase 1 — 즉시 착수 (1~2주)
   ### Phase 2 — 단기 (2~4주)
   ### Phase 3 — 중기 (1~3개월)
## 6. 다음 작업 추천
```

### 6. 문서 동기화 및 커밋

분석 완료 후 아래 워크플로우를 순서대로 실행한다.

1. `/sync_docs` — 보고서를 `docs/impl_plan/`에 버전 저장
2. `/git_commit_push` — 변경사항 커밋 (커밋 메시지 type: `docs`)
