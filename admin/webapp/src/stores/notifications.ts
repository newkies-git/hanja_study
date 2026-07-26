import { defineStore } from "pinia";
import { ref } from "vue";

export type ToastType = "success" | "error" | "warning";

export type Toast = {
  id: number;
  type: ToastType;
  message: string;
  duration: number;
};

let _nextId = 1;

export const useNotificationsStore = defineStore("notifications", () => {
  const toasts = ref<Toast[]>([]);

  function push(type: ToastType, message: string, duration = 4000): number {
    const id = _nextId++;
    toasts.value.push({ id, type, message, duration });
    if (duration > 0) {
      setTimeout(() => dismiss(id), duration);
    }
    return id;
  }

  function dismiss(id: number) {
    const idx = toasts.value.findIndex((t) => t.id === id);
    if (idx !== -1) toasts.value.splice(idx, 1);
  }

  const success = (msg: string, duration?: number) => push("success", msg, duration);
  const error = (msg: string, duration?: number) => push("error", msg, duration ?? 6000);
  const warning = (msg: string, duration?: number) => push("warning", msg, duration);

  return { toasts, push, dismiss, success, error, warning };
});
