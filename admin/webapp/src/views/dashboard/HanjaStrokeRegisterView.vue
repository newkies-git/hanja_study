<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { RouterLink, useRoute, useRouter } from "vue-router";
import { doc, getDoc, serverTimestamp, setDoc } from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import HanjaDetailTabStrokes from "@/components/dashboard/HanjaDetailTabStrokes.vue";
import { glyphFromHanjaBasisDocId } from "@/utils/hanjaBasis";
import type { HanjaStrokeFileShape, StrokeOutlineEntry } from "@/types/hanjaStrokeFile";
import {
  emptyHanjaStrokeFileShape,
  normalizeStrokeBundle,
  extractFontOutlineStrings,
  ensureStrokeOutlinesMatchFileShape,
} from "@/types/hanjaStrokeFile";

const props = withDefaults(
  defineProps<{
    /** 모달 등 라우트 없이 쓸 때 `hanja_stroke` 문서 ID (예: H67B6) */
    embedDocumentId?: string | null;
    /** true면 전용 페이지용 헤더·ID 입력란을 숨깁니다 */
    embedded?: boolean;
  }>(),
  { embedDocumentId: null, embedded: false },
);

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const notifications = useNotificationsStore();

const routeId = computed(() => {
  const raw = route.params.id;
  return typeof raw === "string" && raw.trim().length > 0 ? raw.trim() : "";
});

const documentId = computed(() => {
  if (props.embedded && props.embedDocumentId?.trim()) return props.embedDocumentId.trim();
  return routeId.value;
});

const draftDocId = ref("");
const strokeBundleJsonText = ref("");
const basisGlyph = ref("");
const basisMissing = ref(false);
const isLoading = ref(false);
const isSaving = ref(false);
const error = ref<string | null>(null);

const bundleParse = computed(() => {
  try {
    const raw = JSON.parse(strokeBundleJsonText.value || "{}");
    return normalizeStrokeBundle(raw);
  } catch {
    return { ok: false as const, message: "JSON 문법이 올바르지 않습니다." };
  }
});

const previewSvgPaths = computed(() =>
  bundleParse.value.ok ? bundleParse.value.data.font_outline : [],
);

function radicalNumberFromFirestore(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const n = Number(value);
    if (Number.isFinite(n)) return n;
  }
  return 0;
}

function coerceStrokeOutlines(
  raw: unknown,
  fontOutline: string[],
  rootRadical: number,
): StrokeOutlineEntry[] {
  if (!Array.isArray(raw) || raw.length === 0) {
    return fontOutline.length > 0
      ? ensureStrokeOutlinesMatchFileShape({
          char: "",
          radical: rootRadical,
          font_outline: fontOutline,
          stroke_outlines: [],
        }).stroke_outlines
      : [];
  }
  const out: StrokeOutlineEntry[] = [];
  for (const item of raw) {
    if (!item || typeof item !== "object") continue;
    const it = item as Record<string, unknown>;
    const order = Number(it.order);
    const path = String(it.path ?? "").trim();
    const radical = radicalNumberFromFirestore(it.radical);
    if (!Number.isFinite(order) || !path) continue;
    out.push({
      order,
      path,
      radical: Number.isFinite(radical) ? radical : rootRadical,
    });
  }
  out.sort((a, b) => a.order - b.order);
  return out;
}

function fileShapeFromFirestore(
  sd: Record<string, unknown>,
  defaultChar: string,
): HanjaStrokeFileShape {
  const rootRadical = radicalNumberFromFirestore(sd.radical);
  const font_outline = extractFontOutlineStrings(sd);
  const stroke_outlines = coerceStrokeOutlines(
    sd.stroke_outlines,
    font_outline,
    rootRadical,
  );
  const char = String(sd.char_str ?? defaultChar).trim();
  return {
    char: char || defaultChar,
    radical: rootRadical,
    font_outline,
    stroke_outlines,
  };
}

function openDoc() {
  const id = draftDocId.value.trim();
  if (!id) {
    notifications.error("문서 ID를 입력하세요. (예: H4E00)");
    return;
  }
  void router.push({ name: "firestore-stroke-register", params: { id } });
}

