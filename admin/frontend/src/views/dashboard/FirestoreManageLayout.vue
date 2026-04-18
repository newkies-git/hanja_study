<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { RouterLink, RouterView, useRoute, useRouter } from "vue-router";
import HanjaRegisterFormModal from "@/components/dashboard/HanjaRegisterFormModal.vue";
import HanjaSearchCard from "@/components/dashboard/HanjaSearchCard.vue";
import HanjaListCard from "@/components/dashboard/HanjaListCard.vue";
import { isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useWorkbenchStore } from "@/stores/workbench";
import {
  textIncludesQueryIgnoreCase,
  usePaginatedCollection,
} from "@/composables/usePaginatedCollection";
import { sliceGraphemes } from "@/utils/hanjaBasis";
import type { HanjaListRow } from "@/utils/hanjaBasis";

const auth = useAuthStore();
const workbench = useWorkbenchStore();
const router = useRouter();
const route = useRoute();

const filterGrade = ref<string>("");
/** 입력란(placeholder). 실제 필터는 「검색」 시 `searchApplied`에 반영 */
const searchDraft = ref("");
const searchApplied = ref("");

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
  loadAll,
  loadMore,
  prevPage,
  nextPage,
} = usePaginatedCollection("hanja_basis", (entry) => {
  const { data, id } = entry;
  if (
    filterGrade.value !== "" &&
    String(data["grade"] ?? data["구분"] ?? "").trim() !== filterGrade.value
  )
    return false;
  const q = searchApplied.value.trim();
  if (!q) return true;
  const 한자 = String(data["한자"] ?? "");
  const 음 = String(data["음"] ?? "");
  const 획 = String(data["stroke_count"] ?? "");
  const idStr = String(id ?? "");
  return (
    textIncludesQueryIgnoreCase(한자, q) ||
    textIncludesQueryIgnoreCase(음, q) ||
    textIncludesQueryIgnoreCase(획, q) ||
    textIncludesQueryIgnoreCase(idStr, q)
  );
});

watch(filterGrade, () => {
  currentPage.value = 0;
});
watch(pageSize, () => {
  currentPage.value = 0;
});

const filterActive = computed(
  () =>
    filterGrade.value !== "" ||
    searchDraft.value.trim() !== "" ||
    searchApplied.value.trim() !== "",
);

function runSearch() {
  searchApplied.value = searchDraft.value.trim().slice(0, 2);
  searchDraft.value = searchApplied.value;
  currentPage.value = 0;
}

function basisDisplayId(docId: string, row: Record<string, unknown>): string {
  const hanja = String(row["한자"] ?? "").trim();
  const source = hanja || docId;
  const cp = source.codePointAt(0);
  if (cp === undefined) return docId;
  return `H${cp.toString(16).toUpperCase()}`;
}

function clearFilters() {
  filterGrade.value = "";
  searchDraft.value = "";
  searchApplied.value = "";
  currentPage.value = 0;
}

const activeDocId = computed(() => {
  const raw = route.params.id;
  return typeof raw === "string" && raw.length > 0 ? raw : null;
});

const canMutateBasis = computed(
  () => isFirebaseConfigured() && auth.isAuthenticated && auth.isAdmin,
);

const basisFormModalOpen = ref(false);

function openBasisAddModal() {
  basisFormModalOpen.value = true;
}

async function onBasisSaved(newId: string) {
  await loadAll(true);
  workbench.markPending("hanja_basis");
  workbench.openWorkbenchModal();
  void router.push({ name: "firestore-manage-detail", params: { id: newId } });
}

function openRowDetail(docId: string) {
  void router.push({ name: "firestore-manage-detail", params: { id: docId } });
}

/** 목록 하단 페이지 표시용(1부터, sqlite와 동일 문구) */
const listPageDisplay = computed(() => currentPage.value + 1);

const listRows = computed<HanjaListRow[]>(() =>
  rows.value.map((row, i) => ({
    id: ids.value[i]!,
    displayId: basisDisplayId(ids.value[i]!, row),
    char: String(row["한자"] ?? ""),
    reading: String(row["음"] ?? ""),
    meaning: String(row["훈"] ?? ""),
    tag: sliceGraphemes(String(row["grade"] ?? row["구분"] ?? "").trim(), 2) || "—",
  }))
);

