<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { doc, getDoc, setDoc } from 'firebase/firestore';

import { db, firebaseInitError } from '../../firebase';
import type { RawHanjaDraft, RawHanjaRow } from '../../composables/dashboardTypes';
import { emptyDraft, draftToFirestore, requiredDraftErrors, unicodeDocIdFromHanja } from '../../composables/useDashboardUtils';
import { useHanjaBasisPaging } from '../../composables/useHanjaBasisPaging';
import { useEtlExtend } from '../../composables/useEtlExtend';
import { useCascadeDelete } from '../../composables/useCascadeDelete';
import EtlCard from '../../components/dashboard/EtlCard.vue';

const BASIS_COLLECTION = 'hanja_basis';
const EXTEND_COLLECTION = 'hanja_extend';
const STROKE_COLLECTION = 'hanja_stroke';
const WORD_COLLECTION = 'hanja_word';

const successMessage = ref('');
const contentVersion = ref<number | null>(null);

const {
  rows,
  filteredRows,
  search,
  isLoading,
  errorMessage,
  pageSize,
  pageIndex,
  canGoNext,
  selectedIds,
  selectedCount,
  isAllSelected,
  toggleSelectAll,
  toggleSelected,
  goNextPage,
  goPrevPage,
  onChangePageSize,
  resetAndFetchFirstPage,
} = useHanjaBasisPaging({ db, firebaseInitError, basisCollection: BASIS_COLLECTION });

const { cascadeDeleteByHanjaIds } = useCascadeDelete({
  db,
  firebaseInitError,
  basisCollection: BASIS_COLLECTION,
  extendCollection: EXTEND_COLLECTION,
  strokeCollection: STROKE_COLLECTION,
  wordCollection: WORD_COLLECTION,
});

const isModalOpen = ref(false);
const modalMode = ref<'create' | 'edit'>('create');
const draft = ref<RawHanjaDraft>(emptyDraft());

function openCreate() {
  modalMode.value = 'create';
  draft.value = emptyDraft();
  isModalOpen.value = true;
}

function openEdit(row: RawHanjaRow) {
  modalMode.value = 'edit';
  draft.value = { hanja: row.hanja, 음: row.음, 훈: row.훈, 전체: row.전체, 훈음: row.훈음, 구분: row.구분 };
  isModalOpen.value = true;
}

function closeModal() {
  isModalOpen.value = false;
}

async function saveDraft() {
  errorMessage.value = '';
  try {
    if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
    const errs = requiredDraftErrors(draft.value);
    if (errs.length) {
      errorMessage.value = errs.join(' ');
      return;
    }
    const docId = unicodeDocIdFromHanja(draft.value.hanja);
    if (!docId) {
      errorMessage.value = '문서 ID 생성 실패: 한자 값을 확인하세요.';
      return;
    }
    await setDoc(doc(db, BASIS_COLLECTION, docId), draftToFirestore(draft.value), { merge: true });
    closeModal();
    await refresh();
  } catch (e: any) {
    errorMessage.value = e?.message || String(e);
  }
}

async function deleteRow(row: RawHanjaRow) {
  errorMessage.value = '';
  try {
    if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
    const ok = window.confirm(`정말 삭제할까요?\n\n한자=${row.hanja}\n음=${row.음}\n훈=${row.훈}`);
    if (!ok) return;
    await cascadeDeleteByHanjaIds([row.id]);
    await refresh();
  } catch (e: any) {
    errorMessage.value = e?.message || String(e);
  }
}

async function deleteSelected() {
  errorMessage.value = '';
  try {
    if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
    if (selectedIds.value.length === 0) return;
    const ok = window.confirm(`선택한 ${selectedIds.value.length}건을 삭제할까요?\n(basis + extend)`);
    if (!ok) return;
    const ids = [...selectedIds.value];
    await cascadeDeleteByHanjaIds(ids);
    selectedIds.value = [];
    await refresh();
    successMessage.value = `삭제 완료: ${ids.length}건 (basis + extend + stroke + word)`;
  } catch (e: any) {
    errorMessage.value = e?.message || String(e);
  }
}

const { etlRunning, etlMessage, etlProgress, runEtlForCurrentPage, runEtlAll } = useEtlExtend({
  db,
  firebaseInitError,
  basisCollection: BASIS_COLLECTION,
  extendCollection: EXTEND_COLLECTION,
  strokeCollection: STROKE_COLLECTION,
  wordCollection: WORD_COLLECTION,
});

async function runEtlCurrentPageAction() {
  await runEtlForCurrentPage(rows.value);
}

async function loadContentVersion() {
  if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
  const snap = await getDoc(doc(db, 'config', 'content'));
  const v = snap.data()?.contentVersion;
  if (typeof v === 'number') contentVersion.value = Math.trunc(v);
  else contentVersion.value = null;
}

async function refresh() {
  errorMessage.value = '';
  try {
    await loadContentVersion();
    await resetAndFetchFirstPage();
  } finally {
  }
}

onMounted(() => {
  void refresh();
});
</script>

