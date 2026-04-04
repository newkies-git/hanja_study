<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions = computed(() => {
  const primaryColor = currentColors.value.primary;
  const secondaryColor = currentColors.value.secondary;
  const successColor = currentColors.value.success;
  const errorColor = currentColors.value.error;
  const warningColor = currentColors.value.warning;
  const textColor = currentColors.value.lightText;

  return {
    chart: {
      type: 'pie',
      height: 350,
      width: 350,
      fontFamily: `inherit`,
      foreColor: textColor
    },
    ...getThemeMode(),
    labels: ['Team A', 'Team B', 'Team C', 'Team D', 'Team E'],
    colors: [primaryColor, secondaryColor, successColor, errorColor, warningColor],
    legend: {
      show: true,
      offsetX: 10,
      offsetY: 10,
      labels: {
        colors: textColor,
        useSeriesColors: false
      },
      markers: {
        width: 12,
        height: 12,
        radius: 5
      },
      itemMargin: {
        horizontal: 25,
        vertical: 4
      }
    },
    responsive: [
      {
        breakpoint: 375,
        chart: {
          width: 250,
          height: 250
        },
        options: {
          legend: {
            show: false,
            position: 'bottom'
          }
        }
      }
    ],
    tooltip: {
      theme: 'light',
      fillSeriesColor: false
    }
  };
});
const pieChart = {
  series: [44, 55, 13, 43, 22]
};
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Pie Chart -->
  <!-- ---------------------------------------------------- -->

  <apexchart type="pie" height="350" :options="chartOptions" :series="pieChart.series" />
</template>
