import { describe, expect, it, vi, afterEach } from "vitest";
import { createApp, defineComponent, h, ref, nextTick } from "vue";
import { useFocusTrap } from "./useFocusTrap";

function withSetup<T>(composable: () => T): T {
  let result!: T;
  const app = createApp(defineComponent({ setup() { result = composable(); return () => h("div"); } }));
  app.mount(document.createElement("div"));
  return result;
}

describe("useFocusTrap", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("활성화 시 keydown 리스너 등록", async () => {
    const addSpy = vi.spyOn(document, "addEventListener");
    const container = document.createElement("div");
    const containerRef = ref<HTMLElement | null>(container);
    const activeRef = ref(false);

    withSetup(() => useFocusTrap(containerRef, activeRef));

    activeRef.value = true;
    await nextTick();

    expect(addSpy).toHaveBeenCalledWith("keydown", expect.any(Function));
  });

  it("비활성화 시 keydown 리스너 제거", async () => {
    const removeSpy = vi.spyOn(document, "removeEventListener");
    const container = document.createElement("div");
    const containerRef = ref<HTMLElement | null>(container);
    const activeRef = ref(true);

    withSetup(() => useFocusTrap(containerRef, activeRef));
    await nextTick();

    activeRef.value = false;
    await nextTick();

    expect(removeSpy).toHaveBeenCalledWith("keydown", expect.any(Function));
  });

  it("Tab 키가 마지막 포커서블에서 첫 번째로 순환", async () => {
    const container = document.createElement("div");
    const btn1 = document.createElement("button");
    const btn2 = document.createElement("button");
    container.append(btn1, btn2);
    document.body.appendChild(container);

    const containerRef = ref<HTMLElement | null>(container);
    const activeRef = ref(false);
    withSetup(() => useFocusTrap(containerRef, activeRef));

    activeRef.value = true;
    await nextTick();

    btn2.focus();
    const event = new KeyboardEvent("keydown", { key: "Tab", bubbles: true });
    const preventDefault = vi.spyOn(event, "preventDefault");
    document.dispatchEvent(event);

    expect(preventDefault).toHaveBeenCalled();

    document.body.removeChild(container);
  });

  it("Shift+Tab 이 첫 번째 포커서블에서 마지막으로 순환", async () => {
    const container = document.createElement("div");
    const btn1 = document.createElement("button");
    const btn2 = document.createElement("button");
    container.append(btn1, btn2);
    document.body.appendChild(container);

    const containerRef = ref<HTMLElement | null>(container);
    const activeRef = ref(false);
    withSetup(() => useFocusTrap(containerRef, activeRef));

    activeRef.value = true;
    await nextTick();

    btn1.focus();
    const event = new KeyboardEvent("keydown", { key: "Tab", shiftKey: true, bubbles: true });
    const preventDefault = vi.spyOn(event, "preventDefault");
    document.dispatchEvent(event);

    expect(preventDefault).toHaveBeenCalled();

    document.body.removeChild(container);
  });
});
