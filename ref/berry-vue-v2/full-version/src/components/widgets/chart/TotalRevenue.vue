<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';
import UiParentCard from '@/components/shared/UiParentCard.vue';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'donut',
      height: 200,
      fontFamily: `inherit`,
      foreColor: '#a1aab2'
    },
    ...getThemeMode(),
    colors: ['#f44336', currentColors.value.primary, currentColors.value.secondary],
    dataLabels: {
      enabled: false
    },
    labels: ['Youtube', 'Facebook', 'Twitter'],
    legend: {
      show: true,
      position: 'bottom',
      fontFamily: 'inherit',
      labels: {
        colors: 'inherit'
      },
      itemMargin: {
        horizontal: 10,
        vertical: 10
      }
    }
  };
});

// chart 1
const lineChart1 = {
  series: [1258, 975, 500]
};
</script>

<template>
  <UiParentCard class="overflow-hidden" title="Total Revenue">
    <apexchart type="donut" height="200" :options="chartOptions1" :series="lineChart1.series" />
    <v-row class="mt-6">
      <v-col cols="4">
        <h6>Youtube</h6>
        <h5 class="text-error">+ 16.85%</h5>
      </v-col>
      <v-col cols="4">
        <h6>Facebook</h6>
        <h5 class="text-primary">+ 45.36%</h5>
      </v-col>
      <v-col cols="4">
        <h6>Twitter</h6>
        <h5 class="text-secondary">- 50.69%</h5>
      </v-col>
    </v-row>
  </UiParentCard>
</template>