<template>
  <div class="space-y-6">
    <div class="bg-surface-container-low rounded-3xl p-6">
      <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Dataset</div>
          <h2 class="mt-1 text-2xl font-headline font-extrabold tracking-tight">한자 원본 리스트</h2>
          <p class="text-sm text-on-surface-variant mt-2">
            contentVersion <span class="font-semibold text-on-surface">{{ contentVersion ?? '없음' }}</span>
            <span class="text-on-surface-variant/60 px-2">•</span>
            collection <span class="font-mono">{{ BASIS_COLLECTION }}</span>
          </p>
        </div>
        <div class="flex items-center gap-2">
          <button
            class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-gradient-to-b from-primary to-primary-container text-on-primary shadow-ambient disabled:opacity-50"
            @click="openCreate"
            :disabled="isLoading || !!firebaseInitError"
          >
            개별 등록
          </button>
          <button
            class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-surface-container-lowest hover:bg-surface-container-high transition-colors disabled:opacity-50"
            @click="refresh"
            :disabled="isLoading"
          >
            새로고침
          </button>
          <button
            class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-error/10 text-error hover:bg-error/15 transition-colors disabled:opacity-50"
            @click="deleteSelected"
            :disabled="isLoading || selectedCount === 0 || !!firebaseInitError"
          >
            선택 삭제 ({{ selectedCount }})
          </button>
        </div>
      </div>
    </div>

    <div v-if="successMessage" class="text-sm text-emerald-700 bg-emerald-50 rounded-2xl p-4">
      {{ successMessage }}
    </div>

    <div class="mt-6 bg-surface-container-lowest rounded-3xl p-6 shadow-ambient">
      <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex-1">
          <input
            v-model="search"
            type="text"
            placeholder="id/한자/음/훈/훈음/구분 검색(현재 페이지 로컬 필터)"
            class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl text-on-surface placeholder:text-outline/60 focus:ring-2 focus:ring-primary/40 transition-all"
          />
        </div>
        <div class="text-xs text-on-surface-variant flex items-center gap-2">
          <span class="font-semibold uppercase tracking-wider">page</span>
          <span class="font-semibold text-on-surface">{{ pageIndex + 1 }}</span>
          <span class="text-on-surface-variant/60">•</span>
          <span class="font-semibold uppercase tracking-wider">size</span>
          <select
            v-model.number="pageSize"
            class="text-xs bg-surface-container-high border-none rounded-full px-3 py-2"
            @change="onChangePageSize"
            :disabled="isLoading"
          >
            <option :value="25">25</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
            <option :value="200">200</option>
          </select>
          <span class="text-on-surface-variant/60">•</span>
          <span>로드됨</span>
          <span class="font-semibold text-on-surface">{{ rows.length }}</span>
        </div>
      </div>
    </div>

    <div v-if="errorMessage" class="mt-4 text-sm text-error whitespace-pre-line">
      {{ errorMessage }}
    </div>

    <div class="mt-6 grid grid-cols-1 gap-4 md:hidden">
      <div v-for="r in filteredRows" :key="r.id" class="bg-surface-container-lowest rounded-3xl p-5 shadow-ambient">
        <div class="flex items-start justify-between gap-4">
          <div>
            <div class="text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">Hanja</div>
            <div class="mt-1 text-5xl font-headline font-extrabold text-primary leading-none">{{ r.hanja }}</div>
            <div class="mt-2 text-sm text-on-surface-variant">
              {{ r.훈 }} {{ r.음 }} <span class="text-on-surface-variant/60 px-2">•</span> {{ r.구분 }}
            </div>
          </div>
          <div class="flex flex-col items-end gap-2">
            <button
              class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-high hover:bg-surface-variant transition-colors"
              @click="openEdit(r)"
              :disabled="!!firebaseInitError"
            >
              수정
            </button>
            <button
              class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-error/10 text-error hover:bg-error/15 transition-colors"
              @click="deleteRow(r)"
              :disabled="!!firebaseInitError"
            >
              삭제
            </button>
          </div>
        </div>
        <div class="mt-4 text-xs text-on-surface-variant font-mono break-all">{{ r.id }}</div>
        <div class="mt-3 text-sm text-on-surface-variant">
          <div class="line-clamp-2">{{ r.전체 }}</div>
          <div class="mt-1 text-xs text-on-surface-variant/80">{{ r.훈음 }}</div>
        </div>
      </div>
      <div v-if="!filteredRows.length && !isLoading" class="text-sm text-on-surface-variant text-center py-10">표시할 데이터가 없습니다.</div>
    </div>

    <div class="mt-6 hidden md:block bg-surface-container-lowest rounded-3xl shadow-ambient overflow-auto">
      <table class="min-w-full text-sm">
        <thead class="bg-surface-container-low">
          <tr>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">
              <input type="checkbox" :checked="isAllSelected" @change="toggleSelectAll" />
            </th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">ID</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">한자</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">음</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">훈</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">전체</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">훈음</th>
            <th class="px-6 py-4 text-left text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">구분</th>
            <th class="px-6 py-4 text-right text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">작업</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in filteredRows" :key="r.id" class="hover:bg-surface-container-low transition-colors">
            <td class="px-6 py-4">
              <input type="checkbox" :checked="selectedIds.includes(r.id)" @change="toggleSelected(r.id)" />
            </td>
            <td class="px-6 py-4 font-mono text-xs text-on-surface-variant">{{ r.id }}</td>
            <td class="px-6 py-4 text-xl font-headline font-extrabold text-primary">{{ r.hanja }}</td>
            <td class="px-6 py-4 text-on-surface">{{ r.음 }}</td>
            <td class="px-6 py-4 text-on-surface">{{ r.훈 }}</td>
            <td class="px-6 py-4 text-on-surface-variant max-w-[32rem]"><div class="line-clamp-2">{{ r.전체 }}</div></td>
            <td class="px-6 py-4 text-on-surface-variant">{{ r.훈음 }}</td>
            <td class="px-6 py-4 text-on-surface-variant">{{ r.구분 }}</td>
            <td class="px-6 py-4 text-right whitespace-nowrap">
              <button
                class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-high hover:bg-surface-variant transition-colors mr-2 disabled:opacity-50"
                @click="openEdit(r)"
                :disabled="!!firebaseInitError"
              >
                수정
              </button>
              <button
                class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-error/10 text-error hover:bg-error/15 transition-colors disabled:opacity-50"
                @click="deleteRow(r)"
                :disabled="!!firebaseInitError"
              >
                삭제
              </button>
            </td>
          </tr>
          <tr v-if="!filteredRows.length && !isLoading">
            <td class="px-6 py-10 text-center text-on-surface-variant" colspan="9">표시할 데이터가 없습니다.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <EtlCard
      :firebaseInitError="firebaseInitError"
      :basisCollection="BASIS_COLLECTION"
      :extendCollection="EXTEND_COLLECTION"
      :strokeCollection="STROKE_COLLECTION"
      :wordCollection="WORD_COLLECTION"
      :etlRunning="etlRunning"
      :etlProgress="etlProgress"
      :etlMessage="etlMessage"
      @etlCurrent="runEtlCurrentPageAction"
      @etlAll="runEtlAll"
    />

    <div class="mt-6 flex items-center justify-between">
      <p class="text-[11px] text-on-surface-variant">paging은 문서ID(<span class="font-mono">__name__</span>) 기준 커서 방식입니다.</p>
      <div class="flex items-center gap-2">
        <button
          class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-surface-container-lowest hover:bg-surface-container-high transition-colors disabled:opacity-50"
          @click="goPrevPage"
          :disabled="isLoading || pageIndex <= 0"
        >
          이전
        </button>
        <button
          class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-gradient-to-b from-primary to-primary-container text-on-primary shadow-ambient disabled:opacity-50"
          @click="goNextPage"
          :disabled="isLoading || !canGoNext"
        >
          다음
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="isModalOpen" class="fixed inset-0 z-50">
      <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="closeModal"></div>
      <div class="absolute inset-0 flex items-center justify-center p-4">
        <div class="w-full max-w-2xl bg-white/80 backdrop-blur-xl rounded-3xl shadow-ambient overflow-hidden">
          <div class="px-6 py-5 flex items-center justify-between">
            <div class="font-headline font-extrabold text-on-surface">{{ modalMode === 'create' ? '한자 개별 등록' : '한자 수정' }}</div>
            <button class="text-xs font-semibold uppercase tracking-wider px-3 py-2 rounded-full bg-surface-container-low hover:bg-surface-container-high transition-colors" @click="closeModal">
              닫기
            </button>
          </div>
          <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">한자 (문서 ID)</label>
              <input v-model="draft.hanja" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" :disabled="modalMode === 'edit'" placeholder="예: 佳" />
            </div>
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">음</label>
              <input v-model="draft.음" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" placeholder="예: 가" />
            </div>
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">훈</label>
              <input v-model="draft.훈" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" placeholder="예: 값" />
            </div>
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">구분</label>
              <input v-model="draft.구분" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" placeholder="예: 중/고/기" />
            </div>
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">전체</label>
              <input v-model="draft.전체" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" placeholder="예: 價 (값 가)" />
            </div>
            <div>
              <label class="block text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase mb-2">훈음</label>
              <input v-model="draft.훈음" class="w-full px-4 py-4 bg-surface-container-high border-none rounded-2xl" placeholder="예: 값 가" />
            </div>
          </div>
          <div class="px-6 pb-6">
            <div v-if="errorMessage" class="mb-4 text-sm text-error whitespace-pre-line">{{ errorMessage }}</div>
            <div class="flex justify-end gap-2">
              <button class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-surface-container-lowest hover:bg-surface-container-high transition-colors" @click="closeModal">
                취소
              </button>
              <button
                class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-gradient-to-b from-primary to-primary-container text-on-primary shadow-ambient disabled:opacity-50"
                @click="saveDraft"
                :disabled="!!firebaseInitError"
              >
                저장
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

