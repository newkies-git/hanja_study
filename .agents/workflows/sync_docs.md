---
description: 작업 완료 후 impl_plan 및 work_through 문서 동기화
---

# 작업 완료 후 문서 동기화 + 버전 관리 워크플로우

매 작업이 완료될 때마다 brain 디렉터리의 `implementation_plan.md`와 `walkthrough.md`를
프로젝트 `docs/` 폴더에 저장한다.  
**버전 관리**: 최신본은 항상 덮어쓰고, `_history/` 하위에 타임스탬프 사본을 보존한다.

## 디렉터리 구조

```
docs/
├─ impl_plan/
│  ├─ implementation_plan.md          ← 최신본 (항상 덮어쓰기)
│  └─ _history/
│     ├─ implementation_plan_20260328_090000.md
│     └─ implementation_plan_20260401_143000.md
└─ work_through/
   ├─ walkthrough.md                  ← 최신본 (항상 덮어쓰기)
   └─ _history/
      ├─ walkthrough_20260328_090000.md
      └─ walkthrough_20260401_143000.md
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
위 명령의 출력값을 `TIMESTAMP`로 저장한다 (예: `20260328_090134`).

### 3. implementation_plan.md 버전 저장
brain 디렉터리의 최신 `implementation_plan.md` 내용을 읽어 아래 두 곳에 저장한다.

- **최신본** (Overwrite: true):  
  `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/implementation_plan.md`

- **히스토리 사본** (새 파일):  
  `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/_history/implementation_plan_<TIMESTAMP>.md`

### 4. walkthrough.md 버전 저장
brain 디렉터리의 최신 `walkthrough.md` 내용을 읽어 아래 두 곳에 저장한다.

- **최신본** (Overwrite: true):  
  `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/walkthrough.md`

- **히스토리 사본** (새 파일):  
  `/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/_history/walkthrough_<TIMESTAMP>.md`

### 5. 완료 보고
저장된 파일 경로 4개를 사용자에게 보고한다.
오래된 히스토리가 20개를 초과하면 사용자에게 정리를 권고한다.
