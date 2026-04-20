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

/** 라디오 v-model — 선택과 저장·문서 변수 갱신을 한 경로로 묶음 */
const selectedPreset = computed({
  get: () => preset.value,
  set: (value: HanjaFontPresetId | string) => {
    if (isHanjaFontPresetId(value)) prefs.setPreset(value);
  },
});

/** 미리보기는 CSS 변수 대신 직접 font-family 를 바인딩 (변수 상속 이슈 회피) */
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
    <section class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-4 py-3 shadow-sm">
      <h1 class="page-title"><span class="page-title-kicker">Admin</span>표시 · 한자 폰트</h1>
      <p class="mt-1 text-xs leading-relaxed text-onSurface-variant">
        한자(漢)는 BiauKai, 한글/영문은 Noto Sans를 사용합니다.
      </p>
    </section>

    <section class="rounded-xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-sm sm:p-5">
      <h2 class="text-sm font-semibold text-onSurface">한자 표시 폰트</h2>
      <p class="mt-1 text-[11px] leading-relaxed text-onSurface-variant">
        본문 폰트 스택:
        <code class="rounded bg-surface-low px-1 font-mono text-[10px]">{{ TEXT_FONT_STACK_DEFAULT }}</code>
      </p>

      <fieldset class="mt-4 space-y-3">
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
    </section>

    <section class="rounded-xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-sm sm:p-5">
      <h2 class="text-sm font-semibold text-onSurface">폰트 크기 토큰 (5단계)</h2>
      <div class="mt-4 space-y-4">
        <div v-for="ctrl in fontScaleControls" :key="ctrl.key" class="space-y-1.5">
          <div class="flex items-center justify-between gap-3">
            <label class="text-xs font-medium text-onSurface">{{ ctrl.label }}</label>
            <span class="font-mono text-[11px] text-onSurface-variant"
              >{{ fontScaleRem[ctrl.key].toFixed(2) }}rem</span
            >
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
    </section>

    <section class="rounded-xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-sm sm:p-5">
      <div class="flex items-center justify-between gap-3">
        <h2 class="text-sm font-semibold text-onSurface">텍스트 컬러 토큰</h2>
        <button type="button" class="btn-secondary px-3 py-1.5 text-xs" @click="prefs.resetDisplayPreferences">
          기본값 복원
        </button>
      </div>
      <div class="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
        <label
          v-for="ctrl in fontColorControls"
          :key="ctrl.key"
          class="rounded-lg border border-outline-variant/60 bg-surface-low/30 p-3"
        >
          <span class="mb-2 block text-xs font-medium text-onSurface">{{ ctrl.label }}</span>
          <div class="flex items-center gap-2">
            <input
              type="color"
              :value="fontColors[ctrl.key]"
              class="h-8 w-10 rounded border border-outline-variant/70 bg-transparent"
              @input="updateColor(ctrl.key, ($event.target as HTMLInputElement).value)"
            />
            <input
              type="text"
              :value="fontColors[ctrl.key]"
              class="input-minimal py-1.5 text-xs font-mono"
              @change="updateColor(ctrl.key, ($event.target as HTMLInputElement).value)"
            />
          </div>
        </label>
      </div>
    </section>

    <section class="rounded-xl border border-dashed border-outline-variant/80 bg-surface-low/40 p-4">
      <p class="text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant">통합 미리보기</p>
      <p class="text-title mt-2">제목 미리보기</p>
      <p class="text-subtitle mt-1">소제목 미리보기</p>
      <p class="text-body mt-2">본문 미리보기 텍스트입니다.</p>
      <p class="text-caption mt-1">캡션 미리보기</p>
      <p :key="preset" class="text-hanja-display mt-3" :style="{ fontFamily: previewFontFamily }">漢字朝鮮水</p>
    </section>
  </div>
</template>
