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
import {
  resolveHanjaBasisDocId,
  HANJA_BASIS_COLUMN_ORDER as COLUMN_ORDER,
} from "@/utils/hanjaBasis";
import {
  type HanjaDetailFormState,
  createEmptyHanjaBasisFormRecord,
} from "@/types/hanjaAdminForms";
import HanjaDetailTabBasic from "@/components/dashboard/HanjaDetailTabBasic.vue";
import HanjaDetailTabReadings from "@/components/dashboard/HanjaDetailTabReadings.vue";
import HanjaDetailTabMeaning from "@/components/dashboard/HanjaDetailTabMeaning.vue";
import HanjaDetailTabRelated from "@/components/dashboard/HanjaDetailTabRelated.vue";
import HanjaStrokeRegisterView from "@/views/dashboard/HanjaStrokeRegisterView.vue";

const props = defineProps<{
  open: boolean;
  mode: "add" | "edit";
  entry: { id: string; data: Record<string, unknown> } | null;
}>();

const emit = defineEmits<{
  close: [];
  saved: [newId: string];
}>();

const auth = useAuthStore();
const notifications = useNotificationsStore();

const containerRef = ref<HTMLElement | null>(null);
useFocusTrap(containerRef, () => props.open);

const form = ref<HanjaDetailFormState>(createEmptyHanjaBasisFormRecord());
const busy = ref(false);
const error = ref<string | null>(null);
const activeTab = ref<"basic" | "readings" | "meaning" | "related" | "strokes">("basic");

const tabs = [
  { id: "basic" as const, label: "기본 정보" },
  { id: "readings" as const, label: "음/훈" },
  { id: "meaning" as const, label: "의미/어원" },
  { id: "related" as const, label: "관련 한자" },
  { id: "strokes" as const, label: "획순" },
] as const;

const resolvedId = computed(() => resolveHanjaBasisDocId(form.value) ?? "—");

const strokeEditorDocumentId = computed(() => resolveHanjaBasisDocId(form.value));

function mapBasisRowToModalForm(data: Record<string, unknown>): HanjaDetailFormState {
  const o = createEmptyHanjaBasisFormRecord();
  for (const c of COLUMN_ORDER) {
    const v = data[c];
    if (v !== null && v !== undefined) {
      (o as unknown as Record<string, unknown>)[c] = v;
    }
  }
  const legacyGubun = data["구분"];
  if (!String(o.grade ?? "").trim() && legacyGubun != null && legacyGubun !== "") {
    o.grade = String(legacyGubun);
  }
  return o;
}

watch(
  () => props.open,
  (val) => {
    if (!val) return;
    error.value = null;
    activeTab.value = "basic";
    form.value =
      props.mode === "edit" && props.entry
        ? mapBasisRowToModalForm(props.entry.data)
        : createEmptyHanjaBasisFormRecord();
  },
  { immediate: true },
);

function requestCloseModalAndEmit() {
  if (busy.value) return;
  emit("close");
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Escape") requestCloseModalAndEmit();
}

watch(() => props.open, (val) => {
  if (val) document.addEventListener("keydown", handleKeyDown);
  else document.removeEventListener("keydown", handleKeyDown);
});

onUnmounted(() => { document.removeEventListener("keydown", handleKeyDown); });

