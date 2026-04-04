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
      height: 210,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    colors: [currentColors.value.secondary],
    dataLabels: {
      enabled: false
    },
    plotOptions: {
      bar: {
        columnWidth: '80%'
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
      y: {
        title: {
          formatter: () => 'Stock - '
        }
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
      data: [25, 66, 41, 89, 63, 25, 44, 12, 36, 9, 54, 25, 66, 41, 89, 63, 54, 25, 66, 41, 89, 63, 25, 44, 12, 36, 9, 54]
    }
  ]
};
</script>

<template>
  <v-card class="overflow-hidden" elevation="0">
    <v-card variant="outlined">
      <v-card-text>
        <h5 class="mb-1">New Stock <span class="text-medium-emphasis">(Purchased)</span></h5>
        <span class="text-headline-medium d-flex align-center mb-5"
          >0.85%

          <ArrowUpIcon stroke-width="2" width="20" class="ms-2 text-primary" />
          <span class="text-primary mb-n1">0.50%</span>
        </span>
      </v-card-text>
      <apexchart type="bar" height="210" :options="chartOptions1" :series="lineChart1.series" />
    </v-card>
  </v-card>
</template>
