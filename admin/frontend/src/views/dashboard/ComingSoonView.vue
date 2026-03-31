<script setup lang="ts">
defineProps<{
  title: string;
  description: string;
}>();
</script>

<template>
  <div class="card-surface max-w-2xl">
    <h1 class="font-display text-xl font-semibold text-onSurface">{{ title }}</h1>
    <p class="mt-3 text-onSurface-variant">{{ description }}</p>
  </div>
</template>
