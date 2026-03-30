import { defineStore } from 'pinia';

export const useAppOptionStore = defineStore('appOption', () => {
  return {
    appMode: 'dark' as 'dark' | 'light',
    appHeaderHide: false,
    appSidebarHide: false,
    appSidebarToggled: true,
    appSidebarCollapsed: false,
    appSidebarMobileToggled: false,
    appThemePanelToggled: false,
    appContentClass: '',
  };
});

