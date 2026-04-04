<script setup lang="ts">
import { computed } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
import { useApexChartTheme } from '@/utils/apexChartTheme';

const { currentColors } = useCurrentTheme();
const { getThemeMode } = useApexChartTheme();

const chartOptions1 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: ['#ffc107'],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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

// chart 2
const chartOptions2 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: [currentColors.value.secondary],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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

// chart 3
const chartOptions3 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: ['#FFAB91'],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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

// chart 4
const chartOptions4 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: [currentColors.value.secondary],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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

// chart 5
const chartOptions5 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: [currentColors.value.primary],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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

// chart 6
const chartOptions6 = computed(() => {
  return {
    chart: {
      type: 'line',
      height: 30,
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
    colors: ['#f44336'],
    stroke: {
      curve: 'straight',
      width: 2
    },
    yaxis: {
      min: -2,
      max: 5,
      labels: {
        show: false
      }
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
      name: 'Analytics',
      data: [2, 1, 2, 1, 1, 3, 0]
    }
  ]
};

// chart 2
const lineChart2 = {
  series: [
    {
      name: 'Analytics',
      data: [3, 0, 1, 2, 1, 1, 2]
    }
  ]
};

// chart 3
const lineChart3 = {
  series: [
    {
      name: 'Analytics',
      data: [2, 1, 2, 1, 1, 3, 0]
    }
  ]
};

// chart 4
const lineChart4 = {
  series: [
    {
      name: 'Analytics',
      data: [2, 1, 2, 1, 1, 3, 0]
    }
  ]
};

// chart 5
const lineChart5 = {
  series: [
    {
      name: 'Analytics',
      data: [2, 1, 2, 1, 1, 3, 0]
    }
  ]
};

// chart 6
const lineChart6 = {
  series: [
    {
      name: 'Analytics',
      data: [2, 1, 2, 1, 1, 3, 0]
    }
  ]
};
</script>

<template>
  <v-row>
    <!-- chart 1 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Users</h5>
            <h4 class="mb-1">798</h4>

            <apexchart type="line" height="30" :options="chartOptions1" :series="lineChart1.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <!-- chart 2 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Timeout</h5>
            <h4 class="mb-1">486</h4>

            <apexchart type="line" height="30" :options="chartOptions2" :series="lineChart2.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <!-- chart 3 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Views</h5>
            <h4 class="mb-1">9, 454</h4>

            <apexchart type="line" height="30" :options="chartOptions3" :series="lineChart3.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <!-- chart 4 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Session</h5>
            <h4 class="mb-1">7.15</h4>

            <apexchart type="line" height="30" :options="chartOptions4" :series="lineChart4.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <!-- chart 5 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Avg. Session</h5>
            <h4 class="mb-1">04:30</h4>

            <apexchart type="line" height="30" :options="chartOptions5" :series="lineChart5.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <!-- chart 6 -->
    <v-col cols="12" sm="6" md="4" lg="2">
      <v-card class="overflow-hidden" elevation="0">
        <v-card variant="outlined">
          <v-card-text>
            <h5 class="font-weight-regular">Bounce Rate</h5>
            <h4 class="mb-1">1.55%</h4>

            <apexchart type="line" height="30" :options="chartOptions6" :series="lineChart6.series" />
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
