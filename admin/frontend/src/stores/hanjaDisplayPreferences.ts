import { defineStore } from "pinia";
import { ref } from "vue";
import {
  DISPLAY_PREFERENCES_STORAGE_KEY,
  HANJA_FONT_STORAGE_KEY,
  type HanjaFontPresetId,
  isHanjaFontPresetId,
} from "@/config/hanjaFontPresets";

type FontScaleKey = "hanjaDisplay" | "title" | "subtitle" | "body" | "caption";
type FontColorKey = "textPrimary" | "textSecondary" | "textMuted" | "textBrand" | "textHanja";

type DisplayPreferencesPayload = {
  preset: HanjaFontPresetId;
  fontScaleRem: Record<FontScaleKey, number>;
  fontColors: Record<FontColorKey, string>;
};

const DEFAULT_FONT_SCALE_REM: Record<FontScaleKey, number> = {
  hanjaDisplay: 7,
  title: 1.5,
  subtitle: 1.125,
  body: 0.95,
  caption: 0.78,
};

const DEFAULT_FONT_COLORS: Record<FontColorKey, string> = {
  textPrimary: "#1f2430",
  textSecondary: "#50586b",
  textMuted: "#7b8396",
  textBrand: "#0b4ed1",
  textHanja: "#0f172a",
};

export const useHanjaDisplayPreferencesStore = defineStore("hanjaDisplayPreferences", () => {
  const preset = ref<HanjaFontPresetId>("biaukai-first");
  const fontScaleRem = ref<Record<FontScaleKey, number>>({ ...DEFAULT_FONT_SCALE_REM });
  const fontColors = ref<Record<FontColorKey, string>>({ ...DEFAULT_FONT_COLORS });

  function persistToStorage(): void {
    try {
      const payload: DisplayPreferencesPayload = {
        preset: preset.value,
        fontScaleRem: fontScaleRem.value,
        fontColors: fontColors.value,
      };
      localStorage.setItem(DISPLAY_PREFERENCES_STORAGE_KEY, JSON.stringify(payload));
      localStorage.setItem(HANJA_FONT_STORAGE_KEY, preset.value);
    } catch {
      /* ignore */
    }
  }

  function hydrateFromStorage(): void {
    try {
      const payloadRaw = localStorage.getItem(DISPLAY_PREFERENCES_STORAGE_KEY);
      if (payloadRaw) {
        const payload = JSON.parse(payloadRaw) as Partial<DisplayPreferencesPayload>;
        if (payload.preset && isHanjaFontPresetId(payload.preset)) {
          preset.value = payload.preset;
        }
        if (payload.fontScaleRem && typeof payload.fontScaleRem === "object") {
          for (const key of Object.keys(DEFAULT_FONT_SCALE_REM) as FontScaleKey[]) {
            const value = Number((payload.fontScaleRem as Partial<Record<FontScaleKey, unknown>>)[key]);
            if (Number.isFinite(value) && value > 0) {
              fontScaleRem.value[key] = value;
            }
          }
        }
        if (payload.fontColors && typeof payload.fontColors === "object") {
          for (const key of Object.keys(DEFAULT_FONT_COLORS) as FontColorKey[]) {
            const value = String(
              (payload.fontColors as Partial<Record<FontColorKey, unknown>>)[key] ?? "",
            ).trim();
            if (value) {
              fontColors.value[key] = value;
            }
          }
        }
        return;
      }
      const raw = localStorage.getItem(HANJA_FONT_STORAGE_KEY);
      if (raw && isHanjaFontPresetId(raw)) preset.value = raw;
    } catch {
      /* ignore */
    }
  }

  function setPreset(next: HanjaFontPresetId): void {
    preset.value = next;
    persistToStorage();
  }

  function setFontScaleRem(key: FontScaleKey, value: number): void {
    if (!Number.isFinite(value) || value <= 0) return;
    fontScaleRem.value = { ...fontScaleRem.value, [key]: value };
    persistToStorage();
  }

  function setFontColor(key: FontColorKey, value: string): void {
    const normalized = String(value ?? "").trim();
    if (!normalized) return;
    fontColors.value = { ...fontColors.value, [key]: normalized };
    persistToStorage();
  }

  function resetDisplayPreferences(): void {
    preset.value = "biaukai-first";
    fontScaleRem.value = { ...DEFAULT_FONT_SCALE_REM };
    fontColors.value = { ...DEFAULT_FONT_COLORS };
    persistToStorage();
  }

  return {
    preset,
    fontScaleRem,
    fontColors,
    setPreset,
    setFontScaleRem,
    setFontColor,
    resetDisplayPreferences,
    hydrateFromStorage,
  };
});
