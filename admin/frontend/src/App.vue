<script setup lang="ts">
import { computed, watch } from 'vue';
import { RouterView, useRoute } from 'vue-router';
import { useAppOptionStore } from './stores/app-option';
import AppHeader from './components/app/Header.vue';
import AppSidebar from './components/app/Sidebar.vue';

const route = useRoute();
const appOption = useAppOptionStore();

const isAuthPage = computed(() => route.path === '/login');

watch(
  () => route.fullPath,
  () => {
    appOption.appSidebarMobileToggled = false;
  },
  { immediate: true },
);
</script>

<template>
  <div
    class="app min-h-screen"
    :class="{
      'app-without-header': isAuthPage || appOption.appHeaderHide,
      'app-without-sidebar': isAuthPage || appOption.appSidebarHide,
      'app-sidebar-mobile-toggled': appOption.appSidebarMobileToggled,
    }"
  >
    <AppHeader v-if="!isAuthPage && !appOption.appHeaderHide" />

    <div class="app-content">
      <div v-if="isAuthPage" class="max-w-7xl mx-auto py-10 px-6 lg:px-10">
        <RouterView />
      </div>
      <div v-else class="max-w-7xl mx-auto py-10 px-6 lg:px-10">
        <!-- Mobile sidebar overlay -->
        <div
          v-if="appOption.appSidebarMobileToggled && !appOption.appSidebarHide"
          class="fixed inset-0 z-30 bg-black/40 backdrop-blur-sm md:hidden"
          @click="appOption.appSidebarMobileToggled = false"
        ></div>
        <div class="grid grid-cols-1 gap-8 md:grid-cols-12">
          <AppSidebar v-if="!appOption.appSidebarHide" />
          <section class="md:col-span-9 lg:col-span-9">
            <div class="space-y-6">
              <RouterView />
            </div>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>
