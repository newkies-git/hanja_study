import { computed, ref, watch } from "vue";
import type { Ref } from "vue";
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
export function textIncludesQueryIgnoreCase(text: string, query: string): boolean {
  if (!query.trim()) return true;
  return text.toLowerCase().includes(query.trim().toLowerCase());
}

const PAGE_SIZE_OPTIONS = [10, 20, 50] as const;
type PageSize = (typeof PAGE_SIZE_OPTIONS)[number];

/** 동일 collectionName 뷰 간 공유: allDocs·페이지 커서·TTL·in-flight 단일화. 인스턴스별: isLoading·페이지·rows. */
const CACHE_TTL_MS = 5 * 60 * 1000;

type CacheEntry = {
  allDocs: Ref<DocEntry[]>;
  lastDoc: Ref<QueryDocumentSnapshot<DocumentData> | null>;
  hasMore: Ref<boolean>;
  filterWarning: Ref<string | null>;
  loadedAt: Ref<number | null>;
  loadingPromise: Promise<void> | null;
};

const _collectionCache = new Map<string, CacheEntry>();

function ensureCollectionCacheEntry(name: string): CacheEntry {
  if (!_collectionCache.has(name)) {
    _collectionCache.set(name, {
      allDocs: ref<DocEntry[]>([]),
      lastDoc: ref<QueryDocumentSnapshot<DocumentData> | null>(null),
      hasMore: ref(false),
      filterWarning: ref<string | null>(null),
      loadedAt: ref<number | null>(null),
      loadingPromise: null,
    });
  }
  return _collectionCache.get(name)!;
}

/**
 * Firestore 컬렉션을 클라이언트 메모리에 불러온 뒤
 * 필터·페이지네이션을 처리하는 공용 composable.
 *
 * 동일 collectionName 호출은 모듈 레벨 캐시를 공유하므로
 * 여러 뷰가 마운트되어도 Firestore 읽기는 한 번(TTL 5분)만 발생합니다.
 *
 * @param collectionName  Firestore 컬렉션 이름
 * @param filterFn        항목별 표시 여부 판단 함수 (반응형 refs를 클로저로 캡처 가능)
 * @param options         loadCap(최대 로딩 건수), defaultPageSize
 */
