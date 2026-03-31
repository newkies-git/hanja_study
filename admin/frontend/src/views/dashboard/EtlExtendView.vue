<script setup lang="ts">
import {
  computed,
  nextTick,
  onMounted,
  ref,
  watch,
} from "vue";
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

/** ETL 열 기준: 전체 / Yes(Y) / No(N) */
const filterEtl = ref<"" | "Y" | "N">("");
const search한자 = ref("");
const search음 = ref("");
const search훈 = ref("");

/** 선택된 문서 ID (현재 페이지·전체 목록 공통) */
const selectedIds = ref<Set<string>>(new Set());
/** 행별 비고 (클라이언트만; 추후 서버 연동 시 교체) */
const remarksByDocId = ref<Record<string, string>>({});
/** ETL 성공한 문서 ID (클라이언트 세션; Firestore `etl`과 함께 Yes 판단) */
const etlSucceededIds = ref<Set<string>>(new Set());

const headerCheckboxRef = ref<HTMLInputElement | null>(null);

function rowIndicatesEtlSuccess(row: Row): boolean {
  const raw = row["etl"];
  if (raw === true) return true;
  if (raw === "true" || raw === "True") return true;
  if (typeof raw === "string" && raw.trim().toLowerCase() === "yes") {
    return true;
  }
  return false;
}

function isEtlYes(docId: string, row: Row): boolean {
  if (etlSucceededIds.value.has(docId)) return true;
  return rowIndicatesEtlSuccess(row);
}

function etlLabel(docId: string, row: Row): "Yes" | "No" {
  return isEtlYes(docId, row) ? "Yes" : "No";
}

const filterActive = computed(() => {
  return (
    filterEtl.value !== "" ||
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

function rowMatchesFilter(docId: string, row: Row): boolean {
  if (filterEtl.value === "Y" && !isEtlYes(docId, row)) return false;
  if (filterEtl.value === "N" && isEtlYes(docId, row)) return false;
  if (!contains(String(row["한자"] ?? ""), search한자.value)) return false;
  if (!contains(String(row["음"] ?? ""), search음.value)) return false;
  if (!contains(String(row["훈"] ?? ""), search훈.value)) return false;
  return true;
}

const filteredDocs = computed(() =>
  allDocs.value.filter(({ id, data }) => rowMatchesFilter(id, data)),
);

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredDocs.value.length / pageSize.value)),
);

const totalCount = computed(() => filteredDocs.value.length);

const rangeStart = computed(() =>
  totalCount.value === 0 ? 0 : currentPage.value * pageSize.value + 1,
);

const rangeEnd = computed(() =>
  Math.min((currentPage.value + 1) * pageSize.value, totalCount.value),
);

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

watch([ids, selectedIds], updateHeaderCheckboxIndeterminate, {
  deep: true,
});

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

function remarkFor(docId: string): string {
  return remarksByDocId.value[docId] ?? "";
}

function setRemark(docId: string, value: string) {
  remarksByDocId.value = {
    ...remarksByDocId.value,
    [docId]: value,
  };
}

/** 필터 결과 전체 행 선택 / 전체 해제 */
function selectAllFiltered() {
  const s = new Set(selectedIds.value);
  for (const { id } of filteredDocs.value) {
    s.add(id);
  }
  selectedIds.value = s;
}

function clearAllSelection() {
  selectedIds.value = new Set();
}

/** 파이프라인 CSV 복사 안내 */
const etlActionMessage = ref<string | null>(null);

const ETL_CSV_HEADERS = [
  "한자",
  "음",
  "훈",
  "구분",
  "전체",
  "훈음",
] as const;

