<script setup lang="ts">
import { shallowRef } from 'vue';

const requests = shallowRef([
  {
    color: 'primary',
    name: 'You have 3 pending tasks.'
  },
  {
    color: 'error',
    name: 'New order received'
  },
  {
    color: 'success',
    name: 'You have 3 pending tasks.'
  },
  {
    color: 'primary',
    name: 'New order received'
  },
  {
    color: 'warning',
    name: 'Order cancelled'
  }
]);
</script>

<template>
  <v-list class="py-0">
    <v-list-item v-for="(request, i) in requests" :key="i" class="d-flex align-center no-spacer" :value="request">
      <template #prepend>
        <v-avatar size="15" :color="request.color" variant="flat" class="me-3" />
      </template>
      <div class="d-inline-flex align-center justify-space-between w-100">
        <h5 class="font-weight-regular">
          {{ request.name }}
        </h5>
      </div>
    </v-list-item>
  </v-list>
</template>
