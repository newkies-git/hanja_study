<script setup lang="ts">
import { computed } from "vue";
import { storeToRefs } from "pinia";
import { useHanjaDisplayPreferencesStore } from "@/stores/hanjaDisplayPreferences";
import {
  HANJA_FONT_PRESET_LABELS,
  HANJA_FONT_STACK_BY_PRESET,
  TEXT_FONT_STACK_DEFAULT,
  type HanjaFontPresetId,
  isHanjaFontPresetId,
} from "@/config/hanjaFontPresets";

const prefs = useHanjaDisplayPreferencesStore();
const { preset, fontScaleRem, fontColors } = storeToRefs(prefs);

const selectedPreset = computed({
  get: () => preset.value,
  set: (value: HanjaFontPresetId | string) => {
    if (isHanjaFontPresetId(value)) prefs.setPreset(value);
  },
});

const previewFontFamily = computed(() => HANJA_FONT_STACK_BY_PRESET[preset.value]);

const options: { id: HanjaFontPresetId; hint: string }[] = [
  {
    id: "biaukai-first",
    hint: "한자 전용은 BiauKai 계열을 우선 사용합니다.",
  },
  {
    id: "noto-first",
    hint: "한자도 Noto Sans 계열을 우선 사용합니다. BiauKai는 보조 폴백입니다.",
  },
  {
    id: "browser-serif",
    hint: "한자 전용 스택 없이 시스템 기본 명조에 맡깁니다.",
  },
];

const fontScaleControls: {
  key: keyof typeof fontScaleRem.value;
  label: string;
  min: number;
  max: number;
  step: number;
}[] = [
  { key: "hanjaDisplay", label: "1) 큰 한자", min: 4, max: 12, step: 0.1 },
  { key: "title", label: "2) 제목", min: 1.1, max: 2.2, step: 0.05 },
  { key: "subtitle", label: "3) 소제목", min: 0.95, max: 1.8, step: 0.05 },
  { key: "body", label: "4) 본문", min: 0.8, max: 1.3, step: 0.01 },
  { key: "caption", label: "5) 캡션", min: 0.65, max: 1.1, step: 0.01 },
];

const fontColorControls: { key: keyof typeof fontColors.value; label: string }[] = [
  { key: "textPrimary", label: "기본 텍스트" },
  { key: "textSecondary", label: "보조 텍스트" },
  { key: "textMuted", label: "힌트/캡션" },
  { key: "textBrand", label: "강조 색상" },
  { key: "textHanja", label: "한자 텍스트" },
];

function updateScale(key: keyof typeof fontScaleRem.value, value: number): void {
  prefs.setFontScaleRem(key, value);
}

