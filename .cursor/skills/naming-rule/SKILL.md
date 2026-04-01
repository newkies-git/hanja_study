---
name: naming-rule
description: >-
  Applies shared naming conventions for identifiers: intent-clear names, verb-led
  functions, noun-led types/variables, question-shaped booleans, avoid
  abbreviations, project-wide consistency for synonyms (e.g. fetch vs get). Use
  when writing or reviewing code, renaming symbols, refactoring, or when the
  user asks for naming rules, 네이밍, or 식별자 규칙.
---

# 네이밍 규칙 (공통 핵심)

새 코드·리네임·리뷰 시 아래를 우선 적용한다. 프로젝트에 이미 문서화된 규칙이 있으면 그것을 덮어쓴다.

## 1. 의도를 드러내라

행동·도메인·범위가 한눈에 보이게 짓는다.

- 좋음: `fetchUserById`, `mergeStrokePayloadIntoExisting`, `basisDocumentId`
- 나쁨: `getData`, `handle`, `temp`, `info`, `doStuff`

## 2. 동사로 시작하라 (함수·메서드)

동작이 이름의 첫 어휘가 되게 한다.

- 예: `saveProfile`, `validateForm`, `handleSubmit`, `loadPaginatedBases`
- 예외: 관용적 술어/형용사 시작도 허용: `isValidEmail` (bool 규칙과 함께), `toFirestoreMap` (변환)

## 3. 명사로 시작하라 (클래스·타입·일반 변수·상수 객체)

“무엇”인지가 먼저 온다.

- 클래스/서비스: `UserService`, `FirestoreStrokeRepository`
- 변수: `itemCount`, `selectedBasisId`, `uploadQueue`
- React/Vue 컴포넌트: PascalCase 유지 (`BasisFormModal`)

## 4. bool은 질문형

상태·가능·포함 여부를 읽는 문장처럼.

- 접두: `is*`, `has*`, `can*`, `should*`, `needs*`
- 예: `isLoading`, `hasError`, `canSubmit`, `isAdmin`

`flag`, `ok`, `check` 단독 사용은 피한다.

## 5. 약어를 피하라

팀에서 통용되는 소수(`id`, `url`, `http` 등)만 예외로 두고, 의미 약어·난해한 축약은 쓰지 않는다.

- 좋음: `userAccount`, `documentPath`
- 나쁨: `usrAcc`, `docPth`, `btnClk` (이벤트 핸들러라도 `handlePrimaryClick` 식으로 풀어 쓴다)

## 6. 일관성 유지 (동의어 하나로)

같은 의미에는 같은 동사·같은 패턴을 쓴다.

- `fetch*` vs `get*`, `load*` vs `retrieve*`: **프로젝트에서 하나를 정하고 통일**
- 비동기면 이름에 드러내거나(예: `fetch*`, `load*`) 팀 컨벤션에 맞출 것
- 새 파일을 추가할 때 기존 모듈의 접두어·접미어를 먼저 훑고 맞춘다

## 리뷰·제안 시

이름만 바꿀 때는 공개 API·직렬화 필드·외부 스키마와의 계약이 깨지지 않는지 확인한다. 깨질 수 있으면 리네임 대신 별칭·마이그레이션 계획을 짚는다.

## 한 줄 요약

**의도·역할이 드러나게, 함수는 동사·값·타입은 명사·bool은 질문형·난해한 약어 금지·팀에서 정한 동의어 하나로 통일.**
