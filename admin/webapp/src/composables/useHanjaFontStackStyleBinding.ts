import { computed, type ComputedRef } from "vue";
import { storeToRefs } from "pinia";
import { useHanjaDisplayPreferencesStore } from "@/stores/hanjaDisplayPreferences";
import { HANJA_FONT_STACK_BY_PRESET, TEXT_FONT_STACK_DEFAULT } from "@/config/hanjaFontPresets";

/**
 * `#app` 내부 루트에 바인딩해, `font-hanja` / `var(--hanja-font-stack)` 가
 * 문서 루트 인라인보다 확실히 앱 트리 전체에 상속되도록 합니다.
 */
export function useHanjaFontStackStyleBinding(): ComputedRef<Record<string, string>> {
  const { preset, fontScaleRem, fontColors } = storeToRefs(useHanjaDisplayPreferencesStore());
  return computed(() => ({
    "--hanja-font-stack": HANJA_FONT_STACK_BY_PRESET[preset.value],
    "--font-text-stack": TEXT_FONT_STACK_DEFAULT,
    "--fs-hanja-display": `${fontScaleRem.value.hanjaDisplay}rem`,
    "--fs-title": `${fontScaleRem.value.title}rem`,
    "--fs-subtitle": `${fontScaleRem.value.subtitle}rem`,
    "--fs-body": `${fontScaleRem.value.body}rem`,
    "--fs-caption": `${fontScaleRem.value.caption}rem`,
    "--color-text-primary": fontColors.value.textPrimary,
    "--color-text-secondary": fontColors.value.textSecondary,
    "--color-text-muted": fontColors.value.textMuted,
    "--color-text-brand": fontColors.value.textBrand,
    "--color-text-hanja": fontColors.value.textHanja,
  }));
}
