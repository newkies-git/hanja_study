<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions = computed(() => {
  const primaryColor = currentColors.value.primary;
  const secondaryColor = currentColors.value.secondary;

  return {
    chart: {
      type: 'radialBar',
      height: 350,
      fontFamily: `inherit`,
      foreColor: '#a1aab2'
    },
    ...getThemeMode(),
    colors: [primaryColor, secondaryColor, '#00c853'],
    plotOptions: {
      radialBar: {
        offsetY: 0,
        startAngle: 0,
        endAngle: 270,
        hollow: {
          margin: 5,
          size: '30%',
          background: 'transparent',
          image: undefined
        },
        dataLabels: {
          name: {
            show: false
          },
          value: {
            show: false
          }
        }
      }
    },
    labels: ['Vimeo', 'Messenger', 'Facebook', 'LinkedIn'],
    legend: {
      show: true,
      floating: true,
      fontSize: '16px',
      position: 'left',
      offsetX: 0,
      offsetY: 15,
      labels: {
        useSeriesColors: true
      },
      markers: {
        size: 0
      },
      itemMargin: {
        vertical: 3
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
    ]
  };
});

const redialChart = {
  series: [76, 67, 61, 90]
};
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Redial Chart -->
  <!-- ---------------------------------------------------- -->

  <apexchart type="radialBar" height="350" :options="chartOptions" :series="redialChart.series" />
</template>
