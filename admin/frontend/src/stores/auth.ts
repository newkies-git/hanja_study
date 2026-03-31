import { defineStore } from "pinia";
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
  type User,
} from "firebase/auth";
import { ref, computed } from "vue";
import { getFirebaseAuth, isFirebaseConfigured } from "@/firebase";

export const useAuthStore = defineStore("auth", () => {
  const user = ref<User | null>(null);
  const ready = ref(false);
  const adminClaim = ref<boolean | null>(null);
  const tokenError = ref<string | null>(null);

  const isAuthenticated = computed(() => user.value !== null);
  const isAdmin = computed(() => adminClaim.value === true);

  /** JWT·Firestore 규칙과 동일하게 admin 여부 판별(문자열 true 등 흔한 변형 포함) */
  function claimIsAdmin(claims: Record<string, unknown> | undefined): boolean {
    const v = claims?.admin;
    return v === true || v === "true" || v === 1;
  }

  let unsub: (() => void) | null = null;

  function bindAuthListener() {
    if (!isFirebaseConfigured()) {
      ready.value = true;
      return;
    }
    if (unsub) return;
    const auth = getFirebaseAuth();
    unsub = onAuthStateChanged(auth, async (u) => {
      user.value = u;
      tokenError.value = null;
      adminClaim.value = null;
      if (u) {
        try {
          const token = await u.getIdTokenResult(true);
          adminClaim.value = claimIsAdmin(
            token.claims as Record<string, unknown>,
          );
        } catch (e) {
          tokenError.value =
            e instanceof Error ? e.message : "토큰을 읽을 수 없습니다.";
        }
      }
      ready.value = true;
    });
  }

  async function login(email: string, password: string) {
    if (!isFirebaseConfigured()) {
      throw new Error("Firebase가 설정되지 않았습니다.");
    }
    const auth = getFirebaseAuth();
    await signInWithEmailAndPassword(auth, email, password);
  }

  async function logout() {
    if (!isFirebaseConfigured()) return;
    await signOut(getFirebaseAuth());
  }

  async function refreshClaims() {
    if (!user.value) return;
    tokenError.value = null;
    try {
      const token = await user.value.getIdTokenResult(true);
      adminClaim.value = claimIsAdmin(
        token.claims as Record<string, unknown>,
      );
    } catch (e) {
      tokenError.value =
        e instanceof Error ? e.message : "토큰 갱신에 실패했습니다.";
    }
  }

  /**
   * Firestore 쓰기 직전에 호출. SDK가 최신 ID 토큰(커스텀 클레임 포함)을 쓰도록 강제한다.
   * 클레임을 방금 부여한 뒤 UI만 갱신되고 쓰기가 거절되는 경우에 효과적이다.
   */
  async function syncIdTokenForFirestore(): Promise<void> {
    if (!user.value) {
      throw new Error("로그인이 필요합니다.");
    }
    tokenError.value = null;
    await user.value.getIdToken(true);
    const t = await user.value.getIdTokenResult();
    adminClaim.value = claimIsAdmin(t.claims as Record<string, unknown>);
  }

  return {
    user,
    ready,
    adminClaim,
    tokenError,
    isAuthenticated,
    isAdmin,
    bindAuthListener,
    login,
    logout,
    refreshClaims,
    syncIdTokenForFirestore,
  };
});
