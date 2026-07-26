import { onMounted, onUnmounted, ref } from "vue";

/**
 * 브라우저의 네트워크 연결 상태를 반응형으로 추적합니다.
 * `navigator.onLine`을 기반으로 하며, online/offline 이벤트로 갱신됩니다.
 */
export function useOnlineStatus() {
  const isOnline = ref(typeof navigator !== "undefined" ? navigator.onLine : true);

  function handleOnline() {
    isOnline.value = true;
  }
  function handleOffline() {
    isOnline.value = false;
  }

  onMounted(() => {
    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);
  });

  onUnmounted(() => {
    window.removeEventListener("online", handleOnline);
    window.removeEventListener("offline", handleOffline);
  });

  return { isOnline };
}
