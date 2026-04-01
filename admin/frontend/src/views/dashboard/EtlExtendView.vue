<script setup lang="ts">
import {
  computed,
  nextTick,
  onMounted,
  onUnmounted,
  ref,
  watch,
} from "vue";
import { RouterLink } from "vue-router";
import {
  collection,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  setDoc,
} from "firebase/firestore";
import { getFirebaseAuth, getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

const FILTER_FETCH_CAP = 2500;
const PAGE_SIZE_OPTIONS = [10, 20, 50] as const;

/** hanja_basis CSV 다운로드 열 순서 */
const BASIS_CSV_DOWNLOAD_COLUMNS = ["id", "한자", "음"] as const;

type Row = Record<string, unknown>;
type DocEntry = { id: string; data: Row };

const auth = useAuthStore();

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

/** 행 클릭으로 한 건만 선택 (JSON·획 미리보기·획순 DATA) */
const selectedEtlDocId = ref<string | null>(null);
/** 행별 비고 (클라이언트만; 추후 서버 연동 시 교체) */
const remarksByDocId = ref<Record<string, string>>({});
/** ETL 성공한 문서 ID (클라이언트 세션; Firestore `etl`과 함께 Yes 판단) */
const etlSucceededIds = ref<Set<string>>(new Set());

function selectEtlRow(docId: string) {
  if (selectedEtlDocId.value === docId) {
    selectedEtlDocId.value = null;
  } else {
    selectedEtlDocId.value = docId;
  }
}

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

function remarkFor(docId: string): string {
  return remarksByDocId.value[docId] ?? "";
}

function setRemark(docId: string, value: string) {
  remarksByDocId.value = {
    ...remarksByDocId.value,
    [docId]: value,
  };
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
  const docId = selectedEtlDocId.value;
  if (!docId) return lines.join("\n");
  const entry = allDocs.value.find((d) => d.id === docId);
  if (!entry) return lines.join("\n");
  const r = entry.data;
  const row = ETL_CSV_HEADERS.map((h) =>
    csvEscapeCell(String(r[h] ?? "")),
  );
  lines.push(row.join(","));
  return lines.join("\n");
}

async function runEtlOnSelection() {
  if (!selectedEtlDocId.value) return;
  etlActionMessage.value = null;
  const exported = allDocs.value.some((d) => d.id === selectedEtlDocId.value)
    ? 1
    : 0;
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

/** 선택된 한 행 — JSON 편집 대상 */
const strokePreviewDocId = computed(() => selectedEtlDocId.value);

const strokePreviewRow = computed(() => {
  const id = strokePreviewDocId.value;
  if (!id) return null;
  return allDocs.value.find((d) => d.id === id)?.data ?? null;
});

const strokeLoading = ref(false);

/** 우측 패널: 편집 대상 `hanja_stroke` 문서 ID (없으면 저장 불가) */
const strokeFirestoreDocId = ref<string | null>(null);
const strokeJsonEditorText = ref("");
const strokeJsonBaseline = ref("");
const strokeJsonSaveError = ref<string | null>(null);
const strokeJsonSaving = ref(false);

const strokeJsonDirty = computed(
  () => strokeJsonEditorText.value !== strokeJsonBaseline.value,
);

/** 편집 중 JSON의 svg_paths 가 없거나 빈 배열·공백 문자열만이면 true */
function svgPathsEmptyInStrokeJsonText(raw: string): boolean {
  const t = raw.trim();
  if (!t) return true;
  let parsed: unknown;
  try {
    parsed = JSON.parse(t);
  } catch {
    return false;
  }
  if (
    parsed === null ||
    typeof parsed !== "object" ||
    Array.isArray(parsed)
  ) {
    return false;
  }
  const sp = (parsed as Record<string, unknown>).svg_paths;
  if (sp === undefined || sp === null) return true;
  if (!Array.isArray(sp)) return true;
  if (sp.length === 0) return true;
  const hasPath = sp.some(
    (x) => typeof x === "string" && x.trim().length > 0,
  );
  return !hasPath;
}

const strokeJsonSvgPathsEmpty = computed(() => {
  if (!selectedEtlDocId.value || !strokeFirestoreDocId.value) return false;
  return svgPathsEmptyInStrokeJsonText(strokeJsonEditorText.value);
});

const canMutateStrokeDoc = computed(
  () =>
    isFirebaseConfigured() &&
    auth.isAuthenticated &&
    auth.isAdmin &&
    strokeFirestoreDocId.value !== null,
);

function docDataToJsonText(data: Record<string, unknown>): string {
  return JSON.stringify(
    data,
    (_key, val) => {
      if (
        val &&
        typeof val === "object" &&
        "toDate" in val &&
        typeof (val as { toDate: () => Date }).toDate === "function"
      ) {
        try {
          return (val as { toDate: () => Date }).toDate().toISOString();
        } catch {
          return val;
        }
      }
      return val;
    },
    2,
  );
}

function revertStrokeJsonEditor() {
  strokeJsonEditorText.value = strokeJsonBaseline.value;
  strokeJsonSaveError.value = null;
}

async function saveHanjaStrokeJson() {
  const docId = strokeFirestoreDocId.value;
  if (!docId || !canMutateStrokeDoc.value) return;
  strokeJsonSaveError.value = null;
  let parsed: unknown;
  try {
    parsed = JSON.parse(strokeJsonEditorText.value);
  } catch (e) {
    strokeJsonSaveError.value =
      e instanceof Error ? e.message : "JSON 형식이 올바르지 않습니다.";
    return;
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    strokeJsonSaveError.value = "최상위는 JSON 객체여야 합니다.";
    return;
  }
  if (!isFirebaseConfigured()) return;
  strokeJsonSaving.value = true;
  try {
    const user = getFirebaseAuth().currentUser;
    if (!user) {
      strokeJsonSaveError.value = "로그인이 필요합니다.";
      return;
    }
    await user.getIdToken(true);
    const db = getFirestoreDb();
    await setDoc(doc(db, "hanja_stroke", docId), parsed as Record<string, unknown>);
    strokeJsonBaseline.value = strokeJsonEditorText.value;
    await loadStrokesFromFirestore();
  } catch (e) {
    strokeJsonSaveError.value =
      e instanceof Error ? e.message : "저장에 실패했습니다.";
  } finally {
    strokeJsonSaving.value = false;
  }
}

let strokeLoadToken = 0;

async function loadStrokesFromFirestore() {
  strokeLoadToken += 1;
  const token = strokeLoadToken;
  const row = strokePreviewRow.value;

  if (!row || !isFirebaseConfigured()) {
    strokeFirestoreDocId.value = null;
    strokeJsonEditorText.value = "";
    strokeJsonBaseline.value = "";
    strokeJsonSaveError.value = null;
    strokeLoading.value = false;
    return;
  }

  const hanjaId = hanjaCollectionDocId(row);
  if (!hanjaId) {
    if (token !== strokeLoadToken) return;
    strokeFirestoreDocId.value = null;
    strokeJsonEditorText.value = "";
    strokeJsonBaseline.value = "";
    strokeJsonSaveError.value = null;
    strokeLoading.value = false;
    return;
  }

  strokeLoading.value = true;

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
        strokeDataId = d.stroke_data_id.trim() || undefined;
      }
      if (typeof d.total_strokes === "number") {
        totalStrokes = d.total_strokes;
      } else if (typeof d.stroke_count === "number") {
        totalStrokes = d.stroke_count;
      }
      strokesRaw = d.strokes;
      svgPathsBest = preferLonger(svgPathsBest, extractSvgPaths(d));
    }

    let strokeSnapData: Record<string, unknown> | null = null;
    if (strokeDataId) {
      const stSnap = await getDoc(doc(db, "hanja_stroke", strokeDataId));
      if (stSnap.exists()) {
        strokeSnapData = stSnap.data() as Record<string, unknown>;
      }
    }

    if (strokeSnapData) {
      svgPathsBest = preferLonger(svgPathsBest, extractSvgPaths(strokeSnapData));
    }

    if (
      (!Array.isArray(strokesRaw) || strokesRaw.length === 0) &&
      strokeSnapData
    ) {
      const sd = strokeSnapData;
      strokesRaw = sd.strokes;
      if (!charDoc) charDoc = String(sd.char ?? "");
      if (totalStrokes === undefined && typeof sd.total_strokes === "number") {
        totalStrokes = sd.total_strokes;
      }
    }

    if (token !== strokeLoadToken) return;

    strokeJsonSaveError.value = null;

    if (strokeSnapData && strokeDataId) {
      strokeFirestoreDocId.value = strokeDataId;
      const jsonText = docDataToJsonText(strokeSnapData);
      strokeJsonEditorText.value = jsonText;
      strokeJsonBaseline.value = jsonText;
    } else if (strokeDataId) {
      strokeFirestoreDocId.value = strokeDataId;
      const seed: Record<string, unknown> = {
        char: charDoc || leadingHanjaChar(row),
        total_strokes: totalStrokes,
        strokes: Array.isArray(strokesRaw) ? strokesRaw : [],
        svg_paths: svgPathsBest,
      };
      const text = JSON.stringify(seed, null, 2);
      strokeJsonEditorText.value = text;
      strokeJsonBaseline.value = text;
    } else {
      strokeFirestoreDocId.value = null;
      strokeJsonEditorText.value = "";
      strokeJsonBaseline.value = "";
    }
  } catch (e) {
    if (token !== strokeLoadToken) return;
    strokeFirestoreDocId.value = null;
    strokeJsonEditorText.value = "";
    strokeJsonBaseline.value = "";
    console.error(
      "[ETL] hanja_stroke 로드 실패",
      e instanceof Error ? e.message : e,
    );
  } finally {
    if (token === strokeLoadToken) strokeLoading.value = false;
  }
}

