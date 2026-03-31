<script setup lang="ts">
import { RouterLink, useRoute } from "vue-router";
import { useAppOptionStore } from "@/stores/app-option";

const appOption = useAppOptionStore();
const route = useRoute();

/** HUD `app-sidebar-menu` 패턴: 헤더 + 평면 링크 목록 */
const menu = [
  { type: "header" as const, text: "메뉴" },
  { type: "link" as const, to: "/", label: "대시보드", icon: "◆" },
  { type: "link" as const, to: "/basis", label: "기준 데이터", icon: "▦" },
  { type: "link" as const, to: "/basis/upload", label: "한자 마스터 등록", icon: "↑" },
  { type: "link" as const, to: "/etl", label: "ETL · 확장", icon: "⚙" },
  { type: "header" as const, text: "설정" },
  { type: "link" as const, to: "/settings/auth", label: "인증 · 클레임", icon: "◇" },
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
    class="fixed inset-y-0 left-0 z-50 w-64 bg-surface-low transition-transform duration-200 lg:translate-x-0"
    :class="[
      appOption.sidebarCollapsed ? 'lg:w-20' : 'lg:w-64',
      appOption.sidebarMobileOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0',
    ]"
  >
    <div class="flex h-14 items-center px-4 sm:h-16" :class="{ 'lg:justify-center': appOption.sidebarCollapsed }">
      <span class="font-display text-sm font-semibold text-onSurface-variant" :class="{ 'lg:hidden': appOption.sidebarCollapsed }">
        Scholarly Curator
      </span>
    </div>
    <nav class="space-y-1 px-3 pb-6">
      <template v-for="(item, i) in menu" :key="i">
        <p
          v-if="item.type === 'header'"
          class="px-3 pb-2 pt-4 text-xs font-semibold uppercase tracking-wider text-onSurface-variant"
          :class="{ 'lg:hidden': appOption.sidebarCollapsed }"
        >
          {{ item.text }}
        </p>
        <RouterLink
          v-else
          :to="item.to"
          class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition"
          :class="[
            isActive(item.to)
              ? 'bg-surface-lowest text-primary shadow-float'
              : 'text-onSurface hover:bg-surface-bright',
            appOption.sidebarCollapsed ? 'lg:justify-center lg:px-2' : '',
          ]"
          @click="onNavigate"
        >
          <span class="text-base opacity-70" aria-hidden="true">{{ item.icon }}</span>
          <span :class="{ 'lg:sr-only': appOption.sidebarCollapsed }">{{ item.label }}</span>
        </RouterLink>
      </template>
    </nav>
    <div
      class="absolute bottom-0 left-0 right-0 p-4 text-xs text-onSurface-variant"
      :class="{ 'lg:hidden': appOption.sidebarCollapsed }"
    >
      레이아웃 참고: <code class="rounded bg-surface-lowest px-1">ref_hud_vue_v6.0</code>
    </div>
  </aside>
</template>
