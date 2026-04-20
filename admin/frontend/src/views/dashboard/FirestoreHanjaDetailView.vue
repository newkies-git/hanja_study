<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { RouterLink, useRoute, useRouter } from "vue-router";
import {
  doc,
  getDoc,
  setDoc,
  deleteDoc,
  serverTimestamp,
  writeBatch,
} from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useWorkbenchStore } from "@/stores/workbench";
import type { StrokeShape } from "@/types/strokeOrder";
import ConfirmModal from "@/components/app/ConfirmModal.vue";
import HanjaDetailViewForm from "@/components/dashboard/HanjaDetailViewForm.vue";
import {
  resolveHanjaBasisDocId,
  routeParamAsString,
  glyphFromHanjaBasisDocId,
} from "@/utils/hanjaBasis";
import {
  type HanjaDetailFormState,
  createEmptyHanjaBasisFormRecord,
  hydrateHanjaRelatedFieldsFromExtend,
} from "@/types/hanjaAdminForms";
import {
  extractSvgPaths,
  preferLongerSvgPaths,
} from "@/utils/firestoreStrokeMerge";

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const notifications = useNotificationsStore();
const workbench = useWorkbenchStore();

const id = computed(() => routeParamAsString(route.params.id));

const wordContainingSource = computed(() =>
  isFirebaseConfigured() ? ("firestore" as const) : undefined,
);

const isLoading = ref(true);
const isSaving = ref(false);
const error = ref<string | null>(null);

const form = ref<HanjaDetailFormState>(createEmptyHanjaBasisFormRecord());

const strokeShapes = ref<StrokeShape[]>([]);
const svgPaths = ref<string[]>([]);
const isStrokeLoading = ref(false);

const charDisplay = computed(() => {
  const s = String(form.value.한자 ?? form.value.char_str ?? "").trim();
  if (s.length > 0) return [...s][0] ?? s;
  return glyphFromHanjaBasisDocId(id.value);
});

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

function normalizeStrokes(raw: unknown): StrokeShape[] {
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

async function fetchBasisStrokes() {
  isStrokeLoading.value = true;
  try {
    const db = getFirestoreDb();
    let strokesRaw: unknown;
    let svgPathsBest: string[] = [];

    const stSnap = await getDoc(doc(db, "hanja_stroke", id.value));
    if (stSnap.exists()) {
      const sd = stSnap.data();
      strokesRaw = sd.strokes;
      svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(sd));
    }

    const extSnap = await getDoc(doc(db, "hanja_extend", id.value));
    if (extSnap.exists()) {
      const ed = extSnap.data();
      if (!strokesRaw) strokesRaw = ed.strokes;
      svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(ed));
    }

    if (!strokesRaw || svgPathsBest.length === 0) {
      const snap = await getDoc(doc(db, "hanja_basis", id.value));
      if (snap.exists()) {
        const bd = snap.data();
        if (!strokesRaw) strokesRaw = bd.strokes;
        svgPathsBest = preferLongerSvgPaths(svgPathsBest, extractSvgPaths(bd));
      }
    }

    svgPaths.value = svgPathsBest;
    strokeShapes.value = normalizeStrokes(strokesRaw);
  } catch (e) {
    console.error("Stroke fetch error:", e);
  } finally {
    isStrokeLoading.value = false;
  }
}

async function loadHanjaDetailDocument() {
  isLoading.value = true;
  error.value = null;
  strokeShapes.value = [];
  svgPaths.value = [];

  try {
    if (!isFirebaseConfigured()) return;
    const db = getFirestoreDb();
    const snap = await getDoc(doc(db, "hanja_basis", id.value));
    if (snap.exists()) {
      const data = snap.data();
      const mergedExtend: Record<string, unknown> = {};
      try {
        const extSnap = await getDoc(doc(db, "hanja_extend", id.value));
        if (extSnap.exists()) {
          const rawExt = extSnap.data();
          if (rawExt && typeof rawExt === "object" && !Array.isArray(rawExt)) {
            Object.assign(mergedExtend, rawExt as Record<string, unknown>);
          }
        }
      } catch {
        /* 권한 없음·문서 없음: basis 만으로 진행 */
      }
      const basisExtend = (data as Record<string, unknown>).extend;
      if (basisExtend !== undefined && basisExtend !== null && typeof basisExtend === "object" && !Array.isArray(basisExtend)) {
        Object.assign(mergedExtend, basisExtend as Record<string, unknown>);
      }

      const o = createEmptyHanjaBasisFormRecord();
      o.extend = mergedExtend;

      for (const k of Object.keys(data)) {
        if (!(k in o)) continue;
        if (k === "extend") continue;
        const v = (data as Record<string, unknown>)[k];
        if (v !== undefined && v !== null) {
          (o as unknown as Record<string, unknown>)[k] = v;
        }
      }
      const legacyGubun = (data as Record<string, unknown>)["구분"];
      if (!String(o.grade ?? "").trim() && legacyGubun != null && legacyGubun !== "") {
        o.grade = String(legacyGubun);
      }
      hydrateHanjaRelatedFieldsFromExtend(o);
      form.value = o;
      await fetchBasisStrokes();
    } else {
      error.value = `문서를 찾을 수 없습니다: ${id.value}`;
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "데이터 로드 실패";
  } finally {
    isLoading.value = false;
  }
}

async function persistHanjaDetail() {
  isSaving.value = true;
  try {
    if (!isFirebaseConfigured() || !auth.isAdmin) return;
    const newId = resolveHanjaBasisDocId(form.value);
    if (!newId) {
      notifications.error("문서 ID를 결정할 수 없습니다.");
      return;
    }
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const payload = { ...form.value, id: newId, _updatedAt: serverTimestamp() };
    if (newId !== id.value) {
      const batch = writeBatch(db);
      batch.delete(doc(db, "hanja_basis", id.value));
      batch.set(doc(db, "hanja_basis", newId), payload);
      await batch.commit();
      notifications.success(`이동 및 저장 완료: ${newId}`);
      void router.replace({
        name: "firestore-manage-detail",
        params: { id: newId },
      });
    } else {
      await setDoc(doc(db, "hanja_basis", id.value), payload);
      notifications.success("저장 완료");
    }
    workbench.markPending("hanja_basis");
    workbench.openWorkbenchModal();
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "저장 실패");
  } finally {
    isSaving.value = false;
  }
}

