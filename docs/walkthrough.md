# 저장소 전반 Firebase App Check 아키텍처 및 적용 현황 워크스루

## 1. 개요
**HANJA** 프로젝트 저장소 전체(`client/chusa1817` 클라이언트 앱 및 `admin/webapp` 어드민 백오피스)의 **Firebase App Check 적용 현황**을 정밀 전수 점검하고, 프로덕션 및 개발 모드(`localhost`)에서의 안정적인 작동을 위한 구성을 완료했습니다.

---

## 2. 모듈별 App Check 적용 아키텍처

```mermaid
graph TD
    FIREBASE[(Cloud Firestore / Auth)] --> APP_CHECK_GATEWAY{Firebase App Check Gateway}

    subgraph CLIENT [Flutter 클라이언트 앱 (client/chusa1817)]
        FLUTTER_BOOT[firebase_bootstrap.dart] --> FLUTTER_CHECK{kDebugMode}
        FLUTTER_CHECK -->|Prod Android| PLAY_INTEGRITY[AndroidPlayIntegrityProvider]
        FLUTTER_CHECK -->|Prod iOS| DEVICE_CHECK[AppleDeviceCheckProvider]
        FLUTTER_CHECK -->|Debug| ANDROID_APPLE_DEBUG[AndroidDebugProvider / AppleDebugProvider]
    end

    subgraph ADMIN [Vue 3 어드민 백오피스 (admin/webapp)]
        VUE_BOOT[src/firebase.ts] --> VUE_CHECK{import.meta.env.DEV}
        VUE_CHECK -->|Prod Vercel| RECAPTCHA[ReCaptchaV3Provider]
        VUE_CHECK -->|Dev Localhost| CUSTOM_DEBUG[CustomProvider & DEBUG_TOKEN]
    end

    PLAY_INTEGRITY --> APP_CHECK_GATEWAY
    DEVICE_CHECK --> APP_CHECK_GATEWAY
    ANDROID_APPLE_DEBUG --> APP_CHECK_GATEWAY
    RECAPTCHA --> APP_CHECK_GATEWAY
    CUSTOM_DEBUG --> APP_CHECK_GATEWAY
```

---

## 3. 모듈별 상세 구현 현황

### 3.1 Flutter 클라이언트 앱 (`client/chusa1817/lib/core/firebase/firebase_bootstrap.dart`)
- **Android**: 프로덕션 `AndroidPlayIntegrityProvider`, 디버그 `AndroidDebugProvider`
- **iOS**: 프로덕션 `AppleDeviceCheckProvider`, 디버그 `AppleDeviceCheckProvider`
- **토큰 리프레시**: `setTokenAutoRefreshEnabled(true)` 자동 갱신
- **예외 처리**: App Check 활성화 실패 시에도 앱의 로컬 SQLite(Drift) 오프라인 학습 기능에 차질이 없도록 비동기 안전 처리

### 3.2 Vue 3 어드민 백오피스 (`admin/webapp/src/firebase.ts`)
- **프로덕션 (Vercel)**: `VITE_FIREBASE_APP_CHECK_KEY`를 이용한 `ReCaptchaV3Provider`
- **개발 모드 (`localhost`)**: `FIREBASE_APPCHECK_DEBUG_TOKEN = true` 최우선 설정 및 `CustomProvider` 디버그 폴백 적용하여 reCAPTCHA 400 에러 및 스로틀링 완벽 차단

---

## 4. 관련 문서 및 스펙 최신화 목록

| 문서 파일 | 최신화 반영 내용 |
| :--- | :--- |
| **[`admin/firestore/firestore_connect.md`](../admin/firestore/firestore_connect.md)** | Flutter/Vue 백오피스 App Check 아키텍처 및 relative 경로 최신화 |
| **[`docs/SPEC-admin.md`](SPEC-admin.md)** | Section 3.7 에 App Check reCAPTCHA v3 & CustomProvider 명세 추가 |
| **[`docs/SPEC-client.md`](SPEC-client.md)** | Play Integrity 및 DeviceCheck 연동 명세 확인 |
| **[`admin/webapp/.env.example`](../admin/webapp/.env.example)** | `VITE_FIREBASE_APP_CHECK_KEY` 변수 가이드 명시 |

---

## 5. 검증 결과
- **Flutter 테스트 수트**: **16 / 16 Passed (100% 통과)**
- **Vue Admin Vitest 수트**: **14 / 14 Passed (100% 통과)**
- **Vue Admin 프로덕션 빌드**: **`built in 1.08s` (성공)**
