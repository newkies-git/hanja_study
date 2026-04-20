import {
  collection,
  documentId,
  getDocs,
  limit,
  orderBy,
  query,
  startAfter,
  type Firestore,
  type Query,
  type QueryDocumentSnapshot,
  type QuerySnapshot,
} from "firebase/firestore";

export interface HanjaWordTableRow {
  id: string;
  word: string;
  reading: string;
  meaning: string;
}

/**
 * `word` 필드에 한 글자가 포함된 hanja_word 문서를 모읍니다.
 * Firestore에 부분 문자열 인덱스가 없어 문서를 페이지로 훑으며 필터합니다.
 */
export async function fetchHanjaWordsContainingGlyphFirestore(
  db: Firestore,
  glyphRaw: string,
  options: { matchLimit?: number; maxScanned?: number; pageSize?: number } = {},
): Promise<{ rows: HanjaWordTableRow[]; scanned: number; truncated: boolean }> {
  const matchLimit = options.matchLimit ?? 200;
  const maxScanned = options.maxScanned ?? 4000;
  const pageSize = options.pageSize ?? 400;
  const needle = [...glyphRaw.trim()][0] || glyphRaw.trim();
  if (!needle) return { rows: [], scanned: 0, truncated: false };

  const rows: HanjaWordTableRow[] = [];
  let scanned = 0;
  let last: QueryDocumentSnapshot | null = null;
  let truncated = false;

  while (rows.length < matchLimit && scanned < maxScanned) {
    let q: Query;
    if (last) {
      q = query(
        collection(db, "hanja_word"),
        orderBy(documentId()),
        startAfter(last),
        limit(pageSize),
      );
    } else {
      q = query(collection(db, "hanja_word"), orderBy(documentId()), limit(pageSize));
    }
    const snap: QuerySnapshot = await getDocs(q);
    if (snap.empty) break;

    for (const d of snap.docs) {
      scanned++;
      const data = d.data() as Record<string, unknown>;
      const word = String(data.word ?? "");
      if (word.includes(needle)) {
        rows.push({
          id: d.id,
          word,
          reading: String(data.reading ?? ""),
          meaning: String(data.meaning ?? ""),
        });
        if (rows.length >= matchLimit) break;
      }
      if (scanned >= maxScanned) {
        truncated = true;
        break;
      }
    }

    last = snap.docs[snap.docs.length - 1]!;
    if (snap.docs.length < pageSize) break;
    if (rows.length >= matchLimit || scanned >= maxScanned) {
      truncated = truncated || scanned >= maxScanned;
      break;
    }
  }

  return { rows, scanned, truncated };
}
