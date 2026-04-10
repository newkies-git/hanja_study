<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { collection, doc, writeBatch } from "firebase/firestore";
import WordFormModal from "@/components/dashboard/WordFormModal.vue";
import ConfirmModal from "@/components/app/ConfirmModal.vue";
import ClipboardPastePanel from "@/components/dashboard/ClipboardPastePanel.vue";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useDataVersionStore } from "@/stores/dataVersion";
import {
  textIncludesQueryIgnoreCase,
  usePaginatedCollection,
} from "@/composables/usePaginatedCollection";

const auth = useAuthStore();
const notifications = useNotificationsStore();
const dvStore = useDataVersionStore();

// ── 검색 필터 ──────────────────────────────────────────────────────────────
const searchWord = ref("");
const searchMeaning = ref("");

const {
  PAGE_SIZE_OPTIONS,
  loadCap,
  allDocs,
  rows,
  ids,
  isLoading,
  isLoadingMore,
  error,
  filterWarning,
  hasMore,
  pageSize,
  currentPage,
  totalPages,
  totalCount,
  rangeStart,
  rangeEnd,
  paginationItems,
  loadAll,
  loadMore,
  goToPage,
  prevPage,
  nextPage,
  scheduleResetPage,
} = usePaginatedCollection(
  "hanja_word",
  ({ data }) => {
    if (
      searchWord.value &&
      !textIncludesQueryIgnoreCase(
        String(data["word_id"] ?? data["id"] ?? ""),
        searchWord.value,
      )
    )
      return false;
    if (
      searchMeaning.value &&
      !textIncludesQueryIgnoreCase(
        JSON.stringify(data),
        searchMeaning.value,
      )
    )
      return false;
    return true;
  },
  { defaultPageSize: 20 },
);

watch([searchWord, searchMeaning], () => scheduleResetPage());
watch(pageSize, () => { currentPage.value = 0; });

// ── 선택 ──────────────────────────────────────────────────────────────────

const selectedWordId = ref<string | null>(null);

const selectedCount = computed(() =>
  selectedWordId.value !== null ? 1 : 0,
);

const soleSelectedEntry = computed(() => {
  if (!selectedWordId.value) return null;
  const idx = ids.value.indexOf(selectedWordId.value);
  if (idx === -1) return null;
  return { id: ids.value[idx]!, data: rows.value[idx]! };
});

function selectCard(id: string) {
  selectedWordId.value = selectedWordId.value === id ? null : id;
}

function clearFilters() {
  searchWord.value = "";
  searchMeaning.value = "";
}

const filterActive = computed(
  () => searchWord.value !== "" || searchMeaning.value !== "",
);

const canMutateWord = computed(
  () =>
    isFirebaseConfigured() &&
    auth.isAuthenticated &&
    auth.isAdmin,
);

const canUseSelectionActions = computed(
  () => selectedCount.value === 1,
);

// ── 모달 상태 ──────────────────────────────────────────────────────────────

const wordFormOpen = ref(false);
const wordFormMode = ref<"add" | "edit">("add");
const deleteConfirmOpen = ref(false);

function openAddModal() {
  wordFormMode.value = "add";
  wordFormOpen.value = true;
}

function openEditModal() {
  if (!soleSelectedEntry.value) return;
  wordFormMode.value = "edit";
  wordFormOpen.value = true;
}

async function onWordSaved(newId: string) {
  selectedWordId.value = newId;
  await loadAll(true);
  dvStore.markPending("hanja_word");
  dvStore.openBumpModal();
}

function deleteSelected() {
  if (!canMutateWord.value || !selectedWordId.value) return;
  deleteConfirmOpen.value = true;
}

async function confirmDelete() {
  deleteConfirmOpen.value = false;
  const toDelete = selectedWordId.value;
  if (!toDelete || !isFirebaseConfigured()) {
    error.value = "Firebase가 설정되지 않았습니다.";
    return;
  }
  isLoading.value = true;
  error.value = null;
  try {
    await auth.syncIdTokenForFirestore();
    const db = getFirestoreDb();
    const batch = writeBatch(db);
    batch.delete(doc(collection(db, "hanja_word"), toDelete));
    await batch.commit();
    notifications.success(`hanja_word 삭제 완료: ${toDelete}`);
    selectedWordId.value = null;
    await loadAll(true);
    dvStore.markPending("hanja_word");
    dvStore.openBumpModal();
  } catch (e) {
    const msg = e instanceof Error ? e.message : "삭제에 실패했습니다.";
    error.value = msg;
    notifications.error(msg);
  } finally {
    isLoading.value = false;
  }
}

