<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import {
  collection,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  writeBatch,
} from "firebase/firestore";
import StrokeOrderViewer from "@/components/dashboard/StrokeOrderViewer.vue";
import type { StrokeShape } from "@/components/dashboard/StrokeOrderViewer.vue";
import { getFirebaseAuth, getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

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

const auth = useAuthStore();

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

/** 단일 선택 (문서 ID = hanja_basis 키) */
const selectedBasisDocId = ref<string | null>(null);

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

/** hanja_basis 추가·수정 모달 */
const basisFormModalOpen = ref(false);
const basisFormMode = ref<"add" | "edit">("add");
const basisFormOriginalDocId = ref<string | null>(null);
const basisForm = ref<Record<string, string>>({});
const basisFormBusy = ref(false);
const basisFormError = ref<string | null>(null);

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

/** 타일 하단 캡션: 價 (값 가) 형태 */
function basisTileFooterCaption(row: Row): string {
  const hanja = String(row["한자"] ?? "").trim() || "—";
  const hunEum = String(row["훈음"] ?? "").trim();
  if (hunEum) return `${hanja} (${hunEum})`;
  const hun = String(row["훈"] ?? "").trim();
  const eum = String(row["음"] ?? "").trim();
  const inner = [hun, eum].filter(Boolean).join(" ").trim();
  if (inner) return `${hanja} (${inner})`;
  return hanja;
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

/** 카드 클릭: 한 번에 하나만 선택. 같은 카드 재클릭 시 해제. */
function selectBasisCard(docId: string) {
  if (selectedBasisDocId.value === docId) {
    selectedBasisDocId.value = null;
  } else {
    selectedBasisDocId.value = docId;
  }
}

const soleSelectedEntry = computed((): DocEntry | null => {
  const id = selectedBasisDocId.value;
  if (!id) return null;
  return allDocs.value.find((d) => d.id === id) ?? null;
});

const canUseSelectionActions = computed(
  () => selectedBasisDocId.value !== null && !loading.value,
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

const selectedCount = computed(() =>
  selectedBasisDocId.value ? 1 : 0,
);

const basisTotalLabel = computed(() =>
  allDocs.value.length.toLocaleString("ko-KR"),
);

const canMutateBasis = computed(
  () =>
    isFirebaseConfigured() &&
    auth.isAuthenticated &&
    auth.isAdmin,
);

function emptyBasisForm(): Record<string, string> {
  const o: Record<string, string> = {};
  for (const c of COLUMN_ORDER) o[c] = "";
  return o;
}

function rowToFormStrings(data: Row): Record<string, string> {
  const o = emptyBasisForm();
  for (const c of COLUMN_ORDER) {
    const v = data[c];
    o[c] =
      v === null || v === undefined
        ? ""
        : typeof v === "object"
          ? JSON.stringify(v)
          : String(v);
  }
  return o;
}

function safeDocIdLocal(raw: string, fallback: string): string {
  const s = raw.replace(/\//g, "_").replace(/[\s#?[\]]/g, "_").slice(0, 500);
  return s || fallback;
}

/** 업로드 규칙과 동일: 한자 우선 → H+16진, 없으면 id 열의 H… 또는 안전 문자열 */
function basisDocIdFromForm(form: Record<string, string>): string | null {
  const hanja = String(form["한자"] ?? "").trim();
  if (hanja.length > 0) {
    const cp = hanja.codePointAt(0);
    if (cp !== undefined) {
      return `H${cp.toString(16).toUpperCase()}`;
    }
  }
  const idCol = String(form["id"] ?? "").trim();
  const hex = /^H([0-9A-Fa-f]+)$/i.exec(idCol);
  if (hex) return `H${hex[1]!.toUpperCase()}`;
  if (idCol) {
    const s = safeDocIdLocal(idCol, "");
    return s || null;
  }
  return null;
}

const basisFormResolvedId = computed(
  () => basisDocIdFromForm(basisForm.value) ?? "—",
);

function openBasisAddModal() {
  basisFormMode.value = "add";
  basisFormOriginalDocId.value = null;
  basisForm.value = emptyBasisForm();
  basisFormError.value = null;
  basisFormModalOpen.value = true;
}

function openBasisEditModal() {
  const ent = soleSelectedEntry.value;
  if (!ent) return;
  basisFormMode.value = "edit";
  basisFormOriginalDocId.value = ent.id;
  basisForm.value = rowToFormStrings(ent.data);
  basisFormError.value = null;
  basisFormModalOpen.value = true;
}

function closeBasisFormModal() {
  basisFormModalOpen.value = false;
  basisFormError.value = null;
  basisFormBusy.value = false;
}

async function saveBasisForm() {
  const newId = basisDocIdFromForm(basisForm.value);
  if (!newId) {
    basisFormError.value =
      "문서 ID를 정할 수 없습니다. 한자를 입력하거나 id에 H+16진 형식을 넣으세요.";
    return;
  }
  if (!isFirebaseConfigured()) {
    basisFormError.value = "Firebase가 설정되지 않았습니다.";
    return;
  }
  basisFormBusy.value = true;
  basisFormError.value = null;
  try {
    const user = getFirebaseAuth().currentUser;
    if (!user) {
      basisFormError.value = "로그인이 필요합니다.";
      return;
    }
    await user.getIdToken(true);
    const db = getFirestoreDb();
    const colRef = collection(db, "hanja_basis");

    const payload: Record<string, unknown> = {};
    for (const c of COLUMN_ORDER) {
      payload[c] = c === "id" ? newId : (basisForm.value[c] ?? "");
    }
    payload._importedAt = serverTimestamp();
    if (basisFormMode.value === "edit" && basisFormOriginalDocId.value) {
      const old = allDocs.value.find(
        (d) => d.id === basisFormOriginalDocId.value,
      );
      if (old?.data._row != null) payload._row = old.data._row;
    }

    if (basisFormMode.value === "edit" && basisFormOriginalDocId.value) {
      const oldId = basisFormOriginalDocId.value;
      if (newId !== oldId) {
        const batch = writeBatch(db);
        batch.delete(doc(colRef, oldId));
        batch.set(doc(colRef, newId), payload, { merge: true });
        await batch.commit();
      } else {
        await setDoc(doc(colRef, oldId), payload, { merge: true });
      }
    } else {
      await setDoc(doc(colRef, newId), payload, { merge: true });
    }

    closeBasisFormModal();
    selectedBasisDocId.value = newId;
    await loadAll();
  } catch (e) {
    basisFormError.value =
      e instanceof Error ? e.message : "저장에 실패했습니다.";
  } finally {
    basisFormBusy.value = false;
  }
}

async function deleteSelectedBasis() {
  const toDelete = selectedBasisDocId.value;
  if (!canMutateBasis.value || !toDelete) return;
  if (
    !confirm(
      "선택한 1건을 hanja_basis에서 삭제합니다. 되돌릴 수 없습니다. 계속할까요?",
    )
  ) {
    return;
  }
  if (!isFirebaseConfigured()) {
    error.value = "Firebase가 설정되지 않았습니다.";
    return;
  }
  loading.value = true;
  error.value = null;
  try {
    const user = getFirebaseAuth().currentUser;
    if (!user) {
      error.value = "로그인이 필요합니다.";
      return;
    }
    await user.getIdToken(true);
    const db = getFirestoreDb();
    const colRef = collection(db, "hanja_basis");
    const batch = writeBatch(db);
    batch.delete(doc(colRef, toDelete));
    await batch.commit();
    selectedBasisDocId.value = null;
    await loadAll();
  } catch (e) {
    error.value =
      e instanceof Error ? e.message : "삭제에 실패했습니다.";
  } finally {
    loading.value = false;
  }
}

const BASIS_MANAGE_HELP_TEXT =
  "그리드 위 조회 · 획순은 카드를 눌러 한 개만 선택한 뒤 사용합니다. 조회는 hanja_extend, 획순은 hanja_extend → hanja_stroke → 레거시 hanja 순으로 획 데이터를 불러옵니다. 행 추가·수정·삭제는 Firestore hanja_basis 에 직접 반영됩니다.";

const basisManageHelpTriggerRef = ref<HTMLButtonElement | null>(null);
const basisManageHelpTooltipOpen = ref(false);
const basisManageHelpTooltipStyle = ref<Record<string, string>>({});

let basisManageHelpRemoveScrollListeners: (() => void) | null = null;

function positionBasisManageHelpTooltip() {
  const el = basisManageHelpTriggerRef.value;
  if (!el) return;
  const r = el.getBoundingClientRect();
  const margin = 10;
  const maxW = Math.min(400, window.innerWidth - margin * 2);
  let left = r.left;
  if (left + maxW > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - margin - maxW);
  }
  if (left < margin) left = margin;
  basisManageHelpTooltipStyle.value = {
    top: `${Math.round(r.bottom + margin)}px`,
    left: `${Math.round(left)}px`,
    maxWidth: `${maxW}px`,
  };
}

function openBasisManageHelpTooltip() {
  positionBasisManageHelpTooltip();
  basisManageHelpTooltipOpen.value = true;
  void nextTick(() => positionBasisManageHelpTooltip());
}

function closeBasisManageHelpTooltip() {
  basisManageHelpTooltipOpen.value = false;
}

watch(basisManageHelpTooltipOpen, (open) => {
  basisManageHelpRemoveScrollListeners?.();
  basisManageHelpRemoveScrollListeners = null;
  if (!open) return;
  const handler = () => positionBasisManageHelpTooltip();
  window.addEventListener("scroll", handler, true);
  window.addEventListener("resize", handler);
  basisManageHelpRemoveScrollListeners = () => {
    window.removeEventListener("scroll", handler, true);
    window.removeEventListener("resize", handler);
  };
});

onUnmounted(() => {
  basisManageHelpRemoveScrollListeners?.();
});

onMounted(() => {
  void loadAll();
});
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 (툴팁이 잘리지 않도록 장식만 clip) -->
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
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            基
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <div class="min-w-0 flex-1 leading-tight">
              <p
                class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
              >
                Firestore · hanja_basis
              </p>
              <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
                기준 데이터
              </h1>
            </div>
            <div class="relative shrink-0 pt-0.5">
              <button
                ref="basisManageHelpTriggerRef"
                type="button"
                class="flex h-6 w-6 items-center justify-center rounded-full border border-primary/35 bg-primary/12 text-xs font-bold leading-none text-primary shadow-sm outline-none ring-primary/20 transition hover:bg-primary/18 focus-visible:ring-2"
                :aria-label="BASIS_MANAGE_HELP_TEXT"
                :aria-describedby="
                  basisManageHelpTooltipOpen
                    ? 'basis-manage-help-tooltip-text'
                    : undefined
                "
                @mouseenter="openBasisManageHelpTooltip"
                @mouseleave="closeBasisManageHelpTooltip"
                @focus="openBasisManageHelpTooltip"
                @blur="closeBasisManageHelpTooltip"
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
            필터 결과
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
            :disabled="loading || !canMutateBasis"
            title="admin 클레임·로그인 필요"
            @click="openBasisAddModal"
          >
            추가
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="!canMutateBasis || !canUseSelectionActions"
            title="카드 한 개 선택 · admin 필요"
            @click="openBasisEditModal"
          >
            수정
          </button>
          <button
            type="button"
            class="rounded-md border border-red-300/90 bg-surface-low px-3 py-1.5 text-xs font-medium text-red-800 transition hover:bg-red-50/80 disabled:cursor-not-allowed disabled:opacity-50 sm:text-sm"
            :disabled="loading || !canMutateBasis || selectedCount === 0"
            title="선택한 항목 삭제 · admin 필요"
            @click="deleteSelectedBasis"
          >
            삭제
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="loading"
            @click="refresh"
          >
            새로고침
          </button>
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
          검색 및 목록
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
        <div class="flex w-[4.75rem] shrink-0 flex-col">
          <label
            class="mb-0.5 whitespace-nowrap text-[10px] font-medium text-onSurface-variant"
            >구분</label
          >
          <select
            v-model="filter구분"
            class="input-minimal w-full cursor-pointer py-1.5 text-sm"
          >
            <option value="">전체</option>
            <option value="중">중</option>
            <option value="고">고</option>
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
      v-if="
        isFirebaseConfigured() &&
          auth.ready &&
          auth.isAuthenticated &&
          !auth.isAdmin
      "
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-2.5 text-xs text-amber-950 shadow-sm"
    >
      <strong class="font-medium">admin</strong> 클레임이 있어야
      <strong class="font-medium">추가·수정·삭제</strong>가 가능합니다. 설정 → 인증에서 토큰을 갱신하세요.
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
        한자 마스터 등록에서 <code class="rounded bg-surface-low px-1.5 py-0.5 font-mono text-xs">hanja_basis</code> CSV를 업로드하세요.
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
        검색어나 구분 조건을 바꾸거나 필터 초기화를 눌러 보세요.
      </p>
    </div>

    <template v-if="rows.length">
      <div
        class="overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-low/50 p-3 shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02] sm:p-4"
      >
        <div
          class="mb-3 flex flex-col gap-3 border-b border-outline-variant/50 pb-3 sm:flex-row sm:items-center sm:justify-end"
        >
          <div class="flex shrink-0 flex-wrap items-center gap-2 sm:justify-end">
            <button
              type="button"
              class="btn-primary px-3 py-1.5 text-xs shadow-sm shadow-primary/15 sm:text-sm"
              :disabled="!canUseSelectionActions"
              title="카드 한 개 선택"
              @click="openExtendLookupModal"
            >
              조회
            </button>
            <button
              type="button"
              class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
              :disabled="!canUseSelectionActions"
              title="카드 한 개 선택"
              @click="openStrokeOrderModal"
            >
              획순
            </button>
          </div>
        </div>
        <div
          class="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6"
        >
          <article
            v-for="(row, i) in rows"
            :key="ids[i] ?? i"
            class="relative flex min-h-[10.5rem] cursor-pointer flex-col rounded-xl border p-3 pt-9 text-left shadow-sm transition-all duration-150"
            :class="
              selectedBasisDocId === ids[i]
                ? 'border-primary bg-primary/[0.12] ring-2 ring-primary/35 shadow-md shadow-primary/15'
                : 'border-outline-variant/80 bg-white focus-within:ring-2 focus-within:ring-primary/20 hover:border-outline-variant hover:shadow-md hover:shadow-black/[0.05]'
            "
            role="button"
            tabindex="0"
            :aria-pressed="selectedBasisDocId === ids[i]"
            :aria-label="`${selectedBasisDocId === ids[i] ? '선택됨' : '선택'} · ${String(row['한자'] ?? '') || basisDisplayId(ids[i]!, row)}`"
            @click="selectBasisCard(ids[i]!)"
            @keydown.enter.prevent="selectBasisCard(ids[i]!)"
            @keydown.space.prevent="selectBasisCard(ids[i]!)"
          >
            <div
              class="pointer-events-none absolute left-2.5 top-2.5 z-10"
              aria-hidden="true"
            >
              <input
                type="checkbox"
                tabindex="-1"
                class="h-4 w-4 cursor-default rounded border-outline-variant text-primary"
                :checked="selectedBasisDocId === ids[i]"
              />
            </div>
            <div
              v-if="String(row['구분'] ?? '').trim()"
              class="pointer-events-none absolute right-2 top-2 z-10"
            >
              <span
                class="flex h-7 w-7 items-center justify-center rounded-full border border-outline-variant/70 bg-surface-low text-[11px] font-bold text-onSurface shadow-sm"
                :title="String(row['구분']).trim()"
              >
                {{ String(row["구분"]).trim().charAt(0) }}
              </span>
            </div>
            <div
              class="flex flex-1 flex-col items-center justify-center gap-1 px-1 text-center"
            >
              <p
                class="font-display text-4xl font-semibold leading-none tracking-tight text-onSurface sm:text-[2.75rem]"
                :title="String(row['한자'] ?? '')"
              >
                {{ row["한자"] ?? "—" }}
              </p>
              <p
                v-if="String(row['훈음'] ?? '').trim()"
                class="line-clamp-2 w-full text-xs leading-snug text-onSurface"
                :title="String(row['훈음'])"
              >
                {{ row["훈음"] }}
              </p>
              <p
                v-else
                class="line-clamp-2 w-full text-xs leading-snug text-onSurface"
              >
                <span
                  v-if="String(row['훈'] ?? '').trim()"
                  class="block"
                >{{ row["훈"] }}</span>
                <span
                  v-if="String(row['음'] ?? '').trim()"
                  class="mt-0.5 block text-onSurface-variant"
                >{{ row["음"] }}</span>
                <span
                  v-if="
                    !String(row['훈'] ?? '').trim() &&
                      !String(row['음'] ?? '').trim()
                  "
                  class="text-onSurface-variant"
                >—</span>
              </p>
            </div>
            <div class="mt-auto border-t border-outline-variant/50 pt-2 text-left">
              <p
                class="line-clamp-2 text-[11px] leading-snug text-onSurface"
                :title="basisTileFooterCaption(row)"
              >
                {{ basisTileFooterCaption(row) }}
              </p>
              <p
                class="mt-1 font-mono text-[11px] font-semibold text-primary"
                :title="basisDisplayId(ids[i]!, row)"
              >
                {{ basisDisplayId(ids[i]!, row) }}
              </p>
            </div>
          </article>
        </div>
      </div>

      <div
        class="flex flex-col gap-3 rounded-xl border border-outline-variant/60 bg-surface-low/80 px-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-5"
      >
        <p class="text-xs text-onSurface-variant">
          <span class="font-medium text-onSurface tabular-nums">{{ rangeStart }}–{{ rangeEnd }}</span>
          <span class="mx-1 text-onSurface-variant/70">/</span>
          <span class="tabular-nums">{{ totalCount.toLocaleString("ko-KR") }}</span>건
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
              class="min-w-[2.25rem] rounded-lg px-2 py-1.5 text-sm font-medium transition"
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
              class="grid grid-cols-1 gap-3 sm:grid-cols-2"
            >
              <div
                v-for="fr in extendFieldRows"
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
        class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
        role="dialog"
        aria-modal="true"
        aria-labelledby="basis-stroke-modal-title"
        @click.self="closeStrokeModal"
      >
        <div
          class="flex max-h-[min(92vh,56rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
        >
          <div
            class="relative shrink-0 overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-5 pt-5"
          >
            <div
              class="pointer-events-none absolute -right-8 -top-10 h-36 w-36 rounded-full bg-primary/[0.12] blur-2xl"
            />
            <div class="relative flex items-start justify-between gap-4">
              <div class="min-w-0 flex items-start gap-3">
                <div
                  class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-lg font-bold text-white shadow-md shadow-primary/25"
                  aria-hidden="true"
                >
                  {{ strokeModalTitle && strokeModalTitle.length <= 2 ? strokeModalTitle : "획" }}
                </div>
                <div class="min-w-0">
                  <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                    Stroke order
                  </p>
                  <h2
                    id="basis-stroke-modal-title"
                    class="font-display text-xl font-semibold tracking-tight text-onSurface"
                  >
                    획순
                  </h2>
                  <p class="mt-0.5 truncate text-xs text-onSurface-variant">
                    {{ strokeModalSubtitle || "—" }}
                  </p>
                </div>
              </div>
              <button
                type="button"
                class="btn-secondary shrink-0 px-3 py-2 text-sm"
                @click="closeStrokeModal"
              >
                닫기
              </button>
            </div>
          </div>
          <div
            class="min-h-0 flex-1 overflow-y-auto overflow-x-hidden bg-surface px-4 py-4 sm:px-5 sm:py-5"
          >
            <div
              v-if="strokeLoading"
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
              v-else-if="strokeError"
              class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3.5 text-sm text-red-900 shadow-sm"
            >
              <p class="font-semibold text-red-950">획순 로드 실패</p>
              <p class="mt-1 leading-relaxed text-red-800/95">
                {{ strokeError }}
              </p>
            </div>
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

    <!-- hanja_basis 추가·수정 -->
    <Teleport to="body">
      <div
        v-if="basisFormModalOpen"
        class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
        role="dialog"
        aria-modal="true"
        aria-labelledby="basis-form-modal-title"
        @click.self="closeBasisFormModal"
      >
        <div
          class="flex max-h-[min(92vh,52rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
        >
          <div
            class="relative shrink-0 overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-4 pt-4"
          >
            <div
              class="pointer-events-none absolute -right-8 -top-10 h-32 w-32 rounded-full bg-primary/[0.1] blur-2xl"
            />
            <div class="relative flex items-start justify-between gap-3">
              <div>
                <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                  Firestore · hanja_basis
                </p>
                <h2
                  id="basis-form-modal-title"
                  class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl"
                >
                  {{ basisFormMode === "add" ? "항목 추가" : "항목 수정" }}
                </h2>
                <p class="mt-1 text-xs text-onSurface-variant">
                  필드는 타일 그리드로 입력합니다. 문서 ID는 아래 타일에서 확인하세요.
                </p>
              </div>
              <button
                type="button"
                class="btn-secondary shrink-0 px-3 py-2 text-sm"
                :disabled="basisFormBusy"
                @click="closeBasisFormModal"
              >
                닫기
              </button>
            </div>
          </div>
          <div class="min-h-0 flex-1 overflow-y-auto px-4 py-4 sm:px-5 sm:py-5">
            <div
              v-if="basisFormError"
              class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900 shadow-sm"
            >
              {{ basisFormError }}
            </div>
            <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <!-- 문서 ID -->
              <div
                class="rounded-xl border border-primary/25 bg-gradient-to-br from-primary/[0.08] to-surface-lowest p-3 shadow-sm ring-1 ring-primary/10 sm:col-span-2"
              >
                <p
                  class="text-[10px] font-semibold uppercase tracking-wide text-primary/90"
                >
                  저장 시 문서 ID
                </p>
                <p class="mt-1 break-all font-mono text-base font-semibold text-primary sm:text-lg">
                  {{ basisFormResolvedId }}
                </p>
              </div>

              <!-- 한자 (메인) -->
              <div
                class="rounded-2xl border-2 border-primary/20 bg-gradient-to-b from-primary/[0.07] to-surface-lowest p-4 shadow-sm sm:col-span-2"
              >
                <label
                  class="mb-2 block text-center text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-한자"
                >한자</label>
                <input
                  id="basis-form-한자"
                  v-model="basisForm['한자']"
                  type="text"
                  class="input-minimal w-full border-0 bg-white/60 py-3 text-center text-4xl font-display font-semibold tracking-tight shadow-inner sm:text-5xl"
                  autocomplete="off"
                />
              </div>

              <!-- 음 · 훈 -->
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-음"
                >음</label>
                <input
                  id="basis-form-음"
                  v-model="basisForm['음']"
                  type="text"
                  class="input-minimal py-2 text-sm"
                  autocomplete="off"
                />
              </div>
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-훈"
                >훈</label>
                <input
                  id="basis-form-훈"
                  v-model="basisForm['훈']"
                  type="text"
                  class="input-minimal py-2 text-sm"
                  autocomplete="off"
                />
              </div>

              <!-- 훈음 -->
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02] sm:col-span-2"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-훈음"
                >훈음</label>
                <input
                  id="basis-form-훈음"
                  v-model="basisForm['훈음']"
                  type="text"
                  class="input-minimal py-2 text-sm"
                  autocomplete="off"
                />
              </div>

              <!-- 전체 -->
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02] sm:col-span-2"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-전체"
                >전체</label>
                <input
                  id="basis-form-전체"
                  v-model="basisForm['전체']"
                  type="text"
                  class="input-minimal py-2 text-sm"
                  autocomplete="off"
                />
              </div>

              <!-- id · 구분 -->
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-id"
                >id</label>
                <p class="mb-1 text-[10px] leading-tight text-onSurface-variant">
                  한자 없을 때 H+16진 등
                </p>
                <input
                  id="basis-form-id"
                  v-model="basisForm['id']"
                  type="text"
                  class="input-minimal py-2 font-mono text-xs"
                  placeholder="비우면 한자로부터 자동"
                  autocomplete="off"
                />
              </div>
              <div
                class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
              >
                <label
                  class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                  for="basis-form-구분"
                >구분</label>
                <select
                  id="basis-form-구분"
                  v-model="basisForm['구분']"
                  class="input-minimal w-full cursor-pointer py-2 text-sm"
                >
                  <option value="">(비움)</option>
                  <option value="중">중</option>
                  <option value="고">고</option>
                </select>
              </div>

              <!-- 안내 -->
              <div
                class="rounded-xl border border-outline-variant/60 bg-surface-low/50 p-3 text-[11px] leading-relaxed text-onSurface-variant sm:col-span-2"
              >
                한자가 있으면 문서 ID는 그 글자의
                <code class="rounded bg-white/80 px-1 font-mono text-[10px] text-primary">H</code>+코드포인트입니다.
                수정 시 한자를 바꿔 ID가 바뀌면 기존 문서는 삭제되고 새 ID로 저장됩니다.
              </div>
            </div>
          </div>
          <div
            class="flex shrink-0 flex-wrap items-center justify-end gap-2 border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3"
          >
            <button
              type="button"
              class="btn-secondary px-4 py-2 text-sm"
              :disabled="basisFormBusy"
              @click="closeBasisFormModal"
            >
              취소
            </button>
            <button
              type="button"
              class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
              :disabled="basisFormBusy"
              @click="saveBasisForm"
            >
              {{ basisFormBusy ? "저장 중…" : "저장" }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <Teleport to="body">
      <div
        v-if="basisManageHelpTooltipOpen"
        id="basis-manage-help-tooltip-text"
        class="fixed z-[10050] rounded-xl border border-outline-variant/80 bg-surface-lowest p-3.5 text-left text-xs leading-relaxed text-onSurface shadow-[0_16px_48px_rgba(25,28,30,0.18)] ring-1 ring-black/[0.06]"
        :style="basisManageHelpTooltipStyle"
        role="tooltip"
      >
        {{ BASIS_MANAGE_HELP_TEXT }}
      </div>
    </Teleport>
  </div>
</template>
