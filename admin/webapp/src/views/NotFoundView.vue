<script setup lang="ts">
import { RouterLink } from "vue-router";
import AppFooter from "@/components/app/AppFooter.vue";
</script>

<template>
  <div class="flex min-h-screen flex-col bg-surface">
    <div
      class="flex flex-1 flex-col items-center justify-center px-4 py-12"
    >
      <p class="font-display text-4xl font-semibold text-onSurface">404</p>
      <p class="mt-2 text-onSurface-variant">페이지를 찾을 수 없습니다.</p>
      <RouterLink to="/" class="btn-primary mt-8">대시보드로</RouterLink>
    </div>
    <AppFooter />
  </div>
</template>
