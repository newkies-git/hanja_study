<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import { collection, doc, writeBatch } from "firebase/firestore";
import ExtendLookupModal from "@/components/dashboard/ExtendLookupModal.vue";
import StrokeModal from "@/components/dashboard/StrokeModal.vue";
import BasisFormModal from "@/components/dashboard/BasisFormModal.vue";
import ConfirmModal from "@/components/app/ConfirmModal.vue";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import {
  textIncludesQueryIgnoreCase,
  usePaginatedCollection,
} from "@/composables/usePaginatedCollection";

const auth = useAuthStore();
const notifications = useNotificationsStore();

// 필터 ref
const filter구분 = ref<string>("");
const search한자 = ref("");
const search음 = ref("");
const search훈 = ref("");

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
} = usePaginatedCollection("hanja_basis", ({ data }) => {
  if (filter구분.value !== "" && String(data["구분"] ?? "").trim() !== filter구분.value)
    return false;
  if (!textIncludesQueryIgnoreCase(String(data["한자"] ?? ""), search한자.value)) return false;
  if (!textIncludesQueryIgnoreCase(String(data["음"] ?? ""), search음.value)) return false;
  if (!textIncludesQueryIgnoreCase(String(data["훈"] ?? ""), search훈.value)) return false;
  return true;
});

watch([search한자, search음, search훈], () => scheduleResetPage());
watch(filter구분, () => { currentPage.value = 0; });
watch(pageSize, () => { currentPage.value = 0; });

const filterActive = computed(
  () =>
    filter구분.value !== "" ||
    search한자.value.trim() !== "" ||
    search음.value.trim() !== "" ||
    search훈.value.trim() !== "",
);

function basisDisplayId(docId: string, row: Record<string, unknown>): string {
  const hanja = String(row["한자"] ?? "").trim();
  const source = hanja || docId;
  const cp = source.codePointAt(0);
  if (cp === undefined) return docId;
  return `H${cp.toString(16).toUpperCase()}`;
}

function basisTileFooterCaption(row: Record<string, unknown>): string {
  const hanja = String(row["한자"] ?? "").trim() || "—";
  const hunEum = String(row["훈음"] ?? "").trim();
  if (hunEum) return `${hanja} (${hunEum})`;
  const hun = String(row["훈"] ?? "").trim();
  const eum = String(row["음"] ?? "").trim();
  const inner = [hun, eum].filter(Boolean).join(" ").trim();
  if (inner) return `${hanja} (${inner})`;
  return hanja;
}

function clearFilters() {
  filter구분.value = "";
  search한자.value = "";
  search음.value = "";
  search훈.value = "";
  currentPage.value = 0;
}

// 선택
const selectedBasisDocId = ref<string | null>(null);

function selectBasisCard(docId: string) {
  selectedBasisDocId.value = selectedBasisDocId.value === docId ? null : docId;
}

const soleSelectedEntry = computed(() => {
  const id = selectedBasisDocId.value;
  if (!id) return null;
  return allDocs.value.find((d) => d.id === id) ?? null;
});

const canUseSelectionActions = computed(
  () => selectedBasisDocId.value !== null && !isLoading.value,
);

const extendId = computed(() => {
  const entry = soleSelectedEntry.value;
  if (!entry) return "";
  return basisDisplayId(entry.id, entry.data);
});

const selectedCount = computed(() => (selectedBasisDocId.value ? 1 : 0));
const basisTotalLabel = computed(() => allDocs.value.length.toLocaleString("ko-KR"));

const canMutateBasis = computed(
  () => isFirebaseConfigured() && auth.isAuthenticated && auth.isAdmin,
);

// 모달 open 상태
const extendModalOpen = ref(false);
const strokeModalOpen = ref(false);
const basisFormModalOpen = ref(false);
const basisFormMode = ref<"add" | "edit">("add");
const deleteConfirmOpen = ref(false);

