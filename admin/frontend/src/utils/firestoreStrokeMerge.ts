/** Firestore 문서의 svg_paths 배열을 정규화한 문자열 목록으로 만듭니다. */
export function extractSvgPaths(data: Record<string, unknown>): string[] {
  const raw = data.svg_paths;
  if (!Array.isArray(raw)) return [];
  return (raw as unknown[])
    .filter((x): x is string => typeof x === "string" && x.trim().length > 0)
    .map((x) => x.trim());
}

/** 더 많은 비어 있지 않은 path를 가진 배열을 선택합니다. */
export function preferLongerSvgPaths(a: string[], b: string[]): string[] {
  return b.length > a.length ? b : a;
}
