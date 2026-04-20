<script setup lang="ts">
import { ref, watch } from "vue";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { isLocalApiEnabled, localApiFetch } from "@/config/localApi";
import { fetchHanjaWordsContainingGlyphFirestore } from "@/utils/fetchHanjaWordsContainingFirestore";
import type { HanjaWordTableRow } from "@/utils/fetchHanjaWordsContainingFirestore";

const props = defineProps<{
  /** 리스트에서 고른 한 자(또는 단어에 포함될 첫 글자) */
  glyph: string;
  mode: "local" | "firestore";
}>();

const rows = ref<HanjaWordTableRow[]>([]);
const isLoading = ref(false);
const error = ref<string | null>(null);
const meta = ref<{ scanned?: number; truncated?: boolean }>({});

async function loadRows() {
  const g = String(props.glyph ?? "").trim();
  rows.value = [];
  error.value = null;
  meta.value = {};
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
      const list = j.data ?? [];
      rows.value = list.map((r) => {
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

watch(
  () => [props.glyph, props.mode] as const,
  () => {
    void loadRows();
  },
  { immediate: true },
);
</script>

<template>
  <section
    class="rounded-2xl border border-outline-variant/60 bg-surface-low/40 p-4 shadow-sm sm:p-5"
  >
    <div class="flex flex-wrap items-end justify-between gap-2">
      <div>
        <p class="text-body leading-snug text-onSurface-variant">
          <span class="font-hanja font-medium text-onSurface">{{ glyph || "—" }}</span>
          가 포함된 단어/문자열 (DB내 검색자료)
        </p>
      </div>
      <button
        type="button"
        class="btn-secondary px-2.5 py-1 text-sm"
        :disabled="isLoading || !glyph.trim()"
        @click="() => void loadRows()"
      >
        다시 불러오기
      </button>
    </div>

    <p v-if="error" class="mt-3 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900">
      {{ error }}
    </p>

    <div v-else-if="isLoading" class="mt-4 text-sm text-onSurface-variant">불러오는 중…</div>

    <div v-else-if="rows.length === 0" class="mt-4 text-sm text-onSurface-variant">
      포함 단어가 없거나 아직 동기화되지 않았습니다.
    </div>

    <div v-else class="mt-4 overflow-x-auto rounded-lg border border-outline-variant/50">
      <table class="w-full min-w-[18rem] border-collapse text-left text-sm text-onSurface">
        <thead>
          <tr class="border-b border-outline-variant/70 bg-surface-low/90">
            <th class="px-2 py-2 font-semibold text-onSurface-variant">한자(단어)</th>
            <th class="px-2 py-2 font-semibold text-onSurface-variant">음</th>
            <th class="px-2 py-2 font-semibold text-onSurface-variant">의미</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-outline-variant/40">
          <tr v-for="(r, i) in rows" :key="`${r.id}-${i}`" class="hover:bg-primary/[0.04]">
            <td class="max-w-[12rem] px-2 py-1.5 font-hanja font-medium">{{ r.word }}</td>
            <td class="px-2 py-1.5 text-onSurface-variant">{{ r.reading || "—" }}</td>
            <td class="max-w-[20rem] truncate px-2 py-1.5" :title="r.meaning">{{ r.meaning || "—" }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <p
      v-if="mode === 'firestore' && meta.truncated"
      class="text-caption mt-2 text-amber-800"
    >
      일부 문서만 검사했습니다. 더 많은 단어는 DB 동기화·건수를 늘리거나 검색 한도를 조정하세요.
    </p>
  </section>
</template>
