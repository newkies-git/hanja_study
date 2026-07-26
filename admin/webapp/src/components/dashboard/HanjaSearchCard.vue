<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue: string;
    filterActive: boolean;
    /** true면 `hanja_basis` 등급(전체/중/고, 필드 `grade`) 선택기 표시 — `v-model:segment`와 함께 사용 */
    showHanjaSegmentFilter?: boolean;
  }>(),
  { showHanjaSegmentFilter: false },
);

const emit = defineEmits<{
  "update:modelValue": [value: string];
  search: [];
  clear: [];
}>();

const segment = defineModel<string>("segment", { default: "" });
</script>

<template>
  <div
    class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-2.5 shadow-float sm:px-4"
  >
    <div
      class="flex flex-col gap-2.5 sm:flex-row sm:flex-wrap sm:items-center sm:gap-2.5"
    >
      <span class="shrink-0 text-sm font-semibold text-onSurface">검색</span>
      <select
        v-if="showHanjaSegmentFilter"
        v-model="segment"
        class="input-minimal w-full shrink-0 cursor-pointer py-2 text-sm sm:w-[5.5rem]"
        aria-label="등급"
      >
        <option value="">전체</option>
        <option value="중">중등</option>
        <option value="고">고등</option>
      </select>
      <slot />
      <input
        :value="modelValue"
        type="search"
        maxlength="2"
        class="input-minimal min-w-0 max-w-[5rem] flex-1 py-2 text-sm"
        placeholder="한자·음·획수"
        title="검색어 최대 2자"
        autocomplete="off"
        @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        @keydown.enter.prevent="emit('search')"
      />
      <div class="flex shrink-0 gap-2">
        <button type="button" class="btn-secondary px-3 py-2 text-sm" @click="emit('search')">
          검색
        </button>
        <button
          type="button"
          class="btn-secondary px-3 py-2 text-sm"
          :disabled="!filterActive"
          @click="emit('clear')"
        >
          초기화
        </button>
      </div>
    </div>
  </div>
</template>
