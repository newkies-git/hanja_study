<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { doc, getDoc, serverTimestamp, setDoc } from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useFocusTrap } from "@/composables/useFocusTrap";

const props = defineProps<{
  open: boolean;
  queryId: string;
  /** false 이면 편집 버튼 숨김 */
  canEdit?: boolean;
}>();

const emit = defineEmits<{
  close: [];
  /** setDoc 성공 후 발생. 부모에서 version bump 처리. */
  saved: [];
}>();

const auth = useAuthStore();
const notifications = useNotificationsStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

// ── 조회 상태 ──────────────────────────────────────────────────────────────

const isLoading = ref(false);
const loadError = ref<string | null>(null);
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

async function loadFromFirestore() {
  if (!props.queryId) return;
  isLoading.value = true;
  loadError.value = null;
  payload.value = null;
  try {
    const db = getFirestoreDb();
    const snap = await getDoc(doc(db, "hanja_extend", props.queryId));
    if (!snap.exists()) {
      loadError.value = `hanja_extend / ${props.queryId} 문서가 없습니다.`;
    } else {
      payload.value = snap.data() as Record<string, unknown>;
    }
  } catch (e) {
    loadError.value = e instanceof Error ? e.message : "hanja_extend를 불러오지 못했습니다.";
  } finally {
    isLoading.value = false;
  }
}

// ── 편집 모드 ──────────────────────────────────────────────────────────────

const isEditMode = ref(false);
const isSaving = ref(false);
const saveError = ref<string | null>(null);

type EditField = { key: string; value: string };
const editFields = ref<EditField[]>([]);

function valueToString(v: unknown): string {
  if (v === null || v === undefined) return "";
  if (typeof v === "object") {
    try { return JSON.stringify(v, null, 2); } catch { return String(v); }
  }
  return String(v);
}

function parseFieldValue(s: string): unknown {
  const t = s.trim();
  if (!t) return "";
  if (/^\s*[\[{]/.test(t) || t === "null" || t === "true" || t === "false") {
    try { return JSON.parse(t); } catch {}
  }
  const n = Number(t);
  if (!isNaN(n) && t !== "") return n;
  return s;
}

function enterEditMode() {
  if (!payload.value) return;
  editFields.value = sortExtendKeys(
    Object.keys(payload.value).filter((k) => !k.startsWith("_")),
  ).map((k) => ({ key: k, value: valueToString(payload.value![k]) }));
  isEditMode.value = true;
  saveError.value = null;
}

function exitEditMode() {
  isEditMode.value = false;
  editFields.value = [];
  saveError.value = null;
}

function addEditField() {
  editFields.value = [...editFields.value, { key: "", value: "" }];
}

function removeEditField(i: number) {
  editFields.value = editFields.value.filter((_, idx) => idx !== i);
}

async function saveEdit() {
  const newPayload: Record<string, unknown> = {};
  for (const { key, value } of editFields.value) {
    const k = key.trim();
    if (k) newPayload[k] = parseFieldValue(value);
  }
  newPayload._importedAt = serverTimestamp();

  isSaving.value = true;
  saveError.value = null;
  try {
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    await setDoc(doc(db, "hanja_extend", props.queryId), newPayload);
    payload.value = { ...newPayload };
    notifications.success(`hanja_extend 수정 완료: ${props.queryId}`);
    exitEditMode();
    emit("saved");
  } catch (e) {
    saveError.value = e instanceof Error ? e.message : "저장에 실패했습니다.";
    notifications.error(saveError.value);
  } finally {
    isSaving.value = false;
  }
}

// ── 생명주기 ──────────────────────────────────────────────────────────────

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") {
    if (isEditMode.value) exitEditMode();
    else emit("close");
  }
}

watch(() => props.open, (val) => {
  if (val) {
    loadFromFirestore();
    document.addEventListener("keydown", handleKeyDown);
  } else {
    document.removeEventListener("keydown", handleKeyDown);
    loadError.value = null;
    payload.value = null;
    exitEditMode();
  }
});

