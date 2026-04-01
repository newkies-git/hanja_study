<script setup lang="ts">
import { RouterLink } from "vue-router";
import { useAppOptionStore } from "@/stores/app-option";
import { useAuthStore } from "@/stores/auth";

const appOption = useAppOptionStore();
const auth = useAuthStore();
</script>

<template>
  <header
    class="sticky top-0 z-30 flex h-14 min-h-14 shrink-0 items-center gap-2 border-b border-outline-variant bg-surface-lowest/90 px-3 shadow-float backdrop-blur-md sm:h-16 sm:min-h-16 sm:gap-3 sm:px-6 lg:px-8"
  >
    <!-- 데스크톱(lg+): 사이드바 접기. 모바일에서는 숨김 — lg:flex만 쓰면 모바일에서도 버튼이 보여 햄버거가 이중 표시됨 -->
    <button
      type="button"
      class="hidden h-10 w-10 shrink-0 flex-col items-center justify-center gap-1 rounded-md bg-surface-low lg:flex"
      aria-label="사이드바 접기"
      @click="appOption.toggleSidebarCollapsed"
    >
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
    </button>
    <!-- 모바일: 오버레이 메뉴만 -->
    <button
      type="button"
      class="flex h-10 w-10 shrink-0 flex-col items-center justify-center gap-1 rounded-md bg-surface-low lg:hidden"
      aria-label="메뉴"
      @click="appOption.toggleSidebarMobile"
    >
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
    </button>

    <RouterLink
      to="/"
      class="font-display flex min-w-0 flex-1 items-center gap-2 overflow-hidden text-onSurface no-underline sm:gap-2.5"
    >
      <span
        class="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-gradient-to-b from-primary to-primary-container text-sm font-bold text-white"
        aria-hidden="true"
        >漢</span
      >
      <span
        class="truncate text-base font-semibold tracking-tight sm:text-lg"
        >HANJA Admin</span
      >
    </RouterLink>

    <div
      class="ml-auto flex shrink-0 items-center gap-1.5 sm:gap-2.5 lg:gap-3"
    >
      <span
        v-if="auth.user"
        class="hidden max-w-[12rem] truncate text-sm text-onSurface-variant sm:inline"
        :title="auth.user.email ?? undefined"
      >
        {{ auth.user.email }}
      </span>
      <span
        v-if="auth.isAdmin"
        class="shrink-0 rounded-full bg-primary/10 px-2 py-0.5 text-[11px] font-medium text-primary sm:px-2.5 sm:text-xs"
        >admin</span
      >
      <button
        type="button"
        class="btn-secondary shrink-0 whitespace-nowrap px-2.5 py-2 text-xs sm:px-3 sm:text-sm"
        @click="auth.logout"
      >
        로그아웃
      </button>
    </div>
  </header>
</template>
