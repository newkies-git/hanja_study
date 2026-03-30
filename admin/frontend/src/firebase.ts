import { initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";

type Env = {
  VITE_FIREBASE_API_KEY?: string;
  VITE_FIREBASE_AUTH_DOMAIN?: string;
  VITE_FIREBASE_PROJECT_ID?: string;
  VITE_FIREBASE_STORAGE_BUCKET?: string;
  VITE_FIREBASE_MESSAGING_SENDER_ID?: string;
  VITE_FIREBASE_APP_ID?: string;
  VITE_FIREBASE_MEASUREMENT_ID?: string;
};

const env = import.meta.env as unknown as Env;

const firebaseConfig = {
  apiKey: env.VITE_FIREBASE_API_KEY,
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: env.VITE_FIREBASE_APP_ID,
  measurementId: env.VITE_FIREBASE_MEASUREMENT_ID,
};

function _isConfigReady() {
  return Boolean(
    firebaseConfig.apiKey &&
      firebaseConfig.authDomain &&
      firebaseConfig.projectId &&
      firebaseConfig.appId,
  );
}

export const firebaseConfigReady = _isConfigReady();
export const firebaseInitError: string | null = firebaseConfigReady
  ? null
  : "Firebase 설정이 없습니다. admin/frontend/.env를 만들고 VITE_FIREBASE_* 값을 채우세요.";

export const app: FirebaseApp | null = (() => {
  if (!firebaseConfigReady) return null;
  try {
    return initializeApp(firebaseConfig);
  } catch (e: any) {
    // 중복 초기화/잘못된 설정 등으로 앱 전체가 죽지 않게 방어
    console.error("[admin] Firebase initializeApp failed:", e);
    return null;
  }
})();

export const auth: Auth | null = app ? getAuth(app) : null;
export const db: Firestore | null = app ? getFirestore(app) : null;
