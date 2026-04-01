<script setup lang="ts">
import { ref, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import AppFooter from "@/components/app/AppFooter.vue";
import { useAuthStore } from "@/stores/auth";
import { isFirebaseConfigured } from "@/firebase";

const auth = useAuthStore();
const route = useRoute();
const router = useRouter();

const email = ref("");
const password = ref("");
const error = ref<string | null>(null);
const isLoginSubmitting = ref(false);

const configured = computed(() => isFirebaseConfigured());

async function onSubmit() {
  error.value = null;
  isLoginSubmitting.value = true;
  try {
    await auth.login(email.value.trim(), password.value);
    const redirect = (route.query.redirect as string) || "/";
    await router.replace(redirect);
  } catch (e) {
    error.value =
      e instanceof Error ? e.message : "로그인에 실패했습니다.";
  } finally {
    isLoginSubmitting.value = false;
  }
}
</script>

<template>
  <div
    class="flex min-h-dvh flex-col bg-gradient-to-b from-surface-low/40 via-surface to-surface-low/30"
  >
    <div
      class="pointer-events-none fixed inset-0 overflow-hidden"
      aria-hidden="true"
    >
      <div
        class="absolute -left-20 top-0 h-72 w-72 rounded-full bg-primary/[0.06] blur-3xl"
      />
      <div
        class="absolute -right-16 bottom-32 h-64 w-64 rounded-full bg-primary/[0.05] blur-3xl"
      />
    </div>

    <div class="relative flex flex-1 flex-col items-center justify-center px-4 py-10 sm:py-14">
      <div class="w-full max-w-md space-y-5">
        <!-- 히어로 -->
        <section
          class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-4 py-3 shadow-float ring-1 ring-black/[0.03] sm:px-5 sm:py-3.5"
        >
          <div
            class="pointer-events-none absolute inset-0 overflow-hidden rounded-xl"
            aria-hidden="true"
          >
            <div
              class="absolute -right-6 -top-8 h-24 w-24 rounded-full bg-primary/[0.1] blur-2xl"
            />
          </div>
          <div class="relative flex items-center gap-3 sm:gap-3.5">
            <div
              class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-gradient-to-b from-primary to-primary-container font-display text-sm font-bold text-white shadow-md shadow-primary/25 sm:h-10 sm:w-10"
              aria-hidden="true"
            >
              漢
            </div>
            <div class="min-w-0 leading-tight">
              <p
                class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
              >
                Admin · Firebase Auth
              </p>
              <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
                로그인
              </h1>
              <p class="mt-0.5 text-xs text-onSurface-variant sm:text-sm">
                이메일 계정으로 로그인합니다. Firestore 쓰기는
                <code
                  class="mx-0.5 rounded-md border border-outline-variant/50 bg-white/80 px-1 py-px font-mono text-[10px] text-primary"
                >admin</code>
                클레임이 필요합니다.
              </p>
            </div>
          </div>
        </section>

        <!-- 폼 카드 -->
        <div
          class="overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest/95 shadow-[0_12px_40px_rgba(25,28,30,0.08)] ring-1 ring-black/[0.02] backdrop-blur-sm"
        >
          <div
            class="border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/90 to-surface-lowest px-4 py-3 sm:px-5"
          >
            <p class="text-[10px] font-semibold uppercase tracking-wide text-primary/90">
              계정
            </p>
            <p class="mt-0.5 font-display text-sm font-semibold text-onSurface">
              이메일 · 비밀번호
            </p>
          </div>

          <div class="p-5 sm:p-6">
            <div
              v-if="!configured"
              class="space-y-3 rounded-xl border border-amber-200/90 bg-amber-50/90 px-3 py-3 text-xs leading-relaxed text-amber-950 shadow-sm sm:text-sm"
            >
              <p class="font-semibold text-amber-950">Firebase 미설정</p>
              <p class="text-amber-900/90">
                <strong class="text-amber-950">로컬:</strong>
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >admin/frontend/.env</code>
                를 두고
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >.env.example</code>
                과 같은 키로
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >VITE_FIREBASE_*</code>
                를 채운 뒤 개발 서버를 다시 실행하세요.
              </p>
              <p class="text-amber-900/90">
                <strong class="text-amber-950">배포:</strong>
                환경 변수에
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >VITE_FIREBASE_API_KEY</code>,
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >VITE_FIREBASE_AUTH_DOMAIN</code>,
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >VITE_FIREBASE_PROJECT_ID</code>
                (및 선택 항목)을 넣고 재배포하세요. Root Directory가
                <code
                  class="mx-0.5 rounded-md border border-amber-200/80 bg-white/90 px-1 py-px font-mono text-[11px]"
                >admin/frontend</code>
                인지 확인하세요.
              </p>
            </div>

            <form v-else class="space-y-4" @submit.prevent="onSubmit">
              <div>
                <label
                  class="mb-1.5 block text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="login-email"
                >이메일</label>
                <input
                  id="login-email"
                  v-model="email"
                  type="email"
                  autocomplete="username"
                  required
                  class="input-minimal"
                  placeholder="you@example.com"
                />
              </div>
              <div>
                <label
                  class="mb-1.5 block text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="login-password"
                >비밀번호</label>
                <input
                  id="login-password"
                  v-model="password"
                  type="password"
                  autocomplete="current-password"
                  required
                  class="input-minimal"
                />
              </div>
              <div
                v-if="error"
                class="rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900"
              >
                {{ error }}
              </div>
              <button
                type="submit"
                class="btn-primary mt-2 w-full py-2.5 text-sm font-medium shadow-md shadow-primary/20 disabled:opacity-60"
                :disabled="isLoginSubmitting"
              >
                {{ isLoginSubmitting ? "처리 중…" : "로그인" }}
              </button>
            </form>
          </div>
        </div>

        <p
          v-if="configured"
          class="text-center text-[11px] leading-relaxed text-onSurface-variant"
        >
          관리자 콘솔입니다. 계정은 Firebase Authentication에서 초대·등록합니다.
        </p>
      </div>
    </div>

    <AppFooter />
  </div>
</template>
