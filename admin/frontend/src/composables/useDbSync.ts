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
import { HANJA_FIELD_MAP } from "@/types/hanjaAdminForms";

export type SyncTableKey = "hanja_basis" | "hanja_stroke" | "hanja_word";
export type SyncPhase = "idle" | "running" | "done" | "error";

export interface TableSyncState {
  label: string;
  phase: SyncPhase;
  processed: number;
  total: number;
  errorMessage: string | null;
}

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

function parseJsonField(raw: unknown): unknown {
  if (raw === null || raw === undefined) return null;
  if (typeof raw !== "string") return raw;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
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
  db: Firestore,
  colName: string,
  pageSize: number,
  callback: (docs: QueryDocumentSnapshot[]) => Promise<void>,
): Promise<void> {
  let last: QueryDocumentSnapshot | null = null;
  while (true) {
    const q: Query = last
      ? query(
          collection(db, colName),
          orderBy(documentId()),
          startAfter(last),
          limit(pageSize),
        )
      : query(collection(db, colName), orderBy(documentId()), limit(pageSize));
    const snap: QuerySnapshot = await getDocs(q);
    if (snap.empty) break;
    await callback(snap.docs);
    last = snap.docs[snap.docs.length - 1]!;
    if (snap.docs.length < pageSize) break;
  }
}

/** 로컬 목록 행 → Firestore hanja_basis 문서 페이로드 */
export function localRowToFirestoreBasis(row: Record<string, unknown>): Record<string, unknown> {
  const id = String(row.id ?? "");
  const han = String(row.hanja ?? row.char ?? row.char_str ?? "");
  const extParsed = parseJsonField(row.origin_note);
  const ext =
    typeof extParsed === "object" && extParsed !== null && !Array.isArray(extParsed)
      ? (extParsed as Record<string, unknown>)
      : {};
  const gradeVal = String(ext["grade"] ?? ext["구분"] ?? "").trim();
  const readings = Array.isArray(row.readings)
    ? row.readings
    : (parseJsonField(row.readings) as unknown[] | null);
  const synonyms = Array.isArray(row.synonyms)
    ? row.synonyms
    : (parseJsonField(row.synonyms) as unknown[] | null);
  const antonyms = Array.isArray(row.antonyms)
    ? row.antonyms
    : (parseJsonField(row.antonyms) as unknown[] | null);
  const analogue = Array.isArray(row.analogue)
    ? row.analogue
    : (parseJsonField(row.analogue ?? row.Analogue) as unknown[] | null);
  const variants = Array.isArray(row.variants)
    ? row.variants
    : (parseJsonField(row.variants) as unknown[] | null);
  return {
    ...ext,
    ...(gradeVal ? { grade: gradeVal } : {}),
    id,
    한자: han,
    음: String(row[HANJA_FIELD_MAP.음] ?? ""),
    훈: String(row[HANJA_FIELD_MAP.훈] ?? ""),
    readings: Array.isArray(readings) ? readings : [],
    synonyms: Array.isArray(synonyms) ? synonyms : [],
    antonyms: Array.isArray(antonyms) ? antonyms : [],
    analogue: Array.isArray(analogue) ? analogue : [],
    variants: Array.isArray(variants) ? variants : [],
  };
}

function firestoreBasisToLocalBody(
  docId: string,
  data: Record<string, unknown>,
  changeNumber: number,
): Record<string, unknown> {
  const rawExt = data.extend;
  const extend: Record<string, unknown> =
    typeof rawExt === "object" && rawExt !== null && !Array.isArray(rawExt)
      ? { ...(rawExt as Record<string, unknown>) }
      : {};
  const gradeVal = String(data["grade"] ?? data["구분"] ?? "").trim();
  if (gradeVal) extend.grade = gradeVal;
  delete extend["구분"];

  return {
    id: docId,
    change_number: changeNumber,
    [HANJA_FIELD_MAP.한자]: String(data["한자"] ?? ""),
    [HANJA_FIELD_MAP.음]: String(data["음"] ?? ""),
    [HANJA_FIELD_MAP.훈]: String(data["훈"] ?? ""),
    radical: data.radical ?? "",
    radical_meaning: data.radical_meaning ?? "",
    stroke_count: data.stroke_count ?? "",
    school_level: data.school_level ?? "",
    shape_explanation: data.shape_explanation ?? "",
    etymology: data.etymology ?? data.Etymology ?? "",
    difficulty: data.difficulty ?? "",
    readings: Array.isArray(data.readings) ? data.readings : [],
    synonyms: Array.isArray(data.synonyms) ? data.synonyms : [],
    antonyms: Array.isArray(data.antonyms) ? data.antonyms : [],
    analogue: Array.isArray(data.analogue) ? data.analogue : [],
    variants: Array.isArray(data.variants) ? data.variants : [],
    extend,
  };
}

async function fetchLocalStats(): Promise<{
  hanja: number;
  hanja_stroke: number;
  hanja_word: number;
}> {
  const res = await localApiFetch("/api/sync/stats");
  if (!res.ok) throw new Error("로컬 건수를 가져오지 못했습니다.");
  return res.json();
}

async function fetchActiveSessionId(): Promise<number> {
  const wb = useWorkbenchStore();
  await wb.fetchLocalSession();
  if (!wb.localSession?.id) {
    throw new Error("활성 채번이 없습니다. 상단 변경관리에서 채번을 발급하세요.");
  }
  return Number(wb.localSession.id);
}

