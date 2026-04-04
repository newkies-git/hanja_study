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
  const textColor = currentColors.value.lightText;

  return {
    chart: {
      type: 'bar',
      height: 350,
      fontFamily: `inherit`,
      foreColor: textColor
    },
    ...getThemeMode(),
    colors: [secondaryColor, primaryColor, successColor],
    plotOptions: {
      bar: {
        horizontal: false,
        endingShape: 'rounded',
        columnWidth: '55%'
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
      categories: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
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
    },
    tooltip: {
      y: {
        formatter: function (val: number) {
          return '$ ' + val + ' thousands';
        }
      }
    },
    legend: {
      show: true,
      position: 'bottom',
      offsetX: 10,
      offsetY: 10,
      labels: {
        colors: textColor,
        useSeriesColors: false
      },
      markers: {
        width: 16,
        height: 16,
        radius: 5
      },
      itemMargin: {
        horizontal: 15,
        vertical: 8
      }
    },
    responsive: [
      {
        breakpoint: 600,
        options: {
          yaxis: {
            show: false
          }
        }
      }
    ]
  };
});

const columnChart = {
  series: [
    {
      name: 'Net Profit',
      data: [44, 55, 57, 56, 61, 58, 63, 60, 66]
    },
    {
      name: 'Revenue',
      data: [76, 85, 101, 98, 87, 105, 91, 114, 94]
    },
    {
      name: 'Free Cash Flow',
      data: [35, 41, 36, 26, 45, 48, 52, 53, 41]
    }
  ]
};
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Column Chart -->
  <!-- ---------------------------------------------------- -->

  <apexchart type="bar" height="350" :options="chartOptions" :series="columnChart.series"> </apexchart>
</template>
