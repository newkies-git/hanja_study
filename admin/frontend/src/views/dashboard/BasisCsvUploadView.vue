<script setup lang="ts">
import { ref, computed, nextTick, watch, onUnmounted } from "vue";
import { RouterLink } from "vue-router";
import {
  collection,
  doc,
  getDocs,
  limit,
  query,
  serverTimestamp,
  writeBatch,
} from "firebase/firestore";
import { getFirebaseAuth, getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

/** Firestore 컬렉션 권장 업로드 순서 (단계는 자유 선택 가능, 후속 단계는 선행 컬렉션 존재 시에만 반영) */
const UPLOAD_STEPS = [
  {
    collection: "hanja_basis",
    title: "1. hanja_basis",
    description: "기준 한자 마스터 · 문서 ID=H+코드포인트(한자 기준)",
  },
  {
    collection: "hanja_extend",
    title: "2. hanja_extend",
    description: "확장 필드 (JSON 권장)",
  },
  {
    collection: "hanja_stroke",
    title: "3. hanja_stroke",
    description:
      "획순 데이터 (JSON 권장). 여러 개의 JSON 배열 파일을 한 번에 선택해 업로드할 수 있습니다. svg_paths 가 있어야 실루엣이 표시됩니다.",
  },
  {
    collection: "hanja_word",
    title: "4. hanja_word",
    description:
      "단어·용례 (JSON 권장). 여러 개의 JSON 배열 파일을 한 번에 선택해 업로드할 수 있습니다.",
  },
] as const;

type StepIndex = 0 | 1 | 2 | 3;

type CsvPreview = {
  kind: "csv";
  fileName: string;
  size: number;
  rows: string[][];
};

type JsonPreview = {
  kind: "json";
  fileName: string;
  size: number;
  items: Record<string, unknown>[];
  /** 멀티 JSON 업로드 시 파일별 건수 (미리보기·요약용) */
  sourceParts?: { fileName: string; size: number; count: number }[];
};

const auth = useAuthStore();
/** 선택된 파일 (1~4단계). 3·4단계는 JSON일 때 복수 선택 가능 */
const selectedFiles = ref<File[]>([]);
const busy = ref(false);
const message = ref<string | null>(null);
const uploadError = ref<
  | { kind: "plain"; message: string }
  | { kind: "permission"; steps: string[] }
  | null
>(null);
const lastImported = ref(0);

/** 업로드 진행 (busy 동안만 의미 있음) */
const uploadProgressPhase = ref<"idle" | "validate" | "upload">("idle");
const uploadProgressTotal = ref(0);
const uploadProgressDone = ref(0);
const uploadBatchCurrent = ref(0);
const uploadBatchTotal = ref(0);
const uploadStartedAt = ref(0);
const uploadElapsedMs = ref(0);

const currentStepIndex = ref<StepIndex>(0);

const uploadPreview = ref<CsvPreview | JsonPreview | null>(null);

const lastUploadSummary = ref<{
  collection: string;
  fileName: string;
  format: "csv" | "json";
  headers: string[];
  dataRowCount: number;
  columnCount: number;
  importedRows: number;
  durationMs: number;
} | null>(null);

const sessionCompleted = ref<
  { collection: string; fileName: string; importedRows: number }[]
>([]);

const sessionCoversAllSteps = computed(() =>
  UPLOAD_STEPS.every((s) =>
    sessionCompleted.value.some((c) => c.collection === s.collection),
  ),
);

function stepSessionDone(stepIndex: number): boolean {
  const s = UPLOAD_STEPS[stepIndex];
  if (!s) return false;
  return sessionCompleted.value.some((c) => c.collection === s.collection);
}

function selectStep(i: StepIndex) {
  if (currentStepIndex.value === i) return;
  currentStepIndex.value = i;
  clearFileState();
  message.value = null;
  uploadError.value = null;
  lastUploadSummary.value = null;
  lastImported.value = 0;
}

/** 선행 단계 컬렉션에 문서가 1건 이상 있는지 (권장 의존 순서 검증) */
async function collectionHasAnyDoc(collName: string): Promise<boolean> {
  const db = getFirestoreDb();
  const q = query(collection(db, collName), limit(1));
  const snap = await getDocs(q);
  return !snap.empty;
}

const currentStep = computed(() => {
  const i = currentStepIndex.value;
  if (i < 0 || i >= UPLOAD_STEPS.length) return null;
  return UPLOAD_STEPS[i as 0 | 1 | 2 | 3];
});

/** 2~4단계: ETL 산출 JSON이 표준. CSV도 호환 */
const allowsJson = computed(() => currentStepIndex.value >= 1);

/** hanja_stroke(2) · hanja_word(3): JSON 멀티 파일 선택 */
const allowsMultiJsonFiles = computed(() => currentStepIndex.value >= 2);

const fileInputId = computed(
  () => `data-file-input-${currentStepIndex.value}`,
);

const canUpload = computed(() => {
  if (
    !isFirebaseConfigured() ||
    !auth.isAuthenticated ||
    selectedFiles.value.length === 0 ||
    !uploadPreview.value ||
    busy.value
  ) {
    return false;
  }
  const p = uploadPreview.value;
  if (p.kind === "csv") return p.rows.length >= 2;
  return p.items.length >= 1;
});

const normalizedHeaders = computed(() => {
  if (!uploadPreview.value) return [];
  if (uploadPreview.value.kind === "csv") {
    return uploadPreview.value.rows[0].map(
      (h) => h.replace(/^\ufeff/, "").trim() || "col",
    );
  }
  const keys = new Set<string>();
  for (const item of uploadPreview.value.items.slice(0, 200)) {
    Object.keys(item).forEach((k) => keys.add(k));
  }
  return [...keys];
});

const previewDataRows = computed(() => {
  if (!uploadPreview.value) return [];
  if (uploadPreview.value.kind === "csv") {
    const rows = uploadPreview.value.rows;
    const cols = normalizedHeaders.value.length;
    return rows.slice(1, 9).map((r) => {
      const cells = [...r];
      while (cells.length < cols) cells.push("");
      return cells.slice(0, cols);
    });
  }
  const headers = normalizedHeaders.value;
  return uploadPreview.value.items.slice(0, 8).map((item) =>
    headers.map((h) => {
      const v = item[h];
      if (v === null || v === undefined) return "";
      if (typeof v === "object") return JSON.stringify(v).slice(0, 80);
      return String(v);
    }),
  );
});

const previewDocCount = computed(() => {
  if (!uploadPreview.value) return 0;
  if (uploadPreview.value.kind === "csv") {
    return Math.max(0, uploadPreview.value.rows.length - 1);
  }
  return uploadPreview.value.items.length;
});

function formatBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(2)} MB`;
}

function formatDuration(ms: number): string {
  if (ms < 1000) return `${ms}ms`;
  const s = Math.floor(ms / 1000);
  const m = Math.floor(s / 60);
  const rs = s % 60;
  if (m === 0) return `${s}초`;
  return `${m}분 ${rs}초`;
}

function tickUploadElapsed() {
  if (uploadStartedAt.value > 0) {
    uploadElapsedMs.value = Math.round(performance.now() - uploadStartedAt.value);
  }
}

const uploadProgressPercent = computed(() => {
  const t = uploadProgressTotal.value;
  if (t <= 0) return 0;
  return Math.min(100, Math.round((uploadProgressDone.value / t) * 100));
});

const uploadProgressPhaseLabel = computed(() => {
  if (uploadProgressPhase.value === "validate") return "문서 검증";
  if (uploadProgressPhase.value === "upload") return "Firestore 반영";
  return "";
});

const uploadThroughputLabel = computed(() => {
  if (uploadProgressPhase.value !== "upload") return "";
  const ms = uploadElapsedMs.value;
  const done = uploadProgressDone.value;
  if (ms < 200 || done < 1) return "";
  const perSec = done / (ms / 1000);
  if (perSec >= 100) return ` · 약 ${Math.round(perSec).toLocaleString("ko-KR")}건/초`;
  if (perSec >= 1) return ` · 약 ${perSec.toFixed(1)}건/초`;
  return ` · 약 ${(60 / perSec).toFixed(0)}초/건`;
});

let uploadElapsedTimer: ReturnType<typeof setInterval> | null = null;

function stopUploadElapsedTicker() {
  if (uploadElapsedTimer !== null) {
    clearInterval(uploadElapsedTimer);
    uploadElapsedTimer = null;
  }
}

function resetUploadProgress() {
  stopUploadElapsedTicker();
  uploadProgressPhase.value = "idle";
  uploadProgressTotal.value = 0;
  uploadProgressDone.value = 0;
  uploadBatchCurrent.value = 0;
  uploadBatchTotal.value = 0;
  uploadStartedAt.value = 0;
  uploadElapsedMs.value = 0;
}

function beginUploadProgress() {
  stopUploadElapsedTicker();
  uploadStartedAt.value = performance.now();
  uploadElapsedMs.value = 0;
  uploadProgressDone.value = 0;
  uploadProgressTotal.value = 0;
  uploadBatchCurrent.value = 0;
  uploadBatchTotal.value = 0;
  uploadProgressPhase.value = "idle";
  uploadElapsedTimer = setInterval(() => {
    tickUploadElapsed();
  }, 250);
}

function parseCsvLine(line: string): string[] {
  const out: string[] = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      inQ = !inQ;
    } else if (!inQ && c === ",") {
      out.push(cur.trim());
      cur = "";
    } else {
      cur += c;
    }
  }
  out.push(cur.trim());
  return out;
}

function parseCsv(text: string): string[][] {
  return text
    .split(/\r?\n/)
    .filter((l) => l.trim().length > 0)
    .map(parseCsvLine);
}

function safeDocId(raw: string, fallback: string): string {
  const s = raw.replace(/\//g, "_").replace(/[\s#?[\]]/g, "_").slice(0, 500);
  return s || fallback;
}

/**
 * `hanja_basis` Firestore 문서 ID: `한자` 첫 글자의 유니코드 → `H`+대문자 16진.
 * 한자가 없으면 `id` 열 또는 첫 열이 `H[0-9A-F]+` 형태면 그대로 정규화, 아니면 첫 열을 safeDocId로.
 */
function normalizeHanjaBasisDocId(
  headers: string[],
  cells: string[],
  rowIndex: number,
): string {
  const cellFor = (name: string): string => {
    const i = headers.indexOf(name);
    return i >= 0 ? String(cells[i] ?? "").trim() : "";
  };
  const hanja = cellFor("한자");
  if (hanja.length > 0) {
    const cp = hanja.codePointAt(0);
    if (cp !== undefined) {
      return `H${cp.toString(16).toUpperCase()}`;
    }
  }
  const tryHex = (s: string): string | null => {
    const m = /^H([0-9A-Fa-f]+)$/.exec(s.trim());
    return m ? `H${m[1]!.toUpperCase()}` : null;
  };
  const fromIdCol = tryHex(cellFor("id"));
  if (fromIdCol) return fromIdCol;
  const firstCol = String(cells[0] ?? "").trim();
  const fromFirst = tryHex(firstCol);
  if (fromFirst) return fromFirst;
  return safeDocId(firstCol, `row_${rowIndex}_${Date.now()}`);
}

function docIdFromJsonItem(coll: string, item: Record<string, unknown>): string {
  if (coll === "hanja_extend") return String(item.id ?? "").trim();
  if (coll === "hanja_stroke") return String(item.stroke_data_id ?? "").trim();
  if (coll === "hanja_word")
    return String(item.word_id ?? item.id ?? "").trim();
  return "";
}

/** Firestore는 배열 안 배열을 허용하지 않아 [[x,y],...] → [{x,y},...] */
function pointsForFirestore(points: unknown): Array<{ x: number; y: number }> {
  if (!Array.isArray(points)) return [];
  const out: Array<{ x: number; y: number }> = [];
  for (const p of points) {
    if (Array.isArray(p) && p.length >= 2) {
      const x = p[0];
      const y = p[1];
      if (typeof x === "number" && typeof y === "number") {
        out.push({ x, y });
      }
    }
  }
  return out;
}

function strokesForFirestore(strokes: unknown): Record<string, unknown>[] {
  if (!Array.isArray(strokes)) return [];
  return strokes.map((s) => {
    if (!s || typeof s !== "object") return {};
    const d = { ...(s as Record<string, unknown>) };
    if ("points" in d) d.points = pointsForFirestore(d.points);
    return d;
  });
}

/** ETL stroke_entities 의 svg_paths: JSON 배열 또는 CSV 셀에 넣은 JSON 문자열 */
function normalizeSvgPathsForFirestore(value: unknown): string[] | undefined {
  if (value === undefined || value === null) return undefined;
  if (Array.isArray(value)) {
    const arr = value
      .map((v) =>
        typeof v === "string" ? v.trim() : String(v ?? "").trim(),
      )
      .filter((s) => s.length > 0);
    return arr.length > 0 ? arr : undefined;
  }
  if (typeof value === "string") {
    const t = value.trim();
    if (!t) return undefined;
    try {
      return normalizeSvgPathsForFirestore(JSON.parse(t) as unknown);
    } catch {
      return undefined;
    }
  }
  return undefined;
}

function payloadForFirestore(
  coll: string,
  raw: Record<string, unknown>,
): Record<string, unknown> {
  const payload = { ...raw };
  if (coll === "hanja_stroke") {
    if (Array.isArray(payload.strokes)) {
      payload.strokes = strokesForFirestore(payload.strokes);
    }
    const paths = normalizeSvgPathsForFirestore(payload.svg_paths);
    if (paths !== undefined) {
      payload.svg_paths = paths;
    }
  }
  return payload;
}

function parseFirestoreUploadError(e: unknown) {
  const msg = e instanceof Error ? e.message : String(e);
  if (/permission|insufficient permissions/i.test(msg)) {
    return {
      kind: "permission" as const,
      steps: [
        "규칙 배포: 터미널에서 cd admin/firestore 후 firebase deploy --only firestore:rules --project chusa-1817",
        "admin 클레임: admin/python/set_firebase_custom_claims.py 실행 후 재로그인하거나, 설정 → 인증 · 클레임에서 토큰 새로고침",
        ".env의 VITE_FIREBASE_* 가 Firebase 프로젝트 chusa-1817 웹 앱 설정과 일치하는지 확인",
        "상세 점검: 저장소 admin/firestore/firestore_connect.md §11.1",
      ],
    };
  }
  return {
    kind: "plain" as const,
    message: msg || "업로드 중 오류가 발생했습니다.",
  };
}

function clearFileState() {
  selectedFiles.value = [];
  uploadPreview.value = null;
  const el = document.getElementById(fileInputId.value) as HTMLInputElement | null;
  if (el) el.value = "";
}

async function parseJsonFileToItems(
  f: File,
): Promise<{ items: Record<string, unknown>[]; error: string | null }> {
  const text = await f.text();
  const nameLower = f.name.toLowerCase();
  const tryJson =
    nameLower.endsWith(".json") ||
    text.trimStart().startsWith("[") ||
    text.trimStart().startsWith("{");
  if (!tryJson) {
    return { items: [], error: `${f.name}: JSON이 아닙니다.` };
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    return { items: [], error: `${f.name}: JSON 파싱에 실패했습니다.` };
  }
  const arr = Array.isArray(parsed) ? parsed : [parsed];
  const items: Record<string, unknown>[] = [];
  for (const el of arr) {
    if (el && typeof el === "object" && !Array.isArray(el)) {
      items.push(el as Record<string, unknown>);
    }
  }
  if (items.length === 0) {
    return {
      items: [],
      error: `${f.name}: 객체 문서가 없습니다. 최상위는 객체의 배열이어야 합니다.`,
    };
  }
  return { items, error: null };
}

async function onFileChange(ev: Event) {
  const input = ev.target as HTMLInputElement;
  const list = input.files ? Array.from(input.files) : [];
  const stepIdx = currentStepIndex.value;
  const multi = allowsMultiJsonFiles.value;

  const files =
    stepIdx === 0 || stepIdx === 1
      ? list.slice(0, 1)
      : multi
        ? list
        : list.slice(0, 1);

  selectedFiles.value = files;
  uploadPreview.value = null;
  uploadError.value = null;
  message.value = null;
  lastUploadSummary.value = null;
  lastImported.value = 0;

  if (files.length === 0) return;

  try {
    if (stepIdx === 0) {
      const f = files[0]!;
      const nameLower = f.name.toLowerCase();
      const text = await f.text();
      if (nameLower.endsWith(".json") || text.trimStart().startsWith("[")) {
        uploadError.value = {
          kind: "plain",
          message: "hanja_basis(1단계)는 CSV만 지원합니다.",
        };
        return;
      }
      const rows = parseCsv(text);
      if (rows.length === 0) {
        uploadError.value = {
          kind: "plain",
          message: "파일에 데이터 행이 없습니다.",
        };
        return;
      }
      uploadPreview.value = { kind: "csv", fileName: f.name, size: f.size, rows };
      return;
    }

    if (multi && files.length > 1) {
      const allItems: Record<string, unknown>[] = [];
      const parts: { fileName: string; size: number; count: number }[] = [];
      let totalSize = 0;
      for (const f of files) {
        const nameLower = f.name.toLowerCase();
        if (!nameLower.endsWith(".json")) {
          uploadError.value = {
            kind: "plain",
            message:
              "여러 파일을 올릴 때는 모두 .json 배열 파일이어야 합니다. CSV는 파일 하나만 선택하세요.",
          };
          return;
        }
        const { items, error } = await parseJsonFileToItems(f);
        if (error) {
          uploadError.value = { kind: "plain", message: error };
          return;
        }
        allItems.push(...items);
        parts.push({ fileName: f.name, size: f.size, count: items.length });
        totalSize += f.size;
      }
      const label =
        files.length === 1
          ? files[0]!.name
          : `${files.length}개 파일 (${files.map((x) => x.name).join(", ")})`;
      uploadPreview.value = {
        kind: "json",
        fileName: label,
        size: totalSize,
        items: allItems,
        sourceParts: parts,
      };
      return;
    }

    const f = files[0]!;
    const nameLower = f.name.toLowerCase();
    const text = await f.text();

    const tryJson =
      nameLower.endsWith(".json") ||
      text.trimStart().startsWith("[") ||
      text.trimStart().startsWith("{");

    if (tryJson) {
      const { items, error } = await parseJsonFileToItems(f);
      if (error) {
        uploadError.value = { kind: "plain", message: error };
        return;
      }
      uploadPreview.value = {
        kind: "json",
        fileName: f.name,
        size: f.size,
        items,
      };
      return;
    }

    const rows = parseCsv(text);
    if (rows.length === 0) {
      uploadError.value = {
        kind: "plain",
        message: "파일에 데이터 행이 없습니다.",
      };
      return;
    }
    uploadPreview.value = { kind: "csv", fileName: f.name, size: f.size, rows };
  } catch (e) {
    uploadError.value = {
      kind: "plain",
      message:
        e instanceof Error ? e.message : "파일을 읽는 데 실패했습니다.",
    };
  }
}

function collectDuplicateDocIds(ids: string[]): string[] {
  const count = new Map<string, number>();
  for (const id of ids) {
    count.set(id, (count.get(id) ?? 0) + 1);
  }
  return [...count.entries()]
    .filter(([, c]) => c > 1)
    .map(([id]) => id)
    .sort();
}

/** Firestore Commit 요청 상한(~11MiB) 대비: 획·단어 문서는 건당 크기가 커서 배치를 작게 */
function batchChunkForCollection(coll: string): number {
  if (coll === "hanja_stroke") return 20;
  if (coll === "hanja_word") return 80;
  return 400;
}

async function onUpload() {
  message.value = null;
  uploadError.value = null;
  const step = currentStep.value;
  if (!step || selectedFiles.value.length === 0 || !canUpload.value || !uploadPreview.value)
    return;

  busy.value = true;
  lastImported.value = 0;
  beginUploadProgress();
  try {
    await auth.syncIdTokenForFirestore();
    if (!auth.isAdmin) {
      uploadError.value = {
        kind: "plain",
        message:
          "admin 클레임이 토큰에 없습니다. Firebase에서 클레임을 부여한 뒤 재로그인하거나 설정 → 토큰 새로고침을 누르세요.",
      };
      return;
    }

    const db = getFirestoreDb();
    const chunk = batchChunkForCollection(step.collection);
    let total = 0;
    const collName = step.collection;

    const current = getFirebaseAuth().currentUser;
    if (current) await current.getIdToken(true);

    const stepIdx = currentStepIndex.value;
    if (stepIdx > 0) {
      const prevColl = UPLOAD_STEPS[stepIdx - 1]!.collection;
      const prevOk = await collectionHasAnyDoc(prevColl);
      if (!prevOk) {
        uploadError.value = {
          kind: "plain",
          message: `이 단계를 반영하려면 먼저 Firestore에 ${prevColl} 문서가 있어야 합니다. (현재 0건으로 조회됨)`,
        };
        return;
      }
    }

    const preview = uploadPreview.value;

    if (preview.kind === "csv") {
      const rows = preview.rows;
      if (rows.length < 2) {
        uploadError.value = {
          kind: "plain",
          message: "헤더와 최소 한 행이 필요합니다.",
        };
        return;
      }
      const headers = rows[0].map((h) => h.replace(/^\ufeff/, "").trim() || "col");
      const dataRows = rows.length - 1;

      uploadProgressPhase.value = "validate";
      uploadProgressTotal.value = dataRows;
      uploadProgressDone.value = 0;
      const csvPrimaries: string[] = [];
      for (let r = 1; r < rows.length; r++) {
        const cells = rows[r] ?? [];
        const primary =
          collName === "hanja_basis"
            ? normalizeHanjaBasisDocId(headers, cells, r)
            : safeDocId(cells[0] ?? "", `row_${r}_validate`);
        csvPrimaries.push(primary);
        uploadProgressDone.value = r;
        tickUploadElapsed();
      }

      const csvDupIds = collectDuplicateDocIds(csvPrimaries);
      if (csvDupIds.length > 0) {
        uploadError.value = {
          kind: "plain",
          message: `파일 안에 동일한 문서 ID가 여러 행에 있습니다. (${csvDupIds.slice(0, 8).join(", ")}${csvDupIds.length > 8 ? ` 외 ${csvDupIds.length - 8}종` : ""})`,
        };
        return;
      }

      uploadProgressPhase.value = "upload";
      uploadProgressTotal.value = dataRows;
      uploadBatchTotal.value = Math.max(1, Math.ceil(dataRows / chunk));
      let batchIdx = 0;

      for (let start = 1; start < rows.length; start += chunk) {
        batchIdx += 1;
        uploadBatchCurrent.value = batchIdx;
        const batch = writeBatch(db);
        const slice = rows.slice(start, start + chunk);
        slice.forEach((cells, j) => {
          const rowIndex = start + j;
          const primary =
            collName === "hanja_basis"
              ? normalizeHanjaBasisDocId(headers, cells, rowIndex)
              : safeDocId(
                  cells[0] ?? "",
                  `row_${rowIndex}_${Date.now()}`,
                );
          const data: Record<string, unknown> = {
            _row: rowIndex,
            _importedAt: serverTimestamp(),
          };
          headers.forEach((h, k) => {
            data[h] = cells[k] ?? "";
          });
          if (collName === "hanja_basis") {
            data.id = primary;
          }
          const ref = doc(collection(db, collName), primary);
          batch.set(ref, data);
        });
        await batch.commit();
        total += slice.length;
        uploadProgressDone.value = total;
        tickUploadElapsed();
      }

      tickUploadElapsed();
      const durationMs = Math.round(performance.now() - uploadStartedAt.value);
      lastImported.value = total;
      lastUploadSummary.value = {
        collection: collName,
        fileName: preview.fileName,
        format: "csv",
        headers: [...headers],
        dataRowCount: rows.length - 1,
        columnCount: headers.length,
        importedRows: total,
        durationMs,
      };
      message.value =
        collName === "hanja_basis"
          ? `${total}행을 ${collName}에 반영했습니다. (${formatDuration(durationMs)} · 문서 ID: 한자 기준 H+16진, 필드 id 동기화)`
          : `${total}행을 ${collName}에 반영했습니다. (${formatDuration(durationMs)} · 문서 ID: 첫 번째 열)`;
    } else {
      const items = preview.items;
      const headers = normalizedHeaders.value;
      const n = items.length;
      const validateStride = Math.max(1, Math.floor(n / 80));

      uploadProgressPhase.value = "validate";
      uploadProgressTotal.value = n;
      uploadProgressDone.value = 0;
      uploadBatchTotal.value = 0;
      uploadBatchCurrent.value = 0;

      const jsonPrimaries: string[] = [];
      for (let i = 0; i < n; i++) {
        const id = docIdFromJsonItem(collName, items[i]);
        if (!id) {
          uploadError.value = {
            kind: "plain",
            message: `JSON ${i + 1}번째 객체에 문서 ID가 없습니다. (${collName === "hanja_extend" ? "id" : collName === "hanja_stroke" ? "stroke_data_id" : "word_id"} 필수)`,
          };
          return;
        }
        const rowIndex = i + 1;
        jsonPrimaries.push(
          safeDocId(id, `row_${rowIndex}_validate_${i}`),
        );
        if (i % validateStride === 0 || i === n - 1) {
          uploadProgressDone.value = i + 1;
          tickUploadElapsed();
        }
      }

      const jsonDupIds = collectDuplicateDocIds(jsonPrimaries);
      if (jsonDupIds.length > 0) {
        uploadError.value = {
          kind: "plain",
          message: `JSON에 동일한 문서 ID가 여러 객체에 있습니다. (${jsonDupIds.slice(0, 8).join(", ")}${jsonDupIds.length > 8 ? ` 외 ${jsonDupIds.length - 8}종` : ""})`,
        };
        return;
      }

      uploadProgressPhase.value = "upload";
      uploadProgressDone.value = 0;
      uploadProgressTotal.value = n;
      uploadBatchTotal.value = Math.max(1, Math.ceil(n / chunk));
      let jsonBatchIdx = 0;

      for (let start = 0; start < items.length; start += chunk) {
        jsonBatchIdx += 1;
        uploadBatchCurrent.value = jsonBatchIdx;
        const batch = writeBatch(db);
        const slice = items.slice(start, start + chunk);
        slice.forEach((raw, j) => {
          const rowIndex = start + j + 1;
          const idRaw = docIdFromJsonItem(collName, raw);
          const primary = safeDocId(idRaw, `row_${rowIndex}_${Date.now()}_${j}`);
          const base = payloadForFirestore(collName, raw);
          const data: Record<string, unknown> = {
            ...base,
            _row: rowIndex,
            _importedAt: serverTimestamp(),
          };
          const ref = doc(collection(db, collName), primary);
          batch.set(ref, data);
        });
        await batch.commit();
        total += slice.length;
        uploadProgressDone.value = total;
        tickUploadElapsed();
      }

      tickUploadElapsed();
      const jsonDurationMs = Math.round(performance.now() - uploadStartedAt.value);
      lastImported.value = total;
      lastUploadSummary.value = {
        collection: collName,
        fileName: preview.fileName,
        format: "json",
        headers: [...headers],
        dataRowCount: items.length,
        columnCount: headers.length,
        importedRows: total,
        durationMs: jsonDurationMs,
      };
      const idHint =
        collName === "hanja_extend"
          ? "id"
          : collName === "hanja_stroke"
            ? "stroke_data_id"
            : "word_id";
      message.value = `${total}건을 ${collName}에 반영했습니다. (${formatDuration(jsonDurationMs)} · 문서 ID: ${idHint})`;
    }

    sessionCompleted.value = [
      ...sessionCompleted.value,
      { collection: collName, fileName: preview.fileName, importedRows: total },
    ];

    clearFileState();
  } catch (e) {
    uploadError.value = parseFirestoreUploadError(e);
  } finally {
    busy.value = false;
    resetUploadProgress();
  }
}

/** 녹색 배너: 완료 체크(✓)만 초기화, 현재 단계·파일은 유지 */
function clearSessionCompletedLog() {
  sessionCompleted.value = [];
}

const BASIS_UPLOAD_HELP_TEXT =
  "단계 칩을 눌러 원하는 컬렉션부터 올릴 수 있습니다. 반영 시 Firestore에 선행 컬렉션 문서가 1건 이상 있는지만 검사합니다(extend→basis, stroke→extend, word→stroke). hanja_basis는 CSV. hanja_extend는 JSON·CSV. hanja_stroke·hanja_word는 JSON 다중 파일 가능. 동일 문서 ID가 있으면 업로드 내용으로 문서 전체를 교체합니다(병합 아님·페이로드에 없는 필드는 제거). 한 파일 안에서 같은 문서 ID가 여러 행·객체에 있으면 업로드하지 않습니다.";

const basisUploadHelpTriggerRef = ref<HTMLButtonElement | null>(null);
const basisUploadHelpTooltipOpen = ref(false);
const basisUploadHelpTooltipStyle = ref<Record<string, string>>({});

let basisUploadHelpRemoveScrollListeners: (() => void) | null = null;

function positionBasisUploadHelpTooltip() {
  const el = basisUploadHelpTriggerRef.value;
  if (!el) return;
  const r = el.getBoundingClientRect();
  const margin = 10;
  const maxW = Math.min(400, window.innerWidth - margin * 2);
  let left = r.left;
  if (left + maxW > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - margin - maxW);
  }
  if (left < margin) left = margin;
  basisUploadHelpTooltipStyle.value = {
    top: `${Math.round(r.bottom + margin)}px`,
    left: `${Math.round(left)}px`,
    maxWidth: `${maxW}px`,
  };
}

function openBasisUploadHelpTooltip() {
  positionBasisUploadHelpTooltip();
  basisUploadHelpTooltipOpen.value = true;
  void nextTick(() => positionBasisUploadHelpTooltip());
}

function closeBasisUploadHelpTooltip() {
  basisUploadHelpTooltipOpen.value = false;
}

watch(basisUploadHelpTooltipOpen, (open) => {
  basisUploadHelpRemoveScrollListeners?.();
  basisUploadHelpRemoveScrollListeners = null;
  if (!open) return;
  const handler = () => positionBasisUploadHelpTooltip();
  window.addEventListener("scroll", handler, true);
  window.addEventListener("resize", handler);
  basisUploadHelpRemoveScrollListeners = () => {
    window.removeEventListener("scroll", handler, true);
    window.removeEventListener("resize", handler);
  };
});

onUnmounted(() => {
  basisUploadHelpRemoveScrollListeners?.();
  stopUploadElapsedTicker();
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
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            載
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <div class="min-w-0 flex-1 leading-tight">
              <p
                class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
              >
                Admin · Firestore import
              </p>
              <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
                한자 마스터 등록
              </h1>
            </div>
            <div class="relative shrink-0 pt-0.5">
              <button
                ref="basisUploadHelpTriggerRef"
                type="button"
                class="flex h-6 w-6 items-center justify-center rounded-full border border-primary/35 bg-primary/12 text-xs font-bold leading-none text-primary shadow-sm outline-none ring-primary/20 transition hover:bg-primary/18 focus-visible:ring-2"
                :aria-label="BASIS_UPLOAD_HELP_TEXT"
                :aria-describedby="
                  basisUploadHelpTooltipOpen
                    ? 'basis-upload-help-tooltip-text'
                    : undefined
                "
                @mouseenter="openBasisUploadHelpTooltip"
                @mouseleave="closeBasisUploadHelpTooltip"
                @focus="openBasisUploadHelpTooltip"
                @blur="closeBasisUploadHelpTooltip"
              >
                !
              </button>
            </div>
          </div>
        </div>
        <RouterLink
          :to="{ name: 'basis' }"
          class="btn-secondary inline-flex shrink-0 items-center justify-center px-3 py-1.5 text-xs sm:text-sm"
        >
          기준 데이터 목록
        </RouterLink>
      </div>
    </section>

    <!-- 단계 -->
    <div
      class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4"
    >
      <p
        class="mb-2 text-balance text-[10px] font-semibold uppercase leading-snug tracking-wide text-onSurface-variant"
      >
        업로드 대상 선택 · 권장 순서 basis → extend → stroke → word
      </p>
      <!-- 모바일·태블릿: 단계 카드 세로 스택. lg+ 에서만 가로 한 줄(좁으면 가로 스크롤) -->
      <ol
        class="flex flex-col gap-2 sm:gap-2.5 lg:flex-row lg:flex-nowrap lg:items-stretch lg:overflow-x-auto lg:pb-0.5 [-ms-overflow-style:none] [scrollbar-width:thin] [&::-webkit-scrollbar]:h-1 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-outline-variant/60"
      >
        <li
          v-for="(s, i) in UPLOAD_STEPS"
          :key="s.collection"
          class="w-full min-w-0 lg:min-w-[10.5rem] lg:w-auto lg:shrink-0 lg:flex-1"
        >
          <button
            type="button"
            class="flex h-full min-h-[3.25rem] w-full flex-col gap-1 rounded-xl border px-3 py-2.5 text-left text-sm shadow-sm outline-none ring-primary/25 transition hover:bg-surface-low/90 focus-visible:ring-2 lg:min-h-0 lg:py-2"
            :class="{
              'border-primary/50 bg-primary/[0.08] text-onSurface ring-1 ring-primary/20':
                i === currentStepIndex,
              'border-green-600/35 bg-green-50/80 text-green-950 ring-1 ring-green-600/15':
                stepSessionDone(i) && i !== currentStepIndex,
              'border-outline-variant/80 bg-surface-low text-onSurface-variant':
                !stepSessionDone(i) && i !== currentStepIndex,
            }"
            @click="selectStep(i as StepIndex)"
          >
            <span class="font-display font-semibold leading-tight">{{ s.title }}</span>
            <span class="text-[11px] leading-snug text-onSurface-variant sm:text-xs">
              {{ s.description }}
            </span>
            <span
              v-if="stepSessionDone(i)"
              class="mt-0.5 self-end text-base font-semibold text-green-700"
              aria-hidden="true"
            >✓</span>
          </button>
        </li>
      </ol>
    </div>

    <div
      class="space-y-5 rounded-2xl border border-outline-variant/70 bg-surface-lowest p-5 shadow-float sm:p-6"
    >
      <div
        v-if="!auth.isAdmin"
        class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950 shadow-sm"
      >
        <span class="font-medium">admin</span> 클레임이 없으면 Firestore 쓰기가 거절됩니다.
      </div>

      <div
        v-if="sessionCoversAllSteps"
        class="space-y-3 rounded-xl border border-green-200/90 bg-gradient-to-br from-green-50/95 to-green-50/60 p-4 text-green-950 shadow-sm"
      >
        <p class="font-display text-sm font-semibold">
          이번 세션에서 네 컬렉션 모두 업로드 기록이 있습니다.
        </p>
        <ul class="list-disc space-y-1 pl-5 text-xs text-green-900/95 sm:text-sm">
          <li v-for="(c, i) in sessionCompleted" :key="i">
            <strong>{{ c.collection }}</strong> — {{ c.fileName }} ({{ c.importedRows }}건)
          </li>
        </ul>
        <button
          type="button"
          class="btn-secondary text-xs sm:text-sm"
          @click="clearSessionCompletedLog"
        >
          이번 세션 완료 표시만 지우기
        </button>
      </div>

      <!-- 현재 단계 업로드 -->
      <template v-if="currentStep">
        <div
          class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.06] via-surface-lowest to-surface-low px-4 py-3 ring-1 ring-black/[0.02]"
        >
          <div
            class="pointer-events-none absolute -right-6 -top-8 h-24 w-24 rounded-full bg-primary/[0.08] blur-2xl"
          />
          <div class="relative">
            <p class="text-[10px] font-semibold uppercase tracking-wide text-primary/90">
              현재 단계
            </p>
            <p class="font-display text-sm font-semibold text-onSurface">
              {{ currentStep.title }}
            </p>
            <p class="mt-1 text-xs text-onSurface-variant">
              컬렉션
              <code
                class="rounded-md bg-white/70 px-1.5 py-0.5 font-mono text-[11px] text-primary shadow-sm"
              >{{ currentStep.collection }}</code>
              <span v-if="allowsJson"> · JSON 배열 또는 CSV</span>
            </p>
            <p
              v-if="currentStepIndex > 0"
              class="mt-2 rounded-lg border border-amber-200/80 bg-amber-50/80 px-2.5 py-1.5 text-[11px] leading-snug text-amber-950"
            >
              반영 시 Firestore에
              <code class="rounded bg-white/80 px-1 font-mono text-[10px] text-primary">{{
                UPLOAD_STEPS[currentStepIndex - 1]!.collection
              }}</code>
              문서가 1건 이상 있는지 먼저 확인합니다. 없으면 업로드가 거절됩니다.
            </p>
          </div>
        </div>

        <div>
          <label
            class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
            :for="fileInputId"
          >
            <template v-if="allowsMultiJsonFiles">JSON 여러 개 또는 CSV 1개</template>
            <template v-else-if="allowsJson">파일 (JSON 또는 CSV)</template>
            <template v-else>CSV 파일</template>
            <span class="font-normal normal-case tracking-normal text-onSurface-variant">
              — {{ currentStep.collection }}
            </span>
          </label>
          <input
            :id="fileInputId"
            type="file"
            :multiple="allowsMultiJsonFiles"
            :accept="allowsJson ? '.csv,.json,text/csv,application/json' : '.csv,text/csv'"
            class="block w-full text-sm text-onSurface-variant file:mr-4 file:rounded-lg file:border-0 file:bg-surface-low file:px-4 file:py-2 file:text-sm file:font-medium file:text-onSurface file:shadow-sm hover:file:bg-surface-bright"
            @change="onFileChange"
          />
          <p
            v-if="allowsMultiJsonFiles"
            class="mt-1.5 text-xs text-onSurface-variant"
          >
            획·단어 JSON은 용량이 크면 ETL 분할 파일(<code class="rounded bg-surface-low px-1 font-mono text-[11px]">*.part000.json</code> 등)을
            Shift 클릭으로 여러 개 선택해 한 번에 반영할 수 있습니다.
          </p>
        </div>

        <div
          v-if="uploadPreview"
          class="space-y-4 rounded-2xl border border-outline-variant/70 bg-surface-low/80 p-4 shadow-inner sm:p-5"
        >
          <h2 class="font-display text-sm font-semibold text-onSurface">
            파일 정보
          </h2>
          <p
            v-if="uploadPreview.kind === 'json'"
            class="text-xs font-medium text-primary"
          >
            JSON 형식 · 객체 배열 (문서 수 {{ previewDocCount }}건)
            <span
              v-if="uploadPreview.sourceParts && uploadPreview.sourceParts.length > 1"
              class="block pt-1 font-normal text-onSurface-variant"
            >
              {{ uploadPreview.sourceParts.length }}개 파일 합산
            </span>
          </p>
          <ul
            v-if="uploadPreview.kind === 'json' && uploadPreview.sourceParts && uploadPreview.sourceParts.length > 1"
            class="mt-2 space-y-1 rounded-lg border border-outline-variant/60 bg-surface-lowest/80 px-3 py-2 text-xs text-onSurface-variant"
          >
            <li v-for="(sp, si) in uploadPreview.sourceParts" :key="si">
              <span class="font-mono text-[11px] text-onSurface">{{ sp.fileName }}</span>
              · {{ sp.count }}건 · {{ formatBytes(sp.size) }}
            </li>
          </ul>
          <dl class="grid gap-3 text-sm sm:grid-cols-2">
            <div>
              <dt class="text-onSurface-variant">파일 이름</dt>
              <dd class="mt-0.5 font-medium text-onSurface">
                {{ uploadPreview.fileName }}
              </dd>
            </div>
            <div>
              <dt class="text-onSurface-variant">크기</dt>
              <dd class="mt-0.5 font-medium text-onSurface">
                {{ formatBytes(uploadPreview.size) }}
              </dd>
            </div>
            <div>
              <dt class="text-onSurface-variant">필드 수</dt>
              <dd class="mt-0.5 font-medium text-onSurface">
                {{ normalizedHeaders.length }}
              </dd>
            </div>
            <div>
              <dt class="text-onSurface-variant">
                {{ uploadPreview.kind === 'json' ? '문서 수' : '데이터 행 수' }}
              </dt>
              <dd class="mt-0.5 font-medium text-onSurface">
                {{ previewDocCount }}
                <span
                  v-if="uploadPreview.kind === 'csv'"
                  class="font-normal text-onSurface-variant"
                >(헤더 제외)</span>
              </dd>
            </div>
          </dl>

          <div>
            <p class="text-xs font-medium text-onSurface-variant">
              {{ uploadPreview.kind === 'json' ? '필드 키' : '헤더 (열 이름)' }}
            </p>
            <ul class="mt-2 flex flex-wrap gap-2">
              <li
                v-for="(h, i) in normalizedHeaders"
                :key="i"
                class="rounded-full border border-outline-variant/50 bg-surface-lowest px-3 py-1 text-xs text-onSurface shadow-sm"
                :class="{
                  'border-primary/35 ring-1 ring-primary/25':
                    uploadPreview.kind === 'json'
                      ? (h === 'id' || h === 'stroke_data_id' || h === 'word_id')
                      : i === 0,
                }"
              >
                <span
                  v-if="
                    uploadPreview.kind === 'json' &&
                      (h === 'id' || h === 'stroke_data_id' || h === 'word_id')
                  "
                  class="text-primary"
                >문서 ID ← </span>
                <span
                  v-else-if="uploadPreview.kind === 'csv' && i === 0"
                  class="text-primary"
                >문서 ID ← </span>
                {{ h }}
              </li>
            </ul>
          </div>

          <div v-if="uploadPreview.kind === 'csv' ? uploadPreview.rows.length >= 2 : uploadPreview.items.length >= 1">
            <p class="text-xs font-medium text-onSurface-variant">
              미리보기 (상위 {{ previewDataRows.length }}건, 한자 열은 크게)
            </p>
            <div
              class="mt-2 overflow-hidden rounded-xl border border-outline-variant/80 bg-surface-lowest shadow-[0_8px_28px_rgba(25,28,30,0.05)] ring-1 ring-black/[0.02]"
            >
              <div class="overflow-x-auto">
                <table class="w-full min-w-[480px] border-collapse text-left text-sm">
                  <thead>
                    <tr
                      class="border-b border-outline-variant/80 bg-surface-low/95 text-xs font-semibold uppercase tracking-wide text-onSurface-variant backdrop-blur-sm"
                    >
                      <th
                        v-for="(h, ci) in normalizedHeaders"
                        :key="ci"
                        class="max-w-[10rem] truncate px-3 py-2.5"
                        :title="h"
                      >
                        {{ h }}
                      </th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-outline-variant/60">
                    <tr
                      v-for="(cells, ri) in previewDataRows"
                      :key="ri"
                      class="bg-surface-lowest transition-colors hover:bg-primary/[0.03]"
                    >
                      <td
                        v-for="(cell, ci) in cells"
                        :key="ci"
                        class="max-w-[12rem] truncate px-3 py-2.5 text-onSurface"
                        :class="
                          ci === 0 ||
                          (uploadPreview.kind === 'json' &&
                            (normalizedHeaders[ci] === 'char' ||
                              normalizedHeaders[ci] === 'hanja'))
                            ? 'font-display text-lg leading-tight'
                            : ''
                        "
                        :title="cell"
                      >
                        {{ cell || "—" }}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <p
            v-else-if="uploadPreview.kind === 'csv'"
            class="rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-sm text-amber-950"
          >
            헤더만 있고 데이터 행이 없습니다.
          </p>
        </div>

        <button
          type="button"
          class="btn-primary shadow-md shadow-primary/15"
          :disabled="!canUpload"
          @click="onUpload"
        >
          {{ busy ? "업로드 중…" : `${currentStep.collection}에 반영` }}
        </button>

        <div
          v-if="busy && uploadProgressTotal > 0"
          class="space-y-2 rounded-xl border border-primary/25 bg-primary/[0.06] px-4 py-3 shadow-inner"
          role="status"
          aria-live="polite"
        >
          <div
            class="flex flex-wrap items-baseline justify-between gap-2 text-xs text-onSurface"
          >
            <span class="font-semibold text-primary">
              {{ uploadProgressPhaseLabel }}
            </span>
            <span class="tabular-nums text-onSurface-variant">
              경과 {{ formatDuration(uploadElapsedMs) }}{{ uploadThroughputLabel }}
            </span>
          </div>
          <div
            class="h-2.5 overflow-hidden rounded-full bg-surface-low ring-1 ring-outline-variant/40"
          >
            <div
              class="h-full rounded-full bg-primary transition-[width] duration-200 ease-out"
              :style="{ width: `${uploadProgressPercent}%` }"
            />
          </div>
          <p class="text-xs text-onSurface-variant">
            <span class="font-medium tabular-nums text-onSurface">
              {{ uploadProgressDone.toLocaleString("ko-KR") }}
            </span>
            /
            <span class="tabular-nums text-onSurface">
              {{ uploadProgressTotal.toLocaleString("ko-KR") }}
            </span>
            건 처리
            <span
              v-if="uploadProgressPhase === 'upload' && uploadBatchTotal > 1"
              class="text-onSurface-variant"
            >
              · 배치 {{ uploadBatchCurrent.toLocaleString("ko-KR") }} /
              {{ uploadBatchTotal.toLocaleString("ko-KR") }}
            </span>
          </p>
        </div>

        <p
          v-if="message"
          class="rounded-lg border border-primary/20 bg-primary/[0.06] px-3 py-2 text-sm font-medium text-primary"
        >
          {{ message }}
        </p>
        <div
          v-if="uploadError?.kind === 'permission'"
          class="rounded-xl border border-red-200/90 bg-red-50/90 p-4 text-sm text-red-950 shadow-sm"
          role="alert"
        >
          <p class="font-display font-semibold text-red-950">Firestore가 쓰기를 거절했습니다</p>
          <p class="mt-1 text-red-900/90">
            아래 순서를 확인하세요.
          </p>
          <ol class="mt-3 list-decimal space-y-2 pl-5 marker:font-medium">
            <li v-for="(step, i) in uploadError.steps" :key="i" class="pl-1">
              {{ step }}
            </li>
          </ol>
        </div>
        <p
          v-else-if="uploadError?.kind === 'plain'"
          class="rounded-xl border border-red-200/80 bg-red-50/80 px-4 py-3 text-sm text-red-900"
        >
          {{ uploadError.message }}
        </p>
        <p
          v-if="lastImported && !uploadError"
          class="text-xs text-onSurface-variant"
        >
          다음 단계 파일을 선택하거나,
          <RouterLink
            :to="{ name: 'basis' }"
            class="font-medium text-primary underline decoration-primary/30 underline-offset-2 hover:decoration-primary"
          >기준 데이터</RouterLink>
          화면에서 새로고침해 확인하세요.
        </p>
      </template>
    </div>

    <div
      v-if="lastUploadSummary"
      class="space-y-4 rounded-2xl border border-outline-variant/70 bg-surface-lowest p-5 shadow-float sm:p-6"
    >
      <h2 class="font-display text-sm font-semibold text-onSurface">
        마지막 업로드 요약
      </h2>
      <dl class="grid gap-3 text-sm sm:grid-cols-2">
        <div>
          <dt class="text-xs text-onSurface-variant">형식</dt>
          <dd class="mt-0.5 font-medium text-onSurface">
            {{ lastUploadSummary.format.toUpperCase() }}
          </dd>
        </div>
        <div>
          <dt class="text-xs text-onSurface-variant">컬렉션</dt>
          <dd class="mt-0.5 font-mono text-sm font-medium text-primary">
            {{ lastUploadSummary.collection }}
          </dd>
        </div>
        <div>
          <dt class="text-xs text-onSurface-variant">파일</dt>
          <dd class="mt-0.5 font-medium text-onSurface">
            {{ lastUploadSummary.fileName }}
          </dd>
        </div>
        <div>
          <dt class="text-xs text-onSurface-variant">반영</dt>
          <dd class="mt-0.5 font-medium tabular-nums text-onSurface">
            {{ lastUploadSummary.importedRows }} / {{ lastUploadSummary.dataRowCount }}
          </dd>
        </div>
        <div>
          <dt class="text-xs text-onSurface-variant">처리 시간</dt>
          <dd class="mt-0.5 font-medium tabular-nums text-onSurface">
            {{ formatDuration(lastUploadSummary.durationMs) }}
          </dd>
        </div>
        <div class="sm:col-span-2">
          <dt class="text-xs text-onSurface-variant">
            필드 ({{ lastUploadSummary.columnCount }}개)
          </dt>
          <dd class="mt-2 flex flex-wrap gap-2">
            <span
              v-for="(h, i) in lastUploadSummary.headers"
              :key="i"
              class="rounded-full border border-outline-variant/50 bg-surface-low px-2.5 py-0.5 text-xs text-onSurface shadow-sm"
            >
              {{ h }}
            </span>
          </dd>
        </div>
      </dl>
    </div>

    <Teleport to="body">
      <div
        v-if="basisUploadHelpTooltipOpen"
        id="basis-upload-help-tooltip-text"
        class="fixed z-[10050] rounded-xl border border-outline-variant/80 bg-surface-lowest p-3.5 text-left text-xs leading-relaxed text-onSurface shadow-[0_16px_48px_rgba(25,28,30,0.18)] ring-1 ring-black/[0.06]"
        :style="basisUploadHelpTooltipStyle"
        role="tooltip"
      >
        {{ BASIS_UPLOAD_HELP_TEXT }}
      </div>
    </Teleport>
  </div>
</template>
