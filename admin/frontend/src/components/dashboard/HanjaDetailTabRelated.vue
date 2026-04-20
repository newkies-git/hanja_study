<script setup lang="ts">
import HanjaDetailWordsContainingTable from "@/components/dashboard/HanjaDetailWordsContainingTable.vue";

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
