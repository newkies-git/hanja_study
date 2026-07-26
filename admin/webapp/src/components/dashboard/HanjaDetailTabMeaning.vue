<script setup lang="ts">
import { computed } from "vue";
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";

const form = defineModel<HanjaDetailFormState>("form", { required: true });

const originNoteInterpretationText = computed({
  get() {
    const ex = form.value.extend;
    if (!ex || typeof ex !== "object" || Array.isArray(ex)) return "";
    return String((ex as Record<string, unknown>)["일반적_해석"] ?? "");
  },
  set(value: string) {
    const ex =
      form.value.extend && typeof form.value.extend === "object" && !Array.isArray(form.value.extend)
        ? { ...(form.value.extend as Record<string, unknown>) }
        : {};
    ex["일반적_해석"] = value;
    form.value = { ...form.value, extend: ex };
  },
});
</script>

<template>
  <div class="flex flex-col gap-6">
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <label class="mb-2 block text-sm font-semibold tracking-wide text-onSurface-variant"
        >구성_분석 (etymology)</label
      >
      <textarea
        v-model="form.etymology"
        rows="6"
        class="input-minimal text-body w-full py-3"
        placeholder="한자의 기원이나 어원에 대한 설명..."
      />
    </div>
    <div class="rounded-2xl border border-outline-variant/60 bg-white p-6 shadow-sm">
      <label class="mb-2 block text-sm font-semibold tracking-wide text-onSurface-variant"
        >일반적_해석(origin_note)</label
      >
      <textarea
        v-model="originNoteInterpretationText"
        rows="6"
        class="input-minimal text-body w-full py-3"
        placeholder="origin_note의 일반적 해석을 입력하세요..."
      />
    </div>
  </div>
</template>
