<script setup lang="ts">
import { computed } from "vue";
import { useDashboardShellLayoutStore } from "@/stores/dashboardShellLayout";
import { useAuthStore } from "@/stores/auth";
import { useWorkbenchStore } from "@/stores/workbench";

const layoutShell = useDashboardShellLayoutStore();
const auth = useAuthStore();
const workbench = useWorkbenchStore();

const hasServerPending = computed(() => workbench.pendingCollections.length > 0);
const workbenchNeedsAttention = computed(() => hasServerPending.value);
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
      @click="layoutShell.toggleSidebarCollapsed"
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
      @click="layoutShell.toggleSidebarMobile"
    >
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
      <span class="block h-0.5 w-5 rounded-full bg-onSurface" />
    </button>

    <div
      class="ml-auto flex shrink-0 items-center gap-1.5 sm:gap-2.5 lg:gap-3"
    >
      <!-- 변경관리: admin 전용 (로컬 채번 + 서버 버전 발행) -->
      <button
        v-if="auth.isAdmin"
        type="button"
        class="relative flex max-w-[min(100%,14rem)] items-center gap-1.5 truncate rounded-lg border px-2.5 py-1.5 text-xs font-medium transition sm:max-w-[18rem]"
        :class="
          workbenchNeedsAttention
            ? 'border-amber-300/80 bg-amber-50/90 text-amber-900 hover:bg-amber-100'
            : 'border-outline-variant/60 bg-surface-low text-onSurface-variant hover:bg-surface-bright hover:text-onSurface'
        "
        :title="
          '변경관리: 로컬 채번(chusa.db)과 서버 버전(Firestore _meta/data_version). ' +
          (hasServerPending ? '서버에 미발행 변경이 있습니다.' : '클릭하여 채번·발행을 관리합니다.')
        "
        aria-label="변경관리"
        @click="workbench.openWorkbenchModal"
      >
        <span
          v-if="workbenchNeedsAttention"
          class="h-1.5 w-1.5 shrink-0 animate-pulse rounded-full bg-amber-500"
          aria-hidden="true"
        />
        <span class="truncate">변경관리</span>
      </button>

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