watch([strokePreviewDocId, allDocs], () => {
  void loadStrokesFromFirestore();
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

function escapeCsvCell(s: string): string {
  if (/[",\r\n]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

function basisFieldToCsvString(raw: unknown): string {
  if (raw === null || raw === undefined) return "";
  if (typeof raw === "string") return raw;
  if (typeof raw === "number" || typeof raw === "boolean") return String(raw);
  if (
    typeof raw === "object" &&
    raw !== null &&
    "toDate" in raw &&
    typeof (raw as { toDate: () => Date }).toDate === "function"
  ) {
    return (raw as { toDate: () => Date }).toDate().toISOString();
  }
  try {
    return JSON.stringify(raw);
  } catch {
    return String(raw);
  }
}

function downloadHanjaBasisCsv() {
  const list = allDocs.value;
  if (!list.length) return;

  const headers = BASIS_CSV_DOWNLOAD_COLUMNS;
  const lines: string[] = [
    headers.map((h) => escapeCsvCell(h)).join(","),
  ];
  for (const { id, data } of list) {
    const cells = headers.map((h) => {
      const raw =
        h === "id" ? basisDisplayId(id, data) : data[h];
      return escapeCsvCell(basisFieldToCsvString(raw));
    });
    lines.push(cells.join(","));
  }

  const bom = "\uFEFF";
  const blob = new Blob([bom + lines.join("\r\n")], {
    type: "text/csv;charset=utf-8;",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `hanja_basis_${new Date().toISOString().slice(0, 10)}.csv`;
  a.rel = "noopener";
  a.click();
  URL.revokeObjectURL(url);
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

const selectedCount = computed(() => (selectedEtlDocId.value ? 1 : 0));

const basisTotalLabel = computed(() =>
  allDocs.value.length.toLocaleString("ko-KR"),
);

/** 헤더 ! 도움말 — main overflow 때문에 body 고정 레이어로 표시 */
const etlHelpTriggerRef = ref<HTMLButtonElement | null>(null);
const etlHelpTooltipOpen = ref(false);
const etlHelpTooltipStyle = ref<Record<string, string>>({});

let etlHelpRemoveScrollListeners: (() => void) | null = null;

function positionEtlHelpTooltip() {
  const el = etlHelpTriggerRef.value;
  if (!el) return;
  const r = el.getBoundingClientRect();
  const margin = 10;
  const maxW = Math.min(352, window.innerWidth - margin * 2);
  let left = r.left;
  if (left + maxW > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - margin - maxW);
  }
  if (left < margin) left = margin;
  etlHelpTooltipStyle.value = {
    top: `${Math.round(r.bottom + margin)}px`,
    left: `${Math.round(left)}px`,
    maxWidth: `${maxW}px`,
  };
}

function openEtlHelpTooltip() {
  positionEtlHelpTooltip();
  etlHelpTooltipOpen.value = true;
  void nextTick(() => positionEtlHelpTooltip());
}

function closeEtlHelpTooltip() {
  etlHelpTooltipOpen.value = false;
}

watch(etlHelpTooltipOpen, (open) => {
  etlHelpRemoveScrollListeners?.();
  etlHelpRemoveScrollListeners = null;
  if (!open) return;
  const handler = () => positionEtlHelpTooltip();
  window.addEventListener("scroll", handler, true);
  window.addEventListener("resize", handler);
  etlHelpRemoveScrollListeners = () => {
    window.removeEventListener("scroll", handler, true);
    window.removeEventListener("resize", handler);
  };
});

onUnmounted(() => {
  etlHelpRemoveScrollListeners?.();
});

onMounted(() => {
  void loadAll();
});
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 (툴팁이 잘리지 않도록 본문은 overflow-visible, 장식만 clip) -->
    <section
      class="relative overflow-visible rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute inset-0 overflow-hidden rounded-xl"
        aria-hidden="true"
      >
        <div
          class="absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl"
        />
      </div>
      <div
        class="relative flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between sm:gap-3"
      >
        <div class="flex min-w-0 items-center gap-2.5 sm:gap-3">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            擴
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <div class="min-w-0 flex-1 leading-tight">
              <p
                class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
              >
                Firestore · hanja_basis · ETL
              </p>
              <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
                ETL · 확장
              </h1>
            </div>
            <div class="relative shrink-0 pt-0.5">
              <button
                ref="etlHelpTriggerRef"
                type="button"
                class="flex h-6 w-6 items-center justify-center rounded-full border border-primary/35 bg-primary/12 text-xs font-bold leading-none text-primary shadow-sm outline-none ring-primary/20 transition hover:bg-primary/18 focus-visible:ring-2"
                aria-label="획 데이터는 hanja 의 strokes 또는 hanja_stroke 에서 읽습니다. 목록에서 행을 눌러 한 건을 선택하면 우측 hanja_stroke JSON에 반영됩니다. 추가 수집은 admin/python/hanja_pipeline.py 를 사용합니다."
                :aria-describedby="
                  etlHelpTooltipOpen ? 'etl-help-tooltip-text' : undefined
                "
                @mouseenter="openEtlHelpTooltip"
                @mouseleave="closeEtlHelpTooltip"
                @focus="openEtlHelpTooltip"
                @blur="closeEtlHelpTooltip"
              >
                !
              </button>
            </div>
          </div>
        </div>
        <div
          class="flex flex-wrap items-center gap-1.5 sm:justify-end sm:gap-2"
        >
          <span
            class="inline-flex items-center gap-1 rounded-full border border-white/60 bg-white/90 px-2 py-0.5 text-[11px] font-medium text-onSurface shadow-sm backdrop-blur-sm"
          >
            <span class="text-onSurface-variant">전체</span>
            <span class="tabular-nums text-primary">{{ basisTotalLabel }}</span>
            <span class="text-onSurface-variant">건</span>
          </span>
          <span
            v-if="!loading && allDocs.length && filterActive"
            class="inline-flex items-center rounded-full border border-outline-variant/70 bg-surface-lowest/90 px-2 py-0.5 text-[11px] font-medium text-onSurface backdrop-blur-sm"
          >
            필터
            <span class="ml-0.5 tabular-nums text-primary">{{ totalCount.toLocaleString("ko-KR") }}</span>
            건
          </span>
          <span
            v-if="selectedCount > 0"
            class="inline-flex items-center rounded-full border border-primary/25 bg-primary/[0.1] px-2 py-0.5 text-[11px] font-semibold text-primary"
          >
            {{ selectedCount.toLocaleString("ko-KR") }}건 선택
          </span>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="loading || !allDocs.length"
            title="id는 한자(또는 문서) 기준 H+16진 코드포인트입니다. 열: id, 한자, 음. 최대 2,500건."
            @click="downloadHanjaBasisCsv"
          >
            CSV 받기
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="loading"
            @click="refresh"
          >
            새로고침
          </button>
          <RouterLink
            :to="{ name: 'basis' }"
            class="btn-secondary inline-flex items-center justify-center px-3 py-1.5 text-xs sm:text-sm"
          >
            기준 데이터
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- 필터 (한 줄) -->
    <div
      class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4"
    >
      <div
        class="flex flex-nowrap items-end gap-2 overflow-x-auto pb-0.5 [-ms-overflow-style:none] [scrollbar-width:thin] sm:gap-2.5 [&::-webkit-scrollbar]:h-1 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-outline-variant/60"
      >
        <h2
          class="shrink-0 self-center pr-1 text-sm font-semibold leading-none text-onSurface"
        >
          검색 · ETL
        </h2>
        <div class="flex w-[5.25rem] shrink-0 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >페이지당</label
          >
          <select
            v-model="pageSize"
            class="input-minimal w-full cursor-pointer py-1.5 text-sm"
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
        <div class="flex w-[5.25rem] shrink-0 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >ETL</label
          >
          <select
            v-model="filterEtl"
            class="input-minimal w-full cursor-pointer py-1.5 text-sm"
          >
            <option value="">전체</option>
            <option value="Y">Y</option>
            <option value="N">N</option>
          </select>
        </div>
        <div class="flex min-w-[6.25rem] flex-1 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >한자</label
          >
          <input
            v-model="search한자"
            type="search"
            class="input-minimal min-w-0 w-full py-1.5 text-sm"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div class="flex min-w-[6.25rem] flex-1 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >음</label
          >
          <input
            v-model="search음"
            type="search"
            class="input-minimal min-w-0 w-full py-1.5 text-sm"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div class="flex min-w-[6.25rem] flex-1 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >훈</label
          >
          <input
            v-model="search훈"
            type="search"
            class="input-minimal min-w-0 w-full py-1.5 text-sm"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <button
          type="button"
          class="btn-secondary shrink-0 px-3 py-1.5 text-xs sm:text-sm"
          :disabled="!canClearFilters"
          @click="clearFilters"
        >
          필터 초기화
        </button>
      </div>
    </div>

    <div
      v-if="filterWarning"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950 shadow-sm"
    >
      {{ filterWarning }}
    </div>
    <div
      v-if="error"
      class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3 text-sm text-red-900 shadow-sm"
    >
      {{ error }}
    </div>
    <div
      v-else-if="loading"
      class="flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-outline-variant/80 bg-surface-low/50 py-16"
    >
      <div class="flex gap-1.5" aria-hidden="true">
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
      </div>
      <p class="text-sm font-medium text-onSurface-variant">hanja_basis 불러오는 중…</p>
    </div>
    <div
      v-else-if="!loading && !allDocs.length"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">
        아직 문서가 없습니다
      </p>
      <p class="mt-2 text-sm text-onSurface-variant">
        <RouterLink
          :to="{ name: 'basis-upload' }"
          class="font-medium text-primary underline decoration-primary/30 underline-offset-2 hover:decoration-primary"
        >한자 마스터 등록</RouterLink>
        에서 CSV를 올리거나
        <RouterLink
          :to="{ name: 'basis' }"
          class="font-medium text-primary underline decoration-primary/30 underline-offset-2 hover:decoration-primary"
        >기준 데이터</RouterLink>
        를 확인하세요.
      </p>
    </div>
    <div
      v-else-if="!loading && allDocs.length && !totalCount"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">
        필터와 일치하는 행이 없습니다
      </p>
      <p class="mt-2 text-sm text-onSurface-variant">
        ETL·검색 조건을 바꾸거나 필터 초기화를 눌러 보세요.
      </p>
    </div>

    <template v-if="rows.length">
      <div
        v-if="etlActionMessage"
        class="rounded-xl border border-emerald-200/90 bg-emerald-50/90 px-4 py-3 text-sm font-medium text-emerald-950 shadow-sm"
      >
        {{ etlActionMessage }}
      </div>

      <div
        class="flex flex-col gap-4 lg:flex-row lg:items-stretch lg:gap-5"
      >
        <!-- 좌측 약 1/3: 목록 -->
        <div
          class="flex w-full min-w-0 flex-col gap-3 lg:w-1/3 lg:max-w-[min(100%,33.333333%)] lg:shrink-0"
        >
          <div
            class="flex max-h-[min(72vh,52rem)] min-h-0 flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02]"
          >
            <div class="min-h-0 flex-1 overflow-auto">
              <table class="w-full min-w-[22rem] table-fixed border-collapse text-left text-xs">
                <thead>
                  <tr
                    class="sticky top-0 z-[1] border-b border-outline-variant/80 bg-surface-low/95 text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant backdrop-blur-sm"
                  >
                    <th class="w-[22%] px-2 py-2.5">ID</th>
                    <th class="w-[14%] px-1 py-2.5">음</th>
                    <th class="w-[12%] px-1 py-2.5 text-center">한자</th>
                    <th class="w-[20%] px-1 py-2.5">훈</th>
                    <th class="w-10 px-1 py-2.5 text-center">ETL</th>
                    <th class="px-2 py-2.5">비고</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-outline-variant/60">
                  <tr
                    v-for="(row, i) in rows"
                    :key="ids[i] ?? i"
                    class="cursor-pointer bg-surface-lowest transition-colors hover:bg-primary/[0.04]"
                    :class="
                      selectedEtlDocId === ids[i]
                        ? 'bg-primary/[0.1] ring-1 ring-inset ring-primary/25'
                        : ''
                    "
                    role="button"
                    tabindex="0"
                    :aria-pressed="selectedEtlDocId === ids[i]"
                    :aria-label="`선택 ${basisDisplayId(ids[i]!, row)}`"
                    @click="selectEtlRow(ids[i]!)"
                    @keydown.enter.prevent="selectEtlRow(ids[i]!)"
                    @keydown.space.prevent="selectEtlRow(ids[i]!)"
                  >
                    <td
                      class="truncate px-2 py-2 align-middle font-mono text-[10px] font-medium leading-tight text-primary"
                      :title="basisDisplayId(ids[i]!, row)"
                    >
                      {{ basisDisplayId(ids[i]!, row) }}
                    </td>
                    <td
                      class="truncate px-1 py-2 align-middle text-onSurface"
                      :title="String(row['음'] ?? '')"
                    >
                      {{ row["음"] ?? "—" }}
                    </td>
                    <td
                      class="truncate px-1 py-2 text-center font-display text-base leading-none text-onSurface"
                      :title="String(row['한자'] ?? '')"
                    >
                      {{ row["한자"] ?? "—" }}
                    </td>
                    <td
                      class="truncate px-1 py-2 align-middle text-onSurface"
                      :title="String(row['훈'] ?? '')"
                    >
                      {{ row["훈"] ?? "—" }}
                    </td>
                    <td class="px-1 py-2 align-middle text-center">
                      <span
                        class="text-xs font-medium tabular-nums"
                        :class="
                          etlLabel(ids[i]!, row) === 'Yes'
                            ? 'text-emerald-700'
                            : 'text-onSurface-variant'
                        "
                      >
                        {{ etlLabel(ids[i]!, row) }}
                      </span>
                    </td>
                    <td
                      class="px-1 py-1.5 align-middle"
                      @click.stop
                      @keydown.stop
                    >
                      <input
                        type="text"
                        class="input-minimal w-full py-1 text-[11px]"
                        placeholder="메모"
                        :value="remarkFor(ids[i]!)"
                        @click.stop
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
          </div>

          <div
            class="flex flex-col gap-3 rounded-xl border border-outline-variant/60 bg-surface-low/80 px-3 py-2.5 sm:flex-row sm:items-center sm:justify-between sm:px-4"
          >
            <p class="text-[11px] text-onSurface-variant">
              <span class="font-medium text-onSurface tabular-nums">{{ rangeStart }}–{{ rangeEnd }}</span>
              <span class="mx-1 text-onSurface-variant/70">/</span>
              <span class="tabular-nums">{{ totalCount.toLocaleString("ko-KR") }}</span>건
            </p>
            <div class="flex flex-wrap items-center justify-end gap-1.5">
              <button
                type="button"
                class="btn-secondary px-2.5 py-1.5 text-xs"
                :disabled="loading || currentPage <= 0"
                @click="prevPage"
              >
                이전
              </button>
              <template v-for="(item, idx) in paginationItems" :key="'p-' + idx">
                <span
                  v-if="item === 'ellipsis'"
                  class="px-0.5 text-onSurface-variant"
                >…</span>
                <button
                  v-else
                  type="button"
                  class="min-w-[2rem] rounded-lg px-1.5 py-1.5 text-xs font-medium transition"
                  :class="
                    item === currentPage + 1
                      ? 'bg-primary text-white shadow-md shadow-primary/20'
                      : 'bg-surface-lowest text-onSurface ring-1 ring-outline-variant/50 hover:bg-surface-bright'
                  "
                  :disabled="loading"
                  @click="goToPage(item - 1)"
                >
                  {{ item }}
                </button>
              </template>
              <button
                type="button"
                class="btn-secondary px-2.5 py-1.5 text-xs"
                :disabled="loading || currentPage >= totalPages - 1"
                @click="nextPage"
              >
                다음
              </button>
            </div>
          </div>
        </div>

        <!-- 우측 약 2/3: hanja_stroke JSON -->
        <div class="flex min-h-0 min-w-0 flex-1 flex-col">
          <div
            class="flex min-h-[min(52vh,28rem)] flex-1 flex-col overflow-hidden rounded-2xl border bg-surface-lowest shadow-float transition-[border-color,box-shadow] duration-200"
            :class="
              strokeJsonSvgPathsEmpty
                ? 'border-amber-500/90 shadow-[0_0_0_1px_rgba(245,158,11,0.35)] ring-2 ring-amber-400/20'
                : 'border-outline-variant/70 ring-1 ring-black/[0.02]'
            "
          >
            <div
              class="flex flex-wrap items-start justify-between gap-2 border-b border-outline-variant/50 bg-surface-low/90 px-3 py-2.5 sm:px-4"
            >
              <div class="min-w-0 flex-1">
                <h2 class="text-sm font-semibold text-onSurface">
                  hanja_stroke · JSON
                </h2>
                <p class="mt-0.5 text-[11px] text-onSurface-variant">
                  Firestore 문서를 직접 편집합니다. 저장 시 merge로 반영됩니다.
                </p>
              </div>
              <div
                class="flex shrink-0 flex-wrap items-center justify-end gap-2"
              >
                <code
                  v-if="strokeFirestoreDocId"
                  class="max-w-[min(100%,12rem)] truncate rounded-md border border-primary/20 bg-primary/[0.08] px-2 py-1 font-mono text-[11px] font-medium text-primary sm:max-w-xs"
                  :title="strokeFirestoreDocId"
                >{{ strokeFirestoreDocId }}</code>
                <span
                  v-else
                  class="text-[11px] text-onSurface-variant"
                >문서 ID 없음</span>
                <button
                  type="button"
                  class="btn-primary px-3 py-1.5 text-xs shadow-md shadow-primary/15 sm:text-sm"
                  :disabled="loading || !selectedEtlDocId"
                  title="선택한 한 행 기준 CSV를 클립보드에 복사합니다."
                  @click="runEtlOnSelection"
                >
                  획순 DATA
                </button>
              </div>
            </div>

            <div
              v-if="
                isFirebaseConfigured() &&
                  auth.ready &&
                  auth.isAuthenticated &&
                  !auth.isAdmin
              "
              class="mx-3 mt-2 rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-[11px] text-amber-950"
            >
              <strong class="font-medium">admin</strong> 클레임이 있어야 JSON을 저장할 수 있습니다.
            </div>

            <div class="relative min-h-0 flex-1 p-3 sm:p-4">
              <p
                v-if="!selectedEtlDocId"
                class="rounded-xl border border-dashed border-outline-variant/80 bg-surface-low/50 px-4 py-10 text-center text-sm text-onSurface-variant"
              >
                행을 눌러 선택하면 연결된
                <code class="rounded bg-white/80 px-1 font-mono text-xs text-primary">hanja_stroke</code>
                데이터가 여기에 표시됩니다.
              </p>
              <template v-else>
                <p
                  v-if="!strokeFirestoreDocId"
                  class="rounded-xl border border-amber-200/80 bg-amber-50/80 px-3 py-3 text-xs leading-relaxed text-amber-950"
                >
                  레거시
                  <code class="rounded bg-white/90 px-1 font-mono text-[10px]">hanja</code>
                  문서에
                  <code class="rounded bg-white/90 px-1 font-mono text-[10px]">stroke_data_id</code>
                  가 없습니다. ID를 연결한 뒤 다시 선택하거나, 파이프라인으로 문서를 만든 후 사용하세요.
                </p>
                <textarea
                  v-else
                  v-model="strokeJsonEditorText"
                  :readonly="strokeLoading || strokeJsonSaving"
                  spellcheck="false"
                  class="input-minimal h-full min-h-[16rem] w-full resize-y rounded-lg border border-outline-variant/70 bg-surface-low px-3 py-2.5 font-mono text-[11px] leading-relaxed text-onSurface shadow-inner focus:border-primary/40 focus:ring-1 focus:ring-primary/20"
                  aria-label="hanja_stroke JSON"
                />
                <div
                  v-if="strokeJsonSaveError"
                  class="mt-2 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900"
                >
                  {{ strokeJsonSaveError }}
                </div>
                <div
                  v-if="strokeFirestoreDocId"
                  class="mt-3 flex flex-wrap items-center gap-2"
                >
                  <button
                    type="button"
                    class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
                    :disabled="!strokeJsonDirty || strokeJsonSaving || strokeLoading"
                    @click="revertStrokeJsonEditor"
                  >
                    되돌리기
                  </button>
                  <button
                    type="button"
                    class="btn-primary px-3 py-1.5 text-xs shadow-sm shadow-primary/15 sm:text-sm"
                    :disabled="
                      !strokeJsonDirty ||
                        !canMutateStrokeDoc ||
                        strokeJsonSaving ||
                        strokeLoading
                    "
                    title="admin · 로그인 필요"
                    @click="saveHanjaStrokeJson"
                  >
                    {{ strokeJsonSaving ? "저장 중…" : "Firestore에 저장" }}
                  </button>
                  <span
                    v-if="strokeJsonDirty"
                    class="text-[11px] text-onSurface-variant"
                  >저장되지 않은 변경 있음</span>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </template>

    <Teleport to="body">
      <div
        v-if="etlHelpTooltipOpen"
        id="etl-help-tooltip-text"
        class="fixed z-[10050] rounded-xl border border-outline-variant/80 bg-surface-lowest p-3.5 text-left text-xs leading-relaxed text-onSurface shadow-[0_16px_48px_rgba(25,28,30,0.18)] ring-1 ring-black/[0.06]"
        :style="etlHelpTooltipStyle"
        role="tooltip"
      >
        획 데이터는
        <code class="mx-0.5 rounded bg-primary/10 px-1 py-px font-mono text-[10px] text-primary">hanja</code>
        의
        <code class="mx-0.5 rounded bg-primary/10 px-1 py-px font-mono text-[10px] text-primary">strokes</code>
        또는
        <code class="mx-0.5 rounded bg-primary/10 px-1 py-px font-mono text-[10px] text-primary">hanja_stroke</code>
        에서 읽습니다. 목록에서
        <strong class="font-medium text-onSurface">행을 눌러 한 건</strong>을 선택하면 우측
        <strong class="font-medium text-onSurface">hanja_stroke JSON</strong>에 반영됩니다. 추가 수집은
        <code class="mx-0.5 rounded bg-primary/10 px-1 py-px font-mono text-[10px] text-primary">admin/python/hanja_pipeline.py</code>
        를 사용합니다.
      </div>
    </Teleport>
  </div>
</template>
