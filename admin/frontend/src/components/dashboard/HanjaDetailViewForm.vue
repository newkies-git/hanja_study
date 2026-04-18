<script setup lang="ts">
import { ref } from "vue";
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import HanjaDetailTabBasic from "@/components/dashboard/HanjaDetailTabBasic.vue";
import HanjaDetailTabReadings from "@/components/dashboard/HanjaDetailTabReadings.vue";
import HanjaDetailTabMeaning from "@/components/dashboard/HanjaDetailTabMeaning.vue";
import HanjaDetailTabRelated from "@/components/dashboard/HanjaDetailTabRelated.vue";
import HanjaDetailTabStrokes from "@/components/dashboard/HanjaDetailTabStrokes.vue";
import type { StrokeShape } from "@/types/strokeOrder";

defineProps<{
  /** 로컬 SQLite 신규 행 등에서 사용 */
  isNew?: boolean;
  svgPaths: string[];
  strokeShapes?: StrokeShape[];
  isStrokeLoading?: boolean;
}>();

const form = defineModel<HanjaDetailFormState>("form", { required: true });

const activeTab = ref<"basic" | "readings" | "meaning" | "related" | "strokes">("basic");

const tabs = [
  { id: "basic" as const, label: "기본 정보" },
  { id: "readings" as const, label: "음/훈" },
  { id: "meaning" as const, label: "의미/어원" },
  { id: "related" as const, label: "관련 한자" },
  { id: "strokes" as const, label: "획순" },
] as const;
</script>

<template>
  <div class="mx-auto max-w-4xl">
    <div
      class="mb-6 overflow-hidden rounded-xl border border-outline-variant/70 bg-surface-lowest shadow-float"
    >
      <div class="border-b border-outline-variant/60">
        <nav
          class="-mb-px flex space-x-6 overflow-x-auto px-6"
          aria-label="Tabs"
        >
          <button
            v-for="tab in tabs"
            :key="tab.id"
            type="button"
            :class="[
              activeTab === tab.id
                ? 'border-primary text-primary'
                : 'border-transparent text-onSurface-variant hover:border-outline-variant hover:text-onSurface',
              'whitespace-nowrap border-b-2 px-1 py-4 text-sm font-medium transition-colors',
            ]"
            @click="activeTab = tab.id"
          >
            {{ tab.label }}
          </button>
        </nav>
      </div>

      <div class="p-6">
        <HanjaDetailTabBasic v-show="activeTab === 'basic'" v-model:form="form" :is-new="isNew" />
        <HanjaDetailTabReadings v-show="activeTab === 'readings'" v-model:form="form" />
        <HanjaDetailTabMeaning v-show="activeTab === 'meaning'" v-model:form="form" />
        <HanjaDetailTabRelated v-show="activeTab === 'related'" v-model:form="form" />
        <HanjaDetailTabStrokes
          v-show="activeTab === 'strokes'"
          :svg-paths="svgPaths"
          :stroke-shapes="strokeShapes"
          :is-stroke-loading="isStrokeLoading"
        />
      </div>
    </div>
  </div>
</template>
