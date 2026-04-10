<script setup lang="ts">
import { computed, ref } from "vue";
import { serverTimestamp, writeBatch, doc, collection } from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";

const props = defineProps<{
  /** Firestore 컬렉션 이름 */
  collectionName: string;
  /**
   * 컬럼 드롭다운에 표시할 필드 이름 목록.
   * "(무시)" 옵션은 자동으로 추가됨.
   */
  knownFields: readonly string[];
  /** 행 데이터 → Firestore 문서 ID 결정 함수. null 반환 시 해당 행 건너뜀. */
  resolveDocId: (row: Record<string, string>) => string | null;
  /** 이미 로드된 문서 ID 목록 (중복 건너뜀 정책에 사용) */
  existingIds: string[];
  /** false 이면 저장 버튼 비활성화 */
  canMutate: boolean;
}>();

const emit = defineEmits<{
  /** writeBatch 완료 후 발생. 부모에서 loadAll(true) + version bump 처리. */
  saved: [];
}>();

const auth = useAuthStore();
const notifications = useNotificationsStore();

// ── 패널 표시 ──────────────────────────────────────────────────────────────

const isOpen = ref(false);
function toggle() {
  isOpen.value = !isOpen.value;
  if (!isOpen.value) resetState();
}

// ── 파싱 상태 ──────────────────────────────────────────────────────────────

const rawText = ref("");
const hasHeader = ref(true);
/** 파싱된 전체 행 (헤더 포함) */
const parsedMatrix = ref<string[][]>([]);
/** 컬럼별 필드 매핑. "(무시)"는 저장 시 제외. */
const colMap = ref<string[]>([]);

const DROP_IGNORE = "(무시)";
const fieldOptions = computed(() => [DROP_IGNORE, ...props.knownFields]);

// ── 붙여넣기 처리 ──────────────────────────────────────────────────────────

function onPaste(e: ClipboardEvent) {
  const text = e.clipboardData?.getData("text/plain") ?? "";
  rawText.value = text;
  parseText(text);
  e.preventDefault();
}

function parseText(text: string) {
  const lines = text
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .split("\n")
    .filter((l) => l.trim() !== "");
  if (!lines.length) {
    parsedMatrix.value = [];
    colMap.value = [];
    return;
  }
  const matrix = lines.map((l) => l.split("\t").map((c) => c.trim()));
  parsedMatrix.value = matrix;

  // 헤더 행으로 컬럼명 자동 감지
  if (hasHeader.value && matrix[0]) {
    colMap.value = matrix[0].map((h) => {
      const match = props.knownFields.find(
        (f) => f.toLowerCase() === h.toLowerCase(),
      );
      return match ?? DROP_IGNORE;
    });
  } else {
    // 헤더 없음: knownFields 순서대로 기본 매핑
    const cols = matrix[0]?.length ?? 0;
    colMap.value = Array.from({ length: cols }, (_, i) =>
      i < props.knownFields.length ? props.knownFields[i]! : DROP_IGNORE,
    );
  }
}

/** 실제 데이터 행 (헤더 제외) */
const dataRows = computed<string[][]>(() => {
  if (!parsedMatrix.value.length) return [];
  return hasHeader.value ? parsedMatrix.value.slice(1) : parsedMatrix.value;
});

/** 매핑된 행 객체 (ID 포함) */
type MappedRow = {
  docId: string | null;
  fields: Record<string, string>;
  isDuplicate: boolean;
};

const mappedRows = computed<MappedRow[]>(() =>
  dataRows.value.map((row) => {
    const fields: Record<string, string> = {};
    colMap.value.forEach((col, i) => {
      if (col !== DROP_IGNORE) fields[col] = row[i] ?? "";
    });
    const docId = props.resolveDocId(fields);
    const isDuplicate = docId !== null && props.existingIds.includes(docId);
    return { docId, fields, isDuplicate };
  }),
);

const previewRows = computed(() => mappedRows.value.slice(0, 8));

// ── 저장 옵션 ──────────────────────────────────────────────────────────────

type DupPolicy = "skip" | "overwrite";
const dupPolicy = ref<DupPolicy>("skip");

const rowsToSave = computed(() =>
  mappedRows.value.filter((r) => {
    if (!r.docId) return false;
    if (r.isDuplicate && dupPolicy.value === "skip") return false;
    return true;
  }),
);

const skippedCount = computed(
  () =>
    mappedRows.value.filter((r) => !r.docId).length +
    (dupPolicy.value === "skip"
      ? mappedRows.value.filter((r) => r.docId && r.isDuplicate).length
      : 0),
);

// ── 저장 ──────────────────────────────────────────────────────────────────

const isBusy = ref(false);
const saveError = ref<string | null>(null);

const CHUNK = 450; // Firestore writeBatch 최대 500 미만으로 여유 확보

