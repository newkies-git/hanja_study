<script setup lang="ts">
import { ref, watch } from "vue";
import {
  collection,
  doc,
  addDoc,
  setDoc,
  deleteDoc,
  serverTimestamp,
} from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { isLocalApiEnabled, localApiFetch } from "@/config/localApi";
import { fetchHanjaWordsContainingGlyphFirestore } from "@/utils/fetchHanjaWordsContainingFirestore";
import type { HanjaWordTableRow } from "@/utils/fetchHanjaWordsContainingFirestore";
import { useWorkbenchStore } from "@/stores/workbench";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";

const props = defineProps<{
  glyph: string;
  mode: "local" | "firestore";
}>();

const workbench = useWorkbenchStore();
const auth = useAuthStore();
const notifications = useNotificationsStore();

const rows = ref<HanjaWordTableRow[]>([]);
const isLoading = ref(false);
const error = ref<string | null>(null);
const meta = ref<{ scanned?: number; truncated?: boolean }>({});
const isMutating = ref(false);

// 편집 모달 상태
const editModalOpen = ref(false);
const editingId = ref<string | null>(null);
const editWord = ref("");
const editReading = ref("");
const editMeaning = ref("");

// 추가 상태
const isAdding = ref(false);
const newWord = ref("");
const newReading = ref("");
const newMeaning = ref("");

// 삭제 확인
const deleteConfirmId = ref<string | null>(null);

