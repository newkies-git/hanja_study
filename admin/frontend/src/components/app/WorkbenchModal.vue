<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { RouterLink } from "vue-router";
import { useWorkbenchStore } from "@/stores/workbench";
import { useNotificationsStore } from "@/stores/notifications";
import { useAuthStore } from "@/stores/auth";
import { useFocusTrap } from "@/composables/useFocusTrap";
const props = defineProps<{ open: boolean }>();
const emit = defineEmits<{ close: [] }>();

const wb = useWorkbenchStore();
const notifications = useNotificationsStore();
const auth = useAuthStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

const serverNotes = ref("");
const serverError = ref<string | null>(null);
const localError = ref<string | null>(null);

watch(
  () => props.open,
  (val) => {
    if (val) {
      serverNotes.value = "";
      serverError.value = null;
      localError.value = null;
      void wb.fetchLocalSession();
      document.addEventListener("keydown", handleKeyDown);
    } else {
      document.removeEventListener("keydown", handleKeyDown);
    }
  },
);

const nextGlobal = computed(() => (wb.version?.global ?? 0) + 1);

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

async function publishServer() {
  serverError.value = null;
  try {
    await wb.publish(serverNotes.value);
    notifications.success(`서버 데이터 v${wb.version?.global ?? "?"} 발행 완료`);
    emit("close");
  } catch (e) {
    serverError.value = e instanceof Error ? e.message : "발행에 실패했습니다.";
    notifications.error(serverError.value);
  }
}

async function issueLocalSession() {
  localError.value = null;
  const desc = window.prompt("이 채번(작업 세션)에 대한 작업 로그를 입력하세요 (선택사항):");
  if (desc === null) return;
  try {
    await wb.startLocalSession(desc.trim() || null);
    notifications.success("로컬 채번을 발급했습니다.");
  } catch (e) {
    localError.value = e instanceof Error ? e.message : "채번 발급에 실패했습니다.";
    notifications.error(localError.value);
  }
}

