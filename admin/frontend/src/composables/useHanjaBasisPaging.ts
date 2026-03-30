import { computed, ref } from 'vue';
import { collection, getDocs, limit, orderBy, query, startAfter, type DocumentData, type Firestore, type QueryDocumentSnapshot } from 'firebase/firestore';
import type { RawHanjaRow } from './dashboardTypes';
import { mapHanja } from './useDashboardUtils';

export function useHanjaBasisPaging(args: {
  db: Firestore | null | undefined;
  firebaseInitError: string | null | undefined;
  basisCollection: string;
}) {
  const { db, firebaseInitError, basisCollection } = args;

  const isLoading = ref(false);
  const rows = ref<RawHanjaRow[]>([]);
  const errorMessage = ref('');

  const pageSize = ref(50);
  const pageIndex = ref(0);
  const cursors = ref<Array<QueryDocumentSnapshot<DocumentData> | null>>([null]);
  const canGoNext = ref(false);

  const search = ref('');
  const filteredRows = computed(() => {
    const q = search.value.trim();
    if (!q) return rows.value;
    const qq = q.toLowerCase();
    return rows.value.filter((r) => {
      return (
        r.id.toLowerCase().includes(qq) ||
        r.hanja.includes(q) ||
        r.음.toLowerCase().includes(qq) ||
        r.훈.toLowerCase().includes(qq) ||
        r.훈음.toLowerCase().includes(qq) ||
        r.구분.toLowerCase().includes(qq)
      );
    });
  });

  const selectedIds = ref<string[]>([]);
  const selectedCount = computed(() => selectedIds.value.length);
  const isAllSelected = computed(() => rows.value.length > 0 && selectedIds.value.length === rows.value.length);

  function toggleSelectAll() {
    if (isAllSelected.value) {
      selectedIds.value = [];
      return;
    }
    selectedIds.value = rows.value.map((r) => r.id);
  }

  function toggleSelected(id: string) {
    const idx = selectedIds.value.indexOf(id);
    if (idx >= 0) selectedIds.value.splice(idx, 1);
    else selectedIds.value.push(id);
  }

  async function fetchPage(idx: number) {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
      const cursor = cursors.value[idx] ?? null;
      const base = query(collection(db, basisCollection), orderBy('__name__'), limit(pageSize.value));
      const q2 = cursor ? query(base, startAfter(cursor)) : base;
      const snap = await getDocs(q2);
      rows.value = snap.docs.map((d) => mapHanja(d.id, d.data() as Record<string, unknown>));

      const last = snap.docs.length ? snap.docs[snap.docs.length - 1] : null;
      canGoNext.value = snap.docs.length === pageSize.value && last != null;
      if (canGoNext.value && last) {
        if (cursors.value.length <= idx + 1) cursors.value.push(last);
        else {
          cursors.value[idx + 1] = last;
          cursors.value = cursors.value.slice(0, idx + 2);
        }
      } else {
        cursors.value = cursors.value.slice(0, idx + 1);
      }
    } catch (e: any) {
      errorMessage.value = e?.message || String(e);
    } finally {
      isLoading.value = false;
    }
  }

  async function goNextPage() {
    if (!canGoNext.value) return;
    pageIndex.value += 1;
    await fetchPage(pageIndex.value);
  }

  async function goPrevPage() {
    if (pageIndex.value <= 0) return;
    pageIndex.value -= 1;
    await fetchPage(pageIndex.value);
  }

  async function onChangePageSize() {
    pageIndex.value = 0;
    cursors.value = [null];
    await fetchPage(0);
  }

  async function resetAndFetchFirstPage() {
    rows.value = [];
    selectedIds.value = [];
    pageIndex.value = 0;
    cursors.value = [null];
    canGoNext.value = false;
    await fetchPage(0);
  }

  return {
    // data
    rows,
    filteredRows,
    search,
    isLoading,
    errorMessage,
    pageSize,
    pageIndex,
    canGoNext,

    // selection
    selectedIds,
    selectedCount,
    isAllSelected,
    toggleSelectAll,
    toggleSelected,

    // actions
    fetchPage,
    goNextPage,
    goPrevPage,
    onChangePageSize,
    resetAndFetchFirstPage,
  };
}

