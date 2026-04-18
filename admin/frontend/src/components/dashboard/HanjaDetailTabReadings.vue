<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import ReadingsEditor from "@/components/dashboard/ReadingsEditor.vue";

const form = defineModel<HanjaDetailFormState>("form", { required: true });
</script>

<template>
  <div class="space-y-6">
    <h3 class="mb-3 text-sm font-bold uppercase tracking-wider text-onSurface">상세 음/훈 리스트</h3>
    <ReadingsEditor v-model="form.readings" />
  </div>
</template>
