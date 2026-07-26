# 어드민 백오피스 Firebase App Check (reCAPTCHA v3) 연동 워크스루

## 1. 개요
Firebase Console 상에서 어드민 웹 앱(`chusa1718-admin`)에 **App Check (reCAPTCHA v3)**가 활성화된 환경에 맞춰, [`admin/webapp`](../admin/webapp/README.md) 소스코드 내에 `firebase/app-check` SDK(`initializeAppCheck` & `ReCaptchaV3Provider`) 활성화 로직을 수립하고 인프라 설정을 완료했습니다.

---

## 2. 주요 연동 내역

1. **`admin/webapp/src/firebase.ts`**:
   - `firebase/app-check` 패키지의 `initializeAppCheck` 및 `ReCaptchaV3Provider` 추가
   - `VITE_FIREBASE_APP_CHECK_KEY` 또는 `VITE_RECAPTCHA_V3_SITE_KEY` 환경 변수 읽기 처리
   - 개발 환경(`import.meta.env.DEV`)에서는 `FIREBASE_APPCHECK_DEBUG_TOKEN` 활성화
2. **`admin/webapp/.env.example`**:
   - `VITE_FIREBASE_APP_CHECK_KEY=` 규격 환경 변수 문서화
3. **`docs/SPEC-admin.md`**:
   - 어드민 백오피스 기술 스택 및 보안 명세에 App Check (reCAPTCHA v3) 명시

---

## 3. Vercel 배포 후 설정 가이드 (체크리스트)

1. **Google reCAPTCHA Console**:
   - [reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin) 접속 $\rightarrow$ reCAPTCHA v3 Key에 `chusa1817-admin.vercel.app` 도메인 추가 등록
2. **Vercel Environment Variables**:
   - Vercel Dashboard Settings $\rightarrow$ `VITE_FIREBASE_APP_CHECK_KEY` (Site Key) 추가
   - Vercel **Redeploy (재배포)** 실행

---

## 4. 검증 결과
- **Vitest 유닛 테스트**: **14 / 14 Passed (100% 통과)**
- **Vite 프로덕션 빌드**: **`built in 1.13s` (0에러 성공)**
