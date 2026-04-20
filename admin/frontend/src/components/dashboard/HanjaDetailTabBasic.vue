<script setup lang="ts">
import { computed } from "vue";
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";
import TagArrayEditor from "@/components/dashboard/TagArrayEditor.vue";

withDefaults(
  defineProps<{
    /** 로컬 신규 행: 한자·ID 입력 */
    isNew?: boolean;
  }>(),
  { isNew: false },
);

const form = defineModel<HanjaDetailFormState>("form", { required: true });

function patchFormField<K extends keyof HanjaDetailFormState>(
  key: K,
  value: HanjaDetailFormState[K],
) {
  form.value = { ...form.value, [key]: value };
}

const displayHanja = computed(() => {
  const hanja = (form.value["한자"] ?? "").trim();
  if (hanja.length > 0) return hanja;
  return (form.value.char_str ?? "").trim();
});

function patchHanja(value: string) {
  form.value = {
    ...form.value,
    한자: value,
    char_str: value,
  };
}
</script>

<template>
  <div>
    <div
      v-if="isNew"
      class="mb-6 flex flex-col gap-4 border-b border-outline-variant/50 pb-6 sm:flex-row sm:items-end"
    >
      <div class="min-w-0 flex-1 space-y-1">
        <label class="text-xs font-semibold uppercase text-onSurface-variant">한자 (신규)</label>
        <input
          :value="form.char_str"
          type="text"
          class="input-minimal w-full py-3 text-center font-hanja text-4xl font-bold"
          placeholder="字"
          @input="patchFormField('char_str', ($event.target as HTMLInputElement).value)"
        />
      </div>
      <div class="w-full shrink-0 space-y-1 sm:w-48">
        <label class="text-xs font-semibold uppercase text-onSurface-variant">한자 ID (자동생성됨)</label>
        <input
          v-model="form.id"
          type="text"
          class="input-minimal w-full py-1 text-sm"
          placeholder="예: H4E00"
        />
      </div>
    </div>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-12">
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm lg:col-span-4">
        <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >한자</label
        >
        <input
          :value="displayHanja"
          type="text"
          class="input-minimal text-hanja-display w-full bg-surface-low/30 py-8 text-center font-hanja font-bold"
          @input="patchHanja(($event.target as HTMLInputElement).value)"
        />
      </div>

      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm lg:col-span-8">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div class="space-y-2">
            <label class="block text-sm font-medium text-onSurface">음</label>
            <input
              v-model="form.reading"
              type="text"
              placeholder="음"
              class="input-minimal w-full py-2 font-hanja text-sm"
            />
          </div>
          <div class="space-y-2">
            <label class="block text-sm font-medium text-onSurface">훈</label>
            <input
              v-model="form.meaning"
              type="text"
              placeholder="훈"
              class="input-minimal w-full py-2 font-hanja text-sm"
            />
          </div>

          <div class="space-y-2">
            <label class="block text-sm font-medium text-onSurface">부수 한자</label>
            <input
              v-model="form.radical"
              type="text"
              placeholder="부수 한자"
              class="input-minimal w-full py-2 font-hanja text-sm"
            />
          </div>

          <div class="space-y-2">
            <label class="block text-sm font-medium text-onSurface">부수 의미</label>
            <input
              v-model="form.radical_meaning"
              type="text"
              placeholder="부수 의미"
              class="input-minimal w-full py-2 text-sm"
            />
          </div>

          <div class="space-y-1.5">
            <label class="block text-xs font-semibold uppercase tracking-wide text-onSurface-variant">구분</label>
            <select v-model="form.grade" class="input-minimal w-full py-2">
              <option value="">전체</option>
              <option value="중">중</option>
              <option value="고">고</option>
            </select>
          </div>

          <div class="space-y-1.5">
            <label class="block text-xs font-semibold uppercase tracking-wide text-onSurface-variant">획수</label>
            <input
              v-model="form.stroke_count"
              type="text"
              inputmode="numeric"
              placeholder="예: 8"
              class="input-minimal w-full py-2"
            />
          </div>

          <div class="space-y-1.5 sm:col-span-2">
            <label class="block text-xs font-semibold uppercase tracking-wide text-onSurface-variant">전체</label>
            <input v-model="form['전체']" type="text" class="input-minimal w-full py-2 font-hanja" />
          </div>

          <div class="sm:col-span-2">
            <TagArrayEditor v-model="form.variants" label="이체자 (Variants)" placeholder="이체자 추가..." />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