function openExtendLookupModal() {
  if (!soleSelectedEntry.value || !isFirebaseConfigured()) return;
  extendModalOpen.value = true;
}

function openStrokeOrderModal() {
  if (!soleSelectedEntry.value || !isFirebaseConfigured()) return;
  strokeModalOpen.value = true;
}

function openBasisAddModal() {
  basisFormMode.value = "add";
  basisFormModalOpen.value = true;
}

function openBasisEditModal() {
  if (!soleSelectedEntry.value) return;
  basisFormMode.value = "edit";
  basisFormModalOpen.value = true;
}

async function onBasisSaved(newId: string) {
  selectedBasisDocId.value = newId;
  await loadAll(true);
}

function deleteSelectedBasis() {
  if (!canMutateBasis.value || !selectedBasisDocId.value) return;
  deleteConfirmOpen.value = true;
}

async function confirmDelete() {
  deleteConfirmOpen.value = false;
  const toDelete = selectedBasisDocId.value;
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
    batch.delete(doc(collection(db, "hanja_basis"), toDelete));
    await batch.commit();
    notifications.success(`hanja_basis 삭제 완료: ${toDelete}`);
    selectedBasisDocId.value = null;
    await loadAll(true);
  } catch (e) {
    const msg = e instanceof Error ? e.message : "삭제에 실패했습니다.";
    error.value = msg;
    notifications.error(msg);
  } finally {
    isLoading.value = false;
  }
}

// 도움말 툴팁
const BASIS_MANAGE_HELP_TEXT =
  "그리드 위 조회 · 획순은 카드를 눌러 한 개만 선택한 뒤 사용합니다. 조회는 hanja_extend, 획순은 hanja_extend → hanja_stroke → hanja_basis 순으로 획 데이터를 불러옵니다. 행 추가·수정·삭제는 Firestore hanja_basis 에 직접 반영됩니다.";

const basisManageHelpTriggerRef = ref<HTMLButtonElement | null>(null);
const isBasisManageHelpTooltipOpen = ref(false);
const basisManageHelpTooltipStyle = ref<Record<string, string>>({});

let basisManageHelpRemoveScrollListeners: (() => void) | null = null;

function positionBasisManageHelpTooltip() {
  const el = basisManageHelpTriggerRef.value;
  if (!el) return;
  const boundingRect = el.getBoundingClientRect();
  const margin = 10;
  const maxW = Math.min(400, window.innerWidth - margin * 2);
  let left = boundingRect.left;
  if (left + maxW > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - margin - maxW);
  }
  if (left < margin) left = margin;
  basisManageHelpTooltipStyle.value = {
    top: `${Math.round(boundingRect.bottom + margin)}px`,
    left: `${Math.round(left)}px`,
    maxWidth: `${maxW}px`,
  };
}

function openBasisManageHelpTooltip() {
  positionBasisManageHelpTooltip();
  isBasisManageHelpTooltipOpen.value = true;
  void nextTick(() => positionBasisManageHelpTooltip());
}

function closeBasisManageHelpTooltip() {
  isBasisManageHelpTooltipOpen.value = false;
}

watch(isBasisManageHelpTooltipOpen, (open) => {
  basisManageHelpRemoveScrollListeners?.();
  basisManageHelpRemoveScrollListeners = null;
  if (!open) return;
  const handler = () => positionBasisManageHelpTooltip();
  window.addEventListener("scroll", handler, true);
  window.addEventListener("resize", handler);
  basisManageHelpRemoveScrollListeners = () => {
    window.removeEventListener("scroll", handler, true);
    window.removeEventListener("resize", handler);
  };
});