export function usePaginatedCollection(
  collectionName: string,
  filterFn: (entry: DocEntry) => boolean,
  options: { loadCap?: number; defaultPageSize?: PageSize } = {},
) {
  const LOAD_CAP = options.loadCap ?? 2500;
  const defaultPage = options.defaultPageSize ?? 20;

  const cache = ensureCollectionCacheEntry(collectionName);

  const isLoading = ref(false);
  const isLoadingMore = ref(false);
  const error = ref<string | null>(null);
  const pageSize = ref<PageSize>(defaultPage);
  const currentPage = ref(0);
  const rows = ref<Record<string, unknown>[]>([]);
  const ids = ref<string[]>([]);

  const filteredDocs = computed(() => cache.allDocs.value.filter(filterFn));

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
    return `한 번에 최대 ${LOAD_CAP.toLocaleString("ko-KR")}건씩만 가져옵니다. 지금 ${loadedCount.toLocaleString("ko-KR")}건이 메모리에 있습니다. 더 있으면 「다음 ${LOAD_CAP.toLocaleString("ko-KR")}건 불러오기」를 누르거나 Firebase 콘솔·보내기 스크립트로 전체를 확인하세요.`;
  }

  /** 캐시 TTL을 초기화합니다. 다음 loadAll() 호출 시 Firestore에서 새로 조회합니다. */
  function invalidate() {
    cache.loadedAt.value = null;
  }

  /** 실제 Firestore getDocs를 수행합니다. 캐시 엔트리만 업데이트합니다. */
  async function loadCollectionBatchFromFirestore(): Promise<void> {
    if (!isFirebaseConfigured()) {
      throw new Error("Firebase가 설정되지 않았습니다.");
    }
    const db = getFirestoreDb();
    const q = query(
      collection(db, collectionName),
      orderBy(documentId()),
      limit(LOAD_CAP),
    );
    const snap = await getDocs(q);
    cache.allDocs.value = snap.docs.map((d) => ({
      id: d.id,
      data: d.data() as Record<string, unknown>,
    }));
    cache.lastDoc.value = snap.docs.length > 0 ? snap.docs[snap.docs.length - 1]! : null;
    cache.hasMore.value = snap.docs.length >= LOAD_CAP;
    cache.filterWarning.value = buildWarning(cache.allDocs.value.length, cache.hasMore.value);
    cache.loadedAt.value = Date.now();
  }

  /**
   * 컬렉션 전체를 로드합니다.
   *
   * - force=false (기본): TTL 5분 내 캐시가 유효하면 Firestore 조회를 건너뜁니다.
   * - force=true: TTL 무관하게 즉시 재조회합니다. 뮤테이션(추가·수정·삭제) 후 사용.
   * - 같은 컬렉션에 대해 동시에 여러 인스턴스가 loadAll()을 호출해도
   *   Firestore 요청은 단 하나만 발생하며, 나머지는 그 결과를 공유합니다.
   */
  async function loadAll(force = false) {
    if (force) cache.loadedAt.value = null;

    // TTL 캐시 히트: Firestore 호출 없이 로컬 슬라이스만 동기화
    if (cache.loadedAt.value !== null && Date.now() - cache.loadedAt.value < CACHE_TTL_MS) {
      currentPage.value = 0;
      syncSliceToRows();
      return;
    }

    // in-flight 중복 방지: 이미 진행 중인 요청의 결과를 공유
    if (cache.loadingPromise !== null) {
      isLoading.value = true;
      error.value = null;
      try {
        await cache.loadingPromise;
        currentPage.value = 0;
        syncSliceToRows();
      } catch (e) {
        error.value = e instanceof Error ? e.message : `${collectionName}를 불러오지 못했습니다.`;
      } finally {
        isLoading.value = false;
      }
      return;
    }

    // 신규 Firestore 요청
    isLoading.value = true;
    error.value = null;
    cache.loadingPromise = loadCollectionBatchFromFirestore();
    try {
      await cache.loadingPromise;
      currentPage.value = 0;
      syncSliceToRows();
    } catch (e) {
      error.value = e instanceof Error ? e.message : `${collectionName}를 불러오지 못했습니다.`;
      cache.allDocs.value = [];
      cache.filterWarning.value = null;
      cache.lastDoc.value = null;
      cache.hasMore.value = false;
    } finally {
      cache.loadingPromise = null;
      isLoading.value = false;
    }
  }

  async function loadMore() {
    if (
      !isFirebaseConfigured() ||
      !cache.hasMore.value ||
      !cache.lastDoc.value ||
      isLoading.value ||
      isLoadingMore.value
    ) {
      return;
    }
    isLoadingMore.value = true;
    error.value = null;
    try {
      const db = getFirestoreDb();
      const q = query(
        collection(db, collectionName),
        orderBy(documentId()),
        startAfter(cache.lastDoc.value),
        limit(LOAD_CAP),
      );
      const snap = await getDocs(q);
      const next = snap.docs.map((d) => ({
        id: d.id,
        data: d.data() as Record<string, unknown>,
      }));
      cache.allDocs.value = [...cache.allDocs.value, ...next];
      cache.lastDoc.value =
        snap.docs.length > 0 ? snap.docs[snap.docs.length - 1]! : cache.lastDoc.value;
      cache.hasMore.value = snap.docs.length >= LOAD_CAP;
      cache.filterWarning.value = buildWarning(cache.allDocs.value.length, cache.hasMore.value);
    } catch (e) {
      error.value = e instanceof Error ? e.message : "추가 페이지를 불러오지 못했습니다.";
    } finally {
      isLoadingMore.value = false;
    }
  }

  return {
    PAGE_SIZE_OPTIONS,
    loadCap: LOAD_CAP,
    allDocs: cache.allDocs,
    rows,
    ids,
    isLoading,
    isLoadingMore,
    error,
    filterWarning: cache.filterWarning,
    hasMore: cache.hasMore,
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
    invalidate,
    goToPage,
    prevPage,
    nextPage,
  };
}
