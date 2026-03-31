<script setup lang="ts">
import { RouterLink } from "vue-router";
import { useAppOptionStore } from "@/stores/app-option";
import { useAuthStore } from "@/stores/auth";

const appOption = useAppOptionStore();
const auth = useAuthStore();

async function signOut() {
  await auth.logout();
}
</script>

<template>
  <header
    class="sticky top-0 z-30 flex h-14 items-center gap-3 border-b border-outline-variant bg-surface-lowest/90 px-4 shadow-float backdrop-blur-md sm:h-16 sm:px-6 lg:px-8"
  >
    <button
      type="button"
      class="flex h-10 w-10 flex-col items-center justify-center gap-1 rounded-md bg-surface-low lg:flex"
      aria-label="사이드바 접기"
      @click="appOption.toggleSidebarCollapsed"
    >
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
    </button>
    <button
      type="button"
      class="flex h-10 w-10 flex-col items-center justify-center gap-1 rounded-md bg-surface-low lg:hidden"
      aria-label="메뉴"
      @click="appOption.toggleSidebarMobile"
    >
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
    </button>

    <RouterLink
      to="/"
      class="font-display text-lg font-semibold tracking-tight text-onSurface"
    >
      <span
        class="mr-2 inline-flex h-8 w-8 items-center justify-center rounded-md bg-gradient-to-b from-primary to-primary-container text-sm font-bold text-white"
        >漢</span
      >
      HANJA Admin
    </RouterLink>

    <div class="ml-auto flex items-center gap-3">
      <span
        v-if="auth.user"
        class="hidden max-w-[12rem] truncate text-sm text-onSurface-variant sm:inline"
        :title="auth.user.email ?? undefined"
      >
        {{ auth.user.email }}
      </span>
      <span
        v-if="auth.isAdmin"
        class="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary"
        >admin</span
      >
      <button type="button" class="btn-secondary text-sm" @click="signOut">
        로그아웃
      </button>
    </div>
  </header>
</template>