function csvEscapeCell(raw: string): string {
  const cell = raw.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  if (/[",\n]/.test(cell)) return `"${cell.replace(/"/g, '""')}"`;
  return cell;
}

function buildEtlCsvSnippet(): string {
  const lines: string[] = [ETL_CSV_HEADERS.join(",")];
  for (const docId of selectedIds.value) {
    const entry = allDocs.value.find((d) => d.id === docId);
    if (!entry) continue;
    const r = entry.data;
    const row = ETL_CSV_HEADERS.map((h) =>
      csvEscapeCell(String(r[h] ?? "")),
    );
    lines.push(row.join(","));
  }
  return lines.join("\n");
}

async function runEtlOnSelection() {
  if (selectedIds.value.size === 0) return;
  etlActionMessage.value = null;
  let exported = 0;
  for (const docId of selectedIds.value) {
    if (allDocs.value.some((d) => d.id === docId)) exported += 1;
  }
  const text = buildEtlCsvSnippet();
  try {
    await navigator.clipboard.writeText(text);
    etlActionMessage.value = `선택 ${exported}건을 CSV로 복사했습니다. 로컬에서 admin/python/hanja_pipeline.py 를 실행할 수 있습니다.`;
  } catch {
    etlActionMessage.value =
      "클립보드 복사에 실패했습니다. 콘솔에 CSV를 출력했습니다.";
    console.info("[ETL CSV]\n", text);
  }
}

/** upload_to_firestore.py 가 쓰는 hanja 문서 ID (예: hanja_050F9) */
function hanjaCollectionDocId(row: Row): string | null {
  const raw = String(row["한자"] ?? "").trim();
  const cp = raw.codePointAt(0);
  if (cp === undefined) return null;
  const hex = cp.toString(16).toUpperCase().padStart(5, "0");
  return `hanja_${hex}`;
}

function leadingHanjaChar(row: Row): string {
  const raw = String(row["한자"] ?? "").trim();
  const cp = raw.codePointAt(0);
  return cp === undefined ? "" : String.fromCodePoint(cp);
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

/** 선택 집합에서 첫 문서(삽입 순) — 획 미리보기 대상 */
const strokePreviewDocId = computed(() => {
  const it = selectedIds.value.values().next();
  return it.done ? null : it.value;
});

const strokePreviewRow = computed(() => {
  const id = strokePreviewDocId.value;
  if (!id) return null;
  return allDocs.value.find((d) => d.id === id)?.data ?? null;
});

const strokeLoading = ref(false);
const strokeError = ref<string | null>(null);
const strokeShapes = ref<StrokeShape[]>([]);
const strokeSvgPaths = ref<string[]>([]);
const strokeMeta = ref<{
  hanjaDocId: string;
  strokeDataId?: string;
  totalStrokes?: number;
  charDoc?: string;
} | null>(null);

let strokeLoadToken = 0;

async function loadStrokesFromFirestore() {
  strokeLoadToken += 1;
  const token = strokeLoadToken;
  const row = strokePreviewRow.value;

  if (!row || !isFirebaseConfigured()) {
    strokeShapes.value = [];
    strokeSvgPaths.value = [];
    strokeError.value = null;
    strokeMeta.value = null;
    strokeLoading.value = false;
    return;
  }

  const hanjaId = hanjaCollectionDocId(row);
  if (!hanjaId) {
    if (token !== strokeLoadToken) return;
    strokeShapes.value = [];
    strokeSvgPaths.value = [];
    strokeError.value = "한자 필드에서 글자를 읽을 수 없습니다.";
    strokeMeta.value = null;
    strokeLoading.value = false;
    return;
  }

  strokeLoading.value = true;
  strokeError.value = null;

  try {
    const db = getFirestoreDb();
    let strokesRaw: unknown;
    let strokeDataId: string | undefined;
    let totalStrokes: number | undefined;
    let charDoc = "";
    let svgPathsBest: string[] = [];

    function extractSvgPaths(data: Record<string, unknown>): string[] {
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

    function preferLonger(a: string[], b: string[]): string[] {
      return b.length > a.length ? b : a;
    }

    const hanjaSnap = await getDoc(doc(db, "hanja", hanjaId));
    if (hanjaSnap.exists()) {
      const d = hanjaSnap.data() as Record<string, unknown>;
      charDoc = String(d.char ?? d.character ?? "");
      if (typeof d.stroke_data_id === "string") {
        strokeDataId = d.stroke_data_id;
      }
      if (typeof d.total_strokes === "number") {
        totalStrokes = d.total_strokes;
      } else if (typeof d.stroke_count === "number") {
        totalStrokes = d.stroke_count;
      }
      strokesRaw = d.strokes;
      svgPathsBest = preferLonger(svgPathsBest, extractSvgPaths(d));
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
        svgPathsBest = preferLonger(svgPathsBest, extractSvgPaths(sd));
      }
    }

    if (token !== strokeLoadToken) return;

    const shapes = normalizeStrokesFromFirestore(strokesRaw);
    strokeShapes.value = shapes;
    strokeSvgPaths.value = svgPathsBest;
    strokeMeta.value = {
      hanjaDocId: hanjaId,
      strokeDataId,
      totalStrokes,
      charDoc: charDoc || leadingHanjaChar(row),
    };

    if (shapes.length === 0 && svgPathsBest.length === 0) {
      strokeError.value = `Firestore에 획 배열·svg_paths가 없습니다. (hanja/${hanjaId} 또는 hanja_stroke/${strokeDataId ?? "—"})`;
    }
  } catch (e) {
    if (token !== strokeLoadToken) return;
    strokeShapes.value = [];
    strokeSvgPaths.value = [];
    strokeMeta.value = null;
    strokeError.value =
      e instanceof Error ? e.message : "획 데이터를 불러오지 못했습니다.";
  } finally {
    if (token === strokeLoadToken) strokeLoading.value = false;
  }
}

watch([strokePreviewDocId, allDocs], () => {
  void loadStrokesFromFirestore();
});

const strokePanelSubtitle = computed(() => {
  const row = strokePreviewRow.value;
  if (!row) return "—";
  const read = String(row["음"] ?? "").trim();
  const mean = String(row["훈"] ?? "").trim();
  const n =
    strokeMeta.value?.totalStrokes ?? strokeShapes.value.length;
  const label =
    mean && read ? `${mean} ${read}` : mean || read || "";
  const parts = [label, n ? `${n}획` : ""].filter(Boolean);
  return parts.join(" · ") || "—";
});

const strokePanelFootnote = computed(() => {
  const m = strokeMeta.value;
  if (!m) return undefined;
  return m.strokeDataId ?? m.hanjaDocId;
});

const strokePanelTitle = computed(() => {
  const row = strokePreviewRow.value;
  const fromFs = strokeMeta.value?.charDoc?.trim();
  if (fromFs) return fromFs;
  if (row) return leadingHanjaChar(row) || "—";
  return "—";
});

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

watch(filterEtl, () => {
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
  filterEtl.value = "";
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
          ETL · 확장
        </h1>
      </div>
      <button
        type="button"
        class="btn-secondary text-sm"
        :disabled="loading"
        @click="refresh"
      >
        새로고침
      </button>
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
            >ETL</label
          >
          <select
            v-model="filterEtl"
            class="input-minimal w-full cursor-pointer py-2"
          >
            <option value="">전체</option>
            <option value="Y">Y</option>
            <option value="N">N</option>
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
      문서가 없습니다. 기준 데이터(CSV 업로드)를 먼저 채워 주세요.
    </p>
    <p
      v-else-if="!loading && allDocs.length && !totalCount"
      class="text-onSurface-variant"
    >
      필터와 일치하는 행이 없습니다. 조건을 바꿔 보세요.
    </p>

    <template v-if="rows.length">
      <p class="text-xs leading-relaxed text-onSurface-variant">
        획 데이터는 Firestore
        <code class="rounded bg-surface-low px-1">hanja</code> 문서의
        <code class="rounded bg-surface-low px-1">strokes</code> 필드(또는
        <code class="rounded bg-surface-low px-1">hanja_stroke</code>)에서
        읽습니다. 여러 행을 선택하면 <strong class="font-medium text-onSurface">가장 먼저 선택한 행</strong> 기준으로
        미리보기합니다. 추가 수집은 로컬
        <code class="rounded bg-surface-low px-1">admin/python/hanja_pipeline.py</code>
        를 사용합니다.
      </p>

      <div
        class="mb-2 flex flex-wrap items-center justify-between gap-2"
      >
        <div class="flex flex-wrap items-center gap-2">
          <button
            type="button"
            class="btn-secondary text-sm"
            :disabled="loading || !totalCount"
            @click="selectAllFiltered"
          >
            전체선택
          </button>
          <button
            type="button"
            class="btn-secondary text-sm"
            :disabled="loading || selectedIds.size === 0"
            @click="clearAllSelection"
          >
            전체해제
          </button>
        </div>
        <button
          type="button"
          class="btn-primary text-sm"
          :disabled="loading || selectedIds.size === 0"
          @click="runEtlOnSelection"
        >
          ETL
        </button>
      </div>

      <p
        v-if="etlActionMessage"
        class="text-sm text-emerald-800"
      >
        {{ etlActionMessage }}
      </p>

      <div class="overflow-x-auto rounded-xl bg-surface-lowest shadow-float">
        <table class="w-full min-w-[56rem] border-collapse text-left text-sm">
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
              <th class="px-3 py-3 font-medium">ID</th>
              <th class="px-3 py-3 font-medium">음</th>
              <th class="px-3 py-3 font-medium">한자</th>
              <th class="px-3 py-3 font-medium">훈</th>
              <th class="w-20 px-3 py-3 font-medium">ETL</th>
              <th class="min-w-[8rem] px-3 py-3 font-medium">비고</th>
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
                class="max-w-[6rem] truncate px-3 py-3 font-mono text-xs text-primary"
                :title="basisDisplayId(ids[i]!, row)"
              >
                {{ basisDisplayId(ids[i]!, row) }}
              </td>
              <td class="max-w-[8rem] truncate px-3 py-3 text-onSurface">
                {{ row["음"] ?? "—" }}
              </td>
              <td
                class="max-w-[6rem] truncate px-3 py-3 font-display text-lg leading-tight text-onSurface"
                :title="String(row['한자'] ?? '')"
              >
                {{ row["한자"] ?? "—" }}
              </td>
              <td class="max-w-[12rem] truncate px-3 py-3 text-onSurface">
                {{ row["훈"] ?? "—" }}
              </td>
              <td class="px-3 py-3">
                <span
                  class="text-sm font-medium tabular-nums"
                  :class="
                    etlLabel(ids[i]!, row) === 'Yes'
                      ? 'text-emerald-700'
                      : 'text-onSurface-variant'
                  "
                >
                  {{ etlLabel(ids[i]!, row) }}
                </span>
              </td>
              <td class="px-2 py-2">
                <input
                  type="text"
                  class="input-minimal w-full min-w-[6rem] py-1.5 text-sm"
                  placeholder="메모"
                  :value="remarkFor(ids[i]!)"
                  @input="
                    setRemark(
                      ids[i]!,
                      ($event.target as HTMLInputElement).value,
                    )
                  "
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <section class="mt-6 space-y-3">
        <h2 class="text-sm font-semibold text-onSurface">
          추출 획 미리보기
        </h2>
        <p
          v-if="selectedIds.size === 0"
          class="rounded-lg border border-outline-variant bg-surface-low px-4 py-6 text-center text-sm text-onSurface-variant"
        >
          기준 행을 선택하면 해당 한자의 획이 여기에 표시됩니다.
        </p>
        <template v-else>
          <p class="text-xs text-onSurface-variant">
            문서
            <code class="rounded bg-surface-low px-1">{{
              strokeMeta?.hanjaDocId ?? "…"
            }}</code>
          </p>
          <p
            v-if="strokeLoading"
            class="text-sm text-onSurface-variant"
          >
            획 데이터를 불러오는 중…
          </p>
          <p
            v-else-if="strokeError"
            class="text-sm text-amber-800"
          >
            {{ strokeError }}
          </p>
          <StrokeOrderViewer
            v-else-if="strokeShapes.length || strokeSvgPaths.length"
            :strokes="strokeShapes"
            :svg-paths="strokeSvgPaths"
            :title="strokePanelTitle"
            :subtitle="strokePanelSubtitle"
            :footnote="strokePanelFootnote"
          />
          <p
            v-else
            class="text-sm text-onSurface-variant"
          >
            이 한자에 대한 획 데이터가 없습니다.
          </p>
        </template>
      </section>

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
  </div>
</template>
