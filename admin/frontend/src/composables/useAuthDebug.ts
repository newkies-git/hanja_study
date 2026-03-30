import { computed, ref } from 'vue';
import { getIdToken, getIdTokenResult, type IdTokenResult, type User } from 'firebase/auth';
import type { Auth } from 'firebase/auth';

export function useAuthDebug(auth: Auth | null | undefined) {
  const currentUser = ref<User | null>(null);
  const tokenResult = ref<IdTokenResult | null>(null);
  const tokenError = ref('');

  const isAdminClaim = computed(() => tokenResult.value?.claims?.admin === true);

  async function refreshToken(force = false) {
    tokenError.value = '';
    tokenResult.value = null;
    currentUser.value = auth?.currentUser ?? null;
    if (!currentUser.value) return;
    try {
      if (force) await getIdToken(currentUser.value, true);
      tokenResult.value = await getIdTokenResult(currentUser.value);
    } catch (e: any) {
      tokenError.value = e?.message || String(e);
    }
  }

  return {
    currentUser,
    tokenResult,
    tokenError,
    isAdminClaim,
    refreshToken,
  };
}

