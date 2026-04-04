<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'bar',
      height: 40,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    colors: [currentColors.value.success],
    dataLabels: {
      enabled: false
    },
    plotOptions: {
      bar: {
        columnWidth: '60%'
      }
    },
    xaxis: {
      crosshairs: {
        width: 1
      }
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
      name: 'Bounce Rate',
      data: [9, 66, 41, 89, 63, 25, 44, 12, 36, 20, 54, 25, 9]
    }
  ]
};
</script>

<template>
  <v-card class="overflow-hidden" elevation="0">
    <v-card variant="outlined">
      <v-card-text>
        <h3 class="mb-1">49.54%</h3>
        <span class="text-body-large text-medium-emphasis d-flex align-center mb-5"
          >Bounce Rate
          <ChevronUpIcon stroke-width="2" width="20" class="ms-2 text-primary" />
        </span>

        <apexchart type="bar" height="40" :options="chartOptions1" :series="lineChart1.series" />
      </v-card-text>
    </v-card>
  </v-card>
</template>
