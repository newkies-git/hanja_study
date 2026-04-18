<script setup lang="ts">
import type { HanjaDetailFormState } from "@/types/hanjaAdminForms";

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
          class="input-minimal w-full py-3 text-center font-display text-4xl font-bold"
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

    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm sm:col-span-2">
        <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >한자</label
        >
        <input
          :value="form['한자']"
          type="text"
          class="input-minimal w-full bg-surface-low/30 py-4 text-center font-display text-6xl font-bold"
          @input="patchFormField('한자', ($event.target as HTMLInputElement).value)"
        />
      </div>

      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm sm:col-span-2">
        <label class="mb-2 block text-sm font-medium text-onSurface">대표 음/훈</label>
        <div class="flex gap-2">
          <input
            v-model="form.reading"
            type="text"
            placeholder="음"
            class="input-minimal flex-1 py-2 text-sm"
          />
          <input
            v-model="form.meaning"
            type="text"
            placeholder="훈"
            class="input-minimal flex-1 py-2 text-sm"
          />
        </div>
      </div>

      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-2 block text-sm font-medium text-onSurface">부수 한자</label>
        <input
          v-model="form.radical"
          type="text"
          placeholder="부수 한자"
          class="input-minimal w-full py-2 text-sm"
        />
      </div>
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-2 block text-sm font-medium text-onSurface">부수 의미</label>
        <input
          v-model="form.radical_meaning"
          type="text"
          placeholder="부수 의미"
          class="input-minimal w-full py-2 text-sm"
        />
      </div>

      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >구분</label
        >
        <select v-model="form.grade" class="input-minimal w-full py-2">
          <option value="">전체</option>
          <option value="중">중</option>
          <option value="고">고</option>
        </select>
      </div>
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >훈음 (레거시)</label
        >
        <input v-model="form['훈음']" type="text" class="input-minimal w-full py-2" />
      </div>
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >음 (레거시)</label
        >
        <input v-model="form['음']" type="text" class="input-minimal w-full py-2" />
      </div>
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm">
        <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >훈 (레거시)</label
        >
        <input v-model="form['훈']" type="text" class="input-minimal w-full py-2" />
      </div>
      <div class="rounded-xl border border-outline-variant/60 bg-white p-4 shadow-sm sm:col-span-2">
        <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-onSurface-variant"
          >전체</label
        >
        <input v-model="form['전체']" type="text" class="input-minimal w-full py-2" />
      </div>
    </div>
  </div>
</template>
