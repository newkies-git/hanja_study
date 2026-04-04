---
description: 작업 완료 후 impl_plan 및 work_through 문서 동기화
---

# 작업 완료 후 문서 동기화 + 버전 관리 워크플로우

에이전트(또는 편집 세션)에서 갱신한 **`implementation_plan.md`**·**`walkthrough.md`** 초안을  
프로젝트 **`docs/`** 아래의 정식 경로에 반영한다.

**대상이 아닌 것:** `docs/PRD.md`, `.agents/workflows/*` 등은 저장소에서 직접 편집·커밋한다. 이 워크플로는 **구현 계획·워크스루 두 종류**만 다룬다.

**버전 규칙**

- **최신본:** 항상 같은 파일명으로 덮어쓴다.
- **히스토리:** `_history/`에 `_<TIMESTAMP>.md` 사본을 **추가**한다 (기존 히스토리 파일은 삭제하지 않는다).

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- **소스(초안):** Cursor 등 에이전트 작업 공간에서 편집된 `implementation_plan.md`, `walkthrough.md` (이하 **brain 초안**)
- **싱크 대상(저장소 내 정식 경로):**
  - `docs/impl_plan/implementation_plan.md`
  - `docs/work_through/walkthrough.md`

초안이 비어 있거나 이번 작업에서 손대지 않았다면, 해당 파일에 대해서는 싱크를 건너뛰고 이유를 보고한다.

## 디렉터리 구조

```
docs/
├─ PRD.md                              ← 통합 기획서 (이 워크플로 비대상)
├─ impl_plan/
│  ├─ implementation_plan.md           ← 최신본 (덮어쓰기)
│  └─ _history/
│     └─ implementation_plan_<TIMESTAMP>.md
└─ work_through/
   ├─ walkthrough.md                    ← 최신본 (덮어쓰기)
   └─ _history/
      └─ walkthrough_<TIMESTAMP>.md
```

## 수행 절차

### 1. 디렉터리 준비
// turbo
```bash
mkdir -p /Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/_history
mkdir -p /Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/_history
```

### 2. 타임스탬프 생성
// turbo
```bash
date +%Y%m%d_%H%M%S
```
출력을 `TIMESTAMP`로 쓴다 (예: `20260404_153012`). 로컬 타임존 기준이면 된다.

### 3. implementation_plan.md 반영
brain 초안의 최신 `implementation_plan.md` 내용을 읽어 아래에 저장한다.

| 구분 | 경로 |
|------|------|
| 최신본 (덮어쓰기) | `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/implementation_plan.md` |
| 히스토리 (신규 파일) | `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/_history/implementation_plan_<TIMESTAMP>.md` |

기존 최신본과 **바이트 동일**하면 덮어쓰기와 히스토리 추가를 생략해도 된다 (노이즈 감소).

### 4. walkthrough.md 반영
brain 초안의 최신 `walkthrough.md` 내용을 읽어 아래에 저장한다.

| 구분 | 경로 |
|------|------|
| 최신본 (덮어쓰기) | `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/walkthrough.md` |
| 히스토리 (신규 파일) | `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/_history/walkthrough_<TIMESTAMP>.md` |

동일하면 3단과 같이 생략 가능.

### 5. 완료 보고
실제로 쓰거나 건너뛴 작업을 구분해 보고한다.

- 갱신된 파일 경로(최대 4개: 최신본 2 + 히스토리 2)
- 건너뛴 항목이 있으면 이유(변경 없음, 초안 없음 등)

`_history/` 아래 파일이 **20개를 넘으면** 오래된 사본 정리·아카이브를 사용자에게 권한다.

### 6. 이후 권장
문서 변경을 커밋할 때는 **`/git_commit_push`** 를 사용한다. 커밋 type은 보통 `docs`이다.

## 관련 워크플로우

- `/analyze_and_propose` — 분석 보고서 초안 작성 후 본 워크플로로 `docs/` 반영
- `/git_commit_push` — 싱크된 `docs/` 변경 포함 전체 커밋·푸시
