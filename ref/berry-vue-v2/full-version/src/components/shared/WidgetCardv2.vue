<script setup lang="ts">
const props = defineProps({
  title: String,
  hideaction: Boolean,
  cardClass: String
});
</script>

<template>
  <!-- -------------------------------------------------------------------- -->
  <!-- Card with Header & Footer -->
  <!-- -------------------------------------------------------------------- -->
  <v-card variant="flat" class="overflow-hidden" :class="cardClass">
    <v-card-item>
      <v-card-title class="text-18">
        {{ props.title }}
      </v-card-title>
    </v-card-item>
    <v-divider />
    <slot />
    <v-divider />
    <v-card-actions :class="`${props.hideaction ? 'd-none' : ''}`">
      <slot name="footer" />
    </v-card-actions>
  </v-card>
</template>
