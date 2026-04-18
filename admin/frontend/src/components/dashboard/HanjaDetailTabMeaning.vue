<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";

const form = defineModel<HanjaDetailFormState>("form", { required: true });
</script>

<template>
  <div class="flex flex-col gap-6">
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
        >자원 설명 (Origin Note)</label
      >
      <textarea
        v-model="form.origin_note"
        rows="5"
        class="input-minimal w-full py-2 text-sm"
        placeholder="한자의 기원이나 어원에 대한 설명..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
        >의미 (Meaning)</label
      >
      <textarea
        v-model="form['meaning']"
        rows="6"
        class="input-minimal w-full py-3"
        placeholder="상세 의미를 기술하세요..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
        >어원 (Etymology)</label
      >
      <textarea
        v-model="form['etymology']"
        rows="6"
        class="input-minimal w-full py-3"
        placeholder="자원(字源) 설명을 입력하세요..."
      />
    </div>
  </div>
</template>
