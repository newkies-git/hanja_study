<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from "vue";
import {
  collection,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
} from "firebase/firestore";
import StrokeOrderViewer from "@/components/dashboard/StrokeOrderViewer.vue";
import type { StrokeShape } from "@/components/dashboard/StrokeOrderViewer.vue";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";

const FILTER_FETCH_CAP = 2500;
const PAGE_SIZE_OPTIONS = [10, 20, 50] as const;

/** 테이블 열 순서 (CSV·Firestore 필드명과 동일 가정) */
const COLUMN_ORDER = [
  "id",
  "음",
  "한자",
  "훈",
  "전체",
  "구분",
  "훈음",
] as const;

type Row = Record<string, unknown>;

type DocEntry = { id: string; data: Row };

const allDocs = ref<DocEntry[]>([]);
const rows = ref<Row[]>([]);
const ids = ref<string[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const filterWarning = ref<string | null>(null);

const pageSize = ref<(typeof PAGE_SIZE_OPTIONS)[number]>(20);
const currentPage = ref(0);

const filter구분 = ref<string>("");
const search한자 = ref("");
const search음 = ref("");
const search훈 = ref("");

/** 체크박스 선택 (문서 ID = hanja_basis 키) */
const selectedIds = ref<Set<string>>(new Set());
const headerCheckboxRef = ref<HTMLInputElement | null>(null);

/** hanja_extend 조회 모달 */
const extendModalOpen = ref(false);
const extendLoading = ref(false);
const extendError = ref<string | null>(null);
const extendPayload = ref<Record<string, unknown> | null>(null);
const extendQueryId = ref<string>("");

/** 획순(SVG) 모달 */
const strokeModalOpen = ref(false);
const strokeLoading = ref(false);
const strokeError = ref<string | null>(null);
const strokeShapes = ref<StrokeShape[]>([]);
const strokeModalTitle = ref("");
const strokeModalSubtitle = ref("");
const strokeModalFootnote = ref<string | undefined>(undefined);
/** stroke_sample 과 동일 렌더용 원본 path `d` 배열 (hanja_stroke.svg_paths) */
const strokeModalSvgPaths = ref<string[]>([]);

const filterActive = computed(() => {
  return (
    filter구분.value !== "" ||
    search한자.value.trim() !== "" ||
    search음.value.trim() !== "" ||
    search훈.value.trim() !== ""
  );
});

function basisDisplayId(docId: string, row: Row): string {
  const hanja = String(row["한자"] ?? "").trim();
  const source = hanja || docId;
  const cp = source.codePointAt(0);
  if (cp === undefined) return docId;
  return `H${cp.toString(16).toUpperCase()}`;
}

function contains(hay: string, needle: string): boolean {
  if (!needle.trim()) return true;
  return hay.toLowerCase().includes(needle.trim().toLowerCase());
}

function rowMatchesFilter(row: Row): boolean {
  if (filter구분.value !== "") {
    const g = String(row["구분"] ?? "").trim();
    if (g !== filter구분.value) return false;
  }

  if (!contains(String(row["한자"] ?? ""), search한자.value)) return false;
  if (!contains(String(row["음"] ?? ""), search음.value)) return false;
  if (!contains(String(row["훈"] ?? ""), search훈.value)) return false;

  return true;
}

const filteredDocs = computed(() =>
  allDocs.value.filter(({ data }) => rowMatchesFilter(data)),
);

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredDocs.value.length / pageSize.value)),
);

const totalCount = computed(() => filteredDocs.value.length);

const rangeStart = computed(() =>
  totalCount.value === 0
    ? 0
    : currentPage.value * pageSize.value + 1,
);

const rangeEnd = computed(() =>
  Math.min((currentPage.value + 1) * pageSize.value, totalCount.value),
);

/** 1-based 페이지 번호 버튼용: 1, 2, …, ellipsis, 10 */
const paginationItems = computed((): Array<number | "ellipsis"> => {
  const total = totalPages.value;
  const cur = currentPage.value + 1;
  if (total <= 1) return [1];
  if (total <= 10) {
    return Array.from({ length: total }, (_, i) => i + 1);
  }
  const out: Array<number | "ellipsis"> = [];
  const push = (x: number | "ellipsis") => {
    if (out.length && out[out.length - 1] === x) return;
    out.push(x);
  };
  push(1);
  const left = Math.max(2, cur - 2);
  const right = Math.min(total - 1, cur + 2);
  if (left > 2) push("ellipsis");
  for (let p = left; p <= right; p++) push(p);
  if (right < total - 1) push("ellipsis");
  push(total);
  return out;
});

