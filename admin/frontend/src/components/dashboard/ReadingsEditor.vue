<script setup lang="ts">
import type { HanjaReading } from "@/utils/hanjaBasis";

const props = defineProps<{
  modelValue: HanjaReading[];
}>();

const emit = defineEmits<{
  (e: "update:modelValue", value: HanjaReading[]): void;
}>();

function addReading() {
  const newReadings = [
    ...props.modelValue,
    { 음: "", 훈: "", primary: props.modelValue.length === 0 },
  ];
  emit("update:modelValue", newReadings);
}

function removeReading(index: number) {
  const newReadings = [...props.modelValue];
  const wasPrimary = newReadings[index]?.primary;
  newReadings.splice(index, 1);
  // If we removed the primary, assign a new one if possible
  if (wasPrimary && newReadings.length > 0) {
    newReadings[0].primary = true;
  }
  emit("update:modelValue", newReadings);
}

function updatePrimary(index: number) {
  const newReadings = props.modelValue.map((r, i) => ({
    ...r,
    primary: i === index,
  }));
  emit("update:modelValue", newReadings);
}

function updateField(index: number, field: "음" | "훈", value: string) {
  const newReadings = [...props.modelValue];
  newReadings[index] = { ...newReadings[index], [field]: value };
  emit("update:modelValue", newReadings);
}

function moveUp(index: number) {
  if (index === 0) return;
  const newReadings = [...props.modelValue];
  [newReadings[index - 1], newReadings[index]] = [
    newReadings[index],
    newReadings[index - 1],
  ];
  emit("update:modelValue", newReadings);
}

function moveDown(index: number) {
  if (index === props.modelValue.length - 1) return;
  const newReadings = [...props.modelValue];
  [newReadings[index + 1], newReadings[index]] = [
    newReadings[index],
    newReadings[index + 1],
  ];
  emit("update:modelValue", newReadings);
}
</script>

<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between">
      <label
        class="block text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
      >
        음/훈 목록
      </label>
      <button
        type="button"
        class="text-[11px] font-medium text-primary hover:underline"
        @click="addReading"
      >
        + 추가
      </button>
    </div>

    <div
      v-if="!modelValue || modelValue.length === 0"
      class="rounded-xl border border-dashed border-outline-variant py-4 text-center text-xs text-onSurface-variant"
    >
      등록된 음/훈이 없습니다. 추가 버튼을 눌러주세요.
    </div>

    <div v-else class="space-y-2">
      <div
        v-for="(reading, i) in modelValue"
        :key="i"
        class="group flex items-center gap-2 rounded-xl border border-outline-variant/60 bg-surface-low/50 p-3"
      >
        <div class="flex flex-col gap-1">
          <button
            type="button"
            :disabled="i === 0"
            class="p-0.5 text-onSurface-variant/40 hover:text-primary disabled:opacity-0"
            @click="moveUp(i)"
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="currentColor">
              <path
                d="M7.646 4.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1-.708.708L8 5.707l-5.646 5.647a.5.5 0 0 1-.708-.708l6-6z"
              />
            </svg>
          </button>
          <button
            type="button"
            :disabled="i === modelValue.length - 1"
            class="p-0.5 text-onSurface-variant/40 hover:text-primary disabled:opacity-0"
            @click="moveDown(i)"
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="currentColor">
              <path
                d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"
              />
            </svg>
          </button>
        </div>

        <div class="grid flex-1 grid-cols-2 gap-2">
          <div>
            <input
              :value="reading.음"
              type="text"
              placeholder="음"
              class="input-minimal w-full py-1.5 text-sm"
              @input="
                updateField(
                  i,
                  '음',
                  ($event.target as HTMLInputElement).value,
                )
              "
            />
          </div>
          <div>
            <input
              :value="reading.훈"
              type="text"
              placeholder="훈"
              class="input-minimal w-full py-1.5 text-sm"
              @input="
                updateField(
                  i,
                  '훈',
                  ($event.target as HTMLInputElement).value,
                )
              "
            />
          </div>
        </div>

        <div class="ml-2 flex items-center gap-3">
          <label class="flex cursor-pointer items-center gap-1.5">
            <input
              type="radio"
              :checked="reading.primary"
              class="h-3.5 w-3.5 border-outline-variant text-primary focus:ring-primary/20"
              @change="updatePrimary(i)"
            />
            <span
              class="text-[10px] font-medium uppercase text-onSurface-variant"
              >Key</span
            >
          </label>

          <button
            type="button"
            class="rounded-md p-1.5 text-onSurface-variant/50 transition-all hover:bg-red-50 hover:text-red-600"
            @click="removeReading(i)"
          >
            <svg class="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
              <path
                d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"
              />
              <path
                fill-rule="evenodd"
                d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"
              />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
