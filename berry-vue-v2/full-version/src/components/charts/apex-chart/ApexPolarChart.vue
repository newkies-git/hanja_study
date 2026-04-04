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
      type: 'polarArea',
      width: 450,
      height: 450,
      fontFamily: `inherit`,
      foreColor: textColor
    },
    ...getThemeMode(),
    colors: [primaryColor, secondaryColor, successColor, errorColor, warningColor],
    fill: {
      opacity: 1
    },
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
        breakpoint: 450,
        chart: {
          width: 280,
          height: 280
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
const polarChart = {
  series: [14, 23, 21, 17, 15, 10, 12, 17, 21]
};
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Polar Chart -->
  <!-- ---------------------------------------------------- -->

  <apexchart type="polarArea" :options="chartOptions" :series="polarChart.series" />
</template>
