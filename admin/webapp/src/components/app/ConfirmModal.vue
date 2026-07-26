<script setup lang="ts">
import { onUnmounted, ref, watch } from "vue";
import { useFocusTrap } from "@/composables/useFocusTrap";

const props = withDefaults(
  defineProps<{
    open: boolean;
    title: string;
    message: string;
    confirmLabel?: string;
    cancelLabel?: string;
    danger?: boolean;
  }>(),
  {
    confirmLabel: "확인",
    cancelLabel: "취소",
    danger: false,
  },
);

const emit = defineEmits<{
  confirm: [];
  cancel: [];
}>();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") emit("cancel");
}

watch(
  () => props.open,
  (val) => {
    if (val) document.addEventListener("keydown", handleKeyDown);
    else document.removeEventListener("keydown", handleKeyDown);
  },
);

onUnmounted(() => {
  document.removeEventListener("keydown", handleKeyDown);
});
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[70] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
      role="dialog"
      aria-modal="true"
      :aria-labelledby="`confirm-modal-title-${title}`"
      @click.self="emit('cancel')"
    >
      <div
        ref="containerRef"
        class="w-full max-w-sm overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <!-- 헤더 -->
        <div
          class="border-b border-outline-variant/70 px-5 pb-3 pt-4"
          :class="danger ? 'bg-red-50/60' : 'bg-surface-low/50'"
        >
          <h2
            :id="`confirm-modal-title-${title}`"
            class="font-display text-base font-semibold tracking-tight"
            :class="danger ? 'text-red-900' : 'text-onSurface'"
          >
            {{ title }}
          </h2>
        </div>

        <!-- 본문 -->
        <div class="px-5 py-4">
          <p class="text-sm leading-relaxed text-onSurface-variant">{{ message }}</p>
        </div>

        <!-- 버튼 -->
        <div class="flex justify-end gap-2 border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3">
          <button
            type="button"
            class="btn-secondary px-4 py-2 text-sm"
            @click="emit('cancel')"
          >
            {{ cancelLabel }}
          </button>
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium rounded-lg transition"
            :class="
              danger
                ? 'bg-red-600 text-white shadow-sm hover:bg-red-700 active:bg-red-800'
                : 'btn-primary'
            "
            @click="emit('confirm')"
          >
            {{ confirmLabel }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
