import { reactive, ref } from "vue";
import {
  collection,
  doc,
  documentId,
  getCountFromServer,
  getDocs,
  limit,
  orderBy,
  query,
  startAfter,
  writeBatch,
  type Firestore,
  type Query,
  type QueryDocumentSnapshot,
  type QuerySnapshot,
} from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useWorkbenchStore } from "@/stores/workbench";
import { isLocalApiEnabled, localApiFetch } from "@/config/localApi";
import {
  firestoreBasisToLocalBody,
  localRowToFirestoreBasis,
  parseJsonField,
} from "@/composables/dbSyncMappers";

export type SyncTableKey = "hanja_basis" | "hanja_stroke" | "hanja_word";
export type SyncPhase = "idle" | "running" | "done" | "error";

export interface TableSyncState {
  label: string;
  phase: SyncPhase;
  processed: number;
  total: number;
  errorMessage: string | null;
}

export { localRowToFirestoreBasis } from "@/composables/dbSyncMappers";

function createTableStates(): Record<SyncTableKey, TableSyncState> {
  return {
    hanja_basis: {
      label: "hanja ↔ hanja_basis",
      phase: "idle",
      processed: 0,
      total: 0,
      errorMessage: null,
    },
    hanja_stroke: {
      label: "hanja_stroke",
      phase: "idle",
      processed: 0,
      total: 0,
      errorMessage: null,
    },
    hanja_word: {
      label: "hanja_word",
      phase: "idle",
      processed: 0,
      total: 0,
      errorMessage: null,
    },
  };
}

function markRunningTableError(
  tables: Record<SyncTableKey, TableSyncState>,
  msg: string,
): void {
  for (const key of ["hanja_basis", "hanja_stroke", "hanja_word"] as SyncTableKey[]) {
    if (tables[key].phase === "running") {
      tables[key].phase = "error";
      tables[key].errorMessage = msg;
      return;
    }
  }
  tables.hanja_basis.phase = "error";
  tables.hanja_basis.errorMessage = msg;
}

async function paginateFirestore(
  firestore: Firestore,
  collectionName: string,
  pageSize: number,
  callback: (docs: QueryDocumentSnapshot[]) => Promise<void>,
): Promise<void> {
  let lastDocument: QueryDocumentSnapshot | null = null;
  while (true) {
    const firestoreQuery: Query = lastDocument
      ? query(
          collection(firestore, collectionName),
          orderBy(documentId()),
          startAfter(lastDocument),
          limit(pageSize),
        )
      : query(
          collection(firestore, collectionName),
          orderBy(documentId()),
          limit(pageSize),
        );
    const snapshot: QuerySnapshot = await getDocs(firestoreQuery);
    if (snapshot.empty) break;
    await callback(snapshot.docs);
    lastDocument = snapshot.docs[snapshot.docs.length - 1]!;
    if (snapshot.docs.length < pageSize) break;
  }
}

async function fetchLocalStats(): Promise<{
  hanja: number;
  hanja_stroke: number;
  hanja_word: number;
}> {
  const response = await localApiFetch("/api/sync/stats");
  if (!response.ok) throw new Error("로컬 건수를 가져오지 못했습니다.");
  return response.json();
}

async function fetchActiveSessionId(): Promise<number> {
  const workbenchStore = useWorkbenchStore();
  await workbenchStore.fetchLocalSession();
  if (!workbenchStore.localSession?.id) {
    throw new Error("활성 채번이 없습니다. 상단 변경관리에서 채번을 발급하세요.");
  }
  return Number(workbenchStore.localSession.id);
}

async function firestoreCollectionCount(
  firestore: Firestore,
  collectionName: string,
): Promise<number> {
  const snapshot = await getCountFromServer(
    query(collection(firestore, collectionName)),
  );
  return Number(snapshot.data().count);
}