function syncSliceToRows() {
  const list = filteredDocs.value;
  const start = currentPage.value * pageSize.value;
  const slice = list.slice(start, start + pageSize.value);
  rows.value = slice.map((x) => x.data);
  ids.value = slice.map((x) => x.id);
}

function clampPage() {
  const max = Math.max(0, totalPages.value - 1);
  if (currentPage.value > max) currentPage.value = max;
}

watch([filteredDocs, currentPage, pageSize], () => {
  clampPage();
  syncSliceToRows();
});

const visibleSelectedCount = computed(() =>
  ids.value.filter((id) => selectedIds.value.has(id)).length,
);

const allVisibleSelected = computed(
  () =>
    ids.value.length > 0 &&
    visibleSelectedCount.value === ids.value.length,
);

function updateHeaderCheckboxIndeterminate() {
  nextTick(() => {
    const el = headerCheckboxRef.value;
    if (!el) return;
    const n = visibleSelectedCount.value;
    const len = ids.value.length;
    el.indeterminate = n > 0 && n < len;
  });
}

watch([ids, selectedIds], updateHeaderCheckboxIndeterminate, { deep: true });

function setSelected(mutate: (s: Set<string>) => void) {
  const s = new Set(selectedIds.value);
  mutate(s);
  selectedIds.value = s;
}

function toggleRow(docId: string, checked: boolean) {
  setSelected((s) => {
    if (checked) s.add(docId);
    else s.delete(docId);
  });
}

function toggleAllVisible(checked: boolean) {
  setSelected((s) => {
    for (const id of ids.value) {
      if (checked) s.add(id);
      else s.delete(id);
    }
  });
}

const soleSelectedBasisDocId = computed((): string | null => {
  if (selectedIds.value.size !== 1) return null;
  return selectedIds.value.values().next().value ?? null;
});

const soleSelectedEntry = computed((): DocEntry | null => {
  const id = soleSelectedBasisDocId.value;
  if (!id) return null;
  return allDocs.value.find((d) => d.id === id) ?? null;
});

const canUseSelectionActions = computed(
  () => soleSelectedBasisDocId.value !== null && !loading.value,
);

/** Firestore `hanja_extend` 문서 ID (JSON `id` 및 표시용 H+16진과 동일) */
function hanjaExtendDocId(basisDocId: string, row: Row): string {
  return basisDisplayId(basisDocId, row);
}

function leadingHanjaChar(row: Row): string {
  const raw = String(row["한자"] ?? "").trim();
  const cp = raw.codePointAt(0);
  return cp === undefined ? "" : String.fromCodePoint(cp);
}

/** 레거시 `hanja` 컬렉션 문서 ID */
function hanjaCollectionDocId(row: Row): string | null {
  const raw = String(row["한자"] ?? "").trim();
  const cp = raw.codePointAt(0);
  if (cp === undefined) return null;
  const hex = cp.toString(16).toUpperCase().padStart(5, "0");
  return `hanja_${hex}`;
}

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

function normalizeStrokesFromFirestore(raw: unknown): StrokeShape[] {
  if (!Array.isArray(raw)) return [];
  const list: StrokeShape[] = [];
  for (const s of raw) {
    if (!s || typeof s !== "object") continue;
    const order = Number((s as { order?: unknown }).order);
    const pts = parseStrokePoints((s as { points?: unknown }).points);
    if (pts.length < 2) continue;
    list.push({
      order: Number.isFinite(order) ? order : list.length + 1,
      points: pts,
    });
  }
  return list.sort((a, b) => a.order - b.order);
}

function extractSvgPathsFromDoc(data: Record<string, unknown>): string[] {
  const raw = data.svg_paths;
  if (!Array.isArray(raw)) return [];
  const out: string[] = [];
  for (const x of raw) {
    if (typeof x === "string" && x.trim().length > 0) {
      out.push(x.trim());
    }
  }
  return out;
}

