<script setup lang="ts">
import { computed } from 'vue';

const items = [
  {
    key: 2,
    title: 'Google',
    value: 75,
    color: 'rgba(var(--v-theme-primary), var(--v-high-opacity))'
  },
  {
    key: 1,
    title: 'Bing',
    value: 20,
    color: 'rgba(var(--v-theme-secondary), var(--v-high-opacity))'
  },
  {
    key: 3,
    title: 'DuckDuckGo',
    value: 17,
    color: 'rgba(var(--v-theme-success), var(--v-high-opacity))'
  },
  {
    key: 4,
    title: 'Brave',
    value: 15,
    color: 'rgba(var(--v-theme-warning), var(--v-high-opacity))'
  },
  {
    key: 5,
    title: 'Kagi',
    value: 5,
    color: 'rgba(var(--v-theme-error), var(--v-high-opacity))'
  }
];
const total = computed(() => items.reduce((sum, i) => sum + i.value, 0));

const legendConfig = {
  position: 'bottom' as const // place legend at the bottom
};

const formatNumber = (n: number) => new Intl.NumberFormat().format(n);
</script>
<template>
  <v-pie
    :items="items"
    :legend="legendConfig"
    :tooltip="{
      subtitleFormat: (s) => `${formatNumber(s.value)} respondents (${((100 * s.value) / total).toFixed(1)}%)`
    }"
    inner-cut="85"
    size="250"
    animation
    hide-slice
    class="justify-center"
  >
    <template v-slot:legend-text="{ item }">
      <div class="d-flex ga-6">
        <div>{{ item.title }}</div>

        <div class="ml-auto font-weight-bold">
          {{ formatNumber(item.value) }}
        </div>
      </div>
    </template>
  </v-pie>
</template>