async function onPasteSaved() {
  await loadAll(true);
  dvStore.markPending("hanja_word");
  dvStore.openBumpModal();
}

const existingWordIds = computed(() => allDocs.value.map((d) => d.id));

function resolveWordDocId(row: Record<string, string>): string | null {
  const id = (row["word_id"] ?? row["id"] ?? "").trim();
  return id || null;
}

// ── 표시할 컬럼 목록 (동적이므로 최대 10개만 표시) ──────────────────────

function getDisplayValue(data: Record<string, unknown>, key: string): string {
  const v = data[key];
  if (v === null || v === undefined) return "—";
  if (typeof v === "object") return JSON.stringify(v).slice(0, 60);
  return String(v).slice(0, 80);
}

// 전체 allDocs에서 나타나는 필드 종류 수집 (상위 10개)
const knownWordFields = computed<string[]>(() => {
  const freq = new Map<string, number>();
  for (const d of allDocs.value.slice(0, 200)) {
    for (const k of Object.keys(d.data)) {
      if (!k.startsWith("_")) freq.set(k, (freq.get(k) ?? 0) + 1);
    }
  }
  return [...freq.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 12)
    .map(([k]) => k);
});

onMounted(() => { void loadAll(); });
</script>

<template>
  <div class="space-y-4">
    <!-- 페이지 헤더 -->
    <section>
      <div
        class="overflow-hidden rounded-2xl border border-outline-variant/80 bg-gradient-to-br from-surface-lowest via-surface-low to-surface-low/80 p-4 shadow-[0_8px_32px_rgba(25,28,30,0.07)] sm:p-5"
      >
        <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p class="text-[10px] font-semibold uppercase tracking-[0.14em] text-primary/80">
              Firestore
            </p>
            <h1 class="font-display text-xl font-bold tracking-tight text-onSurface sm:text-2xl">
              단어·성어 관리
            </h1>
            <p class="mt-0.5 text-sm text-onSurface-variant">
              <code class="rounded bg-surface-low px-1.5 py-0.5 font-mono text-xs">hanja_word</code>
              컬렉션 CRUD
            </p>
          </div>
          <div class="flex shrink-0 flex-wrap items-center gap-2">
            <span
              v-if="totalCount > 0"
              class="inline-flex items-center rounded-full border border-outline-variant/70 bg-surface-lowest/90 px-2 py-0.5 text-[11px] font-medium text-onSurface"
            >
              필터 결과 <span class="ml-0.5 tabular-nums text-primary">{{ totalCount.toLocaleString("ko-KR") }}</span>건
            </span>
            <span
              v-if="selectedCount > 0"
              class="inline-flex items-center rounded-full border border-primary/25 bg-primary/[0.1] px-2 py-0.5 text-[11px] font-semibold text-primary"
            >
              {{ selectedCount }}건 선택
            </span>
          </div>
        </div>

        <!-- 액션 버튼 -->
        <div class="mt-3 flex flex-wrap items-center gap-2">
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="isLoading || !canMutateWord"
            @click="openAddModal"
          >
            추가
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="!canMutateWord || !canUseSelectionActions"
            @click="openEditModal"
          >
            수정
          </button>
          <button
            type="button"
            class="rounded-md border border-red-300/90 bg-surface-low px-3 py-1.5 text-xs font-medium text-red-800 transition hover:bg-red-50/80 disabled:cursor-not-allowed disabled:opacity-50 sm:text-sm"
            :disabled="isLoading || !canMutateWord || selectedCount === 0"
            @click="deleteSelected"
          >
            삭제
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
            :disabled="isLoading"
            @click="() => void loadAll()"
          >
            새로고침
          </button>
          <ClipboardPastePanel
            collection-name="hanja_word"
            :known-fields="knownWordFields"
            :resolve-doc-id="resolveWordDocId"
            :existing-ids="existingWordIds"
            :can-mutate="canMutateWord"
            @saved="onPasteSaved"
          />
        </div>
      </div>
    </section>

    <!-- admin 경고 -->
    <div
      v-if="isFirebaseConfigured() && auth.isAuthReady && auth.isAuthenticated && !auth.isAdmin"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-2.5 text-xs text-amber-950 shadow-sm"
    >
      <strong class="font-medium">admin</strong> 클레임이 있어야
      <strong class="font-medium">추가·수정·삭제</strong>가 가능합니다.
    </div>

    <!-- 필터 -->
    <div class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4">
      <div class="flex flex-col gap-3 sm:flex-row sm:flex-wrap sm:items-end sm:gap-3">
        <h2 class="text-sm font-semibold text-onSurface sm:shrink-0 sm:self-center">검색</h2>
        <div class="flex min-w-0 flex-col sm:w-48">
          <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">word_id</label>
          <input
            v-model="searchWord"
            type="search"
            class="input-minimal w-full py-1.5 text-sm"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div class="flex min-w-0 flex-col sm:w-48">
          <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">전체 필드</label>
          <input
            v-model="searchMeaning"
            type="search"
            class="input-minimal w-full py-1.5 text-sm"
            placeholder="부분 일치"
            autocomplete="off"
          />
        </div>
        <div class="flex min-w-0 flex-col sm:w-[5.25rem] sm:shrink-0">
          <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">페이지당</label>
          <select v-model="pageSize" class="input-minimal w-full cursor-pointer py-1.5 text-sm">
            <option v-for="n in PAGE_SIZE_OPTIONS" :key="n" :value="n">{{ n }}건</option>
          </select>
        </div>
        <button
          type="button"
          class="btn-secondary self-end py-2 text-xs sm:py-1.5 sm:text-sm"
          :disabled="!filterActive"
          @click="clearFilters"
        >
          초기화
        </button>
      </div>
    </div>

    <!-- 경고 / 에러 / 로딩 -->
    <div
      v-if="filterWarning"
      class="space-y-3 rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950 shadow-sm"
    >
      <p class="leading-relaxed">{{ filterWarning }}</p>
      <button
        v-if="hasMore"
        type="button"
        class="btn-secondary text-xs sm:text-sm"
        :disabled="isLoadingMore || isLoading"
        @click="loadMore"
      >
        {{ isLoadingMore ? "불러오는 중…" : `다음 ${loadCap.toLocaleString("ko-KR")}건 불러오기` }}
      </button>
    </div>
    <div
      v-if="error"
      class="flex items-start justify-between gap-3 rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3 text-sm text-red-900 shadow-sm"
    >
      <span>{{ error }}</span>
      <button
        type="button"
        class="shrink-0 rounded-md border border-red-300/80 bg-white/70 px-2.5 py-1 text-xs font-medium text-red-900 transition hover:bg-white disabled:opacity-50"
        :disabled="isLoading"
        @click="() => void loadAll(true)"
      >
        재시도
      </button>
    </div>
    <div
      v-else-if="isLoading"
      class="flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-outline-variant/80 bg-surface-low/50 py-16"
    >
      <div class="flex gap-1.5" aria-hidden="true">
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
      </div>
      <p class="text-sm font-medium text-onSurface-variant">hanja_word 불러오는 중…</p>
    </div>
    <div
      v-else-if="!isLoading && !allDocs.length"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">아직 문서가 없습니다</p>
      <p class="mt-2 text-sm text-onSurface-variant">
        한자 마스터 등록 4단계에서 JSON을 업로드하거나 위 「추가」·「클립보드 붙여넣기」를 사용하세요.
      </p>
    </div>
    <div
      v-else-if="!isLoading && allDocs.length && !totalCount"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">필터와 일치하는 항목이 없습니다</p>
    </div>

    <!-- 테이블 -->
    <div
      v-if="rows.length"
      class="overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-lowest shadow-[0_8px_32px_rgba(25,28,30,0.07)] ring-1 ring-black/[0.02]"
    >
      <div class="overflow-x-auto">
        <table class="w-full min-w-[36rem] text-left text-sm">
          <thead>
            <tr class="border-b border-outline-variant/60 bg-surface-low/70">
              <th class="w-8 px-3 py-2.5" />
              <th class="px-3 py-2.5 font-semibold text-onSurface-variant">word_id</th>
              <th
                v-for="col in knownWordFields.filter((c) => c !== 'word_id' && c !== 'id').slice(0, 5)"
                :key="col"
                class="px-3 py-2.5 font-semibold text-onSurface-variant"
              >
                {{ col }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(row, i) in rows"
              :key="ids[i]"
              class="cursor-pointer border-b border-outline-variant/30 transition last:border-0 hover:bg-surface-low/50"
              :class="selectedWordId === ids[i] ? 'bg-primary/[0.06] ring-1 ring-inset ring-primary/15' : ''"
              @click="selectCard(ids[i]!)"
            >
              <td class="px-3 py-2.5">
                <span
                  class="flex h-4 w-4 items-center justify-center rounded-full border-2 transition"
                  :class="
                    selectedWordId === ids[i]
                      ? 'border-primary bg-primary'
                      : 'border-outline-variant/60'
                  "
                  aria-hidden="true"
                >
                  <span
                    v-if="selectedWordId === ids[i]"
                    class="h-1.5 w-1.5 rounded-full bg-white"
                  />
                </span>
              </td>
              <td class="px-3 py-2.5 font-mono text-xs font-semibold text-primary">
                {{ ids[i] }}
              </td>
              <td
                v-for="col in knownWordFields.filter((c) => c !== 'word_id' && c !== 'id').slice(0, 5)"
                :key="col"
                class="max-w-[12rem] truncate px-3 py-2.5 text-xs text-onSurface"
              >
                {{ getDisplayValue(row, col) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- 페이지네이션 -->
      <div
        v-if="totalPages > 1"
        class="flex items-center justify-between gap-3 border-t border-outline-variant/50 px-4 py-3"
      >
        <p class="text-xs text-onSurface-variant">
          {{ rangeStart.toLocaleString("ko-KR") }}–{{ rangeEnd.toLocaleString("ko-KR") }}
          / {{ totalCount.toLocaleString("ko-KR") }}건
        </p>
        <div class="flex items-center gap-1">
          <button
            type="button"
            class="rounded-md px-2 py-1 text-xs text-onSurface-variant transition hover:bg-surface-low disabled:opacity-40"
            :disabled="currentPage === 0"
            @click="prevPage"
          >
            ←
          </button>
          <template v-for="(item, i) in paginationItems" :key="i">
            <span v-if="item === 'ellipsis'" class="px-1 text-xs text-onSurface-variant">…</span>
            <button
              v-else
              type="button"
              class="rounded-md px-2.5 py-1 text-xs font-medium transition"
              :class="
                item - 1 === currentPage
                  ? 'bg-primary text-white'
                  : 'text-onSurface-variant hover:bg-surface-low'
              "
              @click="goToPage(item - 1)"
            >
              {{ item }}
            </button>
          </template>
          <button
            type="button"
            class="rounded-md px-2 py-1 text-xs text-onSurface-variant transition hover:bg-surface-low disabled:opacity-40"
            :disabled="currentPage >= totalPages - 1"
            @click="nextPage"
          >
            →
          </button>
        </div>
      </div>
    </div>

    <!-- 모달 -->
    <WordFormModal
      :open="wordFormOpen"
      :mode="wordFormMode"
      :entry="wordFormMode === 'edit' ? soleSelectedEntry : null"
      @close="wordFormOpen = false"
      @saved="onWordSaved"
    />
    <ConfirmModal
      :open="deleteConfirmOpen"
      title="단어 삭제"
      :message="`'${selectedWordId}'를 hanja_word에서 삭제합니다. 되돌릴 수 없습니다.`"
      confirm-label="삭제"
      :danger="true"
      @confirm="confirmDelete"
      @cancel="deleteConfirmOpen = false"
    />
  </div>
</template>
