<script setup lang="ts">
import { ref } from "vue";

const props = defineProps<{
  modelValue: string[];
  label?: string;
  placeholder?: string;
}>();

const emit = defineEmits<{
  (e: "update:modelValue", value: string[]): void;
}>();

const inputValue = ref("");

function addTag() {
  const val = inputValue.value.trim();
  if (!val) return;

  // Split by comma if present
  const tags = val.split(/[,\s]+/).filter((t) => t.length > 0);
  const newTags = [...props.modelValue];

  let added = false;
  for (const tag of tags) {
    if (!newTags.includes(tag)) {
      newTags.push(tag);
      added = true;
    }
  }

  if (added) {
    emit("update:modelValue", newTags);
  }
  inputValue.value = "";
}

function removeTag(index: number) {
  const newTags = [...props.modelValue];
  newTags.splice(index, 1);
  emit("update:modelValue", newTags);
}

function handleKeyDown(e: KeyboardEvent) {
  if (e.key === "Enter" || e.key === ",") {
    e.preventDefault();
    addTag();
  } else if (
    e.key === "Backspace" &&
    !inputValue.value &&
    props.modelValue.length > 0
  ) {
    removeTag(props.modelValue.length - 1);
  }
}
</script>

<template>
  <div class="space-y-1.5">
    <label
      v-if="label"
      class="block text-sm font-semibold tracking-wide text-onSurface-variant"
    >
      {{ label }}
    </label>
    <div
      class="flex min-h-[42px] flex-wrap gap-1.5 rounded-xl border border-outline-variant/70 bg-surface-low/80 p-2 transition-all focus-within:ring-2 focus-within:ring-primary/20"
    >
      <span
        v-for="(tag, i) in (modelValue || [])"
        :key="i"
        class="inline-flex items-center gap-1 rounded-lg border border-primary/20 bg-primary/10 px-2 py-0.5 text-sm font-medium text-primary"
      >
        {{ tag }}
        <button
          type="button"
          class="transition-colors hover:text-primary/70"
          aria-label="Remove tag"
          @click="removeTag(i)"
        >
          <svg class="h-3 w-3" viewBox="0 0 16 16" fill="currentColor">
            <path
              d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"
            />
          </svg>
        </button>
      </span>
      <input
        v-model="inputValue"
        type="text"
        :placeholder="modelValue.length === 0 ? placeholder : ''"
        class="min-w-[120px] flex-1 border-none bg-transparent text-sm outline-none"
        @keydown="handleKeyDown"
        @blur="addTag"
      />
    </div>
  </div>
</template>
