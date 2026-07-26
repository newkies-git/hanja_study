import { defineStore } from "pinia";
import { ref } from "vue";

/**
 * 대시보드 셸(헤더·사이드바) 전용: 접기·모바일 오버레이만 담는다.
 */
export const useDashboardShellLayoutStore = defineStore("dashboardShellLayout", () => {
  const isSidebarCollapsed = ref(false);
  const isSidebarMobileOpen = ref(false);

  function toggleSidebarCollapsed() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  function toggleSidebarMobile() {
    isSidebarMobileOpen.value = !isSidebarMobileOpen.value;
  }

  function closeSidebarMobile() {
    isSidebarMobileOpen.value = false;
  }

  return {
    isSidebarCollapsed,
    isSidebarMobileOpen,
    toggleSidebarCollapsed,
    toggleSidebarMobile,
    closeSidebarMobile,
  };
});