const confirmOpen = ref(false);

function openDeletionConfirmModal() {
  if (!isFirebaseConfigured() || !auth.isAdmin) return;
  confirmOpen.value = true;
}

async function executeConfirmedDeletion() {
  confirmOpen.value = false;
  isSaving.value = true;
  try {
    if (!isFirebaseConfigured() || !auth.isAdmin) return;
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    await deleteDoc(doc(db, "hanja_basis", id.value));
    notifications.success("삭제 완료");
    workbench.markPending("hanja_basis");
    workbench.openWorkbenchModal();
    void router.push({ name: "firestore-manage" });
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "삭제 실패");
  } finally {
    isSaving.value = false;
  }
}

onMounted(() => {
  void loadHanjaDetailDocument();
});
watch(
  () => routeParamAsString(route.params.id),
  (next, prev) => {
    if (!next || next === prev) return;
    void loadHanjaDetailDocument();
  },
);
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col overflow-hidden bg-surface-lowest">
    <header
      class="z-10 flex shrink-0 flex-col gap-3 border-b border-outline-variant/60 bg-surface-low px-3 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-4"
    >
      <div class="flex min-w-0 items-center gap-3">
        <button
          type="button"
          class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-onSurface-variant transition hover:bg-surface-bright hover:text-primary"
          title="목록으로"
          @click="router.push({ name: 'firestore-manage' })"
        >
          <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </button>
        <div
          class="flex h-12 w-12 shrink-0 select-none items-center justify-center overflow-hidden rounded-xl border border-primary/20 bg-surface-lowest font-hanja text-3xl font-medium text-onSurface shadow-sm"
        >
          <span>{{ isLoading ? "…" : charDisplay || "—" }}</span>
        </div>
        <h1 class="sr-only">
          <template v-if="!isLoading">
            <template v-if="charDisplay">{{ charDisplay }} · </template>{{ id }}
          </template>
          <template v-else>로딩 중</template>
        </h1>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <button
          v-if="!isLoading && !error"
          type="button"
          class="rounded-md border border-red-200/90 bg-surface-lowest px-3 py-1.5 text-xs font-medium text-red-700 transition hover:bg-red-50/80"
          :disabled="isSaving || !auth.isAdmin"
          @click="openDeletionConfirmModal"
        >
          삭제
        </button>
        <button
          type="button"
          class="btn-secondary px-3 py-1.5 text-xs"
          :disabled="isLoading"
          @click="() => void loadHanjaDetailDocument()"
        >
          새로고침
        </button>
        <RouterLink
          v-if="!isLoading && !error"
          :to="{ name: 'firestore-stroke-register', params: { id } }"
          class="btn-secondary inline-flex items-center px-3 py-1.5 text-xs no-underline"
        >
          획순 편집
        </RouterLink>
        <button
          type="button"
          class="btn-primary px-4 py-1.5 text-xs shadow-sm shadow-primary/15"
          :disabled="isSaving || isLoading || !auth.isAdmin"
          @click="persistHanjaDetail"
        >
          {{ isSaving ? "저장 중…" : "저장" }}
        </button>
      </div>
    </header>

    <div class="min-h-0 flex-1 overflow-y-auto overscroll-contain p-3 sm:p-4">
      <div
        v-if="error"
        class="mx-auto flex max-w-4xl items-center gap-3 rounded-lg border border-red-100 bg-red-50 p-4"
      >
        <svg class="h-5 w-5 shrink-0 text-red-500" fill="currentColor" viewBox="0 0 20 20">
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z"
            clip-rule="evenodd"
          />
        </svg>
        <p class="text-sm font-medium text-red-800">{{ error }}</p>
      </div>

      <div v-else-if="isLoading" class="mx-auto max-w-4xl animate-pulse space-y-6">
        <div class="h-32 rounded-xl bg-surface-low" />
        <div class="h-12 rounded-lg bg-surface-low" />
        <div class="h-64 rounded-xl bg-surface-low" />
      </div>

      <HanjaDetailViewForm
        v-else
        v-model:form="form"
        :svg-paths="svgPaths"
        :stroke-shapes="strokeShapes"
        :is-stroke-loading="isStrokeLoading"
        :word-containing-glyph="charDisplay"
        :word-containing-source="wordContainingSource"
      />
    </div>

    <ConfirmModal
      :open="confirmOpen"
      title="한자 삭제"
      :message="`'${charDisplay}' 항목을 정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.`"
      confirm-label="삭제"
      :danger="true"
      @confirm="executeConfirmedDeletion"
      @cancel="confirmOpen = false"
    />
  </div>
</template>
