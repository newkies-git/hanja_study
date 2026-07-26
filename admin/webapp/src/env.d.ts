/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** 푸터 저작권에 표시할 이름·법인명 (미설정 시 "HANJA Admin") */
  readonly VITE_APP_COPYRIGHT_HOLDER?: string;
  readonly VITE_FIREBASE_API_KEY?: string;
  readonly VITE_FIREBASE_AUTH_DOMAIN?: string;
  readonly VITE_FIREBASE_PROJECT_ID?: string;
  readonly VITE_FIREBASE_STORAGE_BUCKET?: string;
  readonly VITE_FIREBASE_MESSAGING_SENDER_ID?: string;
  readonly VITE_FIREBASE_APP_ID?: string;
  /** `true` 등 — 로컬 `server.js` `/api/*` 사용(로컬 DB·동기화·채번) */
  readonly VITE_USE_LOCAL_API?: string;
  /** 로컬 API 베이스 URL(비우면 동일 오리진 `/api`, dev에서는 Vite 프록시) */
  readonly VITE_LOCAL_API_BASE_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
