import type { HanjaReading } from "@/utils/hanjaBasis";

/**
 * Firestore `hanja_basis` 한국어 키 → 로컬 SQLite 영문 컬럼명 매핑 테이블.
 * 양방향 변환 함수(useDbSync)가 이 테이블을 참조한다.
 */
export const HANJA_FIELD_MAP = {
  한자: "char_str",
  음: "reading",
  훈: "meaning",
} as const satisfies Record<string, string>;

/**
 * basis·SQLite 상세·모달에서 공유하는 편집 폼 필드(명시 키로 v-model 타입을 좁힌다).
 */
export interface HanjaDetailFormState {
  id: string;
  char_str: string;
  한자: string;
  음: string;
  훈: string;
  훈음: string;
  전체: string;
  /** Firestore `hanja_basis`·로컬 `origin_note`(JSON)와 동일 키 (중/고 등) */
  grade: string;
  readings: HanjaReading[];
  synonyms: string[];
  antonyms: string[];
  analogue: string[];
  etymology: string;
  meaning: string;
  words: string[];
  idioms: string[];
  etl: string;
  reading: string;
  radical: string;
  radical_meaning: string;
  stroke_count: string;
  school_level: string;
  shape_explanation: string;
  difficulty: string;
  variants: string[];
  extend: Record<string, unknown>;
  _importedAt?: unknown;
  _updatedAt?: unknown;
}

export function createEmptyHanjaBasisFormRecord(): HanjaDetailFormState {
  return {
    id: "",
    char_str: "",
    한자: "",
    음: "",
    훈: "",
    훈음: "",
    전체: "",
    grade: "",
    readings: [],
    synonyms: [],
    antonyms: [],
    analogue: [],
    etymology: "",
    meaning: "",
    words: [],
    idioms: [],
    etl: "",
    reading: "",
    radical: "",
    radical_meaning: "",
    stroke_count: "",
    school_level: "",
    shape_explanation: "",
    difficulty: "",
    variants: [],
    extend: {},
  };
}

export function createEmptyLocalHanjaFormRecord(): HanjaDetailFormState {
  return createEmptyHanjaBasisFormRecord();
}

const RELATED_TAG_KEYS = ["synonyms", "antonyms", "analogue", "variants", "words", "idioms"] as const;

/** API·Firestore에서 문자열·JSON 문자열·콤마 구분 등으로 올 수 있는 값을 태그 배열로 통일 */
export function coerceHanjaStringArray(raw: unknown): string[] {
  if (raw === undefined || raw === null) return [];
  if (Array.isArray(raw)) {
    return raw
      .map((x) => {
        if (x && typeof x === "object" && !Array.isArray(x)) {
          const rec = x as Record<string, unknown>;
          const char = String(rec.char ?? rec["한자"] ?? rec.word ?? "").trim();
          const reading = String(rec["음"] ?? rec.reading ?? "").trim();
          const meaning = String(rec["훈"] ?? rec.meaning ?? "").trim();
          if (char.length > 0) {
            const parts = [char, reading, meaning].filter((v) => v.length > 0);
            return parts.join(", ");
          }
        }
        return String(x).trim();
      })
      .filter((t) => t.length > 0);
  }
  if (typeof raw === "string") {
    const t = raw.trim();
    if (!t) return [];
    try {
      const parsed = JSON.parse(t) as unknown;
      if (Array.isArray(parsed)) {
        return parsed.map((x) => String(x).trim()).filter((s) => s.length > 0);
      }
    } catch {
      /* 단일 문자열 */
    }
    return t
      .split(/[,，\s]+/)
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
  }
  return [];
}

/**
 * 유의어·반의어·이체자·단어·성어는 DB에 `extend` / `origin_note`(JSON) 안에만 있을 수 있다.
 * 상세 폼 탭(관련 한자)에 맞게 채운다.
 */
export function hydrateHanjaRelatedFieldsFromExtend(form: HanjaDetailFormState): void {
  const ex =
    form.extend && typeof form.extend === "object" && !Array.isArray(form.extend)
      ? (form.extend as Record<string, unknown>)
      : {};

  const formRec = form as unknown as Record<string, unknown>;
  for (const key of RELATED_TAG_KEYS) {
    const top = formRec[key];
    let next = coerceHanjaStringArray(top);
    if (next.length === 0) next = coerceHanjaStringArray(ex[key]);
    formRec[key] = next;
  }
}
