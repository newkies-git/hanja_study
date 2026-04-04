<script setup lang="ts">
import { ref, computed } from 'vue';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { getThemeMode } = useApexChartTheme();

const select = ref({ state: 'Today', abbr: 'FL' });
const items = [
  { state: 'Today', abbr: 'FL' },
  { state: 'This Month', abbr: 'GA' },
  { state: 'This Year', abbr: 'NE' }
];

// chart 1
const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'bar',
      height: 480,
      fontFamily: `inherit`,
      foreColor: 'rgba(var(--v-theme-darkText), var(--v-high-opacity))',
      stacked: true
    },
    ...getThemeMode(),
    colors: [
      'rgba(var(--v-theme-lightprimary), var(--v-high-opacity))',
      'rgba(var(--v-theme-primary), var(--v-high-opacity))',
      'rgba(var(--v-theme-secondary), var(--v-high-opacity))',
      'rgba(var(--v-theme-lightsecondary), var(--v-high-opacity))'
    ],
    responsive: [
      {
        breakpoint: 480,
        options: {
          legend: {
            position: 'bottom',
            offsetX: -10,
            offsetY: 0
          }
        }
      }
    ],
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '50%'
      }
    },
    xaxis: {
      type: 'category',
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    },
    legend: {
      show: true,
      fontFamily: `'Roboto', sans-serif`,
      position: 'bottom',
      offsetX: 20,
      labels: {
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
    fill: {
      type: 'solid'
    },
    states: {
      hover: {
        filter: {
          type: 'darken'
        }
      }
    },
    dataLabels: {
      enabled: false
    },
    grid: {
      show: true
    }
  };
});

// chart 1
const lineChart1 = {
  series: [
    {
      name: 'Investment',
      data: [35, 125, 35, 35, 35, 80, 35, 20, 35, 45, 15, 75]
    },
    {
      name: 'Loss',
      data: [35, 15, 15, 35, 65, 40, 80, 25, 15, 85, 25, 75]
    },
    {
      name: 'Profit',
      data: [35, 145, 35, 35, 20, 105, 100, 10, 65, 45, 30, 10]
    },
    {
      name: 'Maintenance',
      data: [0, 0, 75, 0, 0, 115, 0, 0, 0, 0, 150, 0]
    }
  ]
};
</script>

<template>
  <v-card elevation="0">
    <v-card variant="outlined">
      <v-card-text>
        <v-row>
          <v-col cols="12" sm="9">
            <h6 class="text-disabled font-weight-bold">Total Growth</h6>
            <h3 class="mt-1">$2,324.00</h3>
          </v-col>
          <v-col cols="12" sm="3">
            <v-select
              v-model="select"
              color="primary"
              variant="outlined"
              hide-details
              :items="items"
              item-title="state"
              item-value="abbr"
              label="Select"
              persistent-hint
              return-object
              single-line
            />
          </v-col>
        </v-row>
        <div class="mt-4">
          <apexchart type="bar" height="480" :options="chartOptions1" :series="lineChart1.series" />
        </div>
      </v-card-text>
    </v-card>
  </v-card>
</template>