export function useDbSync() {
  const isBusy = ref(false);
  const tables = reactive(createTableStates());

  function resetTables() {
    Object.assign(tables, createTableStates());
  }

  async function runLocalToServer(): Promise<void> {
    if (!isLocalApiEnabled) {
      throw new Error("로컬 API가 비활성화되어 있습니다. VITE_USE_LOCAL_API=true 로 설정하세요.");
    }
    if (!isFirebaseConfigured()) throw new Error("Firebase가 설정되지 않았습니다.");
    resetTables();
    isBusy.value = true;
    try {
      const firestore = getFirestoreDb();
      const stats = await fetchLocalStats();
      const pageSize = 100;

      tables.hanja_basis.phase = "running";
      tables.hanja_basis.total = stats.hanja;
      tables.hanja_basis.processed = 0;
      let page = 1;
      let more = true;
      while (more) {
        const response = await localApiFetch(`/api/hanja?page=${page}&limit=${pageSize}`);
        if (!response.ok) throw new Error("로컬 hanja 목록을 불러오지 못했습니다.");
        const payload = (await response.json()) as { data?: Record<string, unknown>[] };
        const list = payload.data ?? [];
        if (list.length === 0) break;
        let batch = writeBatch(firestore);
        let ops = 0;
        for (const row of list) {
          const basisDocument = localRowToFirestoreBasis(row);
          const id = String(basisDocument.id ?? "");
          if (!id) continue;
          batch.set(doc(firestore, "hanja_basis", id), basisDocument, { merge: true });
          ops++;
          tables.hanja_basis.processed++;
          if (ops >= 400) {
            await batch.commit();
            batch = writeBatch(firestore);
            ops = 0;
          }
        }
        if (ops > 0) await batch.commit();
        if (list.length < pageSize) more = false;
        else page++;
      }
      tables.hanja_basis.phase = "done";

      tables.hanja_stroke.phase = "running";
      tables.hanja_stroke.total = stats.hanja_stroke;
      tables.hanja_stroke.processed = 0;
      page = 1;
      more = true;
      while (more) {
        const response = await localApiFetch(`/api/hanja_stroke/list?page=${page}&limit=${pageSize}`);
        if (!response.ok) throw new Error("로컬 hanja_stroke 목록을 불러오지 못했습니다.");
        const payload = (await response.json()) as { data?: Record<string, unknown>[] };
        const list = payload.data ?? [];
        let batch = writeBatch(firestore);
        let ops = 0;
        for (const row of list) {
          const id = String(row.id);
          const font_outline = parseJsonField(row.font_outline) ?? [];
          const stroke_outlines = parseJsonField(row.stroke_outlines) ?? [];
          batch.set(
            doc(firestore, "hanja_stroke", id),
            { char_str: row.char_str, radical: row.radical, font_outline, stroke_outlines, svg_paths: font_outline },
            { merge: true },
          );
          ops++;
          tables.hanja_stroke.processed++;
          if (ops >= 400) {
            await batch.commit();
            batch = writeBatch(firestore);
            ops = 0;
          }
        }
        if (ops > 0) await batch.commit();
        if (list.length < pageSize) more = false;
        else page++;
      }
      tables.hanja_stroke.phase = "done";

      tables.hanja_word.phase = "running";
      tables.hanja_word.total = stats.hanja_word;
      tables.hanja_word.processed = 0;
      page = 1;
      more = true;
      while (more) {
        const response = await localApiFetch(`/api/hanja_word/list?page=${page}&limit=${pageSize}`);
        if (!response.ok) throw new Error("로컬 hanja_word 목록을 불러오지 못했습니다.");
        const payload = (await response.json()) as { data?: Record<string, unknown>[] };
        const list = payload.data ?? [];
        let batch = writeBatch(firestore);
        let ops = 0;
        for (const row of list) {
          const docId: string =
            (row.server_doc_id != null && String(row.server_doc_id)) ||
            `LW${String(row.id ?? "")}`;
          const relatedHanja = Array.isArray(row.related_hanja)
            ? row.related_hanja
            : ((parseJsonField(row.related_hanja) as unknown[] | null) ?? []);
          batch.set(
            doc(firestore, "hanja_word", docId),
            {
              word_id: docId,
              word: row.word,
              reading: row.reading ?? "",
              meaning: row.meaning ?? "",
              related_hanja: relatedHanja,
            },
            { merge: true },
          );
          ops++;
          tables.hanja_word.processed++;
          if (ops >= 400) {
            await batch.commit();
            batch = writeBatch(firestore);
            ops = 0;
          }
        }
        if (ops > 0) await batch.commit();
        if (list.length < pageSize) more = false;
        else page++;
      }
      tables.hanja_word.phase = "done";
    } catch (e) {
      markRunningTableError(tables, e instanceof Error ? e.message : "동기화 실패");
      throw e;
    } finally {
      isBusy.value = false;
    }
  }

  async function runServerToLocal(): Promise<void> {
    if (!isLocalApiEnabled) {
      throw new Error("로컬 API가 비활성화되어 있습니다. VITE_USE_LOCAL_API=true 로 설정하세요.");
    }
    if (!isFirebaseConfigured()) throw new Error("Firebase가 설정되지 않았습니다.");
    resetTables();
    isBusy.value = true;
    try {
      const firestore = getFirestoreDb();
      const changeNumber = await fetchActiveSessionId();
      const pageSize = 100;

      tables.hanja_basis.total = await firestoreCollectionCount(firestore, "hanja_basis");
      tables.hanja_basis.phase = "running";
      tables.hanja_basis.processed = 0;
      await paginateFirestore(firestore, "hanja_basis", pageSize, async (docs) => {
        for (const d of docs) {
          const body = firestoreBasisToLocalBody(
            d.id,
            d.data() as Record<string, unknown>,
            changeNumber,
          );
          const response = await localApiFetch("/api/hanja/upsert", {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
          });
          if (!response.ok) {
            const err = (await response.json().catch(() => ({}))) as { error?: string };
            throw new Error(err.error || "hanja upsert 실패");
          }
          tables.hanja_basis.processed++;
        }
      });
      tables.hanja_basis.phase = "done";

      tables.hanja_stroke.total = await firestoreCollectionCount(firestore, "hanja_stroke");
      tables.hanja_stroke.phase = "running";
      tables.hanja_stroke.processed = 0;
      await paginateFirestore(firestore, "hanja_stroke", pageSize, async (docs) => {
        for (const d of docs) {
          const data = d.data() as Record<string, unknown>;
          const fo = (data.font_outline ?? data.svg_paths ?? []) as unknown;
          const so = (data.stroke_outlines ?? []) as unknown;
          const response = await localApiFetch(`/api/hanja_stroke/${encodeURIComponent(d.id)}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              change_number: changeNumber,
              char_str: String(data.char_str ?? d.id),
              radical: data.radical,
              font_outline: fo,
              stroke_outlines: so,
            }),
          });
          if (!response.ok) throw new Error("hanja_stroke 저장 실패");
          tables.hanja_stroke.processed++;
        }
      });
      tables.hanja_stroke.phase = "done";

      tables.hanja_word.total = await firestoreCollectionCount(firestore, "hanja_word");
      tables.hanja_word.phase = "running";
      tables.hanja_word.processed = 0;
      await paginateFirestore(firestore, "hanja_word", pageSize, async (docs) => {
        for (const d of docs) {
          const data = d.data() as Record<string, unknown>;
          const word = String(data.word ?? "");
          if (!word) {
            tables.hanja_word.processed++;
            continue;
          }
          const response = await localApiFetch("/api/hanja_word/upsert", {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              change_number: changeNumber,
              server_doc_id: d.id,
              word,
              reading: data.reading ?? "",
              meaning: data.meaning ?? "",
              related_hanja: Array.isArray(data.related_hanja) ? data.related_hanja : [],
            }),
          });
          if (!response.ok) throw new Error("hanja_word 저장 실패");
          tables.hanja_word.processed++;
        }
      });
      tables.hanja_word.phase = "done";
    } catch (e) {
      markRunningTableError(tables, e instanceof Error ? e.message : "동기화 실패");
      throw e;
    } finally {
      isBusy.value = false;
    }
  }

  return {
    isBusy,
    tables,
    resetTables,
    runLocalToServer,
    runServerToLocal,
  };
}