onUnmounted(() => { basisManageHelpRemoveScrollListeners?.(); });
onMounted(() => { void loadAll(); });
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-visible rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute inset-0 overflow-hidden rounded-xl"
        aria-hidden="true"
      >
        <div class="absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl" />
      </div>
      <div
        class="relative flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between sm:gap-3"
      >
        <div class="flex min-w-0 items-center gap-2.5 sm:gap-3">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            基
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <div class="min-w-0 flex-1 leading-tight">
              <p class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90">
                Firestore · hanja_basis
              </p>
              <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
                기준 데이터
              </h1>
            </div>
            <div class="relative shrink-0 pt-0.5">
              <button
                ref="basisManageHelpTriggerRef"
                type="button"
                class="flex h-6 w-6 items-center justify-center rounded-full border border-primary/35 bg-primary/12 text-xs font-bold leading-none text-primary shadow-sm outline-none ring-primary/20 transition hover:bg-primary/18 focus-visible:ring-2"
                :aria-label="BASIS_MANAGE_HELP_TEXT"
                :aria-describedby="isBasisManageHelpTooltipOpen ? 'basis-manage-help-tooltip-text' : undefined"
                @mouseenter="openBasisManageHelpTooltip"
                @mouseleave="closeBasisManageHelpTooltip"
                @focus="openBasisManageHelpTooltip"
                @blur="closeBasisManageHelpTooltip"
              >
                !
              </button>
            </div>
          </div>
        </div>
        <div class="flex w-full min-w-0 flex-col gap-2 sm:items-end">
          <div class="flex flex-wrap items-center gap-1.5 sm:justify-end">
            <span
              class="inline-flex items-center gap-1 rounded-full border border-white/60 bg-white/90 px-2 py-0.5 text-[11px] font-medium text-onSurface shadow-sm backdrop-blur-sm"
            >
              <span class="text-onSurface-variant">전체</span>
              <span class="tabular-nums text-primary">{{ basisTotalLabel }}</span>
              <span class="text-onSurface-variant">건</span>
            </span>
            <span
              v-if="!isLoading && allDocs.length && filterActive"
              class="inline-flex items-center rounded-full border border-outline-variant/70 bg-surface-lowest/90 px-2 py-0.5 text-[11px] font-medium text-onSurface backdrop-blur-sm"
            >
              필터 결과
              <span class="ml-0.5 tabular-nums text-primary">{{ totalCount.toLocaleString("ko-KR") }}</span>건
            </span>
            <span
              v-if="selectedCount > 0"
              class="inline-flex items-center rounded-full border border-primary/25 bg-primary/[0.1] px-2 py-0.5 text-[11px] font-semibold text-primary"
            >
              {{ selectedCount.toLocaleString("ko-KR") }}건 선택
            </span>
          </div>
          <div
            class="grid grid-cols-2 gap-2 sm:flex sm:flex-wrap sm:justify-end sm:gap-2"
          >
            <button
              type="button"
              class="btn-secondary min-h-[2.75rem] px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
              :disabled="isLoading || !canMutateBasis"
              title="admin 클레임·로그인 필요"
              @click="openBasisAddModal"
            >
              추가
            </button>
            <button
              type="button"
              class="btn-secondary min-h-[2.75rem] px-3 py-2 text-xs sm:min-h-0 sm:py-1.5 sm:text-sm"
              :disabled="!canMutateBasis || !canUseSelectionActions"
              title="카드 한 개 선택 · admin 필요"
              @click="openBasisEditModal"
            >
              수정
            </button>
            <button
              type="button"
              class="min-h-[2.75rem] rounded-md border border-red-300/90 bg-surface-low px-3 py-2 text-xs font-medium text-red-800 transition hover:bg-red-50/80 disabled:cursor-not-allowed disabled:opacity-50 sm:min-h-0 sm:py-1.5 sm:text-sm"
              :disabled="isLoading || !canMutateBasis || selectedCount === 0"
              title="선택한 항목 삭제 · admin 필요"
              @click="deleteSelectedBasis"
            >
              삭제
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
      </div>
    </section>

    <!-- 필터: 모바일은 세로·그리드, lg 이상에서 한 줄 (가로 스크롤 제거) -->
    <div
      class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4"
    >
      <div
        class="flex flex-col gap-3 lg:flex-row lg:flex-nowrap lg:items-end lg:gap-2.5"
      >
        <h2
          class="text-sm font-semibold leading-none text-onSurface lg:shrink-0 lg:self-center lg:pr-1"
        >
          검색 및 목록
        </h2>
        <div class="grid grid-cols-2 gap-3 lg:contents">
          <div class="flex min-w-0 flex-col lg:w-[5.25rem] lg:shrink-0">
            <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">페이지당</label>
            <select v-model="pageSize" class="input-minimal w-full cursor-pointer py-1.5 text-sm">
              <option v-for="n in PAGE_SIZE_OPTIONS" :key="n" :value="n">{{ n }}건</option>
            </select>
          </div>
          <div class="flex min-w-0 flex-col lg:w-[4.75rem] lg:shrink-0">
            <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">구분</label>
            <select v-model="filter구분" class="input-minimal w-full cursor-pointer py-1.5 text-sm">
              <option value="">전체</option>
              <option value="중">중</option>
              <option value="고">고</option>
            </select>
          </div>
        </div>
        <div class="grid grid-cols-1 gap-3 lg:contents">
          <div class="flex min-w-0 flex-col lg:min-w-0 lg:flex-1">
            <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">한자</label>
            <input
              v-model="search한자"
              type="search"
              class="input-minimal min-w-0 w-full py-1.5 text-sm"
              placeholder="부분 일치"
              autocomplete="off"
            />
          </div>
          <div class="flex min-w-0 flex-col lg:min-w-0 lg:flex-1">
            <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">음</label>
            <input
              v-model="search음"
              type="search"
              class="input-minimal min-w-0 w-full py-1.5 text-sm"
              placeholder="부분 일치"
              autocomplete="off"
            />
          </div>
          <div class="flex min-w-0 flex-col lg:min-w-0 lg:flex-1">
            <label class="mb-0.5 text-[10px] font-medium text-onSurface-variant">훈</label>
            <input
              v-model="search훈"
              type="search"
              class="input-minimal min-w-0 w-full py-1.5 text-sm"
              placeholder="부분 일치"
              autocomplete="off"
            />
          </div>
        </div>
        <button
          type="button"
          class="btn-secondary w-full shrink-0 py-2.5 text-xs sm:text-sm lg:w-auto lg:self-end lg:py-1.5"
          :disabled="!filterActive"
          @click="clearFilters"
        >
          필터 초기화
        </button>
      </div>
    </div>

    <div
      v-if="isFirebaseConfigured() && auth.isAuthReady && auth.isAuthenticated && !auth.isAdmin"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-2.5 text-xs text-amber-950 shadow-sm"
    >
      <strong class="font-medium">admin</strong> 클레임이 있어야
      <strong class="font-medium">추가·수정·삭제</strong>가 가능합니다. 설정 → 인증에서 토큰을 갱신하세요.
    </div>

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
      <p class="text-sm font-medium text-onSurface-variant">hanja_basis 불러오는 중…</p>
    </div>
    <div
      v-else-if="!isLoading && !allDocs.length"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">아직 문서가 없습니다</p>
      <p class="mt-2 text-sm text-onSurface-variant">
        한자 마스터 등록에서
        <code class="rounded bg-surface-low px-1.5 py-0.5 font-mono text-xs">hanja_basis</code>
        CSV를 업로드하세요.
      </p>
    </div>
    <div
      v-else-if="!isLoading && allDocs.length && !totalCount"
      class="rounded-2xl border border-dashed border-outline-variant bg-surface-low/40 px-6 py-14 text-center"
    >
      <p class="text-sm font-medium text-onSurface">필터와 일치하는 행이 없습니다</p>
      <p class="mt-2 text-sm text-onSurface-variant">검색어나 구분 조건을 바꾸거나 필터 초기화를 눌러 보세요.</p>
    </div>

    <template v-if="rows.length">
      <div
        class="overflow-hidden rounded-2xl border border-outline-variant/80 bg-surface-low/50 p-3 shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02] sm:p-4"
      >
        <div
          class="mb-3 flex flex-col gap-3 border-b border-outline-variant/50 pb-3 sm:flex-row sm:items-center sm:justify-end"
        >
          <div class="flex shrink-0 flex-wrap items-center gap-2 sm:justify-end">
            <button
              type="button"
              class="btn-primary px-3 py-1.5 text-xs shadow-sm shadow-primary/15 sm:text-sm"
              :disabled="!canUseSelectionActions"
              title="카드 한 개 선택"
              @click="openExtendLookupModal"
            >
              조회
            </button>
            <button
              type="button"
              class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
              :disabled="!canUseSelectionActions"
              title="카드 한 개 선택"
              @click="openStrokeOrderModal"
            >
              획순
            </button>
          </div>
        </div>
        <div
          class="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6"
        >
          <article
            v-for="(row, i) in rows"
            :key="ids[i] ?? i"
            class="relative flex min-h-[10.5rem] cursor-pointer flex-col rounded-xl border p-3 pt-9 text-left shadow-sm transition-all duration-150"
            :class="
              selectedBasisDocId === ids[i]
                ? 'border-primary bg-primary/[0.12] ring-2 ring-primary/35 shadow-md shadow-primary/15'
                : 'border-outline-variant/80 bg-white focus-within:ring-2 focus-within:ring-primary/20 hover:border-outline-variant hover:shadow-md hover:shadow-black/[0.05]'
            "
            role="button"
            tabindex="0"
            :aria-pressed="selectedBasisDocId === ids[i]"
            :aria-label="`${selectedBasisDocId === ids[i] ? '선택됨' : '선택'} · ${String(row['한자'] ?? '') || basisDisplayId(ids[i]!, row)}`"
            @click="selectBasisCard(ids[i]!)"
            @keydown.enter.prevent="selectBasisCard(ids[i]!)"
            @keydown.space.prevent="selectBasisCard(ids[i]!)"
          >
            <div class="pointer-events-none absolute left-2.5 top-2.5 z-10" aria-hidden="true">
              <input
                type="checkbox"
                tabindex="-1"
                class="h-4 w-4 cursor-default rounded border-outline-variant text-primary"
                :checked="selectedBasisDocId === ids[i]"
              />
            </div>
            <div
              v-if="String(row['구분'] ?? '').trim()"
              class="pointer-events-none absolute right-2 top-2 z-10"
            >
              <span
                class="flex h-7 w-7 items-center justify-center rounded-full border border-outline-variant/70 bg-surface-low text-[11px] font-bold text-onSurface shadow-sm"
                :title="String(row['구분']).trim()"
              >
                {{ String(row["구분"]).trim().charAt(0) }}
              </span>
            </div>
            <div class="flex flex-1 flex-col items-center justify-center gap-1 px-1 text-center">
              <p
                class="font-display text-4xl font-semibold leading-none tracking-tight text-onSurface sm:text-[2.75rem]"
                :title="String(row['한자'] ?? '')"
              >
                {{ row["한자"] ?? "—" }}
              </p>
              <p
                v-if="String(row['훈음'] ?? '').trim()"
                class="line-clamp-2 w-full text-xs leading-snug text-onSurface"
                :title="String(row['훈음'])"
              >
                {{ row["훈음"] }}
              </p>
              <p v-else class="line-clamp-2 w-full text-xs leading-snug text-onSurface">
                <span v-if="String(row['훈'] ?? '').trim()" class="block">{{ row["훈"] }}</span>
                <span v-if="String(row['음'] ?? '').trim()" class="mt-0.5 block text-onSurface-variant">{{ row["음"] }}</span>
                <span
                  v-if="!String(row['훈'] ?? '').trim() && !String(row['음'] ?? '').trim()"
                  class="text-onSurface-variant"
                >—</span>
              </p>
            </div>
            <div class="mt-auto border-t border-outline-variant/50 pt-2 text-left">
              <p
                class="line-clamp-2 text-[11px] leading-snug text-onSurface"
                :title="basisTileFooterCaption(row)"
              >
                {{ basisTileFooterCaption(row) }}
              </p>
              <p
                class="mt-1 font-mono text-[11px] font-semibold text-primary"
                :title="basisDisplayId(ids[i]!, row)"
              >
                {{ basisDisplayId(ids[i]!, row) }}
              </p>
            </div>
          </article>
        </div>
      </div>

      <div
        class="flex flex-col gap-3 rounded-xl border border-outline-variant/60 bg-surface-low/80 px-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-5"
      >
        <p class="text-xs text-onSurface-variant">
          <span class="font-medium text-onSurface tabular-nums">{{ rangeStart }}–{{ rangeEnd }}</span>
          <span class="mx-1 text-onSurface-variant/70">/</span>
          <span class="tabular-nums">{{ totalCount.toLocaleString("ko-KR") }}</span>건
        </p>
        <div class="flex flex-wrap items-center justify-end gap-2">
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-sm"
            :disabled="isLoading || currentPage <= 0"
            @click="prevPage"
          >
            이전
          </button>
          <template v-for="(item, idx) in paginationItems" :key="'p-' + idx">
            <span v-if="item === 'ellipsis'" class="px-1 text-onSurface-variant">…</span>
            <button
              v-else
              type="button"
              class="min-w-[2.25rem] rounded-lg px-2 py-1.5 text-sm font-medium transition"
              :class="
                item === currentPage + 1
                  ? 'bg-primary text-white shadow-md shadow-primary/20'
                  : 'bg-surface-lowest text-onSurface ring-1 ring-outline-variant/50 hover:bg-surface-bright'
              "
              :disabled="isLoading"
              @click="goToPage(item - 1)"
            >
              {{ item }}
            </button>
          </template>
          <button
            type="button"
            class="btn-secondary px-3 py-1.5 text-sm"
            :disabled="isLoading || currentPage >= totalPages - 1"
            @click="nextPage"
          >
            다음
          </button>
        </div>
      </div>
    </template>

    <!-- 모달 컴포넌트 -->
    <ExtendLookupModal
      :open="extendModalOpen"
      :query-id="extendId"
      @close="extendModalOpen = false"
    />
    <StrokeModal
      :open="strokeModalOpen"
      :entry="soleSelectedEntry"
      :extend-id="extendId"
      @close="strokeModalOpen = false"
    />
    <BasisFormModal
      :open="basisFormModalOpen"
      :mode="basisFormMode"
      :entry="basisFormMode === 'edit' ? soleSelectedEntry : null"
      @close="basisFormModalOpen = false"
      @saved="onBasisSaved"
    />
    <ConfirmModal
      :open="deleteConfirmOpen"
      title="항목 삭제"
      :message="`'${selectedBasisDocId}'를 hanja_basis에서 삭제합니다. 되돌릴 수 없습니다.`"
      confirm-label="삭제"
      :danger="true"
      @confirm="confirmDelete"
      @cancel="deleteConfirmOpen = false"
    />

    <!-- 도움말 툴팁 -->
    <Teleport to="body">
      <div
        v-if="isBasisManageHelpTooltipOpen"
        id="basis-manage-help-tooltip-text"
        class="fixed z-[10050] rounded-xl border border-outline-variant/80 bg-surface-lowest p-3.5 text-left text-xs leading-relaxed text-onSurface shadow-[0_16px_48px_rgba(25,28,30,0.18)] ring-1 ring-black/[0.06]"
        :style="basisManageHelpTooltipStyle"
        role="tooltip"
      >
        {{ BASIS_MANAGE_HELP_TEXT }}
      </div>
    </Teleport>
  </div>
</template>
