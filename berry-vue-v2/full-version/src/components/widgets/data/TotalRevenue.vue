<script setup lang="ts">
import { shallowRef } from 'vue';

// import icons
import { ChevronUpIcon, ChevronDownIcon } from 'vue-tabler-icons';

const revenues = shallowRef([
  {
    name: 'Bitcoin',
    price: 145.58
  },
  {
    name: 'Ethereum',
    price: 6.368
  },
  {
    name: 'Ripple',
    price: 458.63
  },
  {
    name: 'Neo',
    price: 5.631
  },
  {
    name: 'Ethereum',
    price: 6.368
  },
  {
    name: 'Ripple',
    price: 458.63
  },
  {
    name: 'Bitcoin',
    price: 145.58
  }
]);
</script>

<template>
  <PerfectScrollbar :style="{ height: '320px' }" :options="{ suppressScrollX: true }">
    <v-list class="py-0">
      <v-list-item v-for="(revenue, i) in revenues" :key="i" :value="revenue" color="primary">
        <template #prepend>
          <ChevronUpIcon v-if="revenue.price > 145" stroke-width="1.5" width="20" class="me-3 text-success" />
          <ChevronDownIcon v-else stroke-width="1.5" width="20" class="me-3 text-error" />
        </template>
        <div class="d-inline-flex align-center justify-space-between w-100">
          <h5 class="font-weight-regular">
            {{ revenue.name }}
          </h5>
          <h5 v-if="revenue.price > 145" class="ms-auto font-weight-regular text-success">+ ${{ revenue.price }}</h5>
          <h5 v-else class="ms-auto font-weight-regular text-error">- ${{ revenue.price }}</h5>
        </div>
      </v-list-item>
    </v-list>
  </PerfectScrollbar>
</template>
