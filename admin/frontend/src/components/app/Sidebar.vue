<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import { useAppOptionStore } from '../../stores/app-option';

const route = useRoute();
const appOption = useAppOptionStore();
const path = computed(() => String(route.path || ''));
const isActive = (prefix: string) => path.value.startsWith(prefix);
</script>

<template>
  <div
    class="app-sidebar md:col-span-3 lg:col-span-3"
    :class="
      appOption.appSidebarMobileToggled
        ? 'fixed left-0 right-auto top-16 bottom-0 z-40 w-[20rem] overflow-auto md:static md:z-auto md:w-auto md:overflow-visible'
        : 'hidden md:block'
    "
  >
    <div class="bg-surface-container-low rounded-3xl p-5 h-full md:h-auto">
      <div class="mb-4 flex items-center justify-between">
        <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Modules</div>
        <button
          type="button"
          class="md:hidden text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors"
          @click="appOption.appSidebarMobileToggled = false"
        >
          닫기
        </button>
      </div>

      <div class="space-y-4">
        <div>
          <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">DATA</div>
          <ul class="space-y-1">
            <li>
              <RouterLink
                to="/dashboard/basis/manage"
                class="w-full text-left flex items-center gap-3 px-4 py-3 text-sm rounded-2xl transition-colors"
                :class="
                  isActive('/dashboard/basis')
                    ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                    : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                "
              >
                <span class="material-symbols-outlined" :class="isActive('/dashboard/basis') ? 'text-primary' : 'text-outline'">menu_book</span>
                한자 원본 데이터
              </RouterLink>
            </li>
            <li v-if="isActive('/dashboard/basis')">
              <div class="ml-4 mt-1 space-y-1">
                <RouterLink
                  to="/dashboard/basis/manage"
                  class="w-full text-left flex items-center gap-3 px-4 py-2 text-sm rounded-2xl transition-colors"
                  :class="
                    path === '/dashboard/basis/manage'
                      ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                      : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                  "
                >
                  <span class="material-symbols-outlined text-outline">dataset</span>
                  목록/관리
                </RouterLink>
                <RouterLink
                  to="/dashboard/basis/csv-upload"
                  class="w-full text-left flex items-center gap-3 px-4 py-2 text-sm rounded-2xl transition-colors"
                  :class="
                    path === '/dashboard/basis/csv-upload'
                      ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                      : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                  "
                >
                  <span class="material-symbols-outlined text-outline">upload_file</span>
                  CSV 업로드
                </RouterLink>
              </div>
            </li>
          </ul>
        </div>

        <div>
          <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">PIPELINE</div>
          <ul class="space-y-1">
            <li>
              <RouterLink
                to="/dashboard/etl-monitor"
                class="w-full text-left flex items-center gap-3 px-4 py-3 text-sm rounded-2xl transition-colors"
                :class="
                  path === '/dashboard/etl-monitor'
                    ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                    : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                "
              >
                <span class="material-symbols-outlined" :class="path === '/dashboard/etl-monitor' ? 'text-primary' : 'text-outline'">hub</span>
                ETL 상태 모니터링
              </RouterLink>
            </li>
            <li>
              <RouterLink
                to="/dashboard/sync"
                class="w-full text-left flex items-center gap-3 px-4 py-3 text-sm rounded-2xl transition-colors"
                :class="
                  path === '/dashboard/sync'
                    ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                    : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                "
              >
                <span class="material-symbols-outlined" :class="path === '/dashboard/sync' ? 'text-primary' : 'text-outline'">sync</span>
                동기화 관리
              </RouterLink>
            </li>
          </ul>
        </div>

        <div>
          <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">SETTINGS</div>
          <ul class="space-y-1">
            <li>
              <RouterLink
                to="/dashboard/settings/authentication"
                class="w-full text-left flex items-center gap-3 px-4 py-3 text-sm rounded-2xl transition-colors"
                :class="
                  isActive('/dashboard/settings')
                    ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                    : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                "
              >
                <span class="material-symbols-outlined" :class="isActive('/dashboard/settings') ? 'text-primary' : 'text-outline'">settings</span>
                설정
              </RouterLink>
            </li>
            <li v-if="isActive('/dashboard/settings')">
              <div class="ml-4 mt-1 space-y-1">
                <RouterLink
                  to="/dashboard/settings/authentication"
                  class="w-full text-left flex items-center gap-3 px-4 py-2 text-sm rounded-2xl transition-colors"
                  :class="
                    path === '/dashboard/settings/authentication'
                      ? 'bg-surface-container-lowest text-on-surface font-semibold shadow-ambient'
                      : 'text-on-surface-variant hover:bg-surface-container-high font-medium'
                  "
                >
                  <span class="material-symbols-outlined text-outline">admin_panel_settings</span>
                  Authentication
                </RouterLink>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

