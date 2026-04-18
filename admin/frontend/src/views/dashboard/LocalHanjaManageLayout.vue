<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { RouterView, useRoute, useRouter } from "vue-router";
import { isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useWorkbenchStore } from "@/stores/workbench";
import HanjaRegisterFormModal from "@/components/dashboard/HanjaRegisterFormModal.vue";
import HanjaSearchCard from "@/components/dashboard/HanjaSearchCard.vue";
import HanjaListCard from "@/components/dashboard/HanjaListCard.vue";
import type { HanjaListRow } from "@/utils/hanjaBasis";

type SqliteRow = {
  id: string;
  char?: string;
  reading?: string;
  meaning?: string;
  sync_status?: string;
  change_number?: number;
};

const router = useRouter();
const route = useRoute();
const auth = useAuthStore();
const workbench = useWorkbenchStore();

const canMutateBasis = computed(
  () => isFirebaseConfigured() && auth.isAuthenticated && auth.isAdmin,
);

const basisRegisterModalOpen = ref(false);

function openHanjaRegisterModal() {
  basisRegisterModalOpen.value = true;
}

async function onBasisRegisterSaved(newId: string) {
  await loadHanjaTablePage();
  workbench.markPending("hanja_basis");
  workbench.openWorkbenchModal();
  void router.push({ name: "firestore-manage-detail", params: { id: newId } });
}

const PAGE_SIZE_OPTIONS = [10, 20, 50] as const;

const rows = ref<SqliteRow[]>([]);
const totalCount = ref(0);
const currentPage = ref(1);
const pageSize = ref<(typeof PAGE_SIZE_OPTIONS)[number]>(20);
const isLoading = ref(false);

const filterGrade = ref("");
const searchDraft = ref("");
const searchApplied = ref("");

const filterActive = computed(
  () =>
    filterGrade.value !== "" ||
    searchDraft.value.trim() !== "" ||
    searchApplied.value.trim() !== "",
);

const activeRowId = computed(() => {
  const raw = route.params.id;
  return typeof raw === "string" && raw.length > 0 && raw !== "new" ? raw : null;
});

async function loadHanjaTablePage() {
  isLoading.value = true;
  try {
    const q = new URLSearchParams({
      page: String(currentPage.value),
      limit: String(pageSize.value),
    });
    const needle = searchApplied.value.trim();
    if (needle) q.set("q", needle);
    if (filterGrade.value) q.set("gubun", filterGrade.value);

    const res = await fetch(`/api/hanja?${q.toString()}`);
    const result = (await res.json()) as { data?: SqliteRow[]; total?: number };
    rows.value = result.data ?? [];
    totalCount.value = result.total ?? 0;
  } catch {
    rows.value = [];
    totalCount.value = 0;
  } finally {
    isLoading.value = false;
  }
}

const totalPages = computed(() => Math.max(1, Math.ceil(totalCount.value / pageSize.value)));

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++;
}

function prevPage() {
  if (currentPage.value > 1) currentPage.value--;
}

function runSearch() {
  searchApplied.value = searchDraft.value.trim().slice(0, 2);
  searchDraft.value = searchApplied.value;
  if (currentPage.value !== 1) currentPage.value = 1;
  void loadHanjaTablePage();
}

function clearFilters() {
  filterGrade.value = "";
  searchDraft.value = "";
  searchApplied.value = "";
  if (currentPage.value !== 1) currentPage.value = 1;
  void loadHanjaTablePage();
}

watch([currentPage, filterGrade], () => {
  void loadHanjaTablePage();
}, { immediate: true });

watch(pageSize, () => {
  if (currentPage.value !== 1) currentPage.value = 1;
  else void loadHanjaTablePage();
});

function formatSqliteSyncStatusLabel(syncStatus: string | undefined): string {
  if (syncStatus === "ADDED") return "신규";
  if (syncStatus === "MODIFIED") return "수정";
  if (syncStatus === "DELETED") return "삭제";
  return "—";
}

const listRows = computed<HanjaListRow[]>(() =>
  rows.value.map((row) => ({
    id: row.id,
    displayId: row.id,
    char: row.char ?? "",
    reading: row.reading ?? "",
    meaning: row.meaning ?? "",
    tag: formatSqliteSyncStatusLabel(row.sync_status),
  }))
);

function openRow(id: string) {
  void router.push({ name: "sqlite-detail", params: { id } });
}

onMounted(() => {
  void workbench.fetchLocalSession();
});
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col gap-4">
    <section
      class="shrink-0 rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.06] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float sm:px-4 sm:py-3"
    >
      <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex min-w-0 items-center gap-2.5">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            ⌗
          </div>
          <div class="min-w-0 flex-1">
            <h1 class="page-title">로컬 DB 관리</h1>
          </div>
        </div>
        <div class="flex flex-wrap items-center gap-2">
          <button
            type="button"
            class="btn-primary px-3 py-1.5 text-xs shadow-sm shadow-primary/15 sm:text-sm"
            :disabled="!canMutateBasis"
            title="admin 클레임·Firebase 필요 (Firestore에 등록)"
            @click="openHanjaRegisterModal"
          >
            한자 등록
          </button>
        </div>
      </div>
    </section>

    <div class="flex min-h-0 flex-1 flex-col gap-4 lg:flex-row lg:items-stretch lg:gap-5">
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

        <HanjaListCard
          :rows="listRows"
          :active-id="activeRowId"
          :is-loading="isLoading"
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-count="totalCount"
          v-model:pageSize="pageSize"
          :page-size-options="PAGE_SIZE_OPTIONS"
          @select="openRow"
          @prev="prevPage"
          @next="nextPage"
        />
      </div>

      <div
        class="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-lowest shadow-float"
      >
        <div class="flex min-h-0 flex-1 flex-col overflow-hidden">
          <RouterView />
        </div>
      </div>
    </div>

    <HanjaRegisterFormModal
      :open="basisRegisterModalOpen"
      mode="add"
      :entry="null"
      @close="basisRegisterModalOpen = false"
      @saved="onBasisRegisterSaved"
    />
  </div>
</template>
