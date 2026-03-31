<script setup lang="ts">
const year = new Date().getFullYear();
const holder =
  (import.meta.env.VITE_APP_COPYRIGHT_HOLDER as string | undefined)?.trim() ||
  "HANJA Admin";
</script>

<template>
  <footer
    class="shrink-0 border-t border-outline-variant/60 bg-surface-lowest/90 px-4 py-3 text-center text-[11px] leading-relaxed text-onSurface-variant backdrop-blur-sm sm:px-6 lg:px-10"
    role="contentinfo"
  >
    <p>
      © {{ year }}
      <span class="font-medium text-onSurface/90">{{ holder }}</span>.
      All rights reserved.
    </p>
  </footer>
</template>
