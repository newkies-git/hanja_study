<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiTableCard from '@/components/shared/UiTableCard.vue';

// theme breadcrumb
const page = ref({ title: 'Fixed Header Table' });
const breadcrumbs = ref([
  {
    title: 'Tables',
    disabled: false,
    href: '#'
  },
  {
    title: 'Fixed Header Table',
    disabled: true,
    href: '#'
  }
]);

// table data

const desserts = ref([
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6.0,
    carbs: 24,
    protein: 4.0
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 6.0,
    carbs: 24,
    protein: 4.0
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 6.0,
    carbs: 24,
    protein: 4.0
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 6.0,
    carbs: 24,
    protein: 4.0
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 6.0,
    carbs: 24,
    protein: 4.0
  }
]);
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Table Header Fixed -->
  <!-- ---------------------------------------------------- -->
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiTableCard title="Header Fixed Table">
        <v-table fixed-header height="300px">
          <thead>
            <tr>
              <th class="text-start text-body-large">Dessert (100g serving)</th>
              <th class="text-start text-body-large">Calories</th>
              <th class="text-start text-body-large">Fat (g)</th>
              <th class="text-start text-body-large">Carbs (g)</th>
              <th class="text-start text-body-large">Protein (g)</th>
              <th class="text-start text-body-large">Protein (g)</th>
              <th class="text-start text-body-large">Protein (g)</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in desserts" :key="item.name" class="text-lighttext">
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.name }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.calories }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.fat }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.carbs }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.protein }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.protein }}
                </span>
              </td>
              <td class="text-body-large">
                <span class="font-weight-regular">
                  {{ item.protein }}
                </span>
              </td>
            </tr>
          </tbody>
        </v-table>
      </UiTableCard>
    </v-col>
  </v-row>
</template>
