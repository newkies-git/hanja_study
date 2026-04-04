<script setup lang="ts">
// assets
import imageEmpty from '@/assets/images/e-commerce/empty.svg';
</script>

<template>
  <v-row class="justify-conent-center">
    <v-col class="text-center" lg="10">
      <v-img :src="imageEmpty" alt="cover" />
      <h2 class="text-display-large">There is no Product</h2>
      <p>Try checking your spelling or use more general terms</p>
    </v-col>
  </v-row>
</template>
