/**
 * hanja_basis 문서 ID 결정 로직.
 * BasisFormModal·ClipboardPastePanel 양쪽에서 동일하게 사용.
 */

function safeDocId(raw: string, fallback: string): string {
  const s = raw.replace(/\//g, "_").replace(/[\s#?[\]]/g, "_").slice(0, 500);
  return s || fallback;
}

/**
 * 행 데이터로부터 Firestore 문서 ID를 결정합니다.
 * 1순위: 한자 첫 글자의 H+코드포인트 (예: H6C34)
 * 2순위: id 열이 H+16진 형식인 경우
 * 3순위: id 열을 안전하게 변환
 */
export function resolveHanjaBasisDocId(
  row: Record<string, string>,
): string | null {
  const hanja = String(row["한자"] ?? "").trim();
  if (hanja.length > 0) {
    const cp = hanja.codePointAt(0);
    if (cp !== undefined) return `H${cp.toString(16).toUpperCase()}`;
  }
  const idCol = String(row["id"] ?? "").trim();
  const hex = /^H([0-9A-Fa-f]+)$/i.exec(idCol);
  if (hex) return `H${hex[1]!.toUpperCase()}`;
  if (idCol) {
    const s = safeDocId(idCol, "");
    return s || null;
  }
  return null;
}

/** hanja_basis 알려진 필드 목록 (클립보드 컬럼 매핑에서 사용) */
export const HANJA_BASIS_FIELDS = ["한자", "음", "훈", "훈음", "전체", "구분"] as const;

/** hanja_basis Firestore 저장 시 포함할 전체 컬럼 순서 */
export const HANJA_BASIS_COLUMN_ORDER = [
  "id",
  "음",
  "한자",
  "훈",
  "전체",
  "구분",
  "훈음",
] as const;
