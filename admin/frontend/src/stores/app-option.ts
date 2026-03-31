import { defineStore } from "pinia";
import { ref } from "vue";

/**
 * HUD 템플릿의 app-option과 유사: 사이드바·모바일 오버레이 상태만 유지한다.
 */
export const useAppOptionStore = defineStore("appOption", () => {
  const sidebarCollapsed = ref(false);
  const sidebarMobileOpen = ref(false);

  function toggleSidebarCollapsed() {
    sidebarCollapsed.value = !sidebarCollapsed.value;
  }

  function toggleSidebarMobile() {
    sidebarMobileOpen.value = !sidebarMobileOpen.value;
  }

  function closeSidebarMobile() {
    sidebarMobileOpen.value = false;
  }

  return {
    sidebarCollapsed,
    sidebarMobileOpen,
    toggleSidebarCollapsed,
    toggleSidebarMobile,
    closeSidebarMobile,
  };
});
