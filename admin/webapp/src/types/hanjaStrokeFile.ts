/**
 * 로컬 ETL·`admin/data/*.json` 등과 동일한 획 데이터 묶음 형식 (예: 架.json).
 */
export type StrokeOutlineEntry = {
  order: number;
  path: string;
  radical: number;
};

export type HanjaStrokeFileShape = {
  char: string;
  radical: number;
  font_outline: string[];
  stroke_outlines: StrokeOutlineEntry[];
};

export function emptyHanjaStrokeFileShape(char: string): HanjaStrokeFileShape {
  return {
    char: char.trim(),
    radical: 0,
    font_outline: [],
    stroke_outlines: [],
  };
}

function strokeOutlinesFromFontOutline(
  fontOutline: string[],
  radicalPerStroke: number,
): StrokeOutlineEntry[] {
  const r = Number.isFinite(radicalPerStroke) ? radicalPerStroke : 0;
  return fontOutline.map((path, i) => ({
    order: i + 1,
    path,
    radical: r,
  }));
}

export function normalizeStrokeBundle(raw: unknown):
  | { ok: true; data: HanjaStrokeFileShape }
  | { ok: false; message: string } {
  if (!raw || typeof raw !== "object") {
    return { ok: false, message: "루트는 JSON 객체여야 합니다." };
  }
  const o = raw as Record<string, unknown>;
  if (typeof o.char !== "string") {
    return { ok: false, message: '"char"는 문자열이어야 합니다.' };
  }
  if (typeof o.radical !== "number" || !Number.isFinite(o.radical)) {
    return { ok: false, message: '"radical"는 숫자여야 합니다 (예: 架.json).' };
  }
  if (!Array.isArray(o.font_outline)) {
    return { ok: false, message: '"font_outline"는 문자열 배열이어야 합니다.' };
  }
  const font_outline = o.font_outline
    .filter((x): x is string => typeof x === "string")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  if (!Array.isArray(o.stroke_outlines)) {
    return { ok: false, message: '"stroke_outlines"는 배열이어야 합니다.' };
  }
  const stroke_outlines: StrokeOutlineEntry[] = [];
  for (const item of o.stroke_outlines) {
    if (!item || typeof item !== "object") continue;
    const it = item as Record<string, unknown>;
    const order = Number(it.order);
    const path = String(it.path ?? "").trim();
    const radical = Number(it.radical);
    if (!Number.isFinite(order)) {
      return { ok: false, message: "stroke_outlines 항목에 유효한 order가 필요합니다." };
    }
    if (!path) {
      return { ok: false, message: `stroke_outlines order=${order} 에 path가 비었습니다.` };
    }
    if (!Number.isFinite(radical)) {
      return { ok: false, message: `stroke_outlines order=${order} 에 radical 숫자가 필요합니다.` };
    }
    stroke_outlines.push({ order, path, radical });
  }
  stroke_outlines.sort((a, b) => a.order - b.order);
  return {
    ok: true,
    data: {
      char: o.char.trim(),
      radical: o.radical,
      font_outline,
      stroke_outlines,
    },
  };
}

/** Firestore 문서에서 font_outline 후보를 문자열 배열로 모은다. */
export function extractFontOutlineStrings(data: Record<string, unknown>): string[] {
  const fo = data.font_outline;
  if (Array.isArray(fo)) {
    const out = fo
      .filter((x): x is string => typeof x === "string")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    if (out.length > 0) return out;
  }
  const sp = data.svg_paths;
  if (Array.isArray(sp)) {
    return sp
      .filter((x): x is string => typeof x === "string")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
  }
  return [];
}

/**
 * stroke_outlines가 비어 있고 font_outline만 있을 때, 루트 radical로 획별 항목을 만든다 (架.json 형태).
 */
export function ensureStrokeOutlinesMatchFileShape(
  data: HanjaStrokeFileShape,
): HanjaStrokeFileShape {
  if (data.stroke_outlines.length > 0 || data.font_outline.length === 0) return data;
  return {
    ...data,
    stroke_outlines: strokeOutlinesFromFontOutline(data.font_outline, data.radical),
  };
}
