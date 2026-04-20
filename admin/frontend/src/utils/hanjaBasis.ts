/**
 * hanja_basis 문서 ID 결정 로직.
 * HanjaRegisterFormModal 등에서 동일하게 사용.
 *
 * 계약: Firestore `hanja_basis/{docId}` 문서는 마스터(한자·음·훈 등)에 더해
 * ETL·확장 필드(grade·etl 등)를 **같은 문서**로 확장한다. 예전 `hanja_extend` 전용 필드도 여기로 흡수한다.
 * 로컬 `hanja.origin_note`(JSON)에는 동일 docId 기준으로 `hanja_extend` 문서 JSON 통째를 둔다.
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
  row: Record<string, unknown>,
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

export interface HanjaReading {
  음: string;
  훈: string;
  primary: boolean;
}

/** hanja_basis 알려진 필드 목록 (클립보드 컬럼 매핑에서 사용) */
export const HANJA_BASIS_FIELDS = [
  "한자",
  "음",
  "훈",
  "훈음",
  "전체",
  "grade",
  "readings",
  "synonyms",
  "antonyms",
  "etymology",
  "meaning",
  "words",
  "idioms",
  "etl",
] as const;

/** 확장 묶음 기준 최대 `max`자 슬라이스 */
export function sliceGraphemes(value: unknown, max: number): string {
  if (max <= 0) return "";
  const s = String(value ?? "").trim();
  if (!s) return "";
  return [...s].slice(0, max).join("");
}

/** 정규화된 한자 목록 행 (HanjaListCard에서 사용) */
export interface HanjaListRow {
  /** 탐색 키 (라우터 파라미터 id) */
  id: string;
  /** ID 열에 표시할 문자열 (컴포넌트에서 6ch로 자름) */
  displayId: string;
  char: string;
  reading: string;
  meaning: string;
  /** 등급(중/고)·sync 상태 등 미리 포매팅된 레이블 */
  tag: string;
}

/** 첫 한 글자만 반환, 없으면 em-dash */
export function oneGraphemeOrDash(value: unknown): string {
  const s = String(value ?? "").trim();
  if (!s) return "—";
  return [...s][0] ?? "—";
}

/** Vue Router `params` 값을 단일 문자열로 정규화한다. */
export function routeParamAsString(raw: unknown): string {
  if (typeof raw === "string") return raw;
  if (Array.isArray(raw) && raw.length > 0) return String(raw[0]);
  return "";
}

/**
 * `H6C34` 형 hanja_basis 문서 ID → 코드포인트 한 글자.
 * DB에 `한자`가 비어 있어도 목록·타일 미리보기와 맞출 때 사용한다.
 */
export function glyphFromHanjaBasisDocId(docId: string): string {
  const s = String(docId ?? "").trim();
  const m = /^H([0-9A-Fa-f]{2,8})$/i.exec(s);
  if (!m) return "";
  const cp = parseInt(m[1], 16);
  if (!Number.isFinite(cp) || cp < 0 || cp > 0x10ffff) return "";
  try {
    return String.fromCodePoint(cp);
  } catch {
    return "";
  }
}

/** hanja_basis Firestore 저장 시 포함할 전체 컬럼 순서 */
export const HANJA_BASIS_COLUMN_ORDER = [
  "id",
  "한자",
  "음",
  "훈",
  "훈음",
  "전체",
  "grade",
  "readings",
  "synonyms",
  "antonyms",
  "etymology",
  "meaning",
  "words",
  "idioms",
  "etl",
] as const;
