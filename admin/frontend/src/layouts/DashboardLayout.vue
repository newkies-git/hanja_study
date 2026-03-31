<script setup lang="ts">
import { RouterView } from "vue-router";
import AppFooter from "@/components/app/AppFooter.vue";
import AppHeader from "@/components/app/AppHeader.vue";
import AppSidebar from "@/components/app/AppSidebar.vue";
import { useAppOptionStore } from "@/stores/app-option";

const appOption = useAppOptionStore();
</script>

<template>
  <!-- h-dvh + min-h-0: 헤더·푸터는 고정 영역, 본문만 세로 스크롤 -->
  <div class="flex h-dvh min-h-0 overflow-hidden bg-surface">
    <AppSidebar />
    <div
      class="flex min-h-0 min-w-0 flex-1 flex-col transition-[margin] duration-200"
      :class="appOption.sidebarCollapsed ? 'lg:ml-20' : 'lg:ml-64'"
    >
      <AppHeader />
      <main
        class="min-h-0 flex-1 overflow-y-auto overscroll-contain px-4 py-6 sm:px-6 lg:px-10 lg:py-8"
      >
        <RouterView />
      </main>
      <AppFooter />
    </div>
    <button
      v-if="appOption.sidebarMobileOpen"
      type="button"
      class="fixed inset-0 z-40 bg-onSurface/20 backdrop-blur-sm lg:hidden"
      aria-label="메뉴 닫기"
      @click="appOption.closeSidebarMobile"
    />
  </div>
</template>
