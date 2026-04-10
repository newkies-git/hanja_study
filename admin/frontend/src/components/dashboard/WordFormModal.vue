<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import {
  collection,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  writeBatch,
} from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useFocusTrap } from "@/composables/useFocusTrap";

type Row = Record<string, unknown>;

const props = defineProps<{
  open: boolean;
  mode: "add" | "edit";
  entry: { id: string; data: Row } | null;
}>();

const emit = defineEmits<{
  close: [];
  saved: [newId: string];
}>();

const auth = useAuthStore();
const notifications = useNotificationsStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

// word_id 는 고정 필드, 나머지는 동적 key-value 쌍으로 관리
const wordId = ref("");
/** 동적 필드: [{key, value}] */
const dynamicFields = ref<{ key: string; value: string }[]>([]);

const busy = ref(false);
const formError = ref<string | null>(null);

const resolvedId = computed(() => wordId.value.trim() || "—");

function rowToForm(data: Row) {
  wordId.value = String(data["word_id"] ?? data["id"] ?? "");
  dynamicFields.value = Object.entries(data)
    .filter(([k]) => k !== "word_id" && k !== "id" && !k.startsWith("_"))
    .map(([k, v]) => ({
      key: k,
      value:
        v === null || v === undefined
          ? ""
          : typeof v === "object"
            ? JSON.stringify(v)
            : String(v),
    }));
}

function resetForm() {
  wordId.value = "";
  dynamicFields.value = [{ key: "", value: "" }];
  formError.value = null;
}

watch(
  () => props.open,
  (val) => {
    if (!val) return;
    formError.value = null;
    if (props.mode === "edit" && props.entry) {
      rowToForm(props.entry.data);
    } else {
      resetForm();
    }
  },
  { immediate: true },
);

function addField() {
  dynamicFields.value = [...dynamicFields.value, { key: "", value: "" }];
}

function removeField(i: number) {
  dynamicFields.value = dynamicFields.value.filter((_, idx) => idx !== i);
}

function close() {
  if (busy.value) return;
  emit("close");
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") close();
}

watch(() => props.open, (val) => {
  if (val) document.addEventListener("keydown", handleKeyDown);
  else document.removeEventListener("keydown", handleKeyDown);
});

onUnmounted(() => document.removeEventListener("keydown", handleKeyDown));

