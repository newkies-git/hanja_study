<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { useDataVersionStore, COLLECTION_NAMES, COLLECTION_LABELS } from "@/stores/dataVersion";
import { useNotificationsStore } from "@/stores/notifications";
import { useFocusTrap } from "@/composables/useFocusTrap";
import type { CollectionName } from "@/stores/dataVersion";

const props = defineProps<{ open: boolean }>();
const emit = defineEmits<{ close: [] }>();

const dvStore = useDataVersionStore();
const notifications = useNotificationsStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

const selectedCols = ref<CollectionName[]>([]);
const notes = ref("");
const localError = ref<string | null>(null);

watch(
  () => props.open,
  (val) => {
    if (val) {
      // 미발행 컬렉션을 기본 선택
      selectedCols.value = [...dvStore.pendingCollections];
      notes.value = "";
      localError.value = null;
    }
  },
);

function toggleCol(col: CollectionName) {
  if (selectedCols.value.includes(col)) {
    selectedCols.value = selectedCols.value.filter((c) => c !== col);
  } else {
    selectedCols.value = [...selectedCols.value, col];
  }
}

function colNextVersion(col: CollectionName): number {
  const cur = dvStore.version?.[col] ?? 0;
  return selectedCols.value.includes(col) ? cur + 1 : cur;
}

const nextGlobal = computed(() => (dvStore.version?.global ?? 0) + 1);

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

watch(() => props.open, (val) => {
  if (val) document.addEventListener("keydown", handleKeyDown);
  else document.removeEventListener("keydown", handleKeyDown);
});

onUnmounted(() => document.removeEventListener("keydown", handleKeyDown));

async function publish() {
  localError.value = null;
  if (selectedCols.value.length === 0) {
    localError.value = "하나 이상의 컬렉션을 선택하세요.";
    return;
  }
  try {
    await dvStore.publish(selectedCols.value, notes.value);
    notifications.success(`데이터 v${dvStore.version?.global ?? "?"} 발행 완료`);
    emit("close");
  } catch (e) {
    localError.value = e instanceof Error ? e.message : "발행에 실패했습니다.";
    notifications.error(localError.value);
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
      aria-labelledby="version-bump-modal-title"
      @click.self="emit('close')"
    >
      <div
        ref="containerRef"
        class="flex max-h-[min(90vh,42rem)] w-full max-w-md flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <!-- 헤더 -->
        <div
          class="relative shrink-0 overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-4 pt-5"
        >
          <div
            class="pointer-events-none absolute -right-8 -top-10 h-32 w-32 rounded-full bg-primary/[0.12] blur-2xl"
            aria-hidden="true"
          />
          <div class="relative flex items-start justify-between gap-3">
            <div>
              <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                Firestore · _meta/data_version
              </p>
              <h2
                id="version-bump-modal-title"
                class="font-display text-xl font-semibold tracking-tight text-onSurface"
              >
                데이터 버전 발행
              </h2>
              <p class="mt-0.5 text-xs text-onSurface-variant">
                변경된 컬렉션을 선택하고 메모를 남긴 후 발행하세요.
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

        <!-- 본문 -->
        <div class="min-h-0 flex-1 overflow-y-auto px-5 py-5">
          <div
            v-if="localError"
            class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900"
          >
            {{ localError }}
          </div>

          <!-- 컬렉션 선택 -->
          <p class="mb-2 text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant">
            변경된 컬렉션
          </p>
          <div class="mb-5 space-y-2">
            <label
              v-for="col in COLLECTION_NAMES"
              :key="col"
              class="flex cursor-pointer items-center gap-3 rounded-xl border px-4 py-3 transition select-none"
              :class="
                selectedCols.includes(col)
                  ? 'border-primary/25 bg-primary/[0.06] ring-1 ring-primary/10'
                  : 'border-outline-variant/70 bg-surface-low/60 hover:border-outline-variant'
              "
            >
              <input
                type="checkbox"
                class="h-4 w-4 shrink-0 accent-primary"
                :checked="selectedCols.includes(col)"
                @change="toggleCol(col)"
              />
              <span class="flex-1 text-sm font-medium text-onSurface">
                {{ COLLECTION_LABELS[col] }}
              </span>
              <span class="shrink-0 font-mono text-xs text-onSurface-variant">
                v{{ dvStore.version?.[col] ?? 0 }}
                <span
                  v-if="selectedCols.includes(col)"
                  class="font-semibold text-primary"
                >
                  → v{{ colNextVersion(col) }}
                </span>
              </span>
            </label>
          </div>

          <!-- 변경 내용 메모 -->
          <label
            for="version-notes"
            class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
          >
            변경 내용 메모
          </label>
          <textarea
            id="version-notes"
            v-model="notes"
            rows="3"
            class="input-minimal w-full resize-none py-2 text-sm"
            placeholder="예: 수(水)·화(火) 훈 수정, 단어 37건 추가"
          />

          <!-- 버전 미리보기 -->
          <div
            class="mt-4 rounded-xl border border-outline-variant/60 bg-surface-low/50 px-4 py-3"
          >
            <div class="flex items-center justify-between text-xs">
              <span class="text-onSurface-variant">global 버전</span>
              <span class="font-mono font-semibold text-onSurface">
                v{{ dvStore.version?.global ?? 0 }}
                <span v-if="selectedCols.length > 0" class="font-semibold text-primary">
                  → v{{ nextGlobal }}
                </span>
              </span>
            </div>
            <div
              v-if="dvStore.version?.publishedAt"
              class="mt-1.5 flex items-center justify-between text-xs"
            >
              <span class="text-onSurface-variant">마지막 발행</span>
              <span class="text-onSurface-variant">
                {{ formatDate(dvStore.version.publishedAt) }}
                <span v-if="dvStore.version.publishedBy" class="ml-1 text-onSurface-variant/70">
                  · {{ dvStore.version.publishedBy }}
                </span>
              </span>
            </div>
          </div>
        </div>

        <!-- 푸터 -->
        <div
          class="flex shrink-0 items-center justify-end gap-2 border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3"
        >
          <button
            type="button"
            class="btn-secondary px-4 py-2 text-sm"
            :disabled="dvStore.isPublishing"
            @click="emit('close')"
          >
            나중에
          </button>
          <button
            type="button"
            class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
            :disabled="dvStore.isPublishing || selectedCols.length === 0"
            @click="publish"
          >
            {{ dvStore.isPublishing ? "발행 중…" : "버전 발행" }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
