import { computed, type ComputedRef } from 'vue';
import { useTheme } from 'vuetify';

type ThemeColors = Record<string, string>;

export function useCurrentTheme() {
  const theme = useTheme();

  const currentColors: ComputedRef<ThemeColors> = computed<ThemeColors>(() => {
    const currentThemeName = theme.global.name.value;
    const currentThemeColors = theme.themes.value[currentThemeName]?.colors as Record<string, string> | undefined;
    return (currentThemeColors ?? {}) as ThemeColors;
  });

  const getColor = (colorName: string) => {
    return computed(() => currentColors.value[colorName] || '');
  };

  return {
    currentColors,
    getColor,
    theme
  };
}
