---
description: 변경사항을 git commit 하고 원격 저장소에 push 한다
---

# Git Commit & Push 워크플로우

작업 완료 후 변경사항을 커밋하고 원격 저장소(`origin`)에 푸시한다.  
문서·계획서를 바꾼 경우에는 **`/sync_docs`를 먼저** 실행한 뒤 이 워크플로우를 수행하는 것을 권장한다.

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- 원격 저장소: `https://github.com/newkies-git/hanja_study.git` (`origin`)
- 기본 브랜치: `main`
- 주요 경로 참고: Flutter 앱 `flutter/chusa1817/`, 문서 `docs/`(통합 `docs/PRD.md`, `impl_plan/`, `work_through/`), 스크립트 `python/`

**서브모듈·게스트 저장소:** `git status`에 `modified: path (new commits)` 등이 보이면 서브모듈 커밋이 선행되었는지 확인한 뒤 상위 저장소를 커밋한다.

## 수행 절차

### 1. 현재 상태 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status
```
변경·추가·삭제 파일을 확인한다. 변경이 없으면 이후 단계를 생략하고 완료 보고한다.

선택: 요약만 보려면 `git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status -sb` 또는 스테이징 전 `git -C /Users/yutaek/zWorkSpace/zBasis/HANJA diff --stat`.

### 2. 현재 브랜치 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA branch --show-current
```
아래 푸시·리베이스에 동일한 브랜치 이름을 사용한다.

### 3. 커밋 메시지 결정
사용자가 메시지를 주지 않았다면, 변경 내용에 맞춰 **Conventional Commits** 형식으로 생성한다.

```
<type>(<scope>): <subject>

<body>   ← 선택. 무엇을·왜 바꿨는지 한두 문단
```

**type**

| type | 사용 시점 |
|------|-----------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 동작은 유지하고 구조만 개선 |
| `docs` | 문서만 (`docs/`, `.md`, 주석이 목적일 때) |
| `test` | 테스트 추가·수정 |
| `chore` | 빌드·CI·의존성·도구 설정 |
| `style` | 포맷·린트만 (의미 변경 없음) |

**scope 예시:** `chusa1817`, `docs`, `python`, `agents`, `pubspec`, `firebase`, `ui`

**subject:** 50자 이내 권장, 명령형·현재형, 마침표 없음.

**예시:**
```
docs: consolidate PRD and refresh README paths

- Single docs/PRD.md with appendices; removed PRD1–6 and Q*.txt
- README points to flutter/chusa1817 and python/hanja_pipeline.py
```

### 4. 스테이징 및 커밋
사용자가 범위를 지정하지 않으면 **전체** 변경을 스테이징한다.

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA add -A
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA commit -m "<커밋 메시지>"
```

**주의:** API 키·`google-services.json` 비밀·`.env` 등 민감 정보가 포함되지 않았는지 확인한다. 저장소에 두면 안 되는 파일은 `.gitignore`에 두고 커밋하지 않는다.

### 5. Push

최초로 원격에 브랜치를 올릴 때는 업스트림을 지정한다.

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA push -u origin <현재 브랜치>
```

이미 `origin/<브랜치>`가 연결되어 있으면 다음만으로 충분하다.

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA push origin <현재 브랜치>
```

### 6. 완료 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA log --oneline -5
```
최근 커밋이 기대한 메시지로 보이는지 확인한다. 원격과 비교하려면 `git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status`로 `ahead/behind`를 본다.

## 주의사항

> [!CAUTION]
> 팀 정책으로 `main`에 직접 푸시하지 않는다면 브랜치 보호 규칙을 사용하고, 기능은 `feat/<이름>` 등에서 PR로 병합한다.

> [!NOTE]
> `git push`가 거절되면 원격에 새 커밋이 있는 경우가 많다. `git pull --rebase origin <브랜치>` 후 다시 `push`한다. 리베이스 중 충돌이 나면 해결·`git rebase --continue` 후 푸시한다.

> [!NOTE]
> 서브모듈 경로만 바뀐 커밋이면, 상위 저장소에서는 **서브모듈 포인터(커밋 해시)** 변경이 한 줄로 잡힌다. 의도한 서브모듈 버전인지 확인한다.

## 관련 워크플로우

- `/sync_docs` — `implementation_plan.md`·`walkthrough.md`를 `docs/impl_plan/`·`docs/work_through/`에 반영
- `/analyze_and_propose` — 주기적 분석·제안 후 문서 동기화·커밋 순서와 맞물림