async function loadStrokeDocument() {
  const id = documentId.value;
  if (!id || !isFirebaseConfigured()) {
    isLoading.value = false;
    return;
  }
  isLoading.value = true;
  error.value = null;
  basisMissing.value = false;
  try {
    const db = getFirestoreDb();
    const basisSnap = await getDoc(doc(db, "hanja_basis", id));
    let defaultChar = "";
    if (basisSnap.exists()) {
      const bd = basisSnap.data();
      const hj = String(bd["한자"] ?? "").trim();
      defaultChar = hj ? ([...hj][0] ?? "") : "";
      basisGlyph.value = defaultChar || glyphFromHanjaBasisDocId(id);
    } else {
      basisMissing.value = true;
      basisGlyph.value = glyphFromHanjaBasisDocId(id);
    }

    const stSnap = await getDoc(doc(db, "hanja_stroke", id));
    let shape: HanjaStrokeFileShape;
    if (stSnap.exists()) {
      shape = fileShapeFromFirestore(stSnap.data() as Record<string, unknown>, defaultChar);
    } else {
      shape = emptyHanjaStrokeFileShape(defaultChar);
    }
    strokeBundleJsonText.value = JSON.stringify(shape, null, 2);
  } catch (e) {
    error.value = e instanceof Error ? e.message : "로드 실패";
  } finally {
    isLoading.value = false;
  }
}

watch(
  documentId,
  (id) => {
    if (!id) {
      isLoading.value = false;
      return;
    }
    if (!props.embedded) draftDocId.value = id;
    void loadStrokeDocument();
  },
  { immediate: true },
);

async function saveStrokeDocument() {
  const id = documentId.value;
  if (!id) {
    notifications.error("문서 ID가 있어야 저장할 수 있습니다.");
    return;
  }
  const parsed = bundleParse.value;
  if (!parsed.ok) {
    notifications.error(parsed.message);
    return;
  }
  let data = parsed.data;
  if (data.stroke_outlines.length === 0 && data.font_outline.length > 0) {
    data = ensureStrokeOutlinesMatchFileShape(data);
  }
  if (!data.char.trim()) {
    notifications.error('"char"를 비우지 마세요. 한 글자(예: 架)를 넣으세요.');
    return;
  }

  isSaving.value = true;
  try {
    if (!isFirebaseConfigured() || !auth.isAdmin) {
      notifications.error("Firebase 설정 또는 admin 권한이 필요합니다.");
      return;
    }
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const font_outline = data.font_outline;
    await setDoc(
      doc(db, "hanja_stroke", id),
      {
        char_str: data.char.trim(),
        radical: data.radical,
        font_outline,
        stroke_outlines: data.stroke_outlines,
        svg_paths: font_outline,
        _updatedAt: serverTimestamp(),
      },
      { merge: true },
    );
    notifications.success(`hanja_stroke 저장 완료: ${id}`);
    strokeBundleJsonText.value = JSON.stringify(data, null, 2);
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "저장 실패");
  } finally {
    isSaving.value = false;
  }
}
</script>

