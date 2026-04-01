import { defineStore } from "pinia";
import { ref } from "vue";

/**
 * HUD 템플릿의 app-option과 유사: 사이드바·모바일 오버레이 상태만 유지한다.
 */
export const useAppOptionStore = defineStore("appOption", () => {
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