async function loadRows() {
  const g = String(props.glyph ?? "").trim();
  rows.value = [];
  error.value = null;
  meta.value = {};
  editModalOpen.value = false;
  editingId.value = null;
  isAdding.value = false;
  deleteConfirmId.value = null;
  if (!g) return;

  isLoading.value = true;
  try {
    if (props.mode === "local") {
      if (!isLocalApiEnabled) {
        error.value = "로컬 API가 꺼져 있습니다.";
        return;
      }
      const res = await localApiFetch(
        `/api/hanja_word/containing?glyph=${encodeURIComponent(g)}&limit=300`,
      );
      if (!res.ok) {
        const j = (await res.json().catch(() => ({}))) as { error?: string };
        throw new Error(j.error || "단어 목록을 불러오지 못했습니다.");
      }
      const j = (await res.json()) as { data?: unknown[] };
      rows.value = (j.data ?? []).map((r) => {
        const rec = r as Record<string, unknown>;
        return {
          id: String(rec.id ?? rec.server_doc_id ?? ""),
          word: String(rec.word ?? ""),
          reading: String(rec.reading ?? ""),
          meaning: String(rec.meaning ?? ""),
        };
      });
    } else {
      if (!isFirebaseConfigured()) {
        error.value = "Firebase가 설정되지 않았습니다.";
        return;
      }
      const db = getFirestoreDb();
      const { rows: out, scanned, truncated } = await fetchHanjaWordsContainingGlyphFirestore(
        db,
        g,
        { matchLimit: 200, maxScanned: 5000, pageSize: 400 },
      );
      rows.value = out;
      meta.value = { scanned, truncated };
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "불러오기 실패";
  } finally {
    isLoading.value = false;
  }
}

function startEdit(row: HanjaWordTableRow) {
  deleteConfirmId.value = null;
  editingId.value = row.id;
  editWord.value = row.word;
  editReading.value = row.reading;
  editMeaning.value = row.meaning;
  editModalOpen.value = true;
}

function cancelEdit() {
  editModalOpen.value = false;
  editingId.value = null;
}

function startAdd() {
  editingId.value = null;
  deleteConfirmId.value = null;
  newWord.value = props.glyph;
  newReading.value = "";
  newMeaning.value = "";
  isAdding.value = true;
}

function cancelAdd() {
  isAdding.value = false;
}

async function saveEdit() {
  if (!editingId.value || !editWord.value.trim()) return;
  isMutating.value = true;
  try {
    if (props.mode === "local") {
      await workbench.fetchLocalSession();
      if (!workbench.localSession) {
        notifications.error("활성 채번이 없습니다.");
        return;
      }
      const res = await localApiFetch(`/api/hanja_word/${editingId.value}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          word: editWord.value.trim(),
          reading: editReading.value.trim(),
          meaning: editMeaning.value.trim(),
          related_hanja: [],
          change_number: workbench.localSession.id,
        }),
      });
      if (!res.ok) {
        const j = (await res.json().catch(() => ({}))) as { error?: string };
        throw new Error(j.error || "수정 실패");
      }
    } else {
      await auth.syncIdTokenForFirestore();
      const db = getFirestoreDb();
      await setDoc(
        doc(db, "hanja_word", editingId.value),
        {
          word_id: editingId.value,
          word: editWord.value.trim(),
          reading: editReading.value.trim(),
          meaning: editMeaning.value.trim(),
          _updatedAt: serverTimestamp(),
        },
        { merge: true },
      );
    }
    const idx = rows.value.findIndex((r) => r.id === editingId.value);
    if (idx >= 0) {
      rows.value[idx] = {
        ...rows.value[idx],
        word: editWord.value.trim(),
        reading: editReading.value.trim(),
        meaning: editMeaning.value.trim(),
      };
    }
    editModalOpen.value = false;
    editingId.value = null;
    notifications.success("수정 완료");
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "수정 실패");
  } finally {
    isMutating.value = false;
  }
}

async function saveAdd() {
  if (!newWord.value.trim()) return;
  isMutating.value = true;
  try {
    let newId = "";
    if (props.mode === "local") {
      await workbench.fetchLocalSession();
      if (!workbench.localSession) {
        notifications.error("활성 채번이 없습니다.");
        return;
      }
      const res = await localApiFetch("/api/hanja_word", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          word: newWord.value.trim(),
          reading: newReading.value.trim(),
          meaning: newMeaning.value.trim(),
          related_hanja: [],
          change_number: workbench.localSession.id,
        }),
      });
      if (!res.ok) {
        const j = (await res.json().catch(() => ({}))) as { error?: string };
        throw new Error(j.error || "추가 실패");
      }
      const j = (await res.json()) as { id?: number };
      newId = String(j.id ?? "");
    } else {
      await auth.syncIdTokenForFirestore();
      const db = getFirestoreDb();
      const docRef = await addDoc(collection(db, "hanja_word"), {
        word: newWord.value.trim(),
        reading: newReading.value.trim(),
        meaning: newMeaning.value.trim(),
        related_hanja: [],
        _createdAt: serverTimestamp(),
      });
      await setDoc(docRef, { word_id: docRef.id }, { merge: true });
      newId = docRef.id;
    }
    rows.value.push({
      id: newId,
      word: newWord.value.trim(),
      reading: newReading.value.trim(),
      meaning: newMeaning.value.trim(),
    });
    isAdding.value = false;
    notifications.success("추가 완료");
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "추가 실패");
  } finally {
    isMutating.value = false;
  }
}

async function executeDelete() {
  const id = deleteConfirmId.value;
  if (!id) return;
  deleteConfirmId.value = null;
  isMutating.value = true;
  try {
    if (props.mode === "local") {
      const res = await localApiFetch(`/api/hanja_word/${id}`, { method: "DELETE" });
      if (!res.ok) throw new Error("삭제 실패");
    } else {
      await auth.syncIdTokenForFirestore();
      const db = getFirestoreDb();
      await deleteDoc(doc(db, "hanja_word", id));
    }
    rows.value = rows.value.filter((r) => r.id !== id);
    notifications.success("삭제 완료");
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "삭제 실패");
  } finally {
    isMutating.value = false;
  }
}

watch(
  () => [props.glyph, props.mode] as const,
  () => { void loadRows(); },
  { immediate: true },
);
</script>

<template>
  <section
    class="rounded-2xl border border-outline-variant/60 bg-surface-low/40 p-4 shadow-sm sm:p-5"
  >
    <!-- 헤더 -->
    <div class="flex flex-wrap items-center justify-between gap-2">
      <p class="text-body leading-snug text-onSurface-variant">
        <span class="font-hanja font-medium text-onSurface">{{ glyph || "—" }}</span>
        가 포함된 단어
      </p>
      <div class="flex items-center gap-2">
        <button
          type="button"
          class="btn-secondary px-2.5 py-1 text-xs"
          :disabled="isLoading || !glyph.trim()"
          @click="() => void loadRows()"
        >
          새로고침
        </button>
        <button
          type="button"
          class="btn-primary px-2.5 py-1 text-xs"
          :disabled="isAdding || isMutating"
          @click="startAdd"
        >
          + 단어 추가
        </button>
      </div>
    </div>

    <!-- 에러 -->
    <p
      v-if="error"
      class="mt-3 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900"
    >
      {{ error }}
    </p>

    <!-- 로딩 -->
    <div v-else-if="isLoading" class="mt-4 text-sm text-onSurface-variant">불러오는 중…</div>

    <!-- 추가 폼 -->
    <div
      v-if="isAdding"
      class="mt-3 rounded-lg border border-primary/30 bg-primary/[0.03] p-3"
    >
      <p class="mb-2 text-xs font-semibold text-onSurface">새 단어 추가</p>
      <div class="grid grid-cols-3 gap-2">
        <div class="space-y-1">
          <label class="text-[11px] text-onSurface-variant">단어</label>
          <input
            v-model="newWord"
            type="text"
            placeholder="단어"
            class="input-minimal w-full py-1.5 font-hanja text-sm"
          />
        </div>
        <div class="space-y-1">
          <label class="text-[11px] text-onSurface-variant">음</label>
          <input
            v-model="newReading"
            type="text"
            placeholder="음"
            class="input-minimal w-full py-1.5 text-sm"
          />
        </div>
        <div class="space-y-1">
          <label class="text-[11px] text-onSurface-variant">의미</label>
          <input
            v-model="newMeaning"
            type="text"
            placeholder="의미"
            class="input-minimal w-full py-1.5 text-sm"
          />
        </div>
      </div>
      <div class="mt-2 flex justify-end gap-2">
        <button
          type="button"
          class="btn-secondary px-3 py-1 text-xs"
          :disabled="isMutating"
          @click="cancelAdd"
        >
          취소
        </button>
        <button
          type="button"
          class="btn-primary px-3 py-1 text-xs"
          :disabled="isMutating || !newWord.trim()"
          @click="() => void saveAdd()"
        >
          {{ isMutating ? "저장 중…" : "저장" }}
        </button>
      </div>
    </div>

    <!-- 비어있음 -->
    <div
      v-else-if="!isLoading && rows.length === 0"
      class="mt-4 text-sm text-onSurface-variant"
    >
      포함 단어가 없거나 아직 동기화되지 않았습니다.
    </div>

    <!-- 테이블 -->
    <div v-if="rows.length > 0" class="mt-4 overflow-x-auto rounded-lg border border-outline-variant/50">
      <table class="w-full min-w-[24rem] border-collapse text-left text-sm text-onSurface">
        <thead>
          <tr class="border-b border-outline-variant/70 bg-surface-low/90">
            <th class="px-2 py-2 font-semibold text-onSurface-variant">한자(단어)</th>
            <th class="px-2 py-2 font-semibold text-onSurface-variant">음</th>
            <th class="px-2 py-2 font-semibold text-onSurface-variant">의미</th>
            <th class="w-20 px-2 py-2" />
          </tr>
        </thead>
        <tbody class="divide-y divide-outline-variant/40">
          <template v-for="(r, i) in rows" :key="`${r.id}-${i}`">
            <!-- 삭제 확인 행 -->
            <tr v-if="deleteConfirmId === r.id" class="bg-red-50/60">
              <td colspan="3" class="px-3 py-2 text-xs text-red-800">
                <span class="font-hanja font-medium">{{ r.word }}</span> 를 삭제하시겠습니까?
              </td>
              <td class="px-2 py-1.5">
                <div class="flex items-center gap-1">
                  <button
                    type="button"
                    class="rounded px-2 py-0.5 text-xs text-onSurface-variant hover:bg-surface-bright"
                    :disabled="isMutating"
                    @click="deleteConfirmId = null"
                  >
                    취소
                  </button>
                  <button
                    type="button"
                    class="rounded bg-red-600 px-2 py-0.5 text-xs text-white hover:bg-red-700"
                    :disabled="isMutating"
                    @click="() => void executeDelete()"
                  >
                    삭제
                  </button>
                </div>
              </td>
            </tr>

            <!-- 일반 행 -->
            <tr v-else-if="deleteConfirmId !== r.id" class="group hover:bg-primary/[0.04]">
              <td class="max-w-[12rem] px-2 py-1.5 font-hanja font-medium">{{ r.word }}</td>
              <td class="px-2 py-1.5 text-onSurface-variant">{{ r.reading || "—" }}</td>
              <td class="max-w-[20rem] truncate px-2 py-1.5" :title="r.meaning">
                {{ r.meaning || "—" }}
              </td>
              <td class="px-2 py-1.5">
                <div class="flex items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100">
                  <button
                    type="button"
                    class="rounded p-1 text-onSurface-variant hover:bg-surface-bright hover:text-primary"
                    title="편집"
                    @click="startEdit(r)"
                  >
                    <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                    </svg>
                  </button>
                  <button
                    type="button"
                    class="rounded p-1 text-onSurface-variant hover:bg-red-50 hover:text-red-600"
                    title="삭제"
                    @click="deleteConfirmId = r.id"
                  >
                    <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>

    <p
      v-if="mode === 'firestore' && meta.truncated"
      class="text-caption mt-2 text-amber-800"
    >
      일부 문서만 검사했습니다.
    </p>
  </section>

  <!-- 편집 모달 -->
  <Teleport to="body">
    <div
      v-if="editModalOpen"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      @mousedown.self="cancelEdit"
    >
      <!-- 배경 -->
      <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" />

      <!-- 패널 -->
      <div class="relative w-full max-w-sm rounded-2xl border border-outline-variant/60 bg-surface shadow-xl">
        <div class="border-b border-outline-variant/50 px-5 py-4">
          <p class="text-sm font-semibold text-onSurface">단어 편집</p>
        </div>

        <div class="space-y-4 px-5 py-4">
          <div class="space-y-1">
            <label class="text-xs font-semibold uppercase tracking-wide text-onSurface-variant">단어</label>
            <input
              v-model="editWord"
              type="text"
              class="input-minimal w-full py-2 font-hanja text-sm"
              placeholder="단어"
            />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-semibold uppercase tracking-wide text-onSurface-variant">음</label>
            <input
              v-model="editReading"
              type="text"
              class="input-minimal w-full py-2 text-sm"
              placeholder="음"
            />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-semibold uppercase tracking-wide text-onSurface-variant">의미</label>
            <textarea
              v-model="editMeaning"
              rows="4"
              class="input-minimal w-full resize-none py-2 text-sm"
              placeholder="의미"
            />
          </div>
        </div>

        <div class="flex justify-end gap-2 border-t border-outline-variant/50 px-5 py-4">
          <button
            type="button"
            class="btn-secondary px-4 py-1.5 text-sm"
            :disabled="isMutating"
            @click="cancelEdit"
          >
            취소
          </button>
          <button
            type="button"
            class="btn-primary px-4 py-1.5 text-sm"
            :disabled="isMutating || !editWord.trim()"
            @click="() => void saveEdit()"
          >
            {{ isMutating ? "저장 중…" : "저장" }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
