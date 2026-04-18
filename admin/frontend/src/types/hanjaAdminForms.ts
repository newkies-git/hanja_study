import type { HanjaReading } from "@/utils/hanjaBasis";

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
  /** Firestore `hanja_basis`·로컬 `extend_data`와 동일 키 (중/고 등) */
  grade: string;
  readings: HanjaReading[];
  synonyms: string[];
  antonyms: string[];
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
  grade_level: string;
  shape_explanation: string;
  origin_note: string;
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
    grade_level: "",
    shape_explanation: "",
    origin_note: "",
    difficulty: "",
    variants: [],
    extend: {},
  };
}

export function createEmptyLocalHanjaFormRecord(): HanjaDetailFormState {
  return createEmptyHanjaBasisFormRecord();
}
