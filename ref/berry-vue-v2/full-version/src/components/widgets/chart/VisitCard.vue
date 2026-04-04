<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();
const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'area',
      height: 40,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    colors: [currentColors.value.primary],
    dataLabels: {
      enabled: false
    },
    fill: {
      type: 'solid',
      opacity: 0.3
    },
    markers: {
      size: 4,
      strokeWidth: 2,
      hover: {
        size: 6
      }
    },
    stroke: {
      curve: 'straight',
      width: 3
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
      name: 'Visits',
      data: [9, 66, 41, 89, 63, 25, 44, 12, 36, 20, 54, 25, 9]
    }
  ]
};
</script>

<template>
  <v-card class="overflow-hidden" elevation="0">
    <v-card variant="outlined">
      <v-card-text>
        <h3 class="mb-1">$16, 756</h3>
        <h5 class="text-medium-emphasis d-flex align-center mb-5">
          Visits
          <ChevronDownIcon stroke-width="2" width="20" class="ms-2 text-error" />
        </h5>

        <apexchart type="area" height="40" :options="chartOptions1" :series="lineChart1.series" />
      </v-card-text>
    </v-card>
  </v-card>
</template>
