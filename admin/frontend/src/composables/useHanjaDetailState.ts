import { ref, computed } from "vue";
import {
  type HanjaDetailFormState,
  hydrateHanjaRelatedFieldsFromExtend,
} from "@/types/hanjaAdminForms";
import { glyphFromHanjaBasisDocId } from "@/utils/hanjaBasis";

/**
 * Firestore·SQLite 상세 뷰가 공유하는 폼 상태 및 API 응답 병합 로직.
 *
 * - 각 뷰의 fetch/save/delete 는 데이터 소스가 달라 뷰에 남긴다.
 * - 응답 데이터 → 폼 병합, 공통 상태(isLoading/isSaving/error) 만 여기서 관리한다.
 */
export function useHanjaDetailState(
  createEmpty: () => HanjaDetailFormState,
  idGetter: () => string,
) {
  const isLoading = ref(true);
  const isSaving = ref(false);
  const error = ref<string | null>(null);
  const form = ref<HanjaDetailFormState>(createEmpty());
  const svgPaths = ref<string[]>([]);

  const charDisplay = computed(() => {
    const s = String(form.value.한자 ?? form.value.char_str ?? "").trim();
    if (s.length > 0) return [...s][0] ?? s;
    return glyphFromHanjaBasisDocId(idGetter());
  });

  /**
   * API / Firestore 응답 `data` 를 빈 폼에 병합해 반환한다.
   * @param data - 원시 응답 객체
   * @param extend - 별도 조회한 extend 데이터 (없으면 data.extend 사용)
   */
  function mergeApiResponse(
    data: Record<string, unknown>,
    extend?: Record<string, unknown>,
  ): HanjaDetailFormState {
    const o = createEmpty();
    const oRecord = o as unknown as Record<string, unknown>;

    // extend 우선순위: 인자로 전달된 값 > data.extend
    if (extend !== undefined) {
      oRecord.extend = extend;
    } else if (data.extend !== undefined && data.extend !== null) {
      oRecord.extend =
        typeof data.extend === "object" && !Array.isArray(data.extend)
          ? { ...(data.extend as Record<string, unknown>) }
          : {};
    }

    for (const k of Object.keys(oRecord)) {
      if (k === "extend") continue;
      if (data[k] !== undefined && data[k] !== null) {
        oRecord[k] = data[k];
      }
    }

    // 레거시 구분 → grade 마이그레이션 (extend 또는 최상위 필드 참조)
    const extObj = oRecord.extend as Record<string, unknown> | undefined;
    const legacyGrade = String(
      extObj?.["grade"] ?? extObj?.["구분"] ?? data["구분"] ?? "",
    ).trim();
    if (!String(oRecord.grade ?? "").trim() && legacyGrade) {
      oRecord.grade = legacyGrade;
    }

    hydrateHanjaRelatedFieldsFromExtend(o);
    return o;
  }

  return { isLoading, isSaving, error, form, svgPaths, charDisplay, mergeApiResponse };
}
