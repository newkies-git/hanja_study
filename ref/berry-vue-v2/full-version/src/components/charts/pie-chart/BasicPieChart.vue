<script setup lang="ts">
const items = [
  { key: 1, title: 'Yes', value: 45 },
  { key: 2, title: 'No', value: 40 },
  { key: 3, title: 'Maybe', value: 15 }
];
</script>
<template>
  <v-pie
    title="Basic pie"
    :palette="[
      'rgba(var(--v-theme-secondary), var(--v-high-opacity))',
      'rgba(var(--v-theme-success), var(--v-high-opacity))',
      'rgba(var(--v-theme-warning), var(--v-high-opacity))'
    ]"
    :size="223"
    :items="items"
    class="justify-center"
  />
</template>
