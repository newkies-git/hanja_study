<script setup lang="ts">
import { shallowRef } from 'vue';

const products = shallowRef([
  {
    title: 'Materially',
    subtext: 'Powerful Admin Theme',
    sales: '16,300',
    avgprice: '53',
    total: '15,652'
  },
  {
    title: 'Photoshop',
    subtext: 'Design Software',
    sales: '16,300',
    avgprice: '53',
    total: '15,652'
  },
  {
    title: 'Guruable',
    subtext: 'Best Admin Template',
    sales: '16,300',
    avgprice: '53',
    total: '15,652'
  },
  {
    title: 'Flatable',
    subtext: 'Admin App',
    sales: '16,300',
    avgprice: '53',
    total: '15,652'
  }
]);
</script>

<template>
  <v-table>
    <thead>
      <tr>
        <th class="text-start text-body-large">Application</th>
        <th class="text-end text-body-large">Sales</th>
        <th class="text-end text-body-large">Avg. Price</th>
        <th class="text-end text-body-large">Total</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="item in products" :key="item.title">
        <td class="py-5">
          <h5>
            {{ item.title }}
          </h5>
          <span class="text-medium-emphasis text-body-small">{{ item.subtext }}</span>
        </td>
        <td class="text-end py-5">
          {{ item.sales }}
        </td>
        <td class="text-end py-5">${{ item.avgprice }}</td>
        <td class="text-end py-5">${{ item.total }}</td>
      </tr>
    </tbody>
  </v-table>
</template>
