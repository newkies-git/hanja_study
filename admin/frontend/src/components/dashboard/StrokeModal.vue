<script setup lang="ts">
import { onUnmounted, ref, watch } from "vue";
import { doc, getDoc } from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";
import {
  extractSvgPaths,
  preferLongerSvgPaths,
} from "@/utils/firestoreStrokeMerge";
import StrokeOrderViewer from "@/components/dashboard/StrokeOrderViewer.vue";
import type { StrokeShape } from "@/components/dashboard/StrokeOrderViewer.vue";

type Row = Record<string, unknown>;

const props = defineProps<{
  open: boolean;
  entry: { id: string; data: Row } | null;
  extendId: string;
}>();

const emit = defineEmits<{ close: [] }>();

const isModalLoading = ref(false);
const error = ref<string | null>(null);
const shapes = ref<StrokeShape[]>([]);
const svgPaths = ref<string[]>([]);
const title = ref("");
const subtitle = ref("");
const footnote = ref<string | undefined>(undefined);

function parseStrokePoints(raw: unknown): [number, number][] {
  if (!Array.isArray(raw)) return [];
  const out: [number, number][] = [];
  for (const p of raw) {
    if (Array.isArray(p) && p.length >= 2) {
      const x = Number(p[0]);
      const y = Number(p[1]);
      if (Number.isFinite(x) && Number.isFinite(y)) out.push([x, y]);
    } else if (p && typeof p === "object" && "x" in p && "y" in p) {
      const x = Number((p as { x: unknown }).x);
      const y = Number((p as { y: unknown }).y);
      if (Number.isFinite(x) && Number.isFinite(y)) out.push([x, y]);
    }
  }
  return out;
}

function normalizeStrokes(raw: unknown): StrokeShape[] {
  if (!Array.isArray(raw)) return [];
  const list: StrokeShape[] = [];
  for (const s of raw) {
    if (!s || typeof s !== "object") continue;
    const order = Number((s as { order?: unknown }).order);
    const pts = parseStrokePoints((s as { points?: unknown }).points);
    if (pts.length < 2) continue;
    list.push({ order: Number.isFinite(order) ? order : list.length + 1, points: pts });
  }
  return list.sort((a, b) => a.order - b.order);
}

async function loadStrokeModalFromFirestore() {
  const entry = props.entry;
  if (!entry) return;
  isModalLoading.value = true;
  error.value = null;
  shapes.value = [];
  svgPaths.value = [];
  footnote.value = undefined;

  const row = entry.data;
  const extId = props.extendId;
  const read = String(row["음"] ?? "").trim();
  const mean = String(row["훈"] ?? "").trim();
  const label = mean && read ? `${mean} ${read}` : mean || read || "";
  const hanjaChar = String(row["한자"] ?? "").trim();
  title.value = hanjaChar || "—";
  subtitle.value = [label, extId].filter(Boolean).join(" · ") || "—";

  try {
    const db = getFirestoreDb();
    let strokesRaw: unknown;
    let strokeDataId: string | undefined;
    let charDoc = "";
    let totalStrokes: number | undefined;
    let svgPathsBest: string[] = [];

    const extSnap = await getDoc(doc(db, "hanja_extend", extId));
    if (extSnap.exists()) {
      const d = extSnap.data() as Record<string, unknown>;
      charDoc = String(d.char ?? "");
      if (typeof d.stroke_data_id === "string") strokeDataId = d.stroke_data_id.trim() || undefined;
      if (typeof d.total_strokes === "number") totalStrokes = d.total_strokes;
      else if (typeof d.stroke_count === "number") totalStrokes = d.stroke_count;
      strokesRaw = d.strokes;
      svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(d));
    }

    if ((!Array.isArray(strokesRaw) || strokesRaw.length === 0) && strokeDataId) {
      const stSnap = await getDoc(doc(db, "hanja_stroke", strokeDataId));
      if (stSnap.exists()) {
        const sd = stSnap.data() as Record<string, unknown>;
        strokesRaw = sd.strokes;
        if (!charDoc) charDoc = String(sd.char ?? "");
        if (totalStrokes === undefined && typeof sd.total_strokes === "number") totalStrokes = sd.total_strokes;
        svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(sd));
      }
    }

    if (!Array.isArray(strokesRaw) || strokesRaw.length === 0) {
      const basisSnap = await getDoc(doc(db, "hanja_basis", entry.id));
      if (basisSnap.exists()) {
        const bd = basisSnap.data() as Record<string, unknown>;
        if (!charDoc) charDoc = String(bd.char ?? bd.character ?? "");
        if (typeof bd.stroke_data_id === "string" && !strokeDataId) {
          strokeDataId = bd.stroke_data_id.trim() || undefined;
        }
        strokesRaw = bd.strokes;
        svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(bd));
        if ((!Array.isArray(strokesRaw) || strokesRaw.length === 0) && strokeDataId) {
          const stSnap2 = await getDoc(doc(db, "hanja_stroke", strokeDataId));
          if (stSnap2.exists()) {
            const sd = stSnap2.data() as Record<string, unknown>;
            strokesRaw = sd.strokes;
            if (!charDoc) charDoc = String(sd.char ?? "");
            svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(sd));
          }
        }
      }
    }

    svgPaths.value = svgPathsBest;
    const resolved = normalizeStrokes(strokesRaw);
    shapes.value = resolved;
    if (charDoc.trim()) title.value = charDoc.trim();
    const n = totalStrokes ?? resolved.length;
    subtitle.value = [label, extId, n ? `${n}획` : ""].filter(Boolean).join(" · ");
    footnote.value = [
      strokeDataId && `hanja_stroke: ${strokeDataId}`,
      `hanja_extend: ${extId}`,
    ]
      .filter(Boolean)
      .join(" | ");

    if (resolved.length === 0 && svgPathsBest.length === 0) {
      error.value = "표시할 획 데이터가 없습니다. hanja_extend · hanja_stroke · hanja_basis를 확인하세요.";
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "획 데이터를 불러오지 못했습니다.";
  } finally {
    isModalLoading.value = false;
  }
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") emit("close");
}

