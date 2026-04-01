<script setup lang="ts">
import { RouterLink, useRoute } from "vue-router";
import { useAppOptionStore } from "@/stores/app-option";

const appOption = useAppOptionStore();
const route = useRoute();

const menu = [
  { type: "header" as const, text: "메뉴" },
  { type: "link" as const, to: "/", label: "대시보드", icon: "◆" },
  { type: "link" as const, to: "/basis", label: "기준 데이터", icon: "▦" },
  {
    type: "link" as const,
    to: "/basis/upload",
    label: "한자 마스터 등록",
    icon: "↑",
  },
  { type: "link" as const, to: "/etl", label: "ETL · 확장", icon: "⚙" },
  { type: "header" as const, text: "설정" },
  {
    type: "link" as const,
    to: "/settings/auth",
    label: "인증 · 클레임",
    icon: "◇",
  },
];

function isActive(path: string) {
  if (path === "/") return route.path === "/";
  return route.path === path || route.path.startsWith(`${path}/`);
}

function onNavigate() {
  appOption.closeSidebarMobile();
}
</script>

<template>
  <aside
    class="fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-outline-variant/80 bg-gradient-to-b from-surface-lowest via-surface-low to-surface-low/95 shadow-[4px_0_32px_rgba(25,28,30,0.05)] transition-[width,transform] duration-200 ease-out lg:translate-x-0"
    :class="[
      appOption.isSidebarCollapsed ? 'lg:w-20' : 'lg:w-64',
      appOption.isSidebarMobileOpen
        ? 'translate-x-0'
        : '-translate-x-full lg:translate-x-0',
    ]"
  >
    <!-- 브랜드: AppHeader 와 동일 h-14 / sm:h-16 로 상단 바 높이 정렬 -->
    <div
      class="relative flex h-14 min-h-14 shrink-0 items-center border-b border-outline-variant bg-gradient-to-r from-primary/[0.07] to-transparent px-3 sm:h-16 sm:min-h-16 sm:px-4"
      :class="{ 'lg:px-2': appOption.isSidebarCollapsed }"
    >
      <div
        class="pointer-events-none absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-primary/[0.04] to-transparent"
        aria-hidden="true"
      />
      <div
        class="relative flex min-h-0 min-w-0 flex-1 items-center gap-2.5 sm:gap-3"
        :class="{ 'lg:justify-center': appOption.isSidebarCollapsed }"
      >
        <div
          class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-gradient-to-b from-primary to-primary-container font-display text-sm font-bold text-white shadow-md shadow-primary/20 sm:h-9 sm:w-9 sm:rounded-xl"
          aria-hidden="true"
        >
          漢
        </div>
        <div
          class="min-w-0 leading-tight"
          :class="{ 'lg:hidden': appOption.isSidebarCollapsed }"
        >
          <p class="font-display text-sm font-semibold tracking-tight text-onSurface">
            Scholarly Curator
          </p>
          <p class="text-[10px] font-medium uppercase tracking-[0.12em] text-primary/80">
            HANJA Admin
          </p>
        </div>
      </div>
    </div>

    <!-- 내비게이션 -->
    <nav
      class="min-h-0 flex-1 space-y-0.5 overflow-y-auto px-2.5 py-4 [scrollbar-width:thin]"
    >
      <template v-for="(item, i) in menu" :key="i">
        <p
          v-if="item.type === 'header'"
          class="mb-1 mt-4 flex items-center gap-2 px-3 pb-1 pt-1 text-[10px] font-bold uppercase tracking-[0.14em] text-onSurface-variant/90 first:mt-0"
          :class="{ 'lg:hidden': appOption.isSidebarCollapsed }"
        >
          <span
            class="h-px w-2 shrink-0 rounded-full bg-primary/35"
            aria-hidden="true"
          />
          {{ item.text }}
        </p>
        <RouterLink
          v-else
          :to="item.to"
          class="group flex items-center gap-3 rounded-xl border border-transparent px-2.5 py-2 text-sm font-medium transition-all duration-150"
          :class="[
            isActive(item.to)
              ? 'border-primary/15 bg-white text-primary shadow-sm shadow-primary/[0.08] ring-1 ring-primary/10'
              : 'text-onSurface-variant hover:border-outline-variant/50 hover:bg-white/90 hover:text-onSurface hover:shadow-sm',
            appOption.isSidebarCollapsed ? 'lg:justify-center lg:px-2' : '',
          ]"
          :title="appOption.isSidebarCollapsed ? item.label : undefined"
          @click="onNavigate"
        >
          <span
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg text-base transition-colors"
            :class="
              isActive(item.to)
                ? 'bg-primary/12 text-primary'
                : 'bg-surface-lowest/80 text-onSurface-variant group-hover:bg-surface-bright group-hover:text-onSurface'
            "
            aria-hidden="true"
          >{{ item.icon }}</span>
          <span
            class="truncate"
            :class="{ 'lg:sr-only': appOption.isSidebarCollapsed }"
          >{{ item.label }}</span>
        </RouterLink>
      </template>
    </nav>

    <!-- 하단 장식 (HUD식 얇은 구분) -->
    <div
      class="shrink-0 border-t border-outline-variant/50 bg-surface-lowest/40 px-4 py-3"
      :class="{ 'lg:px-2': appOption.isSidebarCollapsed }"
    >
      <div
        class="mx-auto h-1 w-8 rounded-full bg-gradient-to-r from-transparent via-primary/25 to-transparent"
        aria-hidden="true"
      />
    </div>
  </aside>
</template>
