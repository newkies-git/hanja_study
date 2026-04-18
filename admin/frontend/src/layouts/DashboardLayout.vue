<script setup lang="ts">
import { computed, onMounted } from "vue";
import { RouterView, useRoute } from "vue-router";
import AppFooter from "@/components/app/AppFooter.vue";
import AppHeader from "@/components/app/AppHeader.vue";
import AppSidebar from "@/components/app/AppSidebar.vue";
import ToastNotifications from "@/components/app/ToastNotifications.vue";
import WorkbenchModal from "@/components/app/WorkbenchModal.vue";
import { useDashboardShellLayoutStore } from "@/stores/dashboardShellLayout";
import { useOnlineStatus } from "@/composables/useOnlineStatus";
import { useWorkbenchStore } from "@/stores/workbench";

const layoutShell = useDashboardShellLayoutStore();
const { isOnline } = useOnlineStatus();
const workbench = useWorkbenchStore();
const route = useRoute();

const isSplitManage = computed(() =>
  route.matched.some((r) => (r.meta as { splitManage?: boolean }).splitManage === true),
);

onMounted(() => {
  void workbench.fetchVersion();
  void workbench.fetchLocalSession();
});
</script>

<template>
  <!-- h-dvh + min-h-0: 헤더·푸터는 고정 영역, 본문만 세로 스크롤 -->
  <div class="flex h-dvh min-h-0 overflow-hidden bg-surface">
    <AppSidebar />
    <div
      class="flex min-h-0 min-w-0 flex-1 flex-col transition-[margin] duration-200"
      :class="layoutShell.isSidebarCollapsed ? 'lg:ml-20' : 'lg:ml-64'"
    >
      <AppHeader />
      <!-- 오프라인 배너 -->
      <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="-translate-y-full opacity-0"
        enter-to-class="translate-y-0 opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="translate-y-0 opacity-100"
        leave-to-class="-translate-y-full opacity-0"
      >
        <div
          v-if="!isOnline"
          role="alert"
          aria-live="assertive"
          class="flex items-center justify-center gap-2 bg-amber-500 px-4 py-2 text-xs font-medium text-white shadow-sm"
        >
          <svg class="h-3.5 w-3.5 shrink-0" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
            <path d="M8 1a7 7 0 100 14A7 7 0 008 1zm0 3a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 018 4zm0 8a1 1 0 110-2 1 1 0 010 2z"/>
          </svg>
          네트워크 연결이 끊어졌습니다. 데이터 로드 및 저장이 불가합니다.
        </div>
      </Transition>
      <main
        class="min-h-0 flex-1 px-4 py-6 sm:px-6 lg:px-10 lg:py-8"
        :class="
          isSplitManage
            ? 'flex flex-col overflow-hidden overscroll-contain'
            : 'overflow-y-auto overscroll-contain'
        "
      >
        <RouterView
          :class="isSplitManage ? 'flex min-h-0 min-w-0 flex-1 flex-col' : ''"
        />
      </main>
      <AppFooter />
    </div>
    <button
      v-if="layoutShell.isSidebarMobileOpen"
      type="button"
      class="fixed inset-0 z-40 bg-onSurface/20 backdrop-blur-sm lg:hidden"
      aria-label="메뉴 닫기"
      @click="layoutShell.closeSidebarMobile"
    />
  </div>
  <ToastNotifications />
  <WorkbenchModal :open="workbench.workbenchModalOpen" @close="workbench.closeWorkbenchModal" />
</template>
