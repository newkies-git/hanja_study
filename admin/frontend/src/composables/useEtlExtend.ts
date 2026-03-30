import {
  collection,
  doc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  startAfter,
  writeBatch,
  type DocumentData,
  type Firestore,
  type Query,
  type QueryDocumentSnapshot,
  type QuerySnapshot,
} from 'firebase/firestore';
import { ref } from 'vue';
import type { RawHanjaRow } from './dashboardTypes';
import { mapHanja } from './useDashboardUtils';

export function useEtlExtend(args: {
  db: Firestore | null | undefined;
  firebaseInitError: string | null | undefined;
  basisCollection: string;
  extendCollection: string;
  strokeCollection: string;
  wordCollection: string;
}) {
  const { db, firebaseInitError, basisCollection, extendCollection, strokeCollection, wordCollection } = args;

  const etlRunning = ref(false);
  const etlMessage = ref('');
  const etlProgress = ref<{ processed: number; written: number; errors: number } | null>(null);

  function deriveExtend(docId: string, basis: RawHanjaRow): Record<string, unknown> {
    const cpHex = docId.startsWith('U+') ? docId.slice(2) : '';
    const cp = cpHex ? parseInt(cpHex, 16) : null;
    return {
      key: docId,
      codePoint: Number.isFinite(cp as number) ? cp : null,
      hanjaId: docId,
      한자: basis.hanja,
      음: basis.음,
      훈: basis.훈,
      전체: basis.전체,
      훈음: basis.훈음,
      구분: basis.구분,
      etlVersion: 1,
      etlUpdatedAt: serverTimestamp(),
    };
  }

  async function runEtlForCurrentPage(rows: RawHanjaRow[]) {
    etlMessage.value = '';
    try {
      if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
      etlRunning.value = true;
      etlProgress.value = { processed: 0, written: 0, errors: 0 };

      const batch = writeBatch(db);
      for (const r of rows) {
        etlProgress.value.processed++;
        batch.set(doc(db, extendCollection, r.id), deriveExtend(r.id, r), { merge: true });
        etlProgress.value.written++;
      }
      await batch.commit();
      etlMessage.value =
        `ETL 완료(현재 페이지): ${etlProgress.value.written}건\n` +
        `- extend: ${extendCollection}\n` +
        `- stroke/word: ${strokeCollection}, ${wordCollection} (현재는 별도 소스/규격 확정 후 생성 예정)`;
    } catch (e: any) {
      etlMessage.value = e?.message || String(e);
    } finally {
      etlRunning.value = false;
    }
  }

  async function runEtlAll() {
    etlMessage.value = '';
    try {
      if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
      etlRunning.value = true;
      etlProgress.value = { processed: 0, written: 0, errors: 0 };

      const qBase: Query<DocumentData> = query(collection(db, basisCollection), orderBy('__name__'));
      let last: QueryDocumentSnapshot<DocumentData> | null = null;
      const PAGE = 400;
      for (;;) {
        const q2: Query<DocumentData> = last ? query(qBase, startAfter(last), limit(PAGE)) : query(qBase, limit(PAGE));
        const snap: QuerySnapshot<DocumentData> = await getDocs(q2);
        if (snap.docs.length === 0) break;

        const CHUNK = 450;
        for (let i = 0; i < snap.docs.length; i += CHUNK) {
          const batch = writeBatch(db);
          const part = snap.docs.slice(i, i + CHUNK);
          for (const d of part) {
            const basis = mapHanja(d.id, d.data() as Record<string, unknown>);
            etlProgress.value.processed++;
            batch.set(doc(db, extendCollection, d.id), deriveExtend(d.id, basis), { merge: true });
            etlProgress.value.written++;
          }
          await batch.commit();
        }

        last = snap.docs[snap.docs.length - 1];
        if (snap.docs.length < PAGE) break;
      }

      etlMessage.value = `ETL 완료(전체): ${etlProgress.value.written}건`;
    } catch (e: any) {
      etlMessage.value = e?.message || String(e);
    } finally {
      etlRunning.value = false;
    }
  }

  return { etlRunning, etlMessage, etlProgress, runEtlForCurrentPage, runEtlAll };
}