<template>
  <div :class="embedded ? 'space-y-4' : 'mx-auto max-w-3xl space-y-6'">
    <template v-if="!embedded">
      <header class="space-y-1">
        <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/90">
          Firestore · hanja_stroke
        </p>
        <h1 class="page-title text-xl sm:text-2xl">획순 등록</h1>
        <p class="text-sm text-onSurface-variant">
          입력 형식은 로컬 데이터와 동일하게
          <code class="rounded bg-surface-low px-1 py-0.5 font-mono text-xs">admin/data/架.json</code>
          과 같습니다.
          (<code class="font-mono text-[11px]">char</code>,
          <code class="font-mono text-[11px]">radical</code>,
          <code class="font-mono text-[11px]">font_outline</code>,
          <code class="font-mono text-[11px]">stroke_outlines</code>)
        </p>
        <p class="text-xs text-onSurface-variant">
          문서 ID는 <span class="font-mono">hanja_basis</span>와 같은 <span class="font-mono">H+16진</span>입니다.
          저장 시 <span class="font-mono">char</span> → <span class="font-mono">char_str</span>,
          <span class="font-mono">font_outline</span> → <span class="font-mono">svg_paths</span>로도 맞춥니다.
        </p>
      </header>
    </template>
    <template v-else>
      <p class="text-[10px] font-semibold uppercase tracking-[0.12em] text-onSurface-variant">
        hanja_stroke
        <span v-if="documentId" class="font-mono text-primary">· {{ documentId }}</span>
      </p>
    </template>

    <div
      v-if="!isFirebaseConfigured()"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950"
    >
      Firebase가 설정되지 않았습니다.
    </div>

    <div
      v-else-if="!embedded && !documentId"
      class="rounded-xl border border-outline-variant/80 bg-surface-lowest p-5 shadow-float"
    >
      <label class="mb-2 block text-sm font-medium text-onSurface">문서 ID</label>
      <div class="flex flex-col gap-3 sm:flex-row sm:items-end">
        <input
          v-model="draftDocId"
          type="text"
          class="input-minimal min-w-0 flex-1 font-mono text-sm"
          placeholder="예: H67B6 (架)"
          autocomplete="off"
          @keydown.enter.prevent="openDoc"
        />
        <button type="button" class="btn-primary shrink-0 px-4 py-2 text-sm" @click="openDoc">
          열기
        </button>
      </div>
      <p class="mt-3 text-xs text-onSurface-variant">
        한자 상세의 <span class="font-medium text-onSurface">획순 편집</span>으로 이 화면에 올 수 있습니다.
      </p>
    </div>

    <template v-else-if="documentId">
      <div
        v-if="basisMissing"
        class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950"
      >
        <code class="font-mono">{{ documentId }}</code>에 해당하는
        <strong class="font-medium">hanja_basis</strong> 문서가 없습니다. JSON만 저장할 수 있습니다.
      </div>

      <div
        v-if="error"
        class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3 text-sm text-red-900"
      >
        {{ error }}
      </div>

      <div v-if="isLoading" class="animate-pulse space-y-4">
        <div class="h-24 rounded-xl bg-surface-low" />
        <div class="h-48 rounded-xl bg-surface-low" />
      </div>

      <div v-else class="space-y-6">
        <div
          v-if="!embedded"
          class="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-outline-variant/80 bg-surface-lowest px-4 py-3 shadow-sm"
        >
          <div class="flex min-w-0 items-center gap-3">
            <div
              class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-primary/20 bg-surface-low font-hanja text-2xl font-medium text-onSurface"
            >
              {{ basisGlyph || "—" }}
            </div>
            <div class="min-w-0">
              <p class="truncate font-mono text-sm font-semibold text-primary">{{ documentId }}</p>
              <p class="text-xs text-onSurface-variant">hanja_stroke / {{ documentId }}</p>
            </div>
          </div>
          <div class="flex flex-wrap gap-2">
            <RouterLink
              :to="{ name: 'firestore-manage-detail', params: { id: documentId } }"
              class="btn-secondary px-3 py-2 text-xs sm:text-sm"
            >
              한자 상세
            </RouterLink>
            <RouterLink to="/firestore/stroke-register" class="btn-secondary px-3 py-2 text-xs sm:text-sm">
              다른 ID
            </RouterLink>
          </div>
        </div>

        <div
          v-if="!bundleParse.ok"
          class="rounded-xl border border-amber-200/80 bg-amber-50/80 px-4 py-3 text-sm text-amber-950"
        >
          {{ bundleParse.message }}
        </div>

        <div :class="embedded ? 'grid gap-4 lg:grid-cols-2' : 'grid gap-6 lg:grid-cols-2'">
          <div class="space-y-4">
            <div class="rounded-xl border border-outline-variant/80 bg-surface-lowest p-4 shadow-float">
              <label class="mb-2 block text-sm font-medium text-onSurface">
                획 JSON (<code class="font-mono text-xs">架.json</code> 형태)
              </label>
              <textarea
                v-model="strokeBundleJsonText"
                :rows="embedded ? 16 : 22"
                class="input-minimal w-full resize-y font-mono text-[11px] leading-relaxed"
                spellcheck="false"
              />
              <p class="mt-2 text-xs text-onSurface-variant">
                <code class="font-mono">stroke_outlines</code>는
                <code class="font-mono">{ "order", "path", "radical" }</code> 객체의 배열입니다.
                <code class="font-mono">font_outline</code>만 채우고 <code class="font-mono">stroke_outlines</code>를
                비워 두면 저장 시 획마다 동일 <code class="font-mono">path</code>·루트
                <code class="font-mono">radical</code>로 채웁니다.
              </p>
            </div>

            <div class="flex flex-wrap justify-end gap-2">
              <button
                type="button"
                class="btn-secondary px-4 py-2 text-sm"
                :disabled="isSaving || isLoading"
                @click="() => void loadStrokeDocument()"
              >
                되돌리기
              </button>
              <button
                type="button"
                class="btn-primary px-4 py-2 text-sm shadow-md shadow-primary/15"
                :disabled="isSaving || isLoading || !auth.isAdmin || !bundleParse.ok"
                @click="saveStrokeDocument"
              >
                {{ isSaving ? "저장 중…" : "Firestore에 저장" }}
              </button>
            </div>
            <p v-if="!auth.isAdmin" class="text-center text-xs text-amber-800">
              <strong class="font-medium">admin</strong> 클레임이 있어야 저장할 수 있습니다.
            </p>
          </div>

          <div>
            <p class="mb-3 text-sm font-medium text-onSurface">미리보기</p>
            <HanjaDetailTabStrokes
              :svg-paths="previewSvgPaths"
              :stroke-shapes="[]"
              :is-stroke-loading="false"
            />
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
