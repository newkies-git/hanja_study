---
description: 작업 완료 후 implementation_plan 및 walkthrough 문서 동기화 (히스토리 파일 미생성)
---

# 작업 완료 후 문서 동기화 워크플로우

에이전트에서 갱신한 **`implementation_plan.md`**·**`walkthrough.md`** 초안을 프로젝트 **`docs/`** 디렉터리 상위에 직접 덮어씌워 반영한다.

**단일화 원칙:**
- **최신본 단일 유지:** 항상 `docs/implementation_plan.md` 및 `docs/walkthrough.md` 경로에 직접 덮어쓴다.
- **히스토리 미생성:** `_history/` 서브 폴더 및 타임스탬프 사본 파일은 생성하지 않는다.

---

## 디렉터리 구조

```text
docs/
├── PRD.md                 # 통합 기획서
├── implementation_plan.md # 최신 구현 계획서 (덮어쓰기)
└── walkthrough.md         # 최신 실행 워크스루 (덮어쓰기)
```

## 수행 절차

### 1. implementation_plan.md 반영
`/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/implementation_plan.md` 경로로 최신 내용을 직접 덮어쓴다.

### 2. walkthrough.md 반영
`/Users/yutaek/zWorkSpace/zBasis/HANJA/docs/walkthrough.md` 경로로 최신 내용을 직접 덮어쓴다.

### 3. 완료 보고 및 Git 커밋 권장
문서 동기화 후 **`/git_commit_push`** 명령을 사용하여 변경 사항을 원격 저장소에 커밋 및 푸시한다.