async function save() {
  if (!rowsToSave.value.length) return;
  isBusy.value = true;
  saveError.value = null;
  try {
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const colRef = collection(db, props.collectionName);

    let total = 0;
    for (let start = 0; start < rowsToSave.value.length; start += CHUNK) {
      const chunk = rowsToSave.value.slice(start, start + CHUNK);
      const batch = writeBatch(db);
      for (const row of chunk) {
        if (!row.docId) continue;
        batch.set(doc(colRef, row.docId), {
          ...row.fields,
          _importedAt: serverTimestamp(),
        });
        total++;
      }
      await batch.commit();
    }

    notifications.success(
      `${props.collectionName} ${total}건 저장 완료`,
    );
    emit("saved");
    resetState();
    isOpen.value = false;
  } catch (e) {
    const msg = e instanceof Error ? e.message : "저장에 실패했습니다.";
    saveError.value = msg;
    notifications.error(msg);
  } finally {
    isBusy.value = false;
  }
}

function resetState() {
  rawText.value = "";
  parsedMatrix.value = [];
  colMap.value = [];
  saveError.value = null;
}

function onToggleHeader() {
  hasHeader.value = !hasHeader.value;
  if (parsedMatrix.value.length) parseText(rawText.value);
}
</script>

<template>
  <!-- 패널 토글 버튼 (외부에서 보이는 부분) -->
  <div>
    <button
      type="button"
      class="flex items-center gap-1.5 rounded-md border px-3 py-1.5 text-xs font-medium transition"
      :class="
        isOpen
          ? 'border-primary/25 bg-primary/[0.08] text-primary'
          : 'border-outline-variant/60 bg-surface-low text-onSurface-variant hover:border-outline-variant hover:text-onSurface'
      "
      :disabled="!canMutate"
      @click="toggle"
    >
      <svg class="h-3.5 w-3.5 shrink-0" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.75" aria-hidden="true">
        <rect x="2" y="2" width="5" height="5" rx="1" />
        <rect x="9" y="2" width="5" height="5" rx="1" />
        <rect x="2" y="9" width="5" height="5" rx="1" />
        <rect x="9" y="9" width="5" height="5" rx="1" />
      </svg>
      클립보드 붙여넣기
      <span
        class="ml-0.5 transition-transform duration-150"
        :class="isOpen ? 'rotate-180' : ''"
        aria-hidden="true"
      >▾</span>
    </button>

    <!-- 패널 본문 -->
    <Transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="-translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="-translate-y-2 opacity-0"
    >
      <div
        v-if="isOpen"
        class="mt-2 rounded-2xl border border-outline-variant/80 bg-surface-lowest p-4 shadow-[0_8px_32px_rgba(25,28,30,0.08)] ring-1 ring-black/[0.02] sm:p-5"
      >
        <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-onSurface-variant">
          Excel / 스프레드시트에서 복사 후 아래에 붙여넣기 (Ctrl+V)
        </p>

        <!-- Paste textarea -->
        <div
          class="relative mb-4 overflow-hidden rounded-xl border-2 border-dashed border-outline-variant/70 bg-surface-low/60 transition focus-within:border-primary/40 focus-within:bg-primary/[0.03]"
          :class="parsedMatrix.length ? 'border-solid border-primary/25 bg-primary/[0.04]' : ''"
        >
          <textarea
            :value="rawText"
            rows="4"
            class="w-full resize-none bg-transparent px-4 py-3 font-mono text-[11px] leading-relaxed text-onSurface placeholder:text-onSurface-variant/50 focus:outline-none"
            placeholder="Excel 셀을 선택 후 Ctrl+C → 이 곳에 Ctrl+V&#10;탭 구분·줄 바꿈 형식으로 자동 파싱됩니다."
            @paste="onPaste"
            @input="(e) => { rawText = (e.target as HTMLTextAreaElement).value; parseText(rawText); }"
          />
          <div
            v-if="parsedMatrix.length"
            class="pointer-events-none absolute right-3 top-3 rounded-md bg-primary/10 px-1.5 py-0.5 font-mono text-[10px] font-semibold text-primary"
          >
            {{ dataRows.length }}행 파싱됨
          </div>
        </div>

        <!-- 헤더 토글 + 에러 -->
        <div class="mb-3 flex flex-wrap items-center gap-3">
          <label class="flex cursor-pointer items-center gap-2 text-xs text-onSurface-variant select-none">
            <input
              type="checkbox"
              class="h-3.5 w-3.5 accent-primary"
              :checked="hasHeader"
              @change="onToggleHeader"
            />
            첫 행을 헤더로 사용
          </label>
        </div>

        <!-- 컬럼 매핑 -->
        <div
          v-if="colMap.length"
          class="mb-4 overflow-x-auto rounded-xl border border-outline-variant/60 bg-surface-low/50"
        >
          <table class="w-full text-left text-xs">
            <thead>
              <tr class="border-b border-outline-variant/50 bg-surface-low/80">
                <th
                  v-for="(_, i) in colMap"
                  :key="i"
                  class="px-3 py-2 font-semibold text-onSurface-variant"
                >
                  열 {{ i + 1 }}
                </th>
              </tr>
              <tr class="border-b border-outline-variant/50">
                <th
                  v-for="(col, i) in colMap"
                  :key="i"
                  class="px-2 py-1.5"
                >
                  <select
                    :value="col"
                    class="w-full cursor-pointer rounded-md border border-outline-variant/60 bg-white/80 px-1.5 py-1 text-xs font-medium text-onSurface focus:outline-none focus:ring-1 focus:ring-primary/40"
                    @change="(e) => { colMap[i] = (e.target as HTMLSelectElement).value; }"
                  >
                    <option v-for="f in fieldOptions" :key="f" :value="f">{{ f }}</option>
                  </select>
                </th>
              </tr>
            </thead>
            <!-- 미리보기 데이터 행 -->
            <tbody>
              <tr
                v-for="(row, ri) in previewRows"
                :key="ri"
                class="border-b border-outline-variant/30 last:border-0"
                :class="
                  !row.docId
                    ? 'bg-red-50/40 text-red-900/70'
                    : row.isDuplicate
                      ? 'bg-amber-50/50 text-amber-900/80'
                      : ''
                "
              >
                <td
                  v-for="(cell, ci) in dataRows[ri]"
                  :key="ci"
                  class="max-w-[10rem] truncate px-3 py-1.5 font-mono"
                >
                  {{ cell }}
                </td>
                <td v-if="dataRows[ri] && dataRows[ri]!.length === 0" class="px-3 py-1.5 text-onSurface-variant/50">
                  (빈 행)
                </td>
              </tr>
            </tbody>
          </table>
          <p
            v-if="dataRows.length > 8"
            class="border-t border-outline-variant/40 px-3 py-2 text-[11px] text-onSurface-variant"
          >
            … 외 {{ (dataRows.length - 8).toLocaleString("ko-KR") }}행 (저장 시 전체 반영)
          </p>
        </div>

        <!-- 범례 -->
        <div
          v-if="mappedRows.length"
          class="mb-3 flex flex-wrap items-center gap-3 text-[11px]"
        >
          <span class="flex items-center gap-1.5 text-onSurface-variant">
            <span class="inline-block h-2.5 w-2.5 rounded-sm bg-surface-low ring-1 ring-outline-variant/50" />
            정상 {{ mappedRows.filter((r) => r.docId && !r.isDuplicate).length }}건
          </span>
          <span
            v-if="mappedRows.some((r) => r.isDuplicate)"
            class="flex items-center gap-1.5 text-amber-800"
          >
            <span class="inline-block h-2.5 w-2.5 rounded-sm bg-amber-100 ring-1 ring-amber-300/60" />
            중복 {{ mappedRows.filter((r) => r.isDuplicate).length }}건
          </span>
          <span
            v-if="mappedRows.some((r) => !r.docId)"
            class="flex items-center gap-1.5 text-red-700"
          >
            <span class="inline-block h-2.5 w-2.5 rounded-sm bg-red-50 ring-1 ring-red-200/60" />
            ID 미결정 {{ mappedRows.filter((r) => !r.docId).length }}건 (건너뜀)
          </span>
        </div>

        <!-- 중복 처리 정책 -->
        <div
          v-if="mappedRows.some((r) => r.isDuplicate)"
          class="mb-4 flex items-center gap-3"
        >
          <span class="text-xs font-medium text-onSurface-variant">중복 처리:</span>
          <label class="flex cursor-pointer items-center gap-1.5 text-xs select-none">
            <input
              v-model="dupPolicy"
              type="radio"
              value="skip"
              class="accent-primary"
            />
            건너뜀
          </label>
          <label class="flex cursor-pointer items-center gap-1.5 text-xs select-none">
            <input
              v-model="dupPolicy"
              type="radio"
              value="overwrite"
              class="accent-primary"
            />
            덮어쓰기
          </label>
        </div>

        <!-- 저장 에러 -->
        <div
          v-if="saveError"
          class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-xs text-red-900"
        >
          {{ saveError }}
        </div>

        <!-- 액션 버튼 -->
        <div class="flex flex-wrap items-center justify-between gap-3">
          <p
            v-if="rowsToSave.length"
            class="text-xs text-onSurface-variant"
          >
            저장 예정
            <span class="font-semibold text-onSurface">{{ rowsToSave.length }}건</span>
            <span v-if="skippedCount > 0" class="text-onSurface-variant/70">
              · 건너뜀 {{ skippedCount }}건
            </span>
          </p>
          <p
            v-else-if="mappedRows.length"
            class="text-xs text-onSurface-variant"
          >
            저장할 행이 없습니다.
          </p>
          <div v-else />

          <div class="flex gap-2">
            <button
              type="button"
              class="btn-secondary px-3 py-1.5 text-xs"
              :disabled="isBusy"
              @click="toggle"
            >
              닫기
            </button>
            <button
              type="button"
              class="btn-primary px-4 py-1.5 text-xs shadow-sm shadow-primary/15"
              :disabled="isBusy || !rowsToSave.length || !canMutate"
              @click="save"
            >
              {{ isBusy ? "저장 중…" : `${rowsToSave.length}건 저장` }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
