<script setup lang="ts">
import { ref, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { isFirebaseConfigured } from "@/firebase";

const auth = useAuthStore();
const route = useRoute();
const router = useRouter();

const email = ref("");
const password = ref("");
const error = ref<string | null>(null);
const loading = ref(false);

const configured = computed(() => isFirebaseConfigured());

async function onSubmit() {
  error.value = null;
  loading.value = true;
  try {
    await auth.login(email.value.trim(), password.value);
    const redirect = (route.query.redirect as string) || "/";
    await router.replace(redirect);
  } catch (e) {
    error.value =
      e instanceof Error ? e.message : "로그인에 실패했습니다.";
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center bg-surface px-4">
    <div class="card-surface w-full max-w-md">
      <h1 class="font-display text-2xl font-semibold text-onSurface">
        HANJA Admin
      </h1>
      <p class="mt-1 text-sm text-onSurface-variant">
        Firebase Auth 이메일 계정으로 로그인합니다. 쓰기 작업은
        <code class="rounded bg-surface-low px-1 text-xs">admin</code> 커스텀 클레임이 필요합니다.
      </p>

      <div
        v-if="!configured"
        class="mt-6 rounded-lg bg-amber-50 p-4 text-sm text-amber-900"
      >
        <p class="font-medium">Firebase 미설정</p>
        <p class="mt-1 text-onSurface-variant">
          <code class="text-xs text-onSurface">admin/frontend/.env</code>를 만들고
          <code class="text-xs text-onSurface">.env.example</code> 값을 채우세요.
        </p>
      </div>

      <form v-else class="mt-8 space-y-4" @submit.prevent="onSubmit">
        <div>
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >이메일</label
          >
          <input
            v-model="email"
            type="email"
            autocomplete="username"
            required
            class="input-minimal"
            placeholder="you@example.com"
          />
        </div>
        <div>
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >비밀번호</label
          >
          <input
            v-model="password"
            type="password"
            autocomplete="current-password"
            required
            class="input-minimal"
          />
        </div>
        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <button type="submit" class="btn-primary w-full" :disabled="loading">
          {{ loading ? "처리 중…" : "로그인" }}
        </button>
      </form>
    </div>
  </div>
</template>
