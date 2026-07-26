<script setup lang="ts">
import { useNotificationsStore } from "@/stores/notifications";
import type { Toast } from "@/stores/notifications";

const notifications = useNotificationsStore();

const TOAST_STYLE: Record<Toast["type"], { icon: string; color: string; iconColor: string }> = {
  success: { icon: "✓", color: "border-green-200/90 bg-green-50/95 text-green-900", iconColor: "bg-green-500 text-white" },
  error:   { icon: "✕", color: "border-red-200/90 bg-red-50/95 text-red-900",       iconColor: "bg-red-500 text-white" },
  warning: { icon: "!",  color: "border-amber-200/90 bg-amber-50/95 text-amber-900", iconColor: "bg-amber-500 text-white" },
};
</script>

<template>
  <Teleport to="body">
    <div
      aria-live="polite"
      aria-atomic="false"
      class="pointer-events-none fixed bottom-5 right-4 z-[10100] flex flex-col items-end gap-2.5 sm:right-6"
    >
      <TransitionGroup
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="translate-x-8 opacity-0"
        enter-to-class="translate-x-0 opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="translate-x-0 opacity-100"
        leave-to-class="translate-x-8 opacity-0"
      >
        <div
          v-for="toast in notifications.toasts"
          :key="toast.id"
          role="alert"
          class="pointer-events-auto flex w-[22rem] max-w-[calc(100vw-2rem)] items-start gap-3 rounded-xl border px-4 py-3 shadow-[0_8px_30px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
          :class="TOAST_STYLE[toast.type].color"
        >
          <span
            class="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[11px] font-bold"
            :class="TOAST_STYLE[toast.type].iconColor"
            aria-hidden="true"
          >
            {{ TOAST_STYLE[toast.type].icon }}
          </span>
          <p class="flex-1 text-sm leading-snug">{{ toast.message }}</p>
          <button
            type="button"
            class="shrink-0 text-current/50 transition hover:text-current/80"
            :aria-label="`알림 닫기: ${toast.message}`"
            @click="notifications.dismiss(toast.id)"
          >
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M4 4l8 8M12 4l-8 8" />
            </svg>
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>
