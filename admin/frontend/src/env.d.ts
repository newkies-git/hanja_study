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
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
