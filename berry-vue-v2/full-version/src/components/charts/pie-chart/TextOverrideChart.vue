<script setup lang="ts">
const items = [
  {
    key: 1,
    title: 'TypeScript',
    value: 52.3,
    color: 'rgba(var(--v-theme-primary), var(--v-high-opacity))'
  },
  {
    key: 2,
    title: 'Elm',
    value: 11.6,
    color: 'rgba(var(--v-theme-secondary), var(--v-high-opacity))'
  },
  {
    key: 3,
    title: 'CoffeeScript',
    value: 6.2,
    color: 'rgba(var(--v-theme-success), var(--v-high-opacity))'
  },
  {
    key: 4,
    title: 'Civet',
    value: 3.0,
    color: 'rgba(var(--v-theme-warning), var(--v-high-opacity))'
  },
  {
    key: 5,
    title: 'N/A',
    value: 26.9,
    color: 'rgba(var(--v-theme-lightText), .2)'
  }
];
</script>
<template>
  <v-pie
    :items="items"
    :legend="{ textFormat: '[title] ([value]%)' }"
    :tooltip="{ subtitleFormat: '[value]%' }"
    gap="4"
    hover-scale="0"
    inner-cut="85"
    size="250"
    animation
    hide-slice
    class="justify-center"
  />
</template>