function editLocalSessionLog() {
  localError.value = null;
  const s = wb.localSession;
  if (!s) return;
  const cur = s.description || "";
  const next = window.prompt("작업 로그를 수정하세요:", cur);
  if (next === null || next === cur) return;
  void (async () => {
    try {
      await wb.setLocalSessionDescription(next);
      notifications.success("작업 로그를 저장했습니다.");
    } catch (e) {
      localError.value = e instanceof Error ? e.message : "수정에 실패했습니다.";
      notifications.error(localError.value);
    }
  })();
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
        class="flex max-h-[min(92vh,48rem)] w-full max-w-lg flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <div
          class="relative shrink-0 border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-4 pt-5"
        >
          <div
            class="pointer-events-none absolute -right-8 -top-10 h-32 w-32 rounded-full bg-primary/[0.12] blur-2xl"
            aria-hidden="true"
          />
          <div class="relative flex items-start justify-between gap-3">
            <div class="min-w-0">
              <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                로컬 채번 · 서버 버전
              </p>
              <h2
                id="workbench-modal-title"
                class="font-display text-xl font-semibold tracking-tight text-onSurface"
              >
                변경관리
              </h2>
              <p class="mt-1 text-xs leading-relaxed text-onSurface-variant">
                <strong class="text-onSurface">로컬</strong>은
                <code class="rounded bg-surface-low px-1 font-mono text-[10px]">chusa.db</code>
                편집용 채번입니다. 서버로 올린 뒤에는 동기화 정책에 맞게 세션을 마칩니다.
                <strong class="text-onSurface">서버</strong>는 Firestore에서 직접 수정한 뒤
                <code class="rounded bg-surface-low px-1 font-mono text-[10px]">_meta/data_version</code>
                을 발행해야 클라이언트에 반영이 완료됩니다.
              </p>
            </div>
            <button
              type="button"
              class="btn-secondary shrink-0 px-3 py-2 text-sm"
              @click="emit('close')"
            >
              닫기
            </button>
          </div>
        </div>

        <div class="min-h-0 flex-1 overflow-y-auto px-5 py-4">
          <!-- 로컬 -->
          <section class="mb-6 rounded-xl border border-outline-variant/70 bg-surface-low/40 p-4">
            <h3 class="text-sm font-semibold text-onSurface">로컬 작업 (채번)</h3>
            <p class="mt-1 text-[11px] leading-relaxed text-onSurface-variant">
              로컬 한자 저장·삭제 시 필요합니다.
              <RouterLink
                :to="{ name: 'db-sync' }"
                class="font-medium text-primary underline decoration-primary/30 underline-offset-2"
              >DB 동기화</RouterLink>로 서버에 반영할 수 있습니다.
            </p>
            <div
              v-if="localError"
              class="mt-2 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900"
            >
              {{ localError }}
            </div>
            <div
              v-if="wb.localSessionLoading"
              class="mt-3 text-xs text-onSurface-variant"
            >
              채번 정보를 불러오는 중…
            </div>
            <div
              v-else
              class="mt-3 flex flex-col gap-2 rounded-lg border border-outline-variant/60 bg-surface-lowest px-3 py-2.5"
            >
              <div class="flex flex-wrap items-center gap-2 text-sm">
                <span class="text-onSurface-variant">활성 채번</span>
                <span
                  v-if="wb.localSession"
                  class="font-mono font-semibold text-primary"
                >#{{ wb.localSession.id }}</span>
                <span v-else class="font-medium text-red-600">없음</span>
              </div>
              <p
                v-if="wb.localSession?.description"
                class="text-xs text-onSurface-variant"
              >
                {{ wb.localSession.description }}
              </p>
              <div class="mt-1 flex flex-wrap gap-2">
                <button
                  v-if="!wb.localSession"
                  type="button"
                  class="btn-primary px-3 py-1.5 text-xs"
                  @click="issueLocalSession"
                >
                  채번 발급
                </button>
                <template v-else>
                  <button
                    type="button"
                    class="btn-secondary px-3 py-1.5 text-xs"
                    title="기존 세션 종료 후 새 채번"
                    @click="issueLocalSession"
                  >
                    새 채번
                  </button>
                  <button
                    type="button"
                    class="btn-secondary px-3 py-1.5 text-xs"
                    @click="editLocalSessionLog"
                  >
                    작업 로그 수정
                  </button>
                </template>
              </div>
            </div>
          </section>

          <!-- 서버 -->
          <section
            v-if="auth.isAdmin"
            class="rounded-xl border border-outline-variant/70 bg-surface-low/30 p-4"
          >
            <h3 class="text-sm font-semibold text-onSurface">서버 데이터 발행</h3>
            <p class="mt-1 text-[11px] leading-relaxed text-onSurface-variant">
              메모를 남긴 뒤 발행하면 global과 hanja_basis·hanja_extend·hanja_word 버전이 각각 1씩 올라갑니다.
            </p>
            <div
              v-if="serverError"
              class="mt-2 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900"
            >
              {{ serverError }}
            </div>
            <label
              for="workbench-server-notes"
              class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
            >
              변경 내용 메모
            </label>
            <textarea
              id="workbench-server-notes"
              v-model="serverNotes"
              rows="3"
              class="input-minimal w-full resize-none py-2 text-sm"
              placeholder="예: 수(水)·화(火) 훈 수정, 단어 37건 추가"
            />
            <div
              class="mt-3 rounded-xl border border-outline-variant/60 bg-surface-low/50 px-3 py-2.5"
            >
              <div class="flex items-center justify-between text-xs">
                <span class="text-onSurface-variant">global 버전</span>
                <span class="font-mono font-semibold text-onSurface">
                  v{{ wb.version?.global ?? 0 }}
                  <span class="font-semibold text-primary">→ v{{ nextGlobal }}</span>
                </span>
              </div>
              <div
                v-if="wb.version?.publishedAt"
                class="mt-1.5 flex items-center justify-between text-xs"
              >
                <span class="text-onSurface-variant">마지막 발행</span>
                <span class="text-onSurface-variant">
                  {{ formatDate(wb.version.publishedAt) }}
                  <span v-if="wb.version.publishedBy" class="ml-1 text-onSurface-variant/70">
                    · {{ wb.version.publishedBy }}
                  </span>
                </span>
              </div>
            </div>
            <div class="mt-4 flex justify-end">
              <button
                type="button"
                class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
                :disabled="wb.isPublishing"
                @click="publishServer"
              >
                {{ wb.isPublishing ? "발행 중…" : "서버 버전 발행" }}
              </button>
            </div>
          </section>
          <p
            v-else
            class="rounded-xl border border-outline-variant/60 bg-surface-low/30 px-4 py-3 text-xs text-onSurface-variant"
          >
            서버 데이터 버전 발행(Firestore)은 <strong class="text-onSurface">admin</strong> 클레임이 있는 계정만 할 수 있습니다.
          </p>
        </div>

        <div
          class="flex shrink-0 justify-end border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3"
        >
          <button
            type="button"
            class="btn-secondary px-4 py-2 text-sm"
            @click="emit('close')"
          >
            닫기
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
