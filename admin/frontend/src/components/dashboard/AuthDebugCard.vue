<script setup lang="ts">
import type { IdTokenResult, User } from 'firebase/auth';

defineProps<{
  firebaseInitError: string | null | undefined;
  currentUser: User | null;
  tokenResult: IdTokenResult | null;
  tokenError: string;
  isAdminClaim: boolean;
}>();

const emit = defineEmits<{
  (e: 'refreshToken', force: boolean): void;
}>();
</script>

<template>
  <div class="rounded-3xl bg-white/70 backdrop-blur-xl shadow-ambient p-5">
    <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
      <div class="space-y-1">
        <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Authentication</div>
        <div class="text-sm">
          <span class="text-on-surface-variant">Auth</span>:
          <span v-if="currentUser" class="font-semibold">{{ currentUser.email ?? currentUser.uid }}</span>
          <span v-else class="text-on-surface-variant">로그인 사용자 없음</span>
        </div>
        <div v-if="tokenResult" class="text-sm">
          <span class="text-on-surface-variant">admin claim</span>:
          <span :class="isAdminClaim ? 'text-emerald-700 font-bold' : 'text-error font-bold'">
            {{ isAdminClaim ? 'true' : 'false' }}
          </span>
          <span class="text-on-surface-variant/60 px-2">•</span>
          <span class="text-on-surface-variant">exp</span>: {{ tokenResult.expirationTime }}
        </div>
        <div v-if="tokenError" class="text-sm text-error whitespace-pre-line">{{ tokenError }}</div>
        <div class="text-[11px] text-on-surface-variant mt-2">
          write: <span class="font-mono">request.auth.token.admin == true</span>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <button
          class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors"
          @click="emit('refreshToken', false)"
        >
          토큰 확인
        </button>
        <button
          class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors"
          @click="emit('refreshToken', true)"
        >
          토큰 강제 갱신
        </button>
      </div>
    </div>
    <div v-if="firebaseInitError" class="mt-4 text-sm text-tertiary bg-tertiary/10 rounded-2xl p-4">
      {{ firebaseInitError }}
    </div>
  </div>
</template>