onUnmounted(() => document.removeEventListener("keydown", handleKeyDown));
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
        ref="containerRef"
        class="flex max-h-[min(90vh,52rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
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
                class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-sm font-bold text-white shadow-md shadow-primary/25 transition"
                :class="isEditMode ? 'bg-amber-500' : 'bg-primary'"
                aria-hidden="true"
              >
                {{ isEditMode ? "edit" : "ext" }}
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
                  {{ isEditMode ? "필드를 편집하세요. 저장 시 문서 전체가 덮어씌워집니다." : "확장 메타데이터 · 문서 ID 기준 조회" }}
                </p>
              </div>
            </div>
            <div class="flex shrink-0 gap-2">
              <button
                v-if="!isEditMode && canEdit && payload && !isLoading"
                type="button"
                class="btn-secondary px-3 py-2 text-sm"
                @click="enterEditMode"
              >
                편집
              </button>
              <button
                v-if="isEditMode"
                type="button"
                class="btn-secondary px-3 py-2 text-sm"
                :disabled="isSaving"
                @click="exitEditMode"
              >
                편집 취소
              </button>
              <button
                type="button"
                class="btn-secondary px-3 py-2 text-sm"
                :disabled="isSaving"
                @click="emit('close')"
              >
                닫기
              </button>
            </div>
          </div>
          <div class="relative mt-4 flex flex-wrap items-center gap-2">
            <span
              class="inline-flex items-center rounded-lg border border-primary/20 bg-primary/[0.08] px-3 py-1.5 font-mono text-sm font-medium text-primary"
            >
              {{ queryId }}
            </span>
            <span
              v-if="!isLoading && !loadError && fieldRows.length && !isEditMode"
              class="rounded-full bg-onSurface/[0.06] px-2.5 py-1 text-[11px] font-medium text-onSurface-variant"
            >
              {{ fieldRows.length }}개 필드
            </span>
            <span
              v-if="isEditMode"
              class="rounded-full border border-amber-300/60 bg-amber-50 px-2.5 py-1 text-[11px] font-medium text-amber-800"
            >
              편집 중
            </span>
          </div>
        </div>

        <!-- 본문 -->
        <div class="min-h-0 flex-1 overflow-y-auto bg-surface px-4 py-4 sm:px-5 sm:py-5">
          <!-- 로딩 -->
          <div
            v-if="isLoading"
            class="flex flex-col items-center justify-center gap-4 py-16"
          >
            <div class="flex gap-1.5" role="status" aria-label="불러오는 중">
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
              <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
            </div>
            <p class="text-sm font-medium text-onSurface-variant">문서를 불러오는 중…</p>
          </div>

          <!-- 로드 에러 -->
          <div
            v-else-if="loadError"
            class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3.5 text-sm text-red-900 shadow-sm"
          >
            <p class="font-semibold text-red-950">조회 실패</p>
            <p class="mt-1 leading-relaxed text-red-800/95">{{ loadError }}</p>
          </div>

          <!-- ── 편집 모드 ── -->
          <div v-else-if="isEditMode" class="space-y-2">
            <div
              v-if="saveError"
              class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900"
            >
              {{ saveError }}
            </div>

            <div
              v-for="(field, i) in editFields"
              :key="i"
              class="flex items-start gap-2"
            >
              <!-- key -->
              <input
                v-model="field.key"
                type="text"
                class="input-minimal w-[10rem] shrink-0 py-1.5 font-mono text-xs"
                placeholder="key"
                autocomplete="off"
              />
              <!-- value -->
              <textarea
                v-model="field.value"
                rows="1"
                class="input-minimal min-w-0 flex-1 resize-y py-1.5 font-mono text-xs leading-relaxed"
                placeholder="value"
              />
              <button
                type="button"
                class="mt-1 shrink-0 rounded-md p-1.5 text-onSurface-variant/60 transition hover:bg-red-50 hover:text-red-700"
                :aria-label="`필드 ${i + 1} 삭제`"
                @click="removeEditField(i)"
              >
                <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M4 4l8 8M12 4l-8 8" />
                </svg>
              </button>
            </div>

            <button
              type="button"
              class="mt-1 flex items-center gap-1.5 rounded-lg border border-dashed border-outline-variant/70 px-3 py-2 text-xs font-medium text-onSurface-variant transition hover:border-primary/30 hover:text-primary"
              @click="addEditField"
            >
              + 필드 추가
            </button>

            <!-- 저장 버튼 (편집 모드 본문 하단) -->
            <div class="flex justify-end gap-2 pt-4">
              <button
                type="button"
                class="btn-secondary px-4 py-2 text-sm"
                :disabled="isSaving"
                @click="exitEditMode"
              >
                취소
              </button>
              <button
                type="button"
                class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
                :disabled="isSaving"
                @click="saveEdit"
              >
                {{ isSaving ? "저장 중…" : "저장" }}
              </button>
            </div>
          </div>

          <!-- ── 읽기 모드 ── -->
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
