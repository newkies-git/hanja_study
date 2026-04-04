---
name: git-commit-push
description: >-
  Git add/commit/push for this repo using Conventional Commits, branch check, and
  safety checks (secrets, submodules). Use when the user asks to commit, push,
  git_commit_push, 커밋, 푸시, or to finish work with version control. Aligns with
  `.agents/workflows/git_commit_push.md`.
---

# Git 커밋 & Push (HANJA)

저장소 루트는 **`/Users/yutaek/zWorkSpace/zBasis/HANJA`** 이다. 사용자가 커밋·푸시를 요청하면 **직접 명령을 실행**하고 결과를 보고한다.

문서·계획서만 바꾼 경우 **`/sync_docs`**(또는 `sync_docs.md` 절차)를 먼저 마친 뒤 커밋하는 것을 권장한다.

## 사전 확인

- 원격: `origin` → `https://github.com/newkies-git/hanja_study.git`, 기본 브랜치 `main`
- 서브모듈 표시가 있으면 서브모듈 쪽 커밋이 의도된 것인지 확인 후 상위 저장소를 커밋한다

## 절차

### 1. 상태·브랜치

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA branch --show-current
```

변경이 없으면 커밋을 생략하고 보고한다. 요약이 필요하면 `status -sb`, `diff --stat` 를 쓴다.

### 2. 커밋 메시지 (Conventional Commits)

형식:

```
<type>(<scope>): <subject>

<body>   ← 선택
```

| type | 용도 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 동작 유지, 구조만 개선 |
| `docs` | 문서·의도적 주석 |
| `test` | 테스트 |
| `chore` | 빌드·CI·의존성·도구 |
| `style` | 포맷·린트만 |

scope 예: `chusa1817`, `docs`, `python`, `agents`, `pubspec`, `firebase`, `ui`  
subject: 짧은 명령형, 마침표 없음.

사용자가 메시지를 주면 그대로 쓰고, 없으면 변경 파일에 맞춰 생성한다.

### 3. 스테이징·커밋

범위를 지정하지 않으면 전체 스테이징한다.

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA add -A
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA commit -m "<메시지>"
```

커밋 전에 API 키·`.env`·비공개 키·의도치 않은 `google-services.json` 등 **민감 정보**가 포함되지 않았는지 본다.

### 4. Push

```bash
# 업스트림 미설정 브랜치(최초)
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA push -u origin <브랜치>

# 이미 추적 중
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA push origin <브랜치>
```

거절되면 `git pull --rebase origin <브랜치>` 후 재시도. 충돌 시 해결 → `git rebase --continue` → 다시 push.

### 5. 확인

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA log --oneline -5
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status
```

## 정책 메모

- `main` 직접 푸시를 쓰지 않는 팀이면 `feat/...` + PR 규칙을 따른다
- 서브모듈만 변경된 커밋은 **포인터(해시) 변경** 한 줄로 보일 수 있으니 의도 확인

## 관련

- `.agents/workflows/git_commit_push.md` — 동일 절차의 워크플로 문서
- `/sync_docs`, `/analyze_and_propose` — 문서 선행·순서
