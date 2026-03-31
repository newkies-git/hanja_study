<script setup lang="ts">
import { ref, computed } from "vue";
import { RouterLink } from "vue-router";
import {
  collection,
  doc,
  serverTimestamp,
  writeBatch,
} from "firebase/firestore";
import { getFirebaseAuth, getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

/** Firestore 컬렉션 업로드 순서 (반드시 이 순서) */
const UPLOAD_STEPS = [
  {
    collection: "hanja_basis",
    title: "1. hanja_basis",
    description: "기준 한자 마스터",
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
      "획순 데이터 (JSON 권장, stroke_entities.json 그대로). svg_paths 배열이 있어야 관리 화면에서 글자 실루엣이 정상 표시됩니다.",
  },
  {
    collection: "hanja_word",
    title: "4. hanja_word",
    description: "단어·용례 (JSON 권장)",
  },
] as const;

type StepIndex = 0 | 1 | 2 | 3 | 4;

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
};

const auth = useAuthStore();
const file = ref<File | null>(null);
const busy = ref(false);
const message = ref<string | null>(null);
const uploadError = ref<
  | { kind: "plain"; message: string }
  | { kind: "permission"; steps: string[] }
  | null
>(null);
const lastImported = ref(0);

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
} | null>(null);

const sessionCompleted = ref<
  { collection: string; fileName: string; importedRows: number }[]
>([]);

const currentStep = computed(() => {
  const i = currentStepIndex.value;
  if (i < 0 || i >= UPLOAD_STEPS.length) return null;
  return UPLOAD_STEPS[i as 0 | 1 | 2 | 3];
});

/** 2~4단계: ETL 산출 JSON이 표준. CSV도 호환 */
const allowsJson = computed(() => currentStepIndex.value >= 1);

const fileInputId = computed(
  () => `data-file-input-${currentStepIndex.value}`,
);

