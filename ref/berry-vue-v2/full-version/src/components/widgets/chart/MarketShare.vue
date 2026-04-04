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
      height: 200,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    colors: ['#f44336', currentColors.value.secondary, currentColors.value.primary],
    dataLabels: {
      enabled: false
    },
    stroke: {
      curve: 'smooth',
      width: 2
    },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.5,
        opacityTo: 0,
        stops: [0, 80, 100]
      }
    },
    legend: {
      show: false
    },
    yaxis: {
      min: 1,
      max: 100,
      labels: {
        show: false
      }
    }
  };
});

// chart 1
const lineChart1 = {
  series: [
    {
      name: 'Youtube',
      data: [10, 90, 65, 85, 40, 80, 30]
    },
    {
      name: 'Facebook',
      data: [50, 30, 25, 15, 60, 10, 25]
    },
    {
      name: 'Twitter',
      data: [5, 50, 40, 55, 20, 40, 20]
    }
  ]
};
</script>

<template>
  <v-card elevation="0" class="overflow-hidden">
    <v-card variant="outlined">
      <v-card-text>
        <div class="d-sm-flex align-center">
          <div>
            <h3 class="mb-1">Market Share</h3>
            <span class="text-body-large text-medium-emphasis mb-5">Department wise monthly sales report</span>
          </div>
          <h3 class="mt-4 mt-sm-0 ms-auto d-flex align-center">
            <TrendingDownIcon width="34" class="text-error me-2" stroke-width="2" />27, 695.65
          </h3>
        </div>

        <v-row class="mt-5">
          <v-col cols="12" sm="3" class="d-flex align-center">
            <v-btn color="lightsecondary" icon class="text-secondary" rounded="md" variant="flat">
              <BrandFacebookIcon stroke-width="1.5" width="20" />
            </v-btn>
            <h4 class="ms-3">+ 45.36%</h4>
          </v-col>
          <v-col cols="12" sm="3" class="d-flex align-center">
            <v-btn color="lightprimary" icon class="text-primary" rounded="md" variant="flat">
              <BrandTwitterIcon stroke-width="1.5" width="20" />
            </v-btn>
            <h4 class="ms-3">- 50.69%</h4>
          </v-col>
          <v-col cols="12" sm="3" class="d-flex align-center">
            <v-btn color="lighterror" icon class="text-error" rounded="md" variant="flat">
              <BrandYoutubeIcon stroke-width="1.5" width="20" />
            </v-btn>
            <h4 class="ms-3">+ 16.85%</h4>
          </v-col>
        </v-row>
      </v-card-text>
      <apexchart type="area" height="200" :options="chartOptions1" :series="lineChart1.series" />
    </v-card>
  </v-card>
</template>