async function firestoreCollectionCount(db: Firestore, col: string): Promise<number> {
  const snap = await getCountFromServer(query(collection(db, col)));
  return Number(snap.data().count);
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
      const db = getFirestoreDb();
      const stats = await fetchLocalStats();
      const pageSize = 100;

      tables.hanja_basis.phase = "running";
      tables.hanja_basis.total = stats.hanja;
      tables.hanja_basis.processed = 0;
      let page = 1;
      let more = true;
      while (more) {
        const res = await localApiFetch(`/api/hanja?page=${page}&limit=${pageSize}`);
        if (!res.ok) throw new Error("로컬 hanja 목록을 불러오지 못했습니다.");
        const j = (await res.json()) as { data?: Record<string, unknown>[] };
        const list = j.data ?? [];
        if (list.length === 0) break;
        let batch = writeBatch(db);
        let ops = 0;
        for (const row of list) {
          const payload = localRowToFirestoreBasis(row);
          const id = String(payload.id ?? "");
          if (!id) continue;
          batch.set(doc(db, "hanja_basis", id), payload, { merge: true });
          ops++;
          tables.hanja_basis.processed++;
          if (ops >= 400) {
            await batch.commit();
            batch = writeBatch(db);
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
        const res = await localApiFetch(`/api/hanja_stroke/list?page=${page}&limit=${pageSize}`);
        if (!res.ok) throw new Error("로컬 hanja_stroke 목록을 불러오지 못했습니다.");
        const j = (await res.json()) as { data?: Record<string, unknown>[] };
        const list = j.data ?? [];
        let batch = writeBatch(db);
        let ops = 0;
        for (const row of list) {
          const id = String(row.id);
          const font_outline = parseJsonField(row.font_outline) ?? [];
          const stroke_outlines = parseJsonField(row.stroke_outlines) ?? [];
          batch.set(
            doc(db, "hanja_stroke", id),
            { char_str: row.char_str, radical: row.radical, font_outline, stroke_outlines, svg_paths: font_outline },
            { merge: true },
          );
          ops++;
          tables.hanja_stroke.processed++;
          if (ops >= 400) {
            await batch.commit();
            batch = writeBatch(db);
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
        const res = await localApiFetch(`/api/hanja_word/list?page=${page}&limit=${pageSize}`);
        if (!res.ok) throw new Error("로컬 hanja_word 목록을 불러오지 못했습니다.");
        const j = (await res.json()) as { data?: Record<string, unknown>[] };
        const list = j.data ?? [];
        let batch = writeBatch(db);
        let ops = 0;
        for (const row of list) {
          const docId: string =
            (row.server_doc_id != null && String(row.server_doc_id)) ||
            `LW${String(row.id ?? "")}`;
          const relatedHanja = Array.isArray(row.related_hanja)
            ? row.related_hanja
            : ((parseJsonField(row.related_hanja) as unknown[] | null) ?? []);
          batch.set(
            doc(db, "hanja_word", docId),
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
            batch = writeBatch(db);
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
      const db = getFirestoreDb();
      const changeNumber = await fetchActiveSessionId();
      const pageSize = 100;

      tables.hanja_basis.total = await firestoreCollectionCount(db, "hanja_basis");
      tables.hanja_basis.phase = "running";
      tables.hanja_basis.processed = 0;
      await paginateFirestore(db, "hanja_basis", pageSize, async (docs) => {
        for (const d of docs) {
          const body = firestoreBasisToLocalBody(
            d.id,
            d.data() as Record<string, unknown>,
            changeNumber,
          );
          const res = await localApiFetch("/api/hanja/upsert", {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
          });
          if (!res.ok) {
            const err = (await res.json().catch(() => ({}))) as { error?: string };
            throw new Error(err.error || "hanja upsert 실패");
          }
          tables.hanja_basis.processed++;
        }
      });
      tables.hanja_basis.phase = "done";

      tables.hanja_stroke.total = await firestoreCollectionCount(db, "hanja_stroke");
      tables.hanja_stroke.phase = "running";
      tables.hanja_stroke.processed = 0;
      await paginateFirestore(db, "hanja_stroke", pageSize, async (docs) => {
        for (const d of docs) {
          const data = d.data() as Record<string, unknown>;
          const fo = (data.font_outline ?? data.svg_paths ?? []) as unknown;
          const so = (data.stroke_outlines ?? []) as unknown;
          const res = await localApiFetch(`/api/hanja_stroke/${encodeURIComponent(d.id)}`, {
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
          if (!res.ok) throw new Error("hanja_stroke 저장 실패");
          tables.hanja_stroke.processed++;
        }
      });
      tables.hanja_stroke.phase = "done";

      tables.hanja_word.total = await firestoreCollectionCount(db, "hanja_word");
      tables.hanja_word.phase = "running";
      tables.hanja_word.processed = 0;
      await paginateFirestore(db, "hanja_word", pageSize, async (docs) => {
        for (const d of docs) {
          const data = d.data() as Record<string, unknown>;
          const word = String(data.word ?? "");
          if (!word) {
            tables.hanja_word.processed++;
            continue;
          }
          const res = await localApiFetch("/api/hanja_word/upsert", {
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
          if (!res.ok) throw new Error("hanja_word 저장 실패");
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
