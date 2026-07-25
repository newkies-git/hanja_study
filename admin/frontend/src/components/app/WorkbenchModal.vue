<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { useWorkbenchStore } from "@/stores/workbench";
import { useNotificationsStore } from "@/stores/notifications";
import { useAuthStore } from "@/stores/auth";
import { useFocusTrap } from "@/composables/useFocusTrap";
import { isLocalApiEnabled } from "@/config/localApi";

const props = defineProps<{ open: boolean }>();
const emit = defineEmits<{ close: [] }>();

const workbenchStore = useWorkbenchStore();
const notifications = useNotificationsStore();
const authStore = useAuthStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

const serverNotes = ref("");
const serverError = ref<string | null>(null);
const localError = ref<string | null>(null);
const localSessionLogDraft = ref("");
const localBusy = ref(false);

const nextGlobal = computed(() => (workbenchStore.version?.global ?? 0) + 1);

function formatDate(d: Date | null): string {
  if (!d) return "—";
  return d.toLocaleString("ko-KR", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") emit("close");
}

onUnmounted(() => document.removeEventListener("keydown", handleKeyDown));

watch(
  () => props.open,
  (val) => {
    if (val) {
      serverNotes.value = "";
      serverError.value = null;
      localError.value = null;
      document.addEventListener("keydown", handleKeyDown);
      void workbenchStore.fetchVersion();
      if (authStore.isAdmin) {
        void workbenchStore.fetchLocalSession().then(() => {
          localSessionLogDraft.value = workbenchStore.localSession?.description ?? "";
        });
      }
    } else {
      document.removeEventListener("keydown", handleKeyDown);
    }
  },
);

async function publishServer() {
  serverError.value = null;
  try {
    await workbenchStore.publish(serverNotes.value);
    notifications.success(`서버 데이터 v${workbenchStore.version?.global ?? "?"} 발행 완료`);
    emit("close");
  } catch (e) {
    serverError.value = e instanceof Error ? e.message : "발행에 실패했습니다.";
    notifications.error(serverError.value);
  }
}

/** 신규 채번(또는 기존 ACTIVE 종료 후 새 채번) — 변경 이력은 `localSessionLogDraft` */
async function submitNewLocalSession() {
  if (localBusy.value) return;
  localError.value = null;
  localBusy.value = true;
  try {
    await workbenchStore.startLocalSession(localSessionLogDraft.value.trim() || null);
    localSessionLogDraft.value = workbenchStore.localSession?.description ?? "";
    const sid = workbenchStore.localSession?.id;
    notifications.success(sid != null ? `채번 #${sid} 발급` : "채번 발급 완료");
  } catch (e) {
    localError.value = e instanceof Error ? e.message : "채번 발급에 실패했습니다.";
    notifications.error(localError.value);
  } finally {
    localBusy.value = false;
  }
}

async function saveLocalSessionLog() {
  if (!workbenchStore.localSession || localBusy.value) return;
  localError.value = null;
  localBusy.value = true;
  try {
    await workbenchStore.setLocalSessionDescription(localSessionLogDraft.value.trim());
    localSessionLogDraft.value = workbenchStore.localSession?.description ?? "";
    notifications.success("변경 이력 저장됨");
  } catch (e) {
    localError.value = e instanceof Error ? e.message : "저장에 실패했습니다.";
    notifications.error(localError.value);
  } finally {
    localBusy.value = false;
  }
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[70] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
      role="dialog"
      aria-modal="true"
      aria-labelledby="workbench-modal-title"
      @click.self="emit('close')"
    >
      <div
        ref="containerRef"
        class="flex max-h-[min(92vh,44rem)] w-full max-w-md flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-lg"
      >
        <header
          class="flex shrink-0 items-center justify-between gap-3 border-b border-outline-variant/70 px-4 py-3 sm:px-5"
        >
          <h2 id="workbench-modal-title" class="font-display text-lg font-semibold text-onSurface">
            변경관리
          </h2>
          <button type="button" class="btn-secondary px-3 py-1.5 text-sm" @click="emit('close')">
            닫기
          </button>
        </header>

        <div class="min-h-0 flex-1 space-y-4 overflow-y-auto px-4 py-4 sm:px-5">
          <!-- 로컬 채번 (admin + 로컬 API) -->
          <section
            v-if="isLocalApiEnabled && authStore.isAdmin"
            class="rounded-xl border border-outline-variant/60 p-3"
          >
            <h3 class="text-sm font-semibold text-onSurface">로컬 채번</h3>
            <p v-if="workbenchStore.localSessionLoading" class="mt-2 text-xs text-onSurface-variant">불러오는 중…</p>
            <template v-else>
              <p class="mt-1 text-xs text-onSurface-variant">
                활성:
                <span v-if="workbenchStore.localSession" class="font-mono font-semibold text-primary"
                  >#{{ workbenchStore.localSession.id }}</span
                >
                <span v-else class="text-red-600">없음</span>
              </p>
              <label class="mt-2 block text-[11px] font-medium text-onSurface-variant" for="workbench-local-log"
                >변경 이력 (선택)</label
              >
              <textarea
                id="workbench-local-log"
                v-model="localSessionLogDraft"
                rows="3"
                :disabled="localBusy"
                class="input-minimal mt-1 w-full resize-none py-2 text-sm"
                placeholder="예: 水·火 훈 수정, 단어 추가"
              />
              <div v-if="localError" class="mt-2 rounded border border-red-200 bg-red-50/90 px-2 py-1.5 text-xs text-red-900">
                {{ localError }}
              </div>
              <div class="mt-2 flex flex-wrap gap-2">
                <button
                  v-if="!workbenchStore.localSession"
                  type="button"
                  class="btn-primary px-3 py-1.5 text-xs"
                  :disabled="localBusy"
                  @click="submitNewLocalSession"
                >
                  {{ localBusy ? "처리 중…" : "채번 발급" }}
                </button>
                <template v-else>
                  <button
                    type="button"
                    class="btn-secondary px-3 py-1.5 text-xs"
                    :disabled="localBusy"
                    @click="submitNewLocalSession"
                  >
                    {{ localBusy ? "처리 중…" : "새 채번" }}
                  </button>
                  <button
                    type="button"
                    class="btn-primary px-3 py-1.5 text-xs"
                    :disabled="localBusy"
                    @click="saveLocalSessionLog"
                  >
                    {{ localBusy ? "처리 중…" : "변경 이력 저장" }}
                  </button>
                </template>
              </div>
            </template>
          </section>

          <p
            v-else-if="isLocalApiEnabled && !authStore.isAdmin"
            class="rounded-lg border border-outline-variant/60 bg-surface-low/50 px-3 py-2 text-xs text-onSurface-variant"
          >
            로컬 채번은 admin 권한이 필요합니다.
          </p>
          <p
            v-else
            class="rounded-lg border border-outline-variant/60 bg-surface-low/50 px-3 py-2 text-xs text-onSurface-variant"
          >
            로컬 API가 꺼져 있습니다. 개발 시 <code class="font-mono text-[10px]">server.js</code>와
            <code class="font-mono text-[10px]">VITE_USE_LOCAL_API</code>를 확인하세요.
          </p>

          <!-- 서버 발행 -->
          <section v-if="authStore.isAdmin" class="rounded-xl border border-outline-variant/60 p-3">
            <h3 class="text-sm font-semibold text-onSurface">서버 데이터 발행</h3>
            <div v-if="serverError" class="mt-2 rounded border border-red-200 bg-red-50/90 px-2 py-1.5 text-xs text-red-900">
              {{ serverError }}
            </div>
            <label class="mt-2 block text-[11px] font-medium text-onSurface-variant" for="workbench-server-notes">발행 메모</label>
            <textarea
              id="workbench-server-notes"
              v-model="serverNotes"
              rows="2"
              :disabled="workbenchStore.isPublishing"
              class="input-minimal mt-1 w-full resize-none py-2 text-sm"
            />
            <p class="mt-2 text-xs text-onSurface-variant">
              global v{{ workbenchStore.version?.global ?? 0 }} → v{{ nextGlobal }}
              <template v-if="workbenchStore.version?.publishedAt">
                · 마지막 {{ formatDate(workbenchStore.version.publishedAt) }}
              </template>
            </p>
            <div class="mt-2 flex justify-end">
              <button
                type="button"
                class="btn-primary px-3 py-1.5 text-sm"
                :disabled="workbenchStore.isPublishing"
                @click="publishServer"
              >
                {{ workbenchStore.isPublishing ? "발행 중…" : "발행" }}
              </button>
            </div>
          </section>

          <p v-else class="text-xs text-onSurface-variant">서버 발행은 admin 클레임이 필요합니다.</p>
        </div>
      </div>
    </div>
  </Teleport>
</template>
