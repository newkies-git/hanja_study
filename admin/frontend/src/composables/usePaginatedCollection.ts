import { computed, ref, watch } from "vue";
import type { DocumentData, QueryDocumentSnapshot } from "firebase/firestore";
import {
  collection,
  documentId,
  getDocs,
  limit,
  orderBy,
  query,
  startAfter,
} from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";

export type DocEntry = { id: string; data: Record<string, unknown> };

/** 대소문자 무시 부분 일치 검색 헬퍼 */
export function contains(hay: string, needle: string): boolean {
  if (!needle.trim()) return true;
  return hay.toLowerCase().includes(needle.trim().toLowerCase());
}

const PAGE_SIZE_OPTIONS = [10, 20, 50] as const;
type PageSize = (typeof PAGE_SIZE_OPTIONS)[number];

/**
 * Firestore 컬렉션을 클라이언트 메모리에 불러온 뒤
 * 필터·페이지네이션을 처리하는 공용 composable.
 *
 * @param collectionName  Firestore 컬렉션 이름
 * @param filterFn        항목별 표시 여부 판단 함수 (반응형 refs를 클로저로 캡처 가능)
 * @param options         fetchCap(최대 로딩 건수), defaultPageSize
 */
export function usePaginatedCollection(
  collectionName: string,
  filterFn: (entry: DocEntry) => boolean,
  options: { fetchCap?: number; defaultPageSize?: PageSize } = {},
) {
  const FETCH_CAP = options.fetchCap ?? 2500;
  const defaultPage = options.defaultPageSize ?? 20;

  const allDocs = ref<DocEntry[]>([]);
  const rows = ref<Record<string, unknown>[]>([]);
  const ids = ref<string[]>([]);
  const loading = ref(false);
  const loadingMore = ref(false);
  const error = ref<string | null>(null);
  const filterWarning = ref<string | null>(null);
  const lastDoc = ref<QueryDocumentSnapshot<DocumentData> | null>(null);
  const hasMore = ref(false);
  const pageSize = ref<PageSize>(defaultPage);
  const currentPage = ref(0);

  const filteredDocs = computed(() => allDocs.value.filter(filterFn));

  const totalPages = computed(() =>
    Math.max(1, Math.ceil(filteredDocs.value.length / pageSize.value)),
  );

  const totalCount = computed(() => filteredDocs.value.length);

  const rangeStart = computed(() =>
    totalCount.value === 0 ? 0 : currentPage.value * pageSize.value + 1,
  );

  const rangeEnd = computed(() =>
    Math.min((currentPage.value + 1) * pageSize.value, totalCount.value),
  );

  const paginationItems = computed((): Array<number | "ellipsis"> => {
    const total = totalPages.value;
    const cur = currentPage.value + 1;
    if (total <= 1) return [1];
    if (total <= 10) return Array.from({ length: total }, (_, i) => i + 1);
    const out: Array<number | "ellipsis"> = [];
    const push = (x: number | "ellipsis") => {
      if (out.length && out[out.length - 1] === x) return;
      out.push(x);
    };
    push(1);
    const left = Math.max(2, cur - 2);
    const right = Math.min(total - 1, cur + 2);
    if (left > 2) push("ellipsis");
    for (let p = left; p <= right; p++) push(p);
    if (right < total - 1) push("ellipsis");
    push(total);
    return out;
  });

  function syncSliceToRows() {
    const list = filteredDocs.value;
    const start = currentPage.value * pageSize.value;
    const slice = list.slice(start, start + pageSize.value);
    rows.value = slice.map((x) => x.data);
    ids.value = slice.map((x) => x.id);
  }

  function clampPage() {
    const max = Math.max(0, totalPages.value - 1);
    if (currentPage.value > max) currentPage.value = max;
  }

  watch([filteredDocs, currentPage, pageSize], () => {
    clampPage();
    syncSliceToRows();
  });

  function goToPage(zeroBased: number) {
    const max = Math.max(0, totalPages.value - 1);
    currentPage.value = Math.min(Math.max(0, zeroBased), max);
  }

  function prevPage() { goToPage(currentPage.value - 1); }
  function nextPage() { goToPage(currentPage.value + 1); }

  let debounceId: ReturnType<typeof setTimeout> | null = null;
  function scheduleResetPage() {
    if (debounceId) clearTimeout(debounceId);
    debounceId = setTimeout(() => { currentPage.value = 0; }, 300);
  }

  function buildWarning(loadedCount: number, more: boolean): string | null {
    if (!more) return null;
    return `한 번에 최대 ${FETCH_CAP.toLocaleString("ko-KR")}건씩만 가져옵니다. 지금 ${loadedCount.toLocaleString("ko-KR")}건이 메모리에 있습니다. 더 있으면 「다음 ${FETCH_CAP.toLocaleString("ko-KR")}건 불러오기」를 누르거나 Firebase 콘솔·보내기 스크립트로 전체를 확인하세요.`;
  }

  async function loadAll() {
    if (!isFirebaseConfigured()) {
      error.value = "Firebase가 설정되지 않았습니다.";
      return;
    }
    loading.value = true;
    error.value = null;
    try {
      const db = getFirestoreDb();
      const q = query(
        collection(db, collectionName),
        orderBy(documentId()),
        limit(FETCH_CAP),
      );
      const snap = await getDocs(q);
      allDocs.value = snap.docs.map((d) => ({
        id: d.id,
        data: d.data() as Record<string, unknown>,
      }));
      lastDoc.value = snap.docs.length > 0 ? snap.docs[snap.docs.length - 1]! : null;
      hasMore.value = snap.docs.length >= FETCH_CAP;
      filterWarning.value = buildWarning(allDocs.value.length, hasMore.value);
      currentPage.value = 0;
      syncSliceToRows();
    } catch (e) {
      error.value = e instanceof Error ? e.message : `${collectionName} 를 불러오지 못했습니다.`;
      allDocs.value = [];
      rows.value = [];
      ids.value = [];
      filterWarning.value = null;
      lastDoc.value = null;
      hasMore.value = false;
    } finally {
      loading.value = false;
    }
  }

  async function loadMore() {
    if (
      !isFirebaseConfigured() ||
      !hasMore.value ||
      !lastDoc.value ||
      loading.value ||
      loadingMore.value
    ) {
      return;
    }
    loadingMore.value = true;
    error.value = null;
    try {
      const db = getFirestoreDb();
      const q = query(
        collection(db, collectionName),
        orderBy(documentId()),
        startAfter(lastDoc.value),
        limit(FETCH_CAP),
      );
      const snap = await getDocs(q);
      const next = snap.docs.map((d) => ({
        id: d.id,
        data: d.data() as Record<string, unknown>,
      }));
      allDocs.value = [...allDocs.value, ...next];
      lastDoc.value =
        snap.docs.length > 0 ? snap.docs[snap.docs.length - 1]! : lastDoc.value;
      hasMore.value = snap.docs.length >= FETCH_CAP;
      filterWarning.value = buildWarning(allDocs.value.length, hasMore.value);
    } catch (e) {
      error.value = e instanceof Error ? e.message : "추가 페이지를 불러오지 못했습니다.";
    } finally {
      loadingMore.value = false;
    }
  }

  return {
    PAGE_SIZE_OPTIONS,
    fetchCap: FETCH_CAP,
    allDocs,
    rows,
    ids,
    loading,
    loadingMore,
    error,
    filterWarning,
    hasMore,
    pageSize,
    currentPage,
    filteredDocs,
    totalPages,
    totalCount,
    rangeStart,
    rangeEnd,
    paginationItems,
    syncSliceToRows,
    scheduleResetPage,
    loadAll,
    loadMore,
    goToPage,
    prevPage,
    nextPage,
  };
}
