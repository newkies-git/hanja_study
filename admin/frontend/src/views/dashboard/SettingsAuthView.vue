<script setup lang="ts">
import { useAuthStore } from "@/stores/auth";

const auth = useAuthStore();
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="font-display text-2xl font-semibold text-onSurface">
        인증 · 클레임
      </h1>
      <p class="mt-1 text-sm text-onSurface-variant">
        Firestore 쓰기는 <code class="rounded bg-surface-low px-1">request.auth.token.admin == true</code>
        일 때만 허용됩니다. 클레임 부여는
        <code class="rounded bg-surface-low px-1">admin/python/set_firebase_custom_claims.py</code>
        를 사용합니다.
      </p>
    </div>

    <div class="card-surface max-w-xl space-y-4">
      <template v-if="auth.user">
        <div>
          <p class="text-xs font-medium text-onSurface-variant">UID</p>
          <p class="mt-0.5 font-mono text-sm">{{ auth.user.uid }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-onSurface-variant">이메일</p>
          <p class="mt-0.5 text-sm">{{ auth.user.email ?? "—" }}</p>
        </div>
        <div>
          <p class="text-xs font-medium text-onSurface-variant">admin 클레임</p>
          <p class="mt-0.5">
            <span
              v-if="auth.adminClaim === true"
              class="rounded-full bg-primary/10 px-2 py-0.5 text-sm font-medium text-primary"
              >true</span
            >
            <span
              v-else-if="auth.adminClaim === false"
              class="rounded-full bg-surface-low px-2 py-0.5 text-sm text-onSurface-variant"
              >false (쓰기 불가)</span
            >
            <span v-else class="text-sm text-onSurface-variant">확인 중…</span>
          </p>
        </div>
        <p v-if="auth.tokenError" class="text-sm text-red-600">
          {{ auth.tokenError }}
        </p>
        <button type="button" class="btn-secondary text-sm" @click="auth.refreshClaims">
          토큰 새로고침 (클레임 반영)
        </button>
      </template>
      <p v-else class="text-onSurface-variant">로그인 정보가 없습니다.</p>
    </div>
  </div>
</template>
