<template>
  <RouterView />
</template>

<script setup lang="ts">
import { RouterView } from 'vue-router';
import { useThemeHandler } from '@/composables/useThemeHandler';

// Initialize theme handling
useThemeHandler();
</script>