watch(() => props.open, (val) => {
  if (val) {
    loadStrokeModalFromFirestore();
    document.addEventListener("keydown", handleKeyDown);
  } else {
    document.removeEventListener("keydown", handleKeyDown);
    error.value = null;
    shapes.value = [];
    svgPaths.value = [];
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
      aria-labelledby="stroke-modal-title"
      @click.self="emit('close')"
    >
      <div
        class="flex max-h-[min(92vh,56rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <!-- 헤더 -->
        <div
          class="relative shrink-0 overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-5 pt-5"
        >
          <div
            class="pointer-events-none absolute -right-8 -top-10 h-36 w-36 rounded-full bg-primary/[0.12] blur-2xl"
            aria-hidden="true"
          />
          <div class="relative flex items-start justify-between gap-4">
            <div class="flex min-w-0 items-start gap-3">
              <div
                class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-lg font-bold text-white shadow-md shadow-primary/25"
                aria-hidden="true"
              >
                {{ title && title.length <= 2 ? title : "획" }}
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                  Stroke order
                </p>
                <h2
                  id="stroke-modal-title"
                  class="font-display text-xl font-semibold tracking-tight text-onSurface"
                >
                  획순
                </h2>
                <p class="mt-0.5 truncate text-xs text-onSurface-variant">
                  {{ subtitle || "—" }}
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
        </div>

        <!-- 본문 -->
        <div
          class="min-h-0 flex-1 overflow-y-auto overflow-x-hidden bg-surface px-4 py-4 sm:px-5 sm:py-5"
        >
          <div
            v-if="isModalLoading"
            class="flex flex-col items-center justify-center gap-4 py-14 text-sm text-onSurface-variant"
            role="status"
            aria-live="polite"
          >
            <span class="flex gap-1.5" aria-hidden="true">
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
            </span>
            획 데이터를 불러오는 중…
          </div>
          <div
            v-else-if="error"
            class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3.5 text-sm text-red-900 shadow-sm"
          >
            <p class="font-semibold text-red-950">획순 로드 실패</p>
            <p class="mt-1 leading-relaxed text-red-800/95">{{ error }}</p>
          </div>
          <div v-else class="w-full min-w-0">
            <StrokeOrderViewer
              :strokes="shapes"
              :svg-paths="svgPaths"
              :title="title"
              :subtitle="subtitle"
              :footnote="footnote"
            />
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
