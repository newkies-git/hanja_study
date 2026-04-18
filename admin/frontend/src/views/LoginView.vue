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

/** 로그인 후 이동: 앱 내부 상대 경로만 허용(오픈 리다이렉트 완화). */
function normalizeInternalRedirectPathAfterLogin(raw: unknown): string {
  const first = Array.isArray(raw) ? raw[0] : raw;
  if (typeof first !== "string") return "/";
  const path = first.trim();
  if (!path || path.includes("://") || path.includes("\\")) return "/";
  if (!path.startsWith("/") || path.startsWith("//")) return "/";
  return path;
}

async function handleLoginFormSubmit() {
  error.value = null;
  isLoginSubmitting.value = true;
  try {
    await auth.login(email.value.trim(), password.value);
    await router.replace(
      normalizeInternalRedirectPathAfterLogin(route.query.redirect),
    );
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
    class="relative flex min-h-dvh flex-col items-center justify-center overflow-hidden bg-[#fbfcfd] px-6 py-20 sm:py-28"
  >
    <!-- Pastel Background Blobs -->
    <div class="pointer-events-none absolute inset-0 overflow-hidden">
      <!-- Mint Blob -->
      <div
        class="animate-float absolute -left-1/4 -top-1/4 h-[80%] w-[80%] rounded-full bg-emerald-100/60 blur-[120px]"
      ></div>
      <!-- Lavender Blob -->
      <div
        class="animate-float-delayed absolute -right-1/4 -bottom-1/4 h-[70%] w-[70%] rounded-full bg-purple-100/50 blur-[100px]"
      ></div>
      <!-- Peach/Soft Orange Blob -->
      <div
        class="absolute left-1/2 top-1/2 h-[50%] w-[50%] -translate-x-1/2 -translate-y-1/2 rounded-full bg-orange-50/60 blur-[150px]"
      ></div>
    </div>

    <!-- Main Content -->
    <div class="relative w-full max-w-[460px] space-y-12 sm:space-y-16">
      <!-- Header Section -->
      <div class="text-center">
        <div
          class="mx-auto mb-8 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-tr from-indigo-400 to-purple-300 p-0.5 shadow-xl shadow-indigo-100 sm:h-20 sm:w-20"
        >
          <div
            class="flex h-full w-full items-center justify-center rounded-[14px] bg-white font-display text-2xl font-bold text-indigo-600 sm:text-3xl"
          >
            漢
          </div>
        </div>
        <h1
          class="mx-auto max-w-full truncate whitespace-nowrap px-1 font-display text-2xl font-extrabold tracking-tight text-slate-800 sm:text-4xl"
        >
          HANJA Admin · 로그인
        </h1>
      </div>

      <!-- Login Card -->
      <div class="glass-panel-light group relative overflow-hidden p-10 sm:p-14">
        <!-- Subtle inner glow -->
        <div
          class="pointer-events-none absolute inset-0 bg-gradient-to-br from-white/40 to-transparent opacity-0 transition-opacity duration-500 group-hover:opacity-100"
        ></div>

        <div v-if="!configured" class="space-y-6">
          <div
            class="rounded-2xl border border-amber-200 bg-amber-50/80 p-5 text-sm leading-relaxed text-amber-800 backdrop-blur-md"
          >
            <h3 class="mb-2 font-bold text-amber-700">Firebase 설정 필요</h3>
            <p>
              로그인 기능을 사용하려면 <code class="text-amber-600">.env</code> 파일에 Firebase API 키를 설정해야 합니다.
            </p>
          </div>
        </div>

        <form v-else class="relative space-y-8" @submit.prevent="handleLoginFormSubmit">
          <div class="space-y-2.5">
            <label
              for="login-email"
              class="ml-1 text-xs font-bold uppercase tracking-widest text-slate-400"
            >이메일 주소</label>
            <div class="relative">
              <input
                id="login-email"
                v-model="email"
                type="email"
                required
                placeholder="name@example.com"
                class="w-full rounded-2xl border border-slate-200 bg-white/50 px-5 py-4 text-slate-800 outline-none ring-4 ring-transparent transition-all placeholder:text-slate-400 focus:border-indigo-300 focus:bg-white focus:ring-indigo-50"
              />
            </div>
          </div>

          <div class="space-y-2.5">
            <div class="flex items-center justify-between">
              <label
                for="login-password"
                class="ml-1 text-xs font-bold uppercase tracking-widest text-slate-400"
              >비밀번호</label>
            </div>
            <div class="relative">
              <input
                id="login-password"
                v-model="password"
                type="password"
                required
                placeholder="••••••••"
                class="w-full rounded-2xl border border-slate-200 bg-white/50 px-5 py-4 text-slate-800 outline-none ring-4 ring-transparent transition-all placeholder:text-slate-400 focus:border-indigo-300 focus:bg-white focus:ring-indigo-50"
              />
            </div>
          </div>

          <div
            v-if="error"
            class="animate-in fade-in slide-in-from-top-2 rounded-2xl border border-red-200 bg-red-50/80 px-5 py-4 text-sm font-medium text-red-600"
          >
            {{ error }}
          </div>

          <button
            type="submit"
            :disabled="isLoginSubmitting"
            class="relative mt-2 w-full overflow-hidden rounded-2xl bg-indigo-500 py-4.5 text-lg font-bold text-white transition-all hover:scale-[1.02] hover:bg-indigo-600 active:scale-[0.98] disabled:opacity-50 disabled:hover:scale-100 shadow-lg shadow-indigo-200"
          >
            <span :class="{ 'opacity-0': isLoginSubmitting }">
              {{ isLoginSubmitting ? "로그인 중..." : "로그인" }}
            </span>
            <div
              v-if="isLoginSubmitting"
              class="absolute inset-0 flex items-center justify-center"
            >
              <svg
                class="h-6 w-6 animate-spin text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  class="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  stroke-width="4"
                ></circle>
                <path
                  class="opacity-75"
                  fill="currentColor"
                  d="4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
            </div>
          </button>
        </form>
      </div>

      <!-- Footer Info -->
      <p class="text-center text-sm font-medium tracking-wide text-slate-400">
        Admin Console · Authorized Access Only
      </p>
    </div>

    <!-- App Footer -->
    <div class="mt-auto pt-20">
      <AppFooter class="!bg-transparent !border-none !text-slate-400 opacity-80 hover:opacity-100 transition-opacity" />
    </div>
  </div>
</template>
