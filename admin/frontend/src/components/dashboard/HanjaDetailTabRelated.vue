<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import HanjaDetailWordsContainingTable from "@/components/dashboard/HanjaDetailWordsContainingTable.vue";

defineModel<HanjaDetailFormState>("form", { required: true });

defineProps<{
  wordContainingGlyph?: string;
  wordContainingSource?: "local" | "firestore";
}>();
</script>

<template>
  <div class="grid grid-cols-1 gap-6">
    <HanjaDetailWordsContainingTable
      v-if="wordContainingGlyph?.trim() && wordContainingSource"
      :glyph="wordContainingGlyph"
      :mode="wordContainingSource"
    />
  </div>
</template>
