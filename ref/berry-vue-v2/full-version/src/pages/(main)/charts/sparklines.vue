<script setup lang="ts">
import { computed, ref, onMounted } from 'vue';
import { useCurrentTheme } from '@/composables/useCurrentTheme';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// theme breadcrumb
const page = ref({ title: 'Sparklines' });
const breadcrumbs = ref([
  {
    title: 'Charts',
    disabled: false,
    href: '#'
  },
  {
    title: 'Sparklines',
    disabled: true,
    href: '#'
  }
]);

const { currentColors } = useCurrentTheme();

// Sparkline configuration
const width = ref(2);
const radius = ref(10);
const padding = ref(8);
const lineCap = ref('round');
const gradient = computed(() => [currentColors.value.error || '', currentColors.value.warning || '', currentColors.value.info || '']);
const value = ref([0, 2, 5, 9, 5, 10, 3, 5, 0, 0, 1, 8, 2, 9, 0]);
const gradientDirection = ref<'top' | 'bottom' | 'left' | 'right'>('top');
const fill = ref(false);
const type = ref<'trend' | 'bar'>('trend');
const autoLineWidth = ref(false);

// fill chart
const fillChart = ref(true);
const fillColor = ref(['#42b3f4']);
const smooth = ref(true);
const fillValue = ref([0, 2, 5, 9, 5, 10, 3, 5, 0, 0, 1, 8, 2, 9, 0]);

// smooth chart
const noSmooth = ref(false);
const smoothColor = computed(() => [currentColors.value.success || '']);

// line width chart
const lineChartColor = ref(['#ffc107', '#fff8e1']);
const lineWidth = ref(4);

// fill gradient
const fillLineWidth = ref(2);
const fillGradient = ref(['#5e35b1', 'rgba(94, 53, 177, 0.5)', 'rgba(255,255,255,0.8)']);

// custom values
const labelvalue = ref([423, 446, 675, 510, 590, 610, 760]);

const exhale = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
const checking = ref(false);
const heartbeats = ref<number[]>([]);
const avg = computed(() => {
  const sum = heartbeats.value.reduce((acc, cur) => acc + cur, 0);
  const length = heartbeats.value.length;
  if (!sum && !length) return 0;
  return Math.ceil(sum / length);
});
function heartbeat() {
  return Math.ceil(Math.random() * (120 - 80) + 80);
}
async function takePulse(inhale: boolean = true) {
  checking.value = true;
  if (inhale) await exhale(1000);
  heartbeats.value = Array.from({ length: 20 }, heartbeat);
  checking.value = false;
}

onMounted(() => {
  takePulse(false);
});
</script>

<template>
  <!-- ---------------------------------------------------- -->
  <!-- Apex Chart -->
  <!-- ---------------------------------------------------- -->
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Default">
        <v-sparkline
          :auto-line-width="autoLineWidth"
          :fill="fill"
          :gradient="gradient"
          :gradient-direction="gradientDirection"
          :line-width="width"
          :model-value="value"
          :padding="padding"
          :smooth="radius || false"
          :stroke-linecap="lineCap"
          :type="type"
          auto-draw
        ></v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Fill">
        <v-sparkline :fill="fillChart" :gradient="fillColor" :model-value="fillValue" :smooth="smooth"></v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Smooth option">
        <v-sparkline :fill="fillChart" :gradient="smoothColor" :model-value="fillValue" :smooth="noSmooth"></v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Line width">
        <v-sparkline
          :fill="fillChart"
          :gradient="lineChartColor"
          :model-value="fillValue"
          :smooth="smooth"
          :line-width="lineWidth"
        ></v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Fill gradient">
        <v-sparkline
          :fill="fillChart"
          :gradient="fillGradient"
          :line-width="fillLineWidth"
          :model-value="value"
          :smooth="smooth"
        ></v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <UiParentCard title="Custom labels">
        <v-sparkline
          :model-value="labelvalue"
          color="#03c9d7"
          height="75"
          padding="20"
          stroke-linecap="round"
          label-size="11"
          :line-width="2"
          smooth
        >
          <template v-slot:label="item"> ${{ item.value }} </template>
        </v-sparkline>
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Heart rate">
        <v-sparkline
          :key="String(avg)"
          :gradient="['#f72047', '#ffd200', '#1feaea']"
          :line-width="1"
          :model-value="heartbeats"
          :smooth="16"
          height="50"
          stroke-linecap="round"
        ></v-sparkline>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
