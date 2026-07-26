<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import TagArrayEditor from "@/components/dashboard/TagArrayEditor.vue";

const form = defineModel<HanjaDetailFormState>("form", { required: true });
</script>

<template>
  <div class="grid grid-cols-1 gap-4">
    <TagArrayEditor v-model="form.synonyms" label="동의어 (synonyms)" placeholder="동의어 추가..." />
    <TagArrayEditor v-model="form.antonyms" label="반의어(antonyms)" placeholder="반의어 추가..." />
    <TagArrayEditor v-model="form.analogue" label="유의어 (analogue)" placeholder="유의어 추가..." />
  </div>
</template>
