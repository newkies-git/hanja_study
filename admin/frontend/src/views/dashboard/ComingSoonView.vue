<script setup lang="ts">
defineProps<{ title: string; description?: string }>();
</script>

<template>
  <div class="bg-surface-container-lowest rounded-3xl p-8 shadow-ambient">
    <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Coming soon</div>
    <div class="mt-2 text-xl font-headline font-extrabold tracking-tight text-on-surface">{{ title }}</div>
    <p v-if="description" class="mt-3 text-sm text-on-surface-variant whitespace-pre-line">{{ description }}</p>
  </div>
</template>

