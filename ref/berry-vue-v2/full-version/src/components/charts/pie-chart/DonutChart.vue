<script setup lang="ts">
const items = [
  { key: 1, title: 'Yes', value: 45 },
  { key: 2, title: 'No', value: 40 },
  { key: 3, title: 'Maybe', value: 15 }
];
</script>
<template>
  <v-pie
    title="Do you like donuts?"
    hide-slice
    :inner-cut="85"
    :size="223"
    :palette="[
      'rgba(var(--v-theme-secondary), var(--v-high-opacity))',
      'rgba(var(--v-theme-success), var(--v-high-opacity))',
      'rgba(var(--v-theme-warning), var(--v-high-opacity))'
    ]"
    :items="items"
    class="justify-center"
  />
</template>
