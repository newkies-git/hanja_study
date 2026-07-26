import { initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";
import {
  initializeAppCheck,
  ReCaptchaV3Provider,
  type AppCheck,
} from "firebase/app-check";

/** Vite env: 공백·따옴표로 인해 빈 값으로 오인되는 경우 방지 */
function normalizeViteEnvString(v: unknown): string {
  if (v === undefined || v === null) return "";
  let s = String(v).trim();
  if (
    (s.startsWith('"') && s.endsWith('"')) ||
    (s.startsWith("'") && s.endsWith("'"))
  ) {
    s = s.slice(1, -1).trim();
  }
  return s;
}

function readFirebaseWebClientConfigOrNull() {
  const e = import.meta.env;
  const apiKey = normalizeViteEnvString(e.VITE_FIREBASE_API_KEY);
  const authDomain = normalizeViteEnvString(e.VITE_FIREBASE_AUTH_DOMAIN);
  const projectId = normalizeViteEnvString(e.VITE_FIREBASE_PROJECT_ID);
  const storageBucket = normalizeViteEnvString(e.VITE_FIREBASE_STORAGE_BUCKET);
  const messagingSenderId = normalizeViteEnvString(e.VITE_FIREBASE_MESSAGING_SENDER_ID);
  const appId = normalizeViteEnvString(e.VITE_FIREBASE_APP_ID);

  if (!apiKey || !authDomain || !projectId) {
    return null;
  }

  return {
    apiKey,
    authDomain,
    projectId,
    storageBucket: storageBucket || undefined,
    messagingSenderId: messagingSenderId || undefined,
    appId: appId || undefined,
  };
}

let firebaseApp: FirebaseApp | null = null;
let firebaseAuth: Auth | null = null;
let firestoreDatabase: Firestore | null = null;
let firebaseAppCheck: AppCheck | null = null;

export function isFirebaseConfigured(): boolean {
  return readFirebaseWebClientConfigOrNull() !== null;
}

export function getFirebaseApp(): FirebaseApp {
  if (!firebaseApp) {
    const firebaseWebClientConfig = readFirebaseWebClientConfigOrNull();
    if (!firebaseWebClientConfig) {
      throw new Error("Firebase 환경 변수가 설정되지 않았습니다. .env.example 참고.");
    }
    firebaseApp = initializeApp(firebaseWebClientConfig);
    initAppCheckIfConfigured(firebaseApp);
  }
  return firebaseApp;
}

/** Firebase App Check (reCAPTCHA v3 / Debug) 초기화 */
function initAppCheckIfConfigured(app: FirebaseApp): void {
  if (typeof window === "undefined" || firebaseAppCheck) return;

  if (import.meta.env.DEV) {
    // 로컬 개발 환경(localhost)에서 디버그 토큰 허용
    (self as unknown as Record<string, unknown>).FIREBASE_APPCHECK_DEBUG_TOKEN = true;
  }

  const siteKey = normalizeViteEnvString(
    import.meta.env.VITE_FIREBASE_APP_CHECK_KEY ||
      import.meta.env.VITE_RECAPTCHA_V3_SITE_KEY,
  );

  if (!siteKey) return;

  try {
    firebaseAppCheck = initializeAppCheck(app, {
      provider: new ReCaptchaV3Provider(siteKey),
      isTokenAutoRefreshEnabled: true,
    });
  } catch (error) {
    console.warn("Firebase App Check 초기화 실패:", error);
  }
}

export function getFirebaseAuth(): Auth {
  if (!firebaseAuth) {
    firebaseAuth = getAuth(getFirebaseApp());
  }
  return firebaseAuth;
}

export function getFirestoreDb(): Firestore {
  if (!firestoreDatabase) {
    firestoreDatabase = getFirestore(getFirebaseApp());
  }
  return firestoreDatabase;
}
