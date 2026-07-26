import { onUnmounted, toValue, watch } from "vue";
import type { MaybeRefOrGetter, Ref } from "vue";

const FOCUSABLE = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  '[tabindex]:not([tabindex="-1"])',
].join(", ");

/**
 * 모달 등 레이어 내부에 키보드 포커스를 가두는 composable.
 *
 * @param containerRef  포커스를 가둘 컨테이너 요소의 ref
 * @param active        트랩 활성 여부 — Ref, computed, 또는 getter 함수 모두 가능
 */
export function useFocusTrap(
  containerRef: Ref<HTMLElement | null>,
  active: MaybeRefOrGetter<boolean>,
) {
  let previouslyFocused: HTMLElement | null = null;

  function getFocusable(): HTMLElement[] {
    if (!containerRef.value) return [];
    return [...containerRef.value.querySelectorAll<HTMLElement>(FOCUSABLE)].filter(
      (el) => !el.closest('[aria-hidden="true"]'),
    );
  }

  function handleKeyDown(e: KeyboardEvent) {
    if (e.key !== "Tab") return;
    const focusable = getFocusable();
    if (!focusable.length) {
      e.preventDefault();
      return;
    }
    const first = focusable[0]!;
    const last = focusable[focusable.length - 1]!;
    if (e.shiftKey) {
      if (document.activeElement === first) {
        e.preventDefault();
        last.focus();
      }
    } else {
      if (document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  }

  watch(
    () => toValue(active),
    (isActive) => {
      if (isActive) {
        previouslyFocused = document.activeElement as HTMLElement | null;
        setTimeout(() => {
          const focusable = getFocusable();
          if (focusable.length) focusable[0]!.focus();
        }, 0);
        document.addEventListener("keydown", handleKeyDown);
      } else {
        document.removeEventListener("keydown", handleKeyDown);
        previouslyFocused?.focus();
        previouslyFocused = null;
      }
    },
  );

  onUnmounted(() => {
    document.removeEventListener("keydown", handleKeyDown);
  });
}
