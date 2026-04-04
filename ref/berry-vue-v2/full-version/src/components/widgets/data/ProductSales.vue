<script setup lang="ts">
import { shallowRef } from 'vue';

const products = shallowRef([
  {
    sales: '2136',
    name: 'HeadPhone',
    price: '926.23'
  },
  {
    sales: '2546',
    name: 'Iphone 6',
    price: '926.23'
  },
  {
    sales: '2681',
    name: 'Jacket',
    price: '926.23'
  },
  {
    sales: '2756',
    name: 'HeadPhone',
    price: '926.23'
  },
  {
    sales: '8765',
    name: 'Sofa',
    price: '926.23'
  },
  {
    sales: '3652',
    name: 'Iphone 7',
    price: '926.23'
  }
]);
</script>

<template>
  <div class="pa-4 mb-4">
    <v-row>
      <v-col cols="12" sm="4" class="text-center">
        <h6 class="text-medium-emphasis">Earning</h6>
        <h3 class="mt-1">20,569$</h3>
      </v-col>
      <v-col cols="12" sm="4" class="text-center">
        <h6 class="text-medium-emphasis">Yesterday</h6>
        <h3 class="mt-1">580$</h3>
      </v-col>
      <v-col cols="12" sm="4" class="text-center">
        <h6 class="text-medium-emphasis">This Week</h6>
        <h3 class="mt-1">5,789$</h3>
      </v-col>
    </v-row>
  </div>
  <v-table>
    <thead>
      <tr>
        <th class="text-start text-body-large">Latest Sales</th>
        <th class="text-start text-body-large">Name Product</th>
        <th class="text-end text-body-large">Price</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="item in products" :key="item.name">
        <td>{{ item.sales }}</td>
        <td>{{ item.name }}</td>
        <td class="text-end" width="100">$ {{ item.price }}</td>
      </tr>
    </tbody>
  </v-table>
</template>
