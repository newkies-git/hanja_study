<script setup lang="ts">
import { shallowRef } from 'vue';

const sources = shallowRef([
  {
    text: 'Direct',
    percent: 80,
    color: 'primary'
  },
  {
    text: 'Social',
    percent: 50,
    color: 'secondary'
  },
  {
    text: 'Referral',
    percent: 20,
    color: 'primary'
  },
  {
    text: 'Bounce',
    percent: 58,
    color: 'secondary'
  },
  {
    text: 'Internet',
    percent: 40,
    color: 'primary'
  },
  {
    text: 'Social',
    percent: 90,
    color: 'primary'
  },
  {
    text: 'Bounce',
    percent: 50,
    color: 'secondary'
  }
]);
</script>

<template>
  <div v-for="(source, i) in sources" :key="i" class="py-3" :class="{ 'pt-0': i === 0, 'pb-0': i === sources.length - 1 }" :value="source">
    <div class="d-flex align-center justify-space-between mb-3">
      <h5 class="text-medium-emphasis">{{ source.text }}</h5>
      <h5 class="text-medium-emphasis">{{ source.percent }}%</h5>
    </div>
    <v-progress-linear :model-value="source.percent" :color="source.color" />
  </div>
</template>
