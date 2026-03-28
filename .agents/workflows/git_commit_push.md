---
description: 변경사항을 git commit 하고 원격 저장소에 push 한다
---

# Git Commit & Push 워크플로우

작업 완료 후 변경사항을 커밋하고 원격 저장소(`origin`)에 푸시한다.  
`/sync_docs` 가 먼저 실행된 이후에 수행하는 것을 권장한다.

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- 원격 저장소: `https://github.com/newkies-git/hanja_study.git`
- 기본 브랜치: `main`

## 수행 절차

### 1. 현재 상태 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA status
```
출력 결과를 확인하여 변경된 파일 목록을 파악한다.  
변경사항이 없으면 이후 단계를 생략하고 완료 보고한다.

### 2. 현재 브랜치 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA branch --show-current
```

### 3. 커밋 메시지 결정
사용자가 커밋 메시지를 제공하지 않은 경우,  
작업 내용을 기반으로 아래 **Conventional Commits** 형식으로 자동 생성한다.

```
<type>(<scope>): <subject>

<body>  ← 선택사항, 주요 변경 내용 요약
```

**type 선택 기준:**

| type | 사용 시점 |
|------|-----------|
| `feat` | 새 기능 추가 |
| `refactor` | 기능 변경 없이 코드 구조 개선 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `chore` | 빌드·설정·의존성 변경 |
| `style` | 코드 포맷·명명 규칙만 변경 |
| `test` | 테스트 추가·수정 |

**scope 예시:** `flutter`, `docs`, `python`, `pubspec`, `uiux`

**subject 규칙:**
- 50자 이내, 현재형 동사
- 마침표 없음

**예시:**
```
refactor(flutter): split main.dart into feature-layer architecture

- Separated 1,976-line main.dart into 25 focused files
- Applied OOP naming conventions (isSelected, _passwordController, etc.)
- Added Riverpod, go_router, Drift, Dio, flutter_svg packages
```

### 4. 스테이징 및 커밋
사용자가 커밋 범위를 별도로 지정하지 않으면 전체 변경사항을 스테이징한다.

```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA add -A
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA commit -m "<커밋 메시지>"
```

### 5. Push
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA push origin <현재 브랜치>
```

### 6. 완료 확인
// turbo
```bash
git -C /Users/yutaek/zWorkSpace/zBasis/HANJA log --oneline -5
```
최근 5개 커밋을 출력하여 푸시가 정상 반영되었는지 확인한다.

## 주의사항

> [!CAUTION]
> `main` 브랜치에 직접 커밋·푸시를 허용하지 않으려면 브랜치 보호 규칙을 설정하라.  
> 기능 개발 시에는 `feat/<작업명>` 브랜치를 생성하여 PR 방식으로 병합하는 것을 권장한다.

> [!NOTE]
> 충돌(conflict)이 발생하면 `git pull --rebase origin <브랜치>` 후 재시도한다.

## 관련 워크플로우

- `/sync_docs` — 커밋 전에 먼저 실행하여 docs 문서를 최신화한다.
