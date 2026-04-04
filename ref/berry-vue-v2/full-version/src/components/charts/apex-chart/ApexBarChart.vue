<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions = computed(() => {
  const successColor = currentColors.value.success;
  const textColor = currentColors.value.lightText;
  return {
    chart: {
      type: 'bar',
      height: 350,
      fontFamily: `inherit`,
      foreColor: textColor
    },
    ...getThemeMode(),
    colors: [successColor],
    plotOptions: {
      bar: {
        horizontal: true
      }
    },
    dataLabels: {
      enabled: false
    },
    stroke: {
      show: true,
      width: 2,
      colors: ['transparent']
    },

    xaxis: {
      categories: [
        'South Korea',
        'Canada',
        'United Kingdom',
        'Netherlands',
        'Italy',
        'France',
        'Japan',
        'United States',
        'China',
        'Germany'
      ],
      labels: {
        style: {
          colors: textColor
        }
      }
    },
    yaxis: {
      labels: {
        style: {
          colors: textColor
        }
      }
    },
    fill: {
      opacity: 1
    },
    grid: {
      borderColor: 'rgba(0,0,0,0.1)'
    }
  };
});

const barChart = {
  series: [
    {
      data: [400, 430, 448, 470, 540, 580, 690, 1100, 1200, 1380]
    }
  ]
};
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Bar Chart -->
  <!-- ---------------------------------------------------- -->

  <apexchart type="bar" height="350" :options="chartOptions" :series="barChart.series" />
</template>
