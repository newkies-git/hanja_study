<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { doc, getDoc } from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";

const props = defineProps<{
  open: boolean;
  queryId: string;
}>();

const emit = defineEmits<{ close: [] }>();

const isExtendDocumentLoading = ref(false);
const error = ref<string | null>(null);
const payload = ref<Record<string, unknown> | null>(null);

const EXTEND_KEY_PRIORITY = [
  "id", "char", "reading", "meaning", "radical", "radical_meaning",
  "stroke_count", "stroke_data_id", "difficulty", "category",
  "grade_level", "school_level", "shape_explanation", "origin_note",
] as const;

function sortExtendKeys(keys: string[]): string[] {
  const order = new Map<string, number>(
    EXTEND_KEY_PRIORITY.map((k, i) => [k, i]),
  );
  return [...keys].sort((a, b) => {
    const ia = order.has(a) ? order.get(a)! : 1_000;
    const ib = order.has(b) ? order.get(b)! : 1_000;
    if (ia !== ib) return ia - ib;
    return a.localeCompare(b, "ko");
  });
}

const fieldRows = computed(() => {
  const p = payload.value;
  if (!p) return [] as { key: string; value: string; isCode: boolean }[];
  return sortExtendKeys(Object.keys(p)).map((key) => {
    const v = p[key];
    let text: string;
    if (v === null || v === undefined) text = "—";
    else if (typeof v === "object") {
      try { text = JSON.stringify(v, null, 2); } catch { text = String(v); }
    } else text = String(v);
    const isCode = text.includes("\n") || text.length > 140 || /^\s*[\[{]/.test(text);
    return { key, value: text, isCode };
  });
});

async function loadExtendDocumentFromFirestore() {
  if (!props.queryId) return;
  isExtendDocumentLoading.value = true;
  error.value = null;
  payload.value = null;
  try {
    const db = getFirestoreDb();
    const snap = await getDoc(doc(db, "hanja_extend", props.queryId));
    if (!snap.exists()) {
      error.value = `hanja_extend / ${props.queryId} 문서가 없습니다.`;
    } else {
      payload.value = snap.data() as Record<string, unknown>;
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "hanja_extend 를 불러오지 못했습니다.";
  } finally {
    isExtendDocumentLoading.value = false;
  }
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") emit("close");
}

watch(() => props.open, (val) => {
  if (val) {
    loadExtendDocumentFromFirestore();
    document.addEventListener("keydown", handleKeyDown);
  } else {
    document.removeEventListener("keydown", handleKeyDown);
    error.value = null;
    payload.value = null;
  }
});

onUnmounted(() => { document.removeEventListener("keydown", handleKeyDown); });
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
      role="dialog"
      aria-modal="true"
      aria-labelledby="extend-modal-title"
      @click.self="emit('close')"
    >
      <div
        class="flex max-h-[min(90vh,52rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <!-- 헤더 -->
        <div
          class="relative overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-5 pt-5"
        >
          <div
            class="pointer-events-none absolute -right-8 -top-10 h-36 w-36 rounded-full bg-primary/[0.12] blur-2xl"
            aria-hidden="true"
          />
          <div class="relative flex items-start justify-between gap-4">
            <div class="flex min-w-0 items-start gap-3">
              <div
                class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white shadow-md shadow-primary/25"
                aria-hidden="true"
              >
                ext
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                  Firestore
                </p>
                <h2
                  id="extend-modal-title"
                  class="font-display text-xl font-semibold tracking-tight text-onSurface"
                >
                  hanja_extend
                </h2>
                <p class="mt-0.5 text-xs text-onSurface-variant">
                  확장 메타데이터 · 문서 ID 기준 조회
                </p>
              </div>
            </div>
            <button
              type="button"
              class="btn-secondary shrink-0 px-3 py-2 text-sm"
              @click="emit('close')"
            >
              닫기
            </button>
          </div>
          <div class="relative mt-4 flex flex-wrap items-center gap-2">
            <span
              class="inline-flex items-center rounded-lg border border-primary/20 bg-primary/[0.08] px-3 py-1.5 font-mono text-sm font-medium text-primary"
            >
              {{ queryId }}
            </span>
            <span
              v-if="!isExtendDocumentLoading && !error && fieldRows.length"
              class="rounded-full bg-onSurface/[0.06] px-2.5 py-1 text-[11px] font-medium text-onSurface-variant"
            >
              {{ fieldRows.length }}개 필드
            </span>
          </div>
        </div>

        <!-- 본문 -->
        <div class="min-h-0 flex-1 overflow-y-auto bg-surface px-4 py-4 sm:px-5 sm:py-5">
          <div
            v-if="isExtendDocumentLoading"
            class="flex flex-col items-center justify-center gap-4 py-16"
          >
            <div class="flex gap-1.5" role="status" aria-label="불러오는 중">
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
            </div>
            <p class="text-sm font-medium text-onSurface-variant">문서를 불러오는 중…</p>
          </div>

          <div
            v-else-if="error"
            class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3.5 text-sm text-red-900 shadow-sm"
          >
            <p class="font-semibold text-red-950">조회 실패</p>
            <p class="mt-1 leading-relaxed text-red-800/95">{{ error }}</p>
          </div>

          <dl
            v-else-if="fieldRows.length"
            class="grid grid-cols-1 gap-3 sm:grid-cols-2"
          >
            <div
              v-for="fr in fieldRows"
              :key="fr.key"
              class="group rounded-xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-float transition hover:border-primary/30 hover:shadow-[0_8px_24px_rgba(0,74,198,0.06)]"
              :class="fr.isCode ? 'sm:col-span-2' : ''"
            >
              <dt
                class="mb-2 flex items-center gap-2 text-[11px] font-semibold uppercase tracking-wide text-onSurface-variant"
              >
                <span
                  class="rounded-md bg-primary/10 px-2 py-0.5 font-mono normal-case tracking-normal text-primary"
                >
                  {{ fr.key }}
                </span>
              </dt>
              <dd class="min-w-0">
                <pre
                  v-if="fr.isCode"
                  class="max-h-64 overflow-auto rounded-lg border border-outline-variant/60 bg-surface-low px-3 py-2.5 font-mono text-[11px] leading-relaxed text-onSurface [tab-size:2]"
                >{{ fr.value }}</pre>
                <p v-else class="break-words text-sm leading-relaxed text-onSurface">
                  {{ fr.value }}
                </p>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
  </Teleport>
</template>