onMounted(() => {
  void loadAll();
});
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col gap-4">
    <section
      class="relative shrink-0 overflow-visible rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute inset-0 overflow-hidden rounded-xl"
        aria-hidden="true"
      >
        <div class="absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl" />
      </div>
      <div
        class="relative flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between sm:gap-3"
      >
        <div class="flex min-w-0 items-center gap-2.5 sm:gap-3">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            基
          </div>
          <h1 class="page-title min-w-0">서버DB 관리</h1>
        </div>
        <div class="flex flex-wrap gap-2 sm:shrink-0 sm:justify-end">
          <button
            type="button"
            class="btn-secondary min-h-[2.75rem] px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
            :disabled="isLoading || !canMutateBasis"
            title="admin 클레임·로그인 필요"
            @click="openBasisAddModal"
          >
            한자 등록
          </button>
          <button
            type="button"
            class="btn-secondary min-h-[2.75rem] px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
            :disabled="isLoading"
            @click="() => void loadAll()"
          >
            새로고침
          </button>
        </div>
      </div>
    </section>

    <div
      class="flex min-h-0 flex-1 flex-col gap-4 lg:flex-row lg:items-stretch lg:gap-5"
    >
      <!-- 좌: 목록 -->
      <div
        class="flex min-h-0 w-full min-w-0 shrink-0 flex-col gap-3 lg:w-[min(100%,24rem)] lg:max-w-[24rem]"
      >
        <HanjaSearchCard
          v-model="searchDraft"
          v-model:segment="filterGrade"
          show-hanja-segment-filter
          :filter-active="filterActive"
          @search="runSearch"
          @clear="clearFilters"
        />

        <div class="flex flex-col gap-2">
          <div
            v-if="isFirebaseConfigured() && auth.isAuthReady && auth.isAuthenticated && !auth.isAdmin"
            class="shrink-0 rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-xs text-amber-950"
          >
            <strong class="font-medium">admin</strong> 클레임이 있어야
            <strong class="font-medium">한자 등록</strong>이 가능합니다.
          </div>
          <div
            v-if="filterWarning"
            class="shrink-0 space-y-2 rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-xs text-amber-950"
          >
            <p class="leading-relaxed">{{ filterWarning }}</p>
            <button
              v-if="hasMore"
              type="button"
              class="btn-secondary text-xs"
              :disabled="isLoadingMore || isLoading"
              @click="loadMore"
            >
              {{ isLoadingMore ? "불러오는 중…" : `다음 ${loadCap.toLocaleString("ko-KR")}건 불러오기` }}
            </button>
          </div>
          <div
            v-if="error"
            class="flex shrink-0 items-start justify-between gap-2 rounded-lg border border-red-200/90 bg-red-50/90 px-3 py-2 text-xs text-red-900"
          >
            <span>{{ error }}</span>
            <button
              type="button"
              class="shrink-0 rounded border border-red-300/80 bg-white/70 px-2 py-1 text-[11px] font-medium"
              :disabled="isLoading"
              @click="() => void loadAll(true)"
            >
              재시도
            </button>
          </div>
        </div>

        <HanjaListCard
          :rows="listRows"
          :active-id="activeDocId"
          :is-loading="isLoading"
          :current-page="listPageDisplay"
          :total-pages="totalPages"
          :total-count="totalCount"
          v-model:pageSize="pageSize"
          :page-size-options="PAGE_SIZE_OPTIONS"
          @select="openRowDetail"
          @prev="prevPage"
          @next="nextPage"
        >
          <template #empty>
            <template v-if="!allDocs.length">
              <p class="font-medium text-onSurface">아직 문서가 없습니다</p>
              <p class="mt-2 text-xs">
                <RouterLink
                  :to="{ name: 'sqlite-manage' }"
                  class="font-medium text-primary underline decoration-primary/30 underline-offset-2"
                >로컬 DB 관리</RouterLink>
                에서 한자를 편집하거나 동기화하세요.
              </p>
            </template>
            <p v-else>검색 결과가 없습니다.</p>
          </template>
        </HanjaListCard>
      </div>

      <!-- 우: 상세 -->
      <div
        class="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-lowest shadow-float"
      >
        <div class="flex min-h-0 flex-1 flex-col overflow-hidden">
          <RouterView />
        </div>
      </div>
    </div>

    <HanjaRegisterFormModal
      :open="basisFormModalOpen"
      mode="add"
      :entry="null"
      @close="basisFormModalOpen = false"
      @saved="onBasisSaved"
    />

  </div>
</template>
