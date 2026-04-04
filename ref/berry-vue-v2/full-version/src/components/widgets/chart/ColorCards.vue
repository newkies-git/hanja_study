<script setup lang="ts">
import { computed } from 'vue';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { getThemeMode } = useApexChartTheme();

const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'area',
      height: 100,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    dataLabels: {
      enabled: false
    },
    colors: ['#fff'],
    fill: {
      type: 'solid',
      opacity: 0.4
    },
    stroke: {
      curve: 'smooth',
      width: 3
    },
    yaxis: {
      min: 0,
      max: 30
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
          formatter: () => 'Total Sales'
        }
      },
      marker: {
        show: false
      }
    }
  };
});

// chart 2
const chartOptions2 = computed(() => {
  return {
    chart: {
      type: 'area',
      height: 100,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    dataLabels: {
      enabled: false
    },
    colors: ['#fff'],
    fill: {
      type: 'solid',
      opacity: 0.4
    },
    stroke: {
      curve: 'smooth',
      width: 3
    },
    yaxis: {
      min: 0,
      max: 30
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
          formatter: () => 'Total Sales'
        }
      },
      marker: {
        show: false
      }
    }
  };
});

// chart 3
const chartOptions3 = computed(() => {
  return {
    chart: {
      type: 'area',
      height: 100,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    dataLabels: {
      enabled: false
    },
    colors: ['#fff'],
    fill: {
      type: 'solid',
      opacity: 0.4
    },
    stroke: {
      curve: 'smooth',
      width: 3
    },
    yaxis: {
      min: 0,
      max: 30
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
          formatter: () => 'Total Sales'
        }
      },
      marker: {
        show: false
      }
    }
  };
});

// chart 4
const chartOptions4 = computed(() => {
  return {
    chart: {
      type: 'area',
      height: 100,
      fontFamily: `inherit`,
      foreColor: '#a1aab2',
      sparkline: {
        enabled: true
      }
    },
    ...getThemeMode(),
    dataLabels: {
      enabled: false
    },
    colors: ['#fff'],
    fill: {
      type: 'solid',
      opacity: 0.4
    },
    stroke: {
      curve: 'smooth',
      width: 3
    },
    yaxis: {
      min: 0,
      max: 30
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
          formatter: () => 'Total Sales'
        }
      },
      marker: {
        show: false
      }
    }
  };
});

// chart 1
const areaChart1 = {
  series: [
    {
      name: 'series1',
      data: [20, 10, 18, 12, 25, 10, 20]
    }
  ]
};

// chart 2
const areaChart2 = {
  series: [
    {
      name: 'series1',
      data: [10, 20, 18, 25, 12, 10, 20]
    }
  ]
};

// chart 3
const areaChart3 = {
  series: [
    {
      name: 'series1',
      data: [20, 10, 18, 12, 25, 10, 20]
    }
  ]
};

// chart 4
const areaChart4 = {
  series: [
    {
      name: 'series1',
      data: [10, 20, 18, 25, 12, 10, 20]
    }
  ]
};
</script>

<template>
  <v-row>
    <!-- chart 1 -->
    <v-col cols="12" sm="6" lg="3">
      <v-card class="bg-primary overflow-hidden" elevation="0">
        <v-card-text>
          <div class="d-flex align-start">
            <div>
              <h3 class="mb-1">4000</h3>
              <span class="text-body-large"><span class="font-weight-regular">Total Sales</span></span>
            </div>
            <span class="text-body-large ms-auto"><span class="font-weight-regular">42%</span></span>
          </div>
        </v-card-text>
        <apexchart type="area" class="text-darkText" height="100" :options="chartOptions1" :series="areaChart1.series" />
      </v-card>
    </v-col>

    <!-- chart 2 -->
    <v-col cols="12" sm="6" lg="3">
      <v-card class="bg-error overflow-hidden" elevation="0">
        <v-card-text>
          <div class="d-flex align-start">
            <div>
              <h3 class="mb-1">2500</h3>
              <span class="text-body-large">
                <span class="font-weight-regular">Total Comment</span>
              </span>
            </div>
            <span class="text-body-large ms-auto">
              <span class="font-weight-regular">15%</span>
            </span>
          </div>
        </v-card-text>
        <apexchart type="area" class="text-darkText" height="100" :options="chartOptions2" :series="areaChart2.series" />
      </v-card>
    </v-col>

    <!-- chart 3 -->
    <v-col cols="12" sm="6" lg="3">
      <v-card class="bg-success overflow-hidden" elevation="0">
        <v-card-text>
          <div class="d-flex align-start">
            <div>
              <h3 class="mb-1">2500</h3>
              <span class="text-body-large">
                <span class="font-weight-regular">Total Status</span>
              </span>
            </div>
            <span class="text-body-large ms-auto">
              <span class="font-weight-regular">95%</span>
            </span>
          </div>
        </v-card-text>
        <apexchart type="area" class="text-darkText" height="100" :options="chartOptions3" :series="areaChart3.series" />
      </v-card>
    </v-col>

    <!-- chart 4 -->
    <v-col cols="12" sm="6" lg="3">
      <v-card class="bg-secondary overflow-hidden" elevation="0">
        <v-card-text>
          <div class="d-flex align-start">
            <div>
              <h3 class="mb-1">12500</h3>
              <span class="text-body-large">
                <span class="font-weight-regular">Total Visitors</span>
              </span>
            </div>
            <span class="text-body-large ms-auto">
              <span class="font-weight-regular">75%</span>
            </span>
          </div>
        </v-card-text>
        <apexchart type="area" class="text-darkText" height="100" :options="chartOptions4" :series="areaChart4.series" />
      </v-card>
    </v-col>
  </v-row>
</template>
