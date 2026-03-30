import {
  collection,
  doc,
  getDocs,
  limit,
  orderBy,
  query,
  startAfter,
  where,
  writeBatch,
  type DocumentData,
  type Firestore,
  type Query,
  type QueryDocumentSnapshot,
  type QuerySnapshot,
} from 'firebase/firestore';

export function useCascadeDelete(args: {
  db: Firestore | null | undefined;
  firebaseInitError: string | null | undefined;
  basisCollection: string;
  extendCollection: string;
  strokeCollection: string;
  wordCollection: string;
}) {
  const { db, firebaseInitError, basisCollection, extendCollection, strokeCollection, wordCollection } = args;

  async function deleteAllRelatedByHanjaId(collectionName: string, hanjaId: string) {
    if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
    const PAGE = 400;
    let last: QueryDocumentSnapshot<DocumentData> | null = null;
    for (;;) {
      const base: Query<DocumentData> = query(
        collection(db, collectionName),
        where('hanjaId', '==', hanjaId),
        orderBy('__name__'),
        limit(PAGE),
      );
      const q2: Query<DocumentData> = last ? query(base, startAfter(last)) : base;
      const snap: QuerySnapshot<DocumentData> = await getDocs(q2);
      if (snap.docs.length === 0) break;
      const batch = writeBatch(db);
      for (const d of snap.docs) batch.delete(d.ref);
      await batch.commit();
      last = snap.docs[snap.docs.length - 1];
      if (snap.docs.length < PAGE) break;
    }
  }

  async function cascadeDeleteByHanjaIds(hanjaIds: string[]) {
    if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');

    const PER_BATCH = 200; // 2 ops/doc => 400 ops/batch
    for (let i = 0; i < hanjaIds.length; i += PER_BATCH) {
      const chunk = hanjaIds.slice(i, i + PER_BATCH);
      const batch = writeBatch(db);
      for (const id of chunk) {
        batch.delete(doc(db, basisCollection, id));
        batch.delete(doc(db, extendCollection, id));
      }
      await batch.commit();
    }

    for (const id of hanjaIds) {
      await deleteAllRelatedByHanjaId(strokeCollection, id);
      await deleteAllRelatedByHanjaId(wordCollection, id);
    }
  }

  return { cascadeDeleteByHanjaIds };
}

