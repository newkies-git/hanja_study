<script setup lang="ts">
import { computed } from 'vue';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { getThemeMode } = useApexChartTheme();

const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 105,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    dataLabels: {
      enabled: false
    },
    colors: ['#fff'],

    stroke: {
      curve: 'smooth',
      width: 3
    },
    yaxis: {
      min: 20,
      max: 100
    },
    tooltip: {
      fixed: {
        enabled: false
      },
      x: {
        show: false
      },
      marker: {
        show: false
      }
    }
  };
});

// chart 1
const lineChart1 = {
  series: [
    {
      name: 'Sales/Order Per Day',
      data: [55, 35, 75, 25, 90, 50]
    }
  ]
};
</script>

<template>
  <v-card elevation="0">
    <v-card class="overflow-hidden" variant="outlined">
      <v-card-text class="bg-primary text-white">
        <div class="d-flex alig-center justify-space-between mb-4">
          <h3 class="text-body-large mb-1">Order Per Month</h3>
          <span class="text-body-small ms-auto d-flex align-center">
            <TrendingDownIcon width="34" class="text-white me-2" stroke-width="2" />28%
          </span>
        </div>

        <apexchart type="line" height="105" class="text-darkText" :options="chartOptions1" :series="lineChart1.series" />
      </v-card-text>
      <v-card-text>
        <v-row>
          <v-col cols="6" class="text-center">
            <h3 class="mb-1">1695</h3>
            <span class="text-body-large text-medium-emphasis"><span class="font-weight-regular">Total Orders</span></span>
          </v-col>
          <v-col cols="6" class="text-center">
            <h3 class="mb-1">321</h3>
            <span class="text-body-large text-medium-emphasis"><span class="font-weight-regular">Today Orders</span></span>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </v-card>
</template>
