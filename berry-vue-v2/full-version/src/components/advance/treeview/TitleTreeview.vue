<script setup lang="ts">
import { ref } from 'vue';
// common components
import UiChildCard from '@/components/shared/UiChildCard.vue';

// title
const model = ref<string[]>([]);
const titleItems = Array.from({ length: 10 }, (_, i) => ({
  value: `${i}`,
  title: `Example item ${i + 1}`,
  children: Array.from({ length: 23 }, (_, j) => ({
    value: `${i}-${j}`,
    title: `Example child item ${j}`
  }))
}));

const titleOpen = ref<string[]>(['0']);
</script>
<template>
  <UiChildCard title="Title">
    <v-treeview
      v-model="model"
      v-model:opened="titleOpen"
      :items="titleItems"
      :lines="false"
      collapse-icon="$chevronDown"
      density="compact"
      expand-icon="$chevronRight"
      select-strategy="leaf"
      fluid
      selectable
    >
      <template v-slot:title="{ item }">
        <span :class="['text-label-small', model.includes(item.value) && 'text-decoration-line-through']">
          {{ item.title }}
        </span>
      </template>
    </v-treeview>
  </UiChildCard>
</template>
