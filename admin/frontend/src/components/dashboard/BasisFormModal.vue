<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import { collection, doc, getDoc, serverTimestamp, setDoc, writeBatch } from "firebase/firestore";
import { getFirestoreDb } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useFocusTrap } from "@/composables/useFocusTrap";
import {
  resolveHanjaBasisDocId,
  HANJA_BASIS_COLUMN_ORDER as COLUMN_ORDER,
} from "@/utils/hanjaBasis";

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

const form = ref<Record<string, string>>({});
const busy = ref(false);
const error = ref<string | null>(null);

function emptyForm(): Record<string, string> {
  const o: Record<string, string> = {};
  for (const c of COLUMN_ORDER) o[c] = "";
  return o;
}

function rowToFormStrings(data: Row): Record<string, string> {
  const o = emptyForm();
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

const resolvedId = computed(() => resolveHanjaBasisDocId(form.value) ?? "—");

watch(
  () => props.open,
  (val) => {
    if (!val) return;
    error.value = null;
    form.value =
      props.mode === "edit" && props.entry
        ? rowToFormStrings(props.entry.data)
        : emptyForm();
  },
  { immediate: true },
);

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

onUnmounted(() => { document.removeEventListener("keydown", handleKeyDown); });

async function save() {
  const newId = resolveHanjaBasisDocId(form.value);
  if (!newId) {
    error.value = "문서 ID를 정할 수 없습니다. 한자를 입력하거나 id에 H+16진 형식을 넣으세요.";
    return;
  }
  busy.value = true;
  error.value = null;
  try {
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const colRef = collection(db, "hanja_basis");

    // 추가 모드에서 동일 ID 문서가 이미 존재하는지 확인
    if (props.mode === "add") {
      const existing = await getDoc(doc(colRef, newId));
      if (existing.exists()) {
        error.value = `${newId} 는 이미 존재합니다. 수정 모드로 열거나 다른 한자·ID를 입력하세요.`;
        return;
      }
    }

    const payload: Record<string, unknown> = {};
    for (const c of COLUMN_ORDER) payload[c] = c === "id" ? newId : (form.value[c] ?? "");
    payload._importedAt = serverTimestamp();

    if (props.mode === "edit" && props.entry) {
      const oldId = props.entry.id;
      if (props.entry.data._row != null) payload._row = props.entry.data._row;
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
    notifications.success(`hanja_basis ${label} 완료: ${newId}`);
    emit("saved", newId);
    emit("close");
  } catch (e) {
    const msg = e instanceof Error ? e.message : "저장에 실패했습니다.";
    error.value = msg;
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
      aria-labelledby="basis-form-modal-title"
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
                Firestore · hanja_basis
              </p>
              <h2
                id="basis-form-modal-title"
                class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl"
              >
                {{ mode === "add" ? "항목 추가" : "항목 수정" }}
              </h2>
              <p class="mt-1 text-xs text-onSurface-variant">
                필드는 타일 그리드로 입력합니다. 문서 ID는 아래 타일에서 확인하세요.
              </p>
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
        <div class="min-h-0 flex-1 overflow-y-auto px-4 py-4 sm:px-5 sm:py-5">
          <div
            v-if="error"
            class="mb-3 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900 shadow-sm"
          >
            {{ error }}
          </div>
          <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <!-- 문서 ID 미리보기 -->
            <div
              class="rounded-xl border border-primary/25 bg-gradient-to-br from-primary/[0.08] to-surface-lowest p-3 shadow-sm ring-1 ring-primary/10 sm:col-span-2"
            >
              <p class="text-[10px] font-semibold uppercase tracking-wide text-primary/90">
                저장 시 문서 ID
              </p>
              <p class="mt-1 break-all font-mono text-base font-semibold text-primary sm:text-lg">
                {{ resolvedId }}
              </p>
            </div>

            <!-- 한자 (메인) -->
            <div
              class="rounded-2xl border-2 border-primary/20 bg-gradient-to-b from-primary/[0.07] to-surface-lowest p-4 shadow-sm sm:col-span-2"
            >
              <label
                class="mb-2 block text-center text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                for="bf-한자"
              >한자</label>
              <input
                id="bf-한자"
                v-model="form['한자']"
                type="text"
                class="input-minimal w-full border-0 bg-white/60 py-3 text-center font-display text-4xl font-semibold tracking-tight shadow-inner sm:text-5xl"
                autocomplete="off"
              />
            </div>

            <!-- 음 -->
            <div
              class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
            >
              <label
                class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                for="bf-음"
              >음</label>
              <input
                id="bf-음"
                v-model="form['음']"
                type="text"
                class="input-minimal py-2 text-sm"
                autocomplete="off"
              />
            </div>

            <!-- 훈 -->
            <div
              class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
            >
              <label
                class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                for="bf-훈"
              >훈</label>
              <input
                id="bf-훈"
                v-model="form['훈']"
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
                for="bf-훈음"
              >훈음</label>
              <input
                id="bf-훈음"
                v-model="form['훈음']"
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
                for="bf-전체"
              >전체</label>
              <input
                id="bf-전체"
                v-model="form['전체']"
                type="text"
                class="input-minimal py-2 text-sm"
                autocomplete="off"
              />
            </div>

            <!-- id -->
            <div
              class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
            >
              <label
                class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                for="bf-id"
              >id</label>
              <p class="mb-1 text-[10px] leading-tight text-onSurface-variant">
                한자 없을 때 H+16진 등
              </p>
              <input
                id="bf-id"
                v-model="form['id']"
                type="text"
                class="input-minimal py-2 font-mono text-xs"
                placeholder="비우면 한자로부터 자동"
                autocomplete="off"
              />
            </div>

            <!-- 구분 -->
            <div
              class="rounded-xl border border-outline-variant/70 bg-surface-low/80 p-3 shadow-sm ring-1 ring-black/[0.02]"
            >
              <label
                class="mb-1.5 block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
                for="bf-구분"
              >구분</label>
              <select
                id="bf-구분"
                v-model="form['구분']"
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