async function persistHanjaBasisFromModal() {
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

    if (props.mode === "add") {
      const existing = await getDoc(doc(colRef, newId));
      if (existing.exists()) {
        error.value = `${newId} 는 이미 존재합니다. 수정 모드로 열거나 다른 한자·ID를 입력하세요.`;
        return;
      }
    }

    const payload: Record<string, unknown> = {};
    for (const c of COLUMN_ORDER) {
      payload[c] = c === "id" ? newId : (form.value[c] ?? (["readings", "synonyms", "antonyms", "words", "idioms"].includes(c) ? [] : ""));
    }
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
      aria-labelledby="hanja-register-modal-title"
      @click.self="requestCloseModalAndEmit"
    >
      <div
        ref="containerRef"
        class="flex max-h-[min(92vh,52rem)] w-full max-w-4xl flex-col overflow-hidden rounded-2xl border border-outline-variant/90 bg-surface-lowest shadow-[0_24px_80px_rgba(25,28,30,0.14)] ring-1 ring-black/[0.03]"
      >
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
                id="hanja-register-modal-title"
                class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl"
              >
                {{ mode === "add" ? "항목 추가" : "항목 수정" }}
              </h2>
              <p class="mt-1 text-xs text-onSurface-variant">
                상세 화면과 동일한 탭으로 입력합니다. 문서 ID는 기본 정보 탭 상단에서 확인하세요. 획순 탭은
                <code class="rounded bg-surface-low px-1 font-mono text-[10px]">架.json</code> 형식으로
                <code class="font-mono text-[10px]">hanja_stroke</code>에 저장합니다.
              </p>
            </div>
            <button
              type="button"
              class="btn-secondary shrink-0 px-3 py-2 text-sm"
              :disabled="busy"
              @click="requestCloseModalAndEmit"
            >
              닫기
            </button>
          </div>
        </div>

        <div class="shrink-0 border-b border-outline-variant/70 bg-surface-lowest">
          <nav
            class="-mb-px flex space-x-4 overflow-x-auto px-3 sm:space-x-6 sm:px-5"
            aria-label="Tabs"
          >
            <button
              v-for="tab in tabs"
              :key="tab.id"
              type="button"
              :class="[
                activeTab === tab.id
                  ? 'border-primary text-primary'
                  : 'border-transparent text-onSurface-variant hover:border-outline-variant hover:text-onSurface',
                'whitespace-nowrap border-b-2 px-1 py-3 text-xs font-medium transition-colors sm:py-3.5 sm:text-sm',
              ]"
              @click="activeTab = tab.id"
            >
              {{ tab.label }}
            </button>
          </nav>
        </div>

        <div class="min-h-0 flex-1 overflow-y-auto px-4 py-4 sm:px-5 sm:py-5">
          <div
            v-if="error"
            class="mb-4 rounded-xl border border-red-200/90 bg-red-50/90 px-3 py-2.5 text-sm text-red-900 shadow-sm"
          >
            {{ error }}
          </div>

          <div v-show="activeTab === 'basic'" class="space-y-4">
            <div
              class="rounded-xl border border-primary/25 bg-gradient-to-br from-primary/[0.08] to-surface-lowest p-3 shadow-sm ring-1 ring-primary/10"
            >
              <p class="text-[10px] font-semibold uppercase tracking-wide text-primary/90">
                저장 시 문서 ID
              </p>
              <p class="mt-1 break-all font-mono text-base font-semibold text-primary sm:text-lg">
                {{ resolvedId }}
              </p>
            </div>
            <HanjaDetailTabBasic v-model:form="form" />
          </div>
          <HanjaDetailTabReadings v-show="activeTab === 'readings'" v-model:form="form" />
          <HanjaDetailTabMeaning v-show="activeTab === 'meaning'" v-model:form="form" />
          <HanjaDetailTabRelated v-show="activeTab === 'related'" v-model:form="form" />
          <div v-show="activeTab === 'strokes'" class="space-y-3">
            <p
              v-if="!strokeEditorDocumentId"
              class="rounded-lg border border-outline-variant/70 bg-surface-low/80 px-3 py-2.5 text-sm text-onSurface-variant"
            >
              기본 정보에서 한자 또는 id를 입력해 문서 ID가 확정되면 획순 JSON을 편집할 수 있습니다.
            </p>
            <HanjaStrokeRegisterView
              v-else
              embedded
              :embed-document-id="strokeEditorDocumentId"
            />
          </div>
        </div>

        <div
          class="flex shrink-0 flex-wrap items-center justify-end gap-2 border-t border-outline-variant/70 bg-surface-low/50 px-5 py-3"
        >
          <button
            type="button"
            class="btn-secondary px-4 py-2 text-sm"
            :disabled="busy"
            @click="requestCloseModalAndEmit"
          >
            취소
          </button>
          <button
            type="button"
            class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
            :disabled="busy"
            @click="persistHanjaBasisFromModal"
          >
            {{ busy ? "저장 중…" : "저장" }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
