<script setup lang="ts">
import { computed } from "vue";
import { RouterLink, useRoute } from "vue-router";
import { isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { isLocalApiEnabled } from "@/config/localApi";

const auth = useAuthStore();
const route = useRoute();
const showAdminGateNotice = computed(() => route.query.needAdmin === "1");
/** 라우터가 로컬 전용 경로에서 튕겨 낼 때만(쿼리만 남은 오탐 방지) */
const showLocalApiDisabledNotice = computed(
  () => route.query.localApi === "0" && !isLocalApiEnabled,
);
const firebaseConfigured = computed(() => isFirebaseConfigured());
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute -right-10 -top-12 h-32 w-32 rounded-full bg-primary/[0.08] blur-2xl"
        aria-hidden="true"
      />
      <div
        class="relative flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="flex min-w-0 items-center gap-3">
          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-lg font-bold text-white shadow-md shadow-primary/25"
            aria-hidden="true"
          >
            板
          </div>
          <div class="min-w-0 flex-1">
            <h1 class="page-title">대시보드</h1>
          </div>
        </div>
        <div class="flex flex-wrap gap-2 sm:shrink-0 sm:justify-end">
          <RouterLink
            :to="{ name: 'firestore-manage' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            Firestore 관리
          </RouterLink>
          <RouterLink
            v-if="isLocalApiEnabled"
            :to="{ name: 'sqlite-manage' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            로컬 DB
          </RouterLink>
          <RouterLink
            v-if="isLocalApiEnabled"
            :to="{ name: 'db-sync' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            DB 동기화
          </RouterLink>
          <RouterLink
            :to="{ name: 'settings-auth' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            인증
          </RouterLink>
        </div>
      </div>
    </section>

    <div
      v-if="showLocalApiDisabledNotice"
      class="rounded-xl border border-outline-variant/80 bg-surface-low px-4 py-3 text-sm text-onSurface-variant shadow-sm"
    >
      이 배포에서는 로컬 SQLite API를 사용하지 않습니다. 로컬 DB·DB 동기화·채번은
      <code class="rounded bg-surface-lowest px-1.5 py-0.5 font-mono text-xs">VITE_USE_LOCAL_API=true</code>
      로 빌드하고 <code class="rounded bg-surface-lowest px-1.5 py-0.5 font-mono text-xs">server.js</code>를 실행한 뒤 접속하세요.
    </div>

    <div
      v-if="auth.isAuthReady && !auth.isAdmin"
      class="space-y-2 rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950 shadow-sm"
    >
      <p v-if="showAdminGateNotice">
        서버DB 관리·로컬 DB·DB 동기화 는 <strong class="font-medium">admin</strong> 클레임이 있는 계정만 열 수 있습니다.
      </p>
      <p>
        <strong class="font-medium">admin</strong> 클레임이 없으면 Firestore 쓰기도 거절됩니다.
        클레임 부여 후 <strong class="font-medium">설정 → 인증</strong>에서 토큰을 갱신하세요.
      </p>
    </div>

    <div
      v-if="!firebaseConfigured"
      class="rounded-xl border border-outline-variant/70 bg-surface-low px-4 py-3 text-sm text-onSurface-variant"
    >
      Firebase가 설정되지 않았습니다. <code class="rounded bg-surface-lowest px-1.5 py-0.5 font-mono text-xs">.env</code>를 확인하세요.
    </div>

  </div>
</template>
