# 로그인 및 빈 로컬 DB 동기화 순서 제어 워크스루

## 1. 개요
사용자 로그인 인증 완료 후, 로컬 사전 DB가 비어있는 상태(한자 0건)일 경우 **Firestore 마스터 데이터 동기화를 우선 완료한 뒤 메인 앱 화면을 진입**하도록 실행 순서를 보완했습니다.

---

## 2. 변경된 동기화 & 로그인 제어 흐름

```mermaid
graph TD
    START[사용자 로그인 / 게스트 시작] --> AUTH[Firebase Auth 인증 완료]
    AUTH --> CHECK{로컬 DB 사전 데이터 존재 여부}

    CHECK -->|사전 0건: 비어있음| SPLASH[전면 동기화 스플래시 화면 유지]
    SPLASH --> SYNC[Firestore 마스터 데이터 수신 및 로컬 DB 저장]
    SYNC --> MAIN[메인 앱 화면 진입: 1,817자 즉시 표시]

    CHECK -->|사전 데이터 존재| MAIN_DIRECT[메인 앱 화면 즉시 진입]
    MAIN_DIRECT --> BG_SYNC[백그라운드 차분 동기화]
```

---

## 3. 주요 수정 내역

- **`lib/core/firebase/initial_content_sync.dart`**:
  - `hanjaRepositoryProvider.fetchTotalCount()` 기반 초기 데이터 존재 여부 검사
  - 0건일 경우 전면 에디토리얼 동기화 스플래시 UI 표출 및 `syncIfNeeded()` 완료 대기
  - 데이터 동기화 완수 후 `widget.child` 메인 화면으로 전이

---

## 4. 검증 결과
- **Flutter 테스트 수트**: **16 / 16 Passed (100% 통과)**