function preferLongerSvgPaths(
  current: string[],
  candidate: string[],
): string[] {
  return candidate.length > current.length ? candidate : current;
}

/** hanja_extend 필드 표시 순서 (나머지는 가나다순) */
const EXTEND_KEY_PRIORITY = [
  "id",
  "char",
  "reading",
  "meaning",
  "radical",
  "radical_meaning",
  "stroke_count",
  "stroke_data_id",
  "difficulty",
  "category",
  "grade_level",
  "school_level",
  "shape_explanation",
  "origin_note",
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

const extendFieldRows = computed(() => {
  const p = extendPayload.value;
  if (!p)
    return [] as { key: string; value: string; isCode: boolean }[];
  return sortExtendKeys(Object.keys(p)).map((key) => {
    const v = p[key];
    let text: string;
    if (v === null || v === undefined) text = "—";
    else if (typeof v === "object") {
      try {
        text = JSON.stringify(v, null, 2);
      } catch {
        text = String(v);
      }
    } else text = String(v);
    const isCode =
      text.includes("\n") || text.length > 140 || /^\s*[\[{]/.test(text);
    return { key, value: text, isCode };
  });
});

async function openExtendLookupModal() {
  const entry = soleSelectedEntry.value;
  if (!entry || !isFirebaseConfigured()) return;
  extendModalOpen.value = true;
  extendLoading.value = true;
  extendError.value = null;
  extendPayload.value = null;
  const qid = hanjaExtendDocId(entry.id, entry.data);
  extendQueryId.value = qid;
  try {
    const db = getFirestoreDb();
    const snap = await getDoc(doc(db, "hanja_extend", qid));
    if (!snap.exists()) {
      extendError.value = `hanja_extend / ${qid} 문서가 없습니다.`;
    } else {
      extendPayload.value = snap.data() as Record<string, unknown>;
    }
  } catch (e) {
    extendError.value =
      e instanceof Error ? e.message : "hanja_extend 를 불러오지 못했습니다.";
  } finally {
    extendLoading.value = false;
  }
}

function closeExtendModal() {
  extendModalOpen.value = false;
  extendError.value = null;
  extendPayload.value = null;
}

async function openStrokeOrderModal() {
  const entry = soleSelectedEntry.value;
  if (!entry || !isFirebaseConfigured()) return;
  strokeModalOpen.value = true;
  strokeLoading.value = true;
  strokeError.value = null;
  strokeShapes.value = [];
  strokeModalSvgPaths.value = [];
  strokeModalFootnote.value = undefined;
  const row = entry.data;
  const extendId = hanjaExtendDocId(entry.id, row);
  const read = String(row["음"] ?? "").trim();
  const mean = String(row["훈"] ?? "").trim();
  const label =
    mean && read ? `${mean} ${read}` : mean || read || "";
  strokeModalTitle.value = leadingHanjaChar(row) || "—";
  strokeModalSubtitle.value = [label, extendId].filter(Boolean).join(" · ") || "—";

  try {
    const db = getFirestoreDb();
    let strokesRaw: unknown;
    let strokeDataId: string | undefined;
    let charDoc = "";
    let totalStrokes: number | undefined;
    let svgPathsBest: string[] = [];

    const extSnap = await getDoc(doc(db, "hanja_extend", extendId));
    if (extSnap.exists()) {
      const d = extSnap.data() as Record<string, unknown>;
      charDoc = String(d.char ?? "");
      if (typeof d.stroke_data_id === "string") {
        strokeDataId = d.stroke_data_id.trim() || undefined;
      }
      if (typeof d.total_strokes === "number") {
        totalStrokes = d.total_strokes;
      } else if (typeof d.stroke_count === "number") {
        totalStrokes = d.stroke_count;
      }
      strokesRaw = d.strokes;
      svgPathsBest = preferLongerSvgPaths(
        svgPathsBest,
        extractSvgPathsFromDoc(d),
      );
    }

    if (
      (!Array.isArray(strokesRaw) || strokesRaw.length === 0) &&
      strokeDataId
    ) {
      const stSnap = await getDoc(doc(db, "hanja_stroke", strokeDataId));
      if (stSnap.exists()) {
        const sd = stSnap.data() as Record<string, unknown>;
        strokesRaw = sd.strokes;
        if (!charDoc) charDoc = String(sd.char ?? "");
        if (totalStrokes === undefined && typeof sd.total_strokes === "number") {
          totalStrokes = sd.total_strokes;
        }
        svgPathsBest = preferLongerSvgPaths(
          svgPathsBest,
          extractSvgPathsFromDoc(sd),
        );
      }
    }

    if (!Array.isArray(strokesRaw) || strokesRaw.length === 0) {
      const hanjaId = hanjaCollectionDocId(row);
      if (hanjaId) {
        const hSnap = await getDoc(doc(db, "hanja", hanjaId));
        if (hSnap.exists()) {
          const hd = hSnap.data() as Record<string, unknown>;
          if (!charDoc) charDoc = String(hd.char ?? hd.character ?? "");
          if (typeof hd.stroke_data_id === "string" && !strokeDataId) {
            strokeDataId = hd.stroke_data_id.trim() || undefined;
          }
          strokesRaw = hd.strokes;
          svgPathsBest = preferLongerSvgPaths(
            svgPathsBest,
            extractSvgPathsFromDoc(hd),
          );
          if (
            (!Array.isArray(strokesRaw) || strokesRaw.length === 0) &&
            strokeDataId
          ) {
            const stSnap2 = await getDoc(doc(db, "hanja_stroke", strokeDataId));
            if (stSnap2.exists()) {
              const sd = stSnap2.data() as Record<string, unknown>;
              strokesRaw = sd.strokes;
              if (!charDoc) charDoc = String(sd.char ?? "");
              svgPathsBest = preferLongerSvgPaths(
                svgPathsBest,
                extractSvgPathsFromDoc(sd),
              );
            }
          }
        }
      }
    }

    strokeModalSvgPaths.value = svgPathsBest;

    const shapes = normalizeStrokesFromFirestore(strokesRaw);
    strokeShapes.value = shapes;
    if (charDoc.trim()) strokeModalTitle.value = charDoc.trim();
    const n = totalStrokes ?? shapes.length;
    strokeModalSubtitle.value = [
      label,
      extendId,
      n ? `${n}획` : "",
    ]
      .filter(Boolean)
      .join(" · ");
    strokeModalFootnote.value = [
      strokeDataId && `hanja_stroke: ${strokeDataId}`,
      `hanja_extend: ${extendId}`,
    ]
      .filter(Boolean)
      .join(" | ");

    if (shapes.length === 0 && svgPathsBest.length === 0) {
      strokeError.value =
        "표시할 획 데이터가 없습니다. hanja_extend · hanja_stroke · hanja(레거시)를 확인하세요.";
    }
  } catch (e) {
    strokeError.value =
      e instanceof Error ? e.message : "획 데이터를 불러오지 못했습니다.";
  } finally {
    strokeLoading.value = false;
  }
}

function closeStrokeModal() {
  strokeModalOpen.value = false;
  strokeError.value = null;
  strokeShapes.value = [];
  strokeModalSvgPaths.value = [];
}

async function loadAll() {
  if (!isFirebaseConfigured()) {
    error.value = "Firebase가 설정되지 않았습니다.";
    return;
  }
  loading.value = true;
  error.value = null;
  try {
    const db = getFirestoreDb();
    const q = query(
      collection(db, "hanja_basis"),
      orderBy(documentId()),
      limit(FILTER_FETCH_CAP),
    );
    const snap = await getDocs(q);
    allDocs.value = snap.docs.map((d) => ({
      id: d.id,
      data: d.data() as Row,
    }));
    filterWarning.value =
      snap.docs.length >= FILTER_FETCH_CAP
        ? `최대 ${FILTER_FETCH_CAP}건만 불러옵니다. 나머지는 콘솔·다른 도구로 확인하세요.`
        : null;
    currentPage.value = 0;
    syncSliceToRows();
  } catch (e) {
    error.value =
      e instanceof Error ? e.message : "hanja_basis 를 불러오지 못했습니다.";
    allDocs.value = [];
    rows.value = [];
    ids.value = [];
    filterWarning.value = null;
  } finally {
    loading.value = false;
  }
}

function goToPage(zeroBased: number) {
  const max = Math.max(0, totalPages.value - 1);
  currentPage.value = Math.min(Math.max(0, zeroBased), max);
}

function prevPage() {
  goToPage(currentPage.value - 1);
}

function nextPage() {
  goToPage(currentPage.value + 1);
}

let debounceId: ReturnType<typeof setTimeout> | null = null;
function scheduleResetPage() {
  if (debounceId) clearTimeout(debounceId);
  debounceId = setTimeout(() => {
    currentPage.value = 0;
  }, 300);
}

watch([search한자, search음, search훈], () => scheduleResetPage());

watch(filter구분, () => {
  currentPage.value = 0;
  syncSliceToRows();
});

watch(pageSize, () => {
  currentPage.value = 0;
  syncSliceToRows();
});

async function refresh() {
  await loadAll();
}

function clearFilters() {
  filter구분.value = "";
  search한자.value = "";
  search음.value = "";
  search훈.value = "";
  currentPage.value = 0;
  syncSliceToRows();
}

const canClearFilters = computed(() => filterActive.value);

onMounted(() => {
  void loadAll();
  updateHeaderCheckboxIndeterminate();
});
</script>

<template>
  <div class="space-y-6">
    <div class="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
      <div>
        <h1 class="font-display text-2xl font-semibold text-onSurface">
          기준 데이터
        </h1>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <button
          type="button"
          class="btn-primary text-sm"
          :disabled="!canUseSelectionActions"
          title="한 행만 선택해야 합니다"
          @click="openExtendLookupModal"
        >
          조회
        </button>
        <button
          type="button"
          class="btn-secondary text-sm"
          :disabled="!canUseSelectionActions"
          title="한 행만 선택해야 합니다"
          @click="openStrokeOrderModal"
        >
          획순
        </button>
        <button
          type="button"
          class="btn-secondary text-sm"
          :disabled="loading"
          @click="refresh"
        >
          새로고침
        </button>
      </div>
    </div>

    <div class="space-y-4 rounded-xl bg-surface-low p-4">
      <div class="flex flex-wrap items-end gap-4">
        <div class="min-w-[5.5rem]">
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >페이지당</label
          >
          <select
            v-model="pageSize"
            class="input-minimal w-full cursor-pointer py-2"
          >
            <option
              v-for="n in PAGE_SIZE_OPTIONS"
              :key="n"
              :value="n"
            >
              {{ n }}건
            </option>
          </select>
        </div>
        <div class="min-w-[8rem]">
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >구분</label
          >
          <select
            v-model="filter구분"
            class="input-minimal w-full cursor-pointer py-2"
          >
            <option value="">전체</option>
            <option value="중">중</option>
            <option value="고">고</option>
          </select>
        </div>
        <button
          type="button"
          class="btn-secondary text-sm self-end"
          :disabled="!canClearFilters"
          @click="clearFilters"
        >
          필터 초기화
        </button>
      </div>

      <div class="grid max-w-3xl gap-3 sm:grid-cols-3">
        <div>
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >한자</label
          >
          <input
            v-model="search한자"
            type="search"
            class="input-minimal py-2"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div>
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >음</label
          >
          <input
            v-model="search음"
            type="search"
            class="input-minimal py-2"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div>
          <label class="mb-1 block text-xs font-medium text-onSurface-variant"
            >훈</label
          >
          <input
            v-model="search훈"
            type="search"
            class="input-minimal py-2"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
      </div>
    </div>

    <p v-if="filterWarning" class="text-sm text-amber-800">{{ filterWarning }}</p>
    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-else-if="loading" class="text-onSurface-variant">불러오는 중…</p>
    <p
      v-else-if="!loading && !allDocs.length"
      class="text-onSurface-variant"
    >
      문서가 없습니다. CSV 업로드로 채울 수 있습니다.
    </p>
    <p
      v-else-if="!loading && allDocs.length && !totalCount"
      class="text-onSurface-variant"
    >
      필터와 일치하는 행이 없습니다. 조건을 바꿔 보세요.
    </p>

    <template v-if="rows.length">
    <p class="text-xs leading-relaxed text-onSurface-variant">
      한 행을 선택한 뒤 <strong class="font-medium text-onSurface">조회</strong>는
      Firestore <code class="rounded bg-surface-low px-1">hanja_extend</code> 필드를,
      <strong class="font-medium text-onSurface">획순</strong>은
      <code class="rounded bg-surface-low px-1">hanja_extend</code> /
      <code class="rounded bg-surface-low px-1">hanja_stroke</code> /
      레거시 <code class="rounded bg-surface-low px-1">hanja</code> 순으로 획 좌표를 불러와 SVG로 표시합니다.
    </p>

    <div class="overflow-x-auto rounded-xl bg-surface-lowest shadow-float">
      <table class="w-full min-w-[760px] border-collapse text-left text-sm">
        <thead>
          <tr class="bg-surface-low text-xs text-onSurface-variant">
            <th class="w-10 px-2 py-3">
              <input
                ref="headerCheckboxRef"
                type="checkbox"
                class="h-4 w-4 rounded border-outline-variant text-primary focus:ring-primary"
                :checked="allVisibleSelected"
                aria-label="현재 페이지 전체 선택"
                @change="
                  toggleAllVisible(
                    ($event.target as HTMLInputElement).checked,
                  )
                "
              />
            </th>
            <th
              v-for="col in COLUMN_ORDER"
              :key="col"
              class="px-4 py-3 font-medium"
            >
              {{ col === "id" ? "ID" : col }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(row, i) in rows"
            :key="ids[i] ?? i"
            class="border-t border-outline-variant bg-surface-lowest"
          >
            <td class="px-2 py-3">
              <input
                type="checkbox"
                class="h-4 w-4 rounded border-outline-variant text-primary focus:ring-primary"
                :checked="selectedIds.has(ids[i]!)"
                :aria-label="`선택 ${basisDisplayId(ids[i]!, row)}`"
                @change="
                  toggleRow(
                    ids[i]!,
                    ($event.target as HTMLInputElement).checked,
                  )
                "
              />
            </td>
            <td
              v-for="col in COLUMN_ORDER"
              :key="col"
              class="max-w-[14rem] truncate px-4 py-3 text-onSurface"
              :class="[
                col === '한자' ? 'font-display text-lg leading-tight' : '',
                col === 'id' ? 'font-mono text-xs text-primary' : '',
              ]"
              :title="
                col === 'id'
                  ? basisDisplayId(ids[i]!, row)
                  : String(row[col] ?? '')
              "
            >
              <template v-if="col === 'id'">
                {{ basisDisplayId(ids[i]!, row) }}
              </template>
              <template v-else>
                {{ row[col] ?? "—" }}
              </template>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div
      class="mt-4 flex flex-col gap-3 border-t border-outline-variant pt-4 sm:flex-row sm:items-center sm:justify-between"
    >
      <p class="text-xs text-onSurface-variant">
        {{ rangeStart }}–{{ rangeEnd }} / {{ totalCount }}건
      </p>
      <div class="flex flex-wrap items-center justify-end gap-2">
        <button
          type="button"
          class="btn-secondary px-3 py-1.5 text-sm"
          :disabled="loading || currentPage <= 0"
          @click="prevPage"
        >
          이전
        </button>
        <template v-for="(item, idx) in paginationItems" :key="'p-' + idx">
          <span
            v-if="item === 'ellipsis'"
            class="px-1 text-onSurface-variant"
          >…</span>
          <button
            v-else
            type="button"
            class="min-w-[2.25rem] rounded-md px-2 py-1.5 text-sm transition"
            :class="
              item === currentPage + 1
                ? 'bg-primary text-white shadow-sm'
                : 'bg-surface-low text-onSurface hover:bg-surface-bright'
            "
            :disabled="loading"
            @click="goToPage(item - 1)"
          >
            {{ item }}
          </button>
        </template>
        <button
          type="button"
          class="btn-secondary px-3 py-1.5 text-sm"
          :disabled="loading || currentPage >= totalPages - 1"
          @click="nextPage"
        >
          다음
        </button>
      </div>
    </div>
    </template>

    <!-- hanja_extend 조회 모달 -->
    <Teleport to="body">
      <div
        v-if="extendModalOpen"
        class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
        role="dialog"
        aria-modal="true"
        aria-labelledby="basis-extend-modal-title"
        @click.self="closeExtendModal"
      >
        <div
          class="flex max-h-[min(90vh,52rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
        >
          <div
            class="relative overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-5 pt-5"
          >
            <div
              class="pointer-events-none absolute -right-8 -top-10 h-36 w-36 rounded-full bg-primary/[0.12] blur-2xl"
            />
            <div class="relative flex items-start justify-between gap-4">
              <div class="min-w-0 flex items-start gap-3">
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
                    id="basis-extend-modal-title"
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
                @click="closeExtendModal"
              >
                닫기
              </button>
            </div>
            <div class="relative mt-4 flex flex-wrap items-center gap-2">
              <span
                class="inline-flex items-center rounded-lg border border-primary/20 bg-primary/[0.08] px-3 py-1.5 font-mono text-sm font-medium text-primary"
              >
                {{ extendQueryId }}
              </span>
              <span
                v-if="!extendLoading && !extendError && extendFieldRows.length"
                class="rounded-full bg-onSurface/[0.06] px-2.5 py-1 text-[11px] font-medium text-onSurface-variant"
              >
                {{ extendFieldRows.length }}개 필드
              </span>
            </div>
          </div>

          <div
            class="min-h-0 flex-1 overflow-y-auto bg-surface px-4 py-4 sm:px-5 sm:py-5"
          >
            <div
              v-if="extendLoading"
              class="flex flex-col items-center justify-center gap-4 py-16"
            >
              <div
                class="flex gap-1.5"
                role="status"
                aria-label="불러오는 중"
              >
                <span
                  class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]"
                />
                <span
                  class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]"
                />
                <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
              </div>
              <p class="text-sm font-medium text-onSurface-variant">
                문서를 불러오는 중…
              </p>
            </div>

            <div
              v-else-if="extendError"
              class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3.5 text-sm text-red-900 shadow-sm"
            >
              <p class="font-semibold text-red-950">조회 실패</p>
              <p class="mt-1 leading-relaxed text-red-800/95">
                {{ extendError }}
              </p>
            </div>

            <dl
              v-else-if="extendFieldRows.length"
              class="grid gap-3"
            >
              <div
                v-for="fr in extendFieldRows"
                :key="fr.key"
                class="group rounded-xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-float transition hover:border-primary/30 hover:shadow-[0_8px_24px_rgba(0,74,198,0.06)]"
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
                  <p
                    v-else
                    class="break-words text-sm leading-relaxed text-onSurface"
                  >
                    {{ fr.value }}
                  </p>
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 획순 SVG 모달 -->
    <Teleport to="body">
      <div
        v-if="strokeModalOpen"
        class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/40 p-4 backdrop-blur-sm"
        role="dialog"
        aria-modal="true"
        aria-labelledby="basis-stroke-modal-title"
        @click.self="closeStrokeModal"
      >
        <div
          class="flex max-h-[min(92vh,56rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant bg-surface-lowest shadow-float"
        >
          <div
            class="flex shrink-0 items-center justify-between border-b border-outline-variant px-5 py-4"
          >
            <h2
              id="basis-stroke-modal-title"
              class="text-lg font-semibold text-onSurface"
            >
              획순
            </h2>
            <button
              type="button"
              class="rounded-lg px-3 py-1.5 text-sm text-onSurface-variant hover:bg-surface-low"
              @click="closeStrokeModal"
            >
              닫기
            </button>
          </div>
          <div
            class="min-h-0 flex-1 overflow-y-auto overflow-x-hidden px-4 py-4 sm:px-6"
          >
            <p
              v-if="strokeLoading"
              class="py-8 text-center text-sm text-onSurface-variant"
            >
              획 데이터를 불러오는 중…
            </p>
            <p
              v-else-if="strokeError"
              class="py-4 text-center text-sm text-red-600"
            >
              {{ strokeError }}
            </p>
            <div v-else class="w-full min-w-0">
              <StrokeOrderViewer
                :strokes="strokeShapes"
                :svg-paths="strokeModalSvgPaths"
                :title="strokeModalTitle"
                :subtitle="strokeModalSubtitle"
                :footnote="strokeModalFootnote"
              />
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