function updateColor(key: keyof typeof fontColors.value, value: string): void {
  prefs.setFontColor(key, value);
}
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute -right-10 -top-12 h-32 w-32 rounded-full bg-primary/[0.08] blur-2xl"
        aria-hidden="true"
      />
      <div class="relative flex min-w-0 items-center gap-3">
        <div
          class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-lg font-bold text-white shadow-md shadow-primary/25"
          aria-hidden="true"
        >
          文
        </div>
        <div class="min-w-0 flex-1">
          <h1 class="page-title">
            <span class="page-title-kicker">Settings</span>표시 · 한자 폰트
          </h1>
          <p class="mt-0.5 text-xs text-onSurface-variant">
            한자(漢)는 BiauKai, 한글/영문은 Noto Sans를 사용합니다.
          </p>
        </div>
      </div>
    </section>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-4">
      <!-- 왼쪽(2칸): 폰트 선택 -->
      <div class="flex flex-col lg:col-span-2">
        <!-- 한자 표시 폰트 -->
        <div
          class="flex flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02]"
        >
          <div
            class="border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/80 to-surface-lowest px-4 py-3 sm:px-5"
          >
            <h2 class="font-display text-sm font-semibold tracking-tight text-onSurface sm:text-base">
              한자 표시 폰트
            </h2>
            <p class="mt-0.5 text-[11px] leading-relaxed text-onSurface-variant">
              본문 폰트 스택:
              <code class="rounded bg-surface-low px-1 font-mono text-[10px]">{{
                TEXT_FONT_STACK_DEFAULT
              }}</code>
            </p>
          </div>
          <div class="p-4 sm:p-5">
            <fieldset class="space-y-3">
              <legend class="sr-only">한자 폰트 프리셋</legend>
              <label
                v-for="opt in options"
                :key="opt.id"
                class="flex cursor-pointer gap-3 rounded-lg border border-outline-variant/60 bg-surface-low/40 p-3 transition hover:border-primary/25 has-[:checked]:border-primary/40 has-[:checked]:bg-primary/[0.04]"
              >
                <input
                  v-model="selectedPreset"
                  type="radio"
                  class="mt-1 h-4 w-4 shrink-0 border-outline-variant text-primary focus:ring-primary/30"
                  name="hanja-font-preset"
                  :value="opt.id"
                />
                <span class="min-w-0 flex-1">
                  <span class="block text-sm font-medium text-onSurface">{{
                    HANJA_FONT_PRESET_LABELS[opt.id]
                  }}</span>
                  <span class="mt-0.5 block text-[11px] leading-snug text-onSurface-variant">{{
                    opt.hint
                  }}</span>
                </span>
              </label>
            </fieldset>
          </div>
        </div>
      </div>

      <!-- 가운데: 폰트 크기 토큰 -->
      <div class="flex flex-col">
        <div
          class="flex flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02]"
        >
          <div
            class="border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/80 to-surface-lowest px-4 py-3 sm:px-5"
          >
            <h2 class="font-display text-sm font-semibold tracking-tight text-onSurface sm:text-base">
              폰트 크기 토큰
              <span class="text-xs font-normal text-onSurface-variant">(5단계)</span>
            </h2>
          </div>
          <div class="p-4 sm:p-5">
            <div class="space-y-5">
              <div v-for="ctrl in fontScaleControls" :key="ctrl.key" class="space-y-1.5">
                <div class="flex items-center justify-between gap-3">
                  <label class="text-xs font-medium text-onSurface">{{ ctrl.label }}</label>
                  <span class="font-mono text-[11px] tabular-nums text-onSurface-variant">
                    {{ fontScaleRem[ctrl.key].toFixed(2) }}rem
                  </span>
                </div>
                <input
                  type="range"
                  :min="ctrl.min"
                  :max="ctrl.max"
                  :step="ctrl.step"
                  :value="fontScaleRem[ctrl.key]"
                  class="w-full accent-primary"
                  @input="updateScale(ctrl.key, Number(($event.target as HTMLInputElement).value))"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 오른쪽: 텍스트 컬러 토큰 -->
      <div class="flex flex-col">
        <div
          class="flex flex-1 flex-col overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02]"
        >
          <div
            class="flex items-center justify-between gap-3 border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/80 to-surface-lowest px-4 py-3 sm:px-5"
          >
            <h2 class="font-display text-sm font-semibold tracking-tight text-onSurface sm:text-base">
              텍스트 컬러 토큰
            </h2>
            <button
              type="button"
              class="btn-secondary px-3 py-1.5 text-xs"
              @click="prefs.resetDisplayPreferences"
            >
              기본값 복원
            </button>
          </div>
          <div class="p-4 sm:p-5">
            <div class="space-y-3">
              <label
                v-for="ctrl in fontColorControls"
                :key="ctrl.key"
                class="flex items-center justify-between gap-3"
              >
                <span class="text-xs font-medium text-onSurface">{{ ctrl.label }}</span>
                <div class="flex items-center gap-2">
                  <input
                    type="color"
                    :value="fontColors[ctrl.key]"
                    class="h-7 w-9 rounded border border-outline-variant/70 bg-transparent"
                    @input="updateColor(ctrl.key, ($event.target as HTMLInputElement).value)"
                  />
                  <input
                    type="text"
                    :value="fontColors[ctrl.key]"
                    class="input-minimal w-24 py-1.5 text-xs font-mono"
                    @change="updateColor(ctrl.key, ($event.target as HTMLInputElement).value)"
                  />
                </div>
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 통합 미리보기 (전체 너비) -->
    <div
      class="overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest shadow-[0_12px_40px_rgba(25,28,30,0.06)] ring-1 ring-black/[0.02]"
    >
      <div
        class="border-b border-outline-variant/60 bg-gradient-to-r from-primary/[0.06] via-surface-low/80 to-surface-lowest px-4 py-3 sm:px-5"
      >
        <h2 class="font-display text-sm font-semibold tracking-tight text-onSurface sm:text-base">
          통합 미리보기
        </h2>
      </div>
      <div class="p-4 sm:p-5">
        <div
          class="rounded-xl border border-dashed border-outline-variant/80 bg-surface-low/40 p-4"
        >
          <p class="text-title">제목 미리보기</p>
          <p class="text-subtitle mt-1">소제목 미리보기</p>
          <p class="text-body mt-2">본문 미리보기 텍스트입니다.</p>
          <p class="text-caption mt-1">캡션 미리보기</p>
          <p
            :key="preset"
            class="text-hanja-display mt-3"
            :style="{ fontFamily: previewFontFamily }"
          >
            漢字朝鮮水
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

