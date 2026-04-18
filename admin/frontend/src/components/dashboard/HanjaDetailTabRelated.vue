<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import TagArrayEditor from "@/components/dashboard/TagArrayEditor.vue";

const form = defineModel<HanjaDetailFormState>("form", { required: true });
</script>

<template>
  <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <TagArrayEditor
        v-model="form.synonyms"
        label="유의어"
        placeholder="유의어 추가..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <TagArrayEditor
        v-model="form.antonyms"
        label="반의어"
        placeholder="반의어 추가..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm md:col-span-2">
      <TagArrayEditor
        v-model="form.variants"
        label="이체자 (Variants)"
        placeholder="이체자 추가..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <TagArrayEditor v-model="form['words']" label="사용 단어" placeholder="단어 추가..." />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <TagArrayEditor v-model="form['idioms']" label="성어 (Idioms)" placeholder="성어 추가..." />
    </div>
  </div>
</template>
