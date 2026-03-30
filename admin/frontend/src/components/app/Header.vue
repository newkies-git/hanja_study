<script setup lang="ts">
import { useRouter } from 'vue-router';
import { signOut } from 'firebase/auth';
import { auth } from '../../firebase';
import { useAuthDebug } from '../../composables/useAuthDebug';
import { useAppOptionStore } from '../../stores/app-option';

const router = useRouter();
const appOption = useAppOptionStore();
const { currentUser } = useAuthDebug(auth);
currentUser.value = auth?.currentUser ?? null;

async function logout() {
  if (!auth) {
    await router.push('/login');
    return;
  }
  await signOut(auth);
  router.push('/login');
}
</script>

<template>
  <div class="app-header sticky top-0 z-40 bg-surface/80 backdrop-blur-xl">
    <div class="max-w-7xl mx-auto px-6 lg:px-10">
      <div class="flex h-16 items-center justify-between">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="md:hidden text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors"
            @click="appOption.appSidebarMobileToggled = !appOption.appSidebarMobileToggled"
          >
            메뉴
          </button>
          <span class="material-symbols-outlined text-primary hidden md:inline">history_edu</span>
          <div class="font-headline font-extrabold tracking-tight italic">Hanja Archive Admin</div>
        </div>
        <div class="flex items-center gap-3">
          <span class="hidden sm:inline text-xs text-on-surface-variant">{{ currentUser?.email ?? 'Admin' }}</span>
          <button
            class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors"
            @click="logout"
          >
            로그아웃
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