const canUpload = computed(() => {
  if (
    !isFirebaseConfigured() ||
    !auth.isAuthenticated ||
    currentStepIndex.value >= UPLOAD_STEPS.length ||
    !file.value ||
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
  file.value = null;
  uploadPreview.value = null;
  const el = document.getElementById(fileInputId.value) as HTMLInputElement | null;
  if (el) el.value = "";
}

async function onFileChange(ev: Event) {
  const input = ev.target as HTMLInputElement;
  const f = input.files?.[0] ?? null;
  file.value = f;
  uploadPreview.value = null;
  uploadError.value = null;
  message.value = null;
  lastUploadSummary.value = null;
  lastImported.value = 0;

  if (!f) return;

  const stepIdx = currentStepIndex.value;
  const nameLower = f.name.toLowerCase();

  try {
    const text = await f.text();

    if (stepIdx === 0) {
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

    const tryJson =
      nameLower.endsWith(".json") ||
      text.trimStart().startsWith("[") ||
      text.trimStart().startsWith("{");

    if (tryJson) {
      let parsed: unknown;
      try {
        parsed = JSON.parse(text);
      } catch {
        parsed = null;
      }
      if (parsed === null) {
        uploadError.value = {
          kind: "plain",
          message: "JSON 파싱에 실패했습니다. 배열 형식인지 확인하세요.",
        };
        return;
      }
      const arr = Array.isArray(parsed) ? parsed : [parsed];
      const items: Record<string, unknown>[] = [];
      for (const el of arr) {
        if (el && typeof el === "object" && !Array.isArray(el)) {
          items.push(el as Record<string, unknown>);
        }
      }
      if (items.length === 0) {
        uploadError.value = {
          kind: "plain",
          message: "JSON에 객체 문서가 없습니다. 최상위는 객체의 배열이어야 합니다.",
        };
        return;
      }
      uploadPreview.value = { kind: "json", fileName: f.name, size: f.size, items };
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

async function onUpload() {
  message.value = null;
  uploadError.value = null;
  const step = currentStep.value;
  if (!step || !file.value || !canUpload.value || !uploadPreview.value) return;

  busy.value = true;
  lastImported.value = 0;
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
    const chunk = 400;
    let total = 0;
    const collName = step.collection;

    const current = getFirebaseAuth().currentUser;
    if (current) await current.getIdToken(true);

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

      for (let start = 1; start < rows.length; start += chunk) {
        const batch = writeBatch(db);
        const slice = rows.slice(start, start + chunk);
        slice.forEach((cells, j) => {
          const rowIndex = start + j;
          const data: Record<string, unknown> = {
            _row: rowIndex,
            _importedAt: serverTimestamp(),
          };
          headers.forEach((h, k) => {
            data[h] = cells[k] ?? "";
          });
          const primary = safeDocId(
            cells[0] ?? "",
            `row_${rowIndex}_${Date.now()}`,
          );
          const ref = doc(collection(db, collName), primary);
          batch.set(ref, data, { merge: true });
        });
        await batch.commit();
        total += slice.length;
      }

      lastImported.value = total;
      lastUploadSummary.value = {
        collection: collName,
        fileName: preview.fileName,
        format: "csv",
        headers: [...headers],
        dataRowCount: rows.length - 1,
        columnCount: headers.length,
        importedRows: total,
      };
      message.value = `${total}행을 ${collName}에 반영했습니다. (문서 ID: 첫 번째 열)`;
    } else {
      const items = preview.items;
      const headers = normalizedHeaders.value;

      for (let i = 0; i < items.length; i++) {
        const id = docIdFromJsonItem(collName, items[i]);
        if (!id) {
          uploadError.value = {
            kind: "plain",
            message: `JSON ${i + 1}번째 객체에 문서 ID가 없습니다. (${collName === "hanja_extend" ? "id" : collName === "hanja_stroke" ? "stroke_data_id" : "word_id"} 필수)`,
          };
          return;
        }
      }

      for (let start = 0; start < items.length; start += chunk) {
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
          batch.set(ref, data, { merge: true });
        });
        await batch.commit();
        total += slice.length;
      }

      lastImported.value = total;
      lastUploadSummary.value = {
        collection: collName,
        fileName: preview.fileName,
        format: "json",
        headers: [...headers],
        dataRowCount: items.length,
        columnCount: headers.length,
        importedRows: total,
      };
      const idHint =
        collName === "hanja_extend"
          ? "id"
          : collName === "hanja_stroke"
            ? "stroke_data_id"
            : "word_id";
      message.value = `${total}건을 ${collName}에 반영했습니다. (문서 ID: ${idHint})`;
    }

    sessionCompleted.value = [
      ...sessionCompleted.value,
      { collection: collName, fileName: preview.fileName, importedRows: total },
    ];

    clearFileState();
    const next = (currentStepIndex.value + 1) as StepIndex;
    currentStepIndex.value = next;
  } catch (e) {
    uploadError.value = parseFirestoreUploadError(e);
  } finally {
    busy.value = false;
  }
}

function restartWizard() {
  currentStepIndex.value = 0;
  sessionCompleted.value = [];
  clearFileState();
  message.value = null;
  uploadError.value = null;
  lastUploadSummary.value = null;
  lastImported.value = 0;
}
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl"
      />
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
          <div class="min-w-0 leading-tight">
            <p
              class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
            >
              Admin · Firestore import
            </p>
            <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
              한자 마스터 등록
            </h1>
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

    <div
      class="rounded-xl border border-primary/15 bg-gradient-to-r from-primary/[0.05] to-transparent px-4 py-3 text-xs leading-relaxed text-onSurface-variant shadow-sm sm:px-5"
    >
      <strong class="font-medium text-onSurface">hanja_basis</strong>는 CSV(첫 줄 헤더, 문서 ID=첫 열).
      <strong class="font-medium text-onSurface">hanja_extend · hanja_stroke · hanja_word</strong>는
      ETL과 동일한 <strong class="font-medium text-onSurface">JSON 배열</strong>이 표준이며 CSV도 호환됩니다.
      순서를 지키고, 동일 문서 ID는 <code class="rounded-md bg-white/80 px-1.5 py-0.5 font-mono text-[11px] text-primary shadow-sm">merge</code>됩니다.
    </div>

    <!-- 단계 -->
    <div
      class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4"
    >
      <p
        class="mb-2 text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
      >
        업로드 단계 (고정 순서)
      </p>
      <ol
        class="flex flex-nowrap items-stretch gap-2 overflow-x-auto pb-0.5 [-ms-overflow-style:none] [scrollbar-width:thin] sm:gap-2.5 [&::-webkit-scrollbar]:h-1 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-outline-variant/60"
      >
        <li
          v-for="(s, i) in UPLOAD_STEPS"
          :key="s.collection"
          class="flex min-w-[11rem] shrink-0 flex-col gap-1 rounded-xl border px-3 py-2 text-sm shadow-sm transition sm:min-w-0 sm:flex-1 sm:flex-row sm:items-center sm:gap-2"
          :class="{
            'border-primary/50 bg-primary/[0.08] text-onSurface ring-1 ring-primary/20':
              i === currentStepIndex,
            'border-outline-variant/80 bg-surface-low text-onSurface-variant':
              i > currentStepIndex,
            'border-green-600/35 bg-green-50/80 text-green-950 ring-1 ring-green-600/15':
              i < currentStepIndex,
          }"
        >
          <span class="font-display font-semibold leading-tight">{{ s.title }}</span>
          <span class="text-[11px] leading-snug text-onSurface-variant sm:text-xs">
            {{ s.description }}
          </span>
          <span
            v-if="i < currentStepIndex"
            class="ml-auto text-base font-semibold text-green-700 sm:ml-0"
            aria-hidden="true"
          >✓</span>
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

      <!-- 전체 완료 -->
      <div
        v-if="currentStepIndex >= UPLOAD_STEPS.length"
        class="space-y-4 rounded-2xl border border-green-200/90 bg-gradient-to-br from-green-50/95 to-green-50/60 p-5 text-green-950 shadow-sm"
      >
        <p class="font-display text-base font-semibold">
          네 단계 모두 반영되었습니다.
        </p>
        <p class="text-sm text-green-900/90">
          hanja_basis → hanja_extend → hanja_stroke → hanja_word 순서로 업로드가 완료되었습니다.
        </p>
        <ul class="list-disc space-y-1.5 pl-5 text-sm text-green-900/95">
          <li v-for="(c, i) in sessionCompleted" :key="i">
            <strong>{{ c.collection }}</strong> — {{ c.fileName }} ({{ c.importedRows }}건)
          </li>
        </ul>
        <button
          type="button"
          class="btn-primary shadow-md shadow-primary/15"
          @click="restartWizard"
        >
          처음부터 다시 등록
        </button>
      </div>

      <!-- 현재 단계 업로드 -->
      <template v-else-if="currentStep">
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
          </div>
        </div>

        <div>
          <label
            class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
            :for="fileInputId"
          >
            <template v-if="allowsJson">파일 (JSON 또는 CSV)</template>
            <template v-else>CSV 파일</template>
            <span class="font-normal normal-case tracking-normal text-onSurface-variant">
              — {{ currentStep.collection }}
            </span>
          </label>
          <input
            :id="fileInputId"
            type="file"
            :accept="allowsJson ? '.csv,.json,text/csv,application/json' : '.csv,text/csv'"
            class="block w-full text-sm text-onSurface-variant file:mr-4 file:rounded-lg file:border-0 file:bg-surface-low file:px-4 file:py-2 file:text-sm file:font-medium file:text-onSurface file:shadow-sm hover:file:bg-surface-bright"
            @change="onFileChange"
          />
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
          </p>
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
  </div>
</template>
