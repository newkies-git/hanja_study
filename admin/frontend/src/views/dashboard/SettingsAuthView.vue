<script setup lang="ts">
import { computed } from "vue";
import { RouterLink } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { isFirebaseConfigured } from "@/firebase";

const auth = useAuthStore();
const firebaseConfigured = computed(() => isFirebaseConfigured());
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-visible rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute inset-0 overflow-hidden rounded-xl"
        aria-hidden="true"
      >
        <div
          class="absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl"
        />
      </div>
      <div
        class="relative flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between sm:gap-3"
      >
        <div class="flex min-w-0 items-center gap-2.5 sm:gap-3">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-sm font-bold text-white shadow-md shadow-primary/20 sm:h-10 sm:w-10 sm:text-base"
            aria-hidden="true"
          >
            認
          </div>
          <div class="min-w-0 flex-1">
            <h1 class="page-title">
              <span class="page-title-kicker">Admin · Firebase Auth</span>인증 · 클레임
            </h1>
          </div>
        </div>
        <div
          class="flex w-full flex-col gap-2 sm:w-auto sm:shrink-0 sm:flex-row sm:flex-wrap sm:justify-end"
        >
          <RouterLink
            :to="{ name: 'firestore-manage' }"
            class="btn-secondary inline-flex min-h-[2.75rem] items-center justify-center px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
          >
            서버DB 관리
          </RouterLink>
          <RouterLink
            :to="{ name: 'sqlite-manage' }"
            class="btn-secondary inline-flex min-h-[2.75rem] items-center justify-center px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
          >
            로컬 DB
          </RouterLink>
        </div>
      </div>
    </section>

    <p class="truncate text-xs text-onSurface-variant">
      Firestore 쓰기는 JWT
      <code
        class="mx-0.5 rounded border border-outline-variant/50 bg-surface-low px-1 py-px font-mono text-[10px] text-primary"
      >admin</code>
      클레임이 필요합니다. 부여 후 아래에서 토큰을 갱신하세요.
    </p>

    <div
      v-if="!firebaseConfigured"
      class="rounded-xl border border-outline-variant/70 bg-surface-low px-4 py-3 text-sm text-onSurface-variant shadow-sm"
    >
      Firebase가 설정되지 않았습니다.
      <code class="rounded-md bg-surface-lowest px-1.5 py-0.5 font-mono text-xs">.env</code>
      를 확인하세요.
    </div>

    <div
      v-else-if="auth.isAuthReady && auth.isAuthenticated && !auth.isAdmin"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm leading-relaxed text-amber-950 shadow-sm"
    >
      <strong class="font-medium">admin</strong> 클레임이 없으면 Firestore 쓰기가 거절됩니다.
      <code
        class="mx-0.5 rounded-md border border-amber-300/60 bg-white/90 px-1.5 py-0.5 font-mono text-xs text-amber-900"
      >admin/python/set_firebase_custom_claims.py</code>
      로 부여한 뒤
      <strong class="font-medium">토큰 새로고침</strong>을 눌러 반영하세요.
    </div>

    <!-- 본문 카드 -->
    <div
      class="overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02] sm:rounded-2xl"
    >
      <div
        class="border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/80 to-surface-lowest px-4 py-3 sm:px-5"
      >
        <h2 class="truncate whitespace-nowrap font-display text-sm font-semibold tracking-tight text-onSurface sm:text-base">
          <span class="page-title-kicker">현재 세션</span>로그인 계정 · 클레임 상태
        </h2>
      </div>

      <div class="p-4 sm:p-6">
        <div
          v-if="!auth.isAuthReady"
          class="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-outline-variant/70 bg-surface-low/40 py-14"
        >
          <div class="flex gap-1.5" aria-hidden="true">
            <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
            <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
            <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
          </div>
          <p class="text-sm font-medium text-onSurface-variant">인증 상태 확인 중…</p>
        </div>

        <template v-else-if="auth.user">
          <dl class="space-y-0 divide-y divide-outline-variant/60">
            <div class="grid gap-1 py-3 first:pt-0 sm:grid-cols-[7rem_1fr] sm:items-baseline sm:gap-4 sm:py-3.5">
              <dt class="text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant">
                UID
              </dt>
              <dd class="min-w-0 break-all font-mono text-sm text-onSurface">
                {{ auth.user.uid }}
              </dd>
            </div>
            <div class="grid gap-1 py-3 sm:grid-cols-[7rem_1fr] sm:items-baseline sm:gap-4 sm:py-3.5">
              <dt class="text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant">
                이메일
              </dt>
              <dd class="min-w-0 break-words text-sm text-onSurface">
                {{ auth.user.email ?? "—" }}
              </dd>
            </div>
            <div class="grid gap-1 py-3 sm:grid-cols-[7rem_1fr] sm:items-center sm:gap-4 sm:py-3.5">
              <dt class="text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant">
                admin 클레임
              </dt>
              <dd class="flex flex-wrap items-center gap-2">
                <span
                  v-if="auth.adminClaim === true"
                  class="inline-flex items-center rounded-full border border-primary/25 bg-primary/[0.12] px-2.5 py-1 text-xs font-semibold text-primary shadow-sm"
                >true · 쓰기 가능</span>
                <span
                  v-else-if="auth.adminClaim === false"
                  class="inline-flex items-center rounded-full border border-outline-variant/70 bg-surface-low px-2.5 py-1 text-xs font-medium text-onSurface-variant"
                >false · Firestore 쓰기 불가</span>
                <span
                  v-else
                  class="text-sm text-onSurface-variant"
                >확인 중…</span>
              </dd>
            </div>
          </dl>

          <div
            v-if="auth.tokenError"
            class="mt-4 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900"
          >
            {{ auth.tokenError }}
          </div>

          <div class="mt-6 flex flex-col gap-2 border-t border-outline-variant/50 pt-5 sm:flex-row sm:items-center sm:justify-between">
            <p class="text-xs leading-relaxed text-onSurface-variant">
              규칙 조건:
              <code
                class="rounded-md border border-outline-variant/50 bg-surface-low px-1.5 py-0.5 font-mono text-[10px] text-primary"
              >request.auth.token.admin == true</code>
            </p>
            <button
              type="button"
              class="btn-primary w-full shrink-0 px-4 py-2.5 text-sm shadow-md shadow-primary/15 sm:w-auto"
              @click="auth.refreshClaims"
            >
              토큰 새로고침 (클레임 반영)
            </button>
          </div>
        </template>

        <div
          v-else
          class="rounded-xl border border-dashed border-outline-variant/80 bg-surface-low/40 px-4 py-12 text-center"
        >
          <p class="text-sm font-medium text-onSurface">로그인 정보가 없습니다</p>
          <p class="mt-2 text-sm text-onSurface-variant">
            관리자 콘솔을 쓰려면 로그인하세요.
          </p>
          <RouterLink
            :to="{ name: 'login', query: { redirect: $route.fullPath } }"
            class="btn-primary mt-5 inline-flex items-center justify-center px-5 py-2.5 text-sm shadow-md shadow-primary/15"
          >
            로그인으로 이동
          </RouterLink>
        </div>
      </div>
    </div>

    <!-- 참고 -->
    <div
      class="rounded-xl border border-outline-variant/60 bg-surface-low/60 px-4 py-3 text-xs leading-relaxed text-onSurface-variant sm:px-5"
    >
      <p>
        클레임 부여는 프로젝트에서 제공하는 스크립트
        <code
          class="rounded-md border border-outline-variant/50 bg-surface-lowest px-1.5 py-0.5 font-mono text-[11px] text-primary"
        >admin/python/set_firebase_custom_claims.py</code>
        를 사용합니다. 변경 후 반드시 이 페이지에서 토큰을 갱신해야 Firestore에 반영됩니다.
      </p>
    </div>
  </div>
</template>
