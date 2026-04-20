/** 브라우저/OS에 설치된 이름 + 웹 로드용 Noto 계열 */

export type HanjaFontPresetId = "biaukai-first" | "noto-first" | "browser-serif";

export const HANJA_FONT_STORAGE_KEY = "chusa-admin-hanja-font-preset";
export const DISPLAY_PREFERENCES_STORAGE_KEY = "chusa-admin-display-preferences-v2";

/** 기본 원칙: 한자는 BiauKai 우선 */
const STACK_BIAUKAI_FIRST =
  '"BiauKai TC", "BiauKai SC", "BiauKai", "DFKai-SB", "KaiTi", "STKaiti", "Noto Serif TC", "Noto Serif CJK TC", "Noto Serif", ui-serif, serif';

const STACK_NOTO_FIRST =
  '"Noto Serif TC", "Noto Serif CJK TC", "Noto Serif", "BiauKai TC", "BiauKai SC", "BiauKai", ui-serif, serif';

const STACK_BROWSER = "ui-serif, Georgia, 'Times New Roman', serif";

export const HANJA_FONT_STACK_BY_PRESET: Record<HanjaFontPresetId, string> = {
  "biaukai-first": STACK_BIAUKAI_FIRST,
  "noto-first": STACK_NOTO_FIRST,
  "browser-serif": STACK_BROWSER,
};

/** 기본 본문 폰트: Noto Sans 계열 */
export const TEXT_FONT_STACK_DEFAULT =
  '"Noto Sans KR", "Noto Sans CJK KR", "Noto Sans TC", "Noto Sans CJK TC", "Noto Sans", "Noto Sans JP", "Noto Sans SC", system-ui, -apple-system, "Segoe UI", sans-serif';

export const HANJA_FONT_PRESET_LABELS: Record<HanjaFontPresetId, string> = {
  "biaukai-first": "標楷體(BiauKai) 우선 (권장)",
  "noto-first": "Noto Serif 우선 (웹폰트 위주)",
  "browser-serif": "브라우저 기본 명조(serif)",
};

export function isHanjaFontPresetId(value: string): value is HanjaFontPresetId {
  return value in HANJA_FONT_STACK_BY_PRESET;
}
