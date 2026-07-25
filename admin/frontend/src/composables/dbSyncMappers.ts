import { HANJA_FIELD_MAP } from "@/types/hanjaAdminForms";

export function parseJsonField(raw: unknown): unknown {
  if (raw === null || raw === undefined) return null;
  if (typeof raw !== "string") return raw;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

/** 로컬 목록 행 → Firestore hanja_basis 문서 페이로드 */
export function localRowToFirestoreBasis(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const id = String(row.id ?? "");
  const hanjaCharacter = String(row.hanja ?? row.char ?? row.char_str ?? "");
  const extendParsed = parseJsonField(row.origin_note);
  const extendFields =
    typeof extendParsed === "object" &&
    extendParsed !== null &&
    !Array.isArray(extendParsed)
      ? (extendParsed as Record<string, unknown>)
      : {};
  const gradeValue = String(extendFields["grade"] ?? extendFields["구분"] ?? "").trim();
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
    ...extendFields,
    ...(gradeValue ? { grade: gradeValue } : {}),
    id,
    한자: hanjaCharacter,
    음: String(row[HANJA_FIELD_MAP.음] ?? ""),
    훈: String(row[HANJA_FIELD_MAP.훈] ?? ""),
    readings: Array.isArray(readings) ? readings : [],
    synonyms: Array.isArray(synonyms) ? synonyms : [],
    antonyms: Array.isArray(antonyms) ? antonyms : [],
    analogue: Array.isArray(analogue) ? analogue : [],
    variants: Array.isArray(variants) ? variants : [],
  };
}

/** Firestore hanja_basis 문서 → 로컬 SQLite upsert body */
export function firestoreBasisToLocalBody(
  documentId: string,
  data: Record<string, unknown>,
  changeNumber: number,
): Record<string, unknown> {
  const rawExtend = data.extend;
  const extend: Record<string, unknown> =
    typeof rawExtend === "object" && rawExtend !== null && !Array.isArray(rawExtend)
      ? { ...(rawExtend as Record<string, unknown>) }
      : {};
  const gradeValue = String(data["grade"] ?? data["구분"] ?? "").trim();
  if (gradeValue) extend.grade = gradeValue;
  delete extend["구분"];

  return {
    id: documentId,
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
