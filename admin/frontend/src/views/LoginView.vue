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
  <div class="flex min-h-screen flex-col bg-surface">
    <div class="flex flex-1 items-center justify-center px-4 py-8">
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
          class="mt-6 space-y-2 rounded-lg bg-amber-50 p-4 text-sm text-amber-900"
        >
          <p class="font-medium">Firebase 미설정</p>
          <p class="text-onSurface-variant">
            <strong class="text-amber-950">로컬:</strong>
            <code class="text-xs text-onSurface">admin/frontend/.env</code>를 두고
            <code class="text-xs text-onSurface">.env.example</code>과 같은 키로
            <code class="text-xs text-onSurface">VITE_FIREBASE_*</code>를 채운 뒤
            <code class="text-xs text-onSurface">npm run dev</code>를 다시 실행하세요.
          </p>
          <p class="text-onSurface-variant">
            <strong class="text-amber-950">Vercel 등 배포:</strong>
            프로젝트 Settings → Environment Variables에 동일한
            <code class="text-xs text-onSurface">VITE_FIREBASE_API_KEY</code>,
            <code class="text-xs text-onSurface">VITE_FIREBASE_AUTH_DOMAIN</code>,
            <code class="text-xs text-onSurface">VITE_FIREBASE_PROJECT_ID</code>
            (및 선택 항목)을 넣고 재배포하세요. Root Directory가
            <code class="text-xs text-onSurface">admin/frontend</code>가 아니거나 빌드에
            <code class="text-xs text-onSurface">.env</code>가 안 실리면 여기서 채워야 합니다.
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
    <AppFooter />
  </div>
</template>