async function save() {
  const newId = wordId.value.trim();
  if (!newId) {
    formError.value = "word_id를 입력하세요.";
    return;
  }
  busy.value = true;
  formError.value = null;
  try {
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const colRef = collection(db, "hanja_word");

    if (props.mode === "add") {
      const existing = await getDoc(doc(colRef, newId));
      if (existing.exists()) {
        formError.value = `${newId} 는 이미 존재합니다. 수정 모드로 열거나 다른 ID를 입력하세요.`;
        return;
      }
    }

    const payload: Record<string, unknown> = { word_id: newId };
    for (const { key, value } of dynamicFields.value) {
      const k = key.trim();
      if (k) payload[k] = value;
    }
    payload._importedAt = serverTimestamp();

    if (props.mode === "edit" && props.entry) {
      const oldId = props.entry.id;
      if (newId !== oldId) {
        const batch = writeBatch(db);
        batch.delete(doc(colRef, oldId));
        batch.set(doc(colRef, newId), payload);
        await batch.commit();
      } else {
        await setDoc(doc(colRef, oldId), payload);
      }
    } else {
      await setDoc(doc(colRef, newId), payload);
    }

    const label = props.mode === "add" ? "추가" : "수정";
    notifications.success(`hanja_word ${label} 완료: ${newId}`);
    emit("saved", newId);
    emit("close");
  } catch (e) {
    const msg = e instanceof Error ? e.message : "저장에 실패했습니다.";
    formError.value = msg;
    notifications.error(msg);
  } finally {
    busy.value = false;
  }
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[60] flex items-center justify-center bg-onSurface/45 p-4 backdrop-blur-[2px]"
      role="dialog"
      aria-modal="true"
      aria-labelledby="word-form-modal-title"
      @click.self="close"
    >
      <div
        ref="containerRef"
        class="flex max-h-[min(92vh,52rem)] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
        <!-- 헤더 -->
        <div
          class="relative shrink-0 overflow-hidden border-b border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-5 pb-4 pt-4"
        >
          <div
            class="pointer-events-none absolute -right-8 -top-10 h-32 w-32 rounded-full bg-primary/[0.1] blur-2xl"
            aria-hidden="true"
          />
          <div class="relative flex items-start justify-between gap-3">
            <div>
              <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                Firestore · hanja_word
              </p>
              <h2
                id="word-form-modal-title"
                class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl"
              >
                {{ mode === "add" ? "단어 추가" : "단어 수정" }}
              </h2>
            </div>
            <button
              type="button"
              class="btn-secondary shrink-0 px-3 py-2 text-sm"
              :disabled="busy"
              @click="close"
            >
              닫기
            </button>
          </div>
        </div>

        <!-- 폼 본문 -->
        <div class="min-h-0 flex-1 overflow-y-auto px-5 py-5">
          <div
            v-if="formError"
            class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900"
          >
            {{ formError }}
          </div>

          <!-- 문서 ID 미리보기 -->
          <div
            class="mb-4 rounded-xl border border-primary/25 bg-gradient-to-br from-primary/[0.08] to-surface-lowest p-3 shadow-sm ring-1 ring-primary/10"
          >
            <p class="text-[10px] font-semibold uppercase tracking-wide text-primary/90">
              저장 시 문서 ID
            </p>
            <p class="mt-1 break-all font-mono text-base font-semibold text-primary sm:text-lg">
              {{ resolvedId }}
            </p>
          </div>

          <!-- word_id -->
          <div class="mb-4">
            <label
              for="wf-word-id"
              class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
            >
              word_id <span class="normal-case text-red-500">*필수</span>
            </label>
            <input
              id="wf-word-id"
              v-model="wordId"
              type="text"
              class="input-minimal w-full py-2 font-mono text-sm"
              autocomplete="off"
              placeholder="예: 水木, word_001"
            />
          </div>

          <!-- 동적 필드 -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <p class="text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant">
                추가 필드
              </p>
              <button
                type="button"
                class="flex items-center gap-1 rounded-md border border-outline-variant/60 bg-surface-low px-2.5 py-1 text-xs font-medium text-onSurface-variant transition hover:bg-surface-bright hover:text-onSurface"
                @click="addField"
              >
                + 필드 추가
              </button>
            </div>
            <div
              v-for="(field, i) in dynamicFields"
              :key="i"
              class="flex items-start gap-2"
            >
              <input
                v-model="field.key"
                type="text"
                class="input-minimal w-2/5 shrink-0 py-1.5 font-mono text-xs"
                placeholder="key"
                autocomplete="off"
              />
              <input
                v-model="field.value"
                type="text"
                class="input-minimal min-w-0 flex-1 py-1.5 text-xs"
                placeholder="value"
                autocomplete="off"
              />
              <button
                type="button"
                class="shrink-0 rounded-md p-1.5 text-onSurface-variant/60 transition hover:bg-red-50 hover:text-red-700"
                :aria-label="`필드 ${i + 1} 삭제`"
                @click="removeField(i)"
              >
                <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M4 4l8 8M12 4l-8 8" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- 푸터 -->
        <div
          class="flex shrink-0 flex-wrap items-center justify-end gap-2 border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3"
        >
          <button
            type="button"
            class="btn-secondary px-4 py-2 text-sm"
            :disabled="busy"
            @click="close"
          >
            취소
          </button>
          <button
            type="button"
            class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
            :disabled="busy"
            @click="save"
          >
            {{ busy ? "저장 중…" : "저장" }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
