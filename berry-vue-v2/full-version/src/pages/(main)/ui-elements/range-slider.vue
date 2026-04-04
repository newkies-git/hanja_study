<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Range slider' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Range slider',
    disabled: true,
    href: '#'
  }
]);

// Reactive slider values
const disabledSlider = ref([30, 60]);
const range = ref([-5, 5]);
const value = ref([20, 40]);
const verticalSlider = ref([20, 40]);
const slider1 = ref([10, 20]);
const slider2 = ref([20, 50]);
const slider3 = ref([10, 40]);
const slider4 = ref([30, 60]);
const slider5 = ref([40, 80]);
const slider6 = ref([20, 50]);

const seasons = ref({
  0: 'Winter',
  1: 'Spring',
  2: 'Summer',
  3: 'Fall'
});
const icons = ref(['$snowflake', '$leaf', '$fire', '$water']);
function season(val: number) {
  return icons.value[val];
}
</script>

// ===============================|| Ui Range Slider ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Range slider">
        <v-row>
          <!-- Basic Range Slider -->
          <v-col cols="12" md="6">
            <UiChildCard title="Basic">
              <v-range-slider />
            </UiChildCard>
          </v-col>
          <!-- Disabled -->
          <v-col cols="12" md="6">
            <UiChildCard title="Disabled">
              <v-range-slider v-model="disabledSlider" label="Disabled" disabled />
            </UiChildCard>
          </v-col>
          <!-- Min & Max -->
          <v-col cols="12" md="6">
            <UiChildCard title="Min & Max">
              <v-range-slider v-model="range" :max="10" :min="-10" :step="1" class="align-center mx-0" hide-details color="primary">
                <template v-slot:prepend>
                  <v-text-field
                    v-model="range[0]"
                    density="compact"
                    style="width: 70px"
                    type="number"
                    variant="outlined"
                    hide-details
                    single-line
                  ></v-text-field>
                </template>
                <template v-slot:append>
                  <v-text-field
                    v-model="range[1]"
                    density="compact"
                    style="width: 70px"
                    type="number"
                    variant="outlined"
                    hide-details
                    single-line
                  ></v-text-field>
                </template>
              </v-range-slider>
            </UiChildCard>
          </v-col>
          <!-- Step -->
          <v-col cols="12" md="6">
            <UiChildCard title="Step">
              <v-range-slider
                v-model="value"
                step="10"
                thumb-label="always"
                color="secondary"
                hide-details
                class="pt-5 mt-3"
              ></v-range-slider>
            </UiChildCard>
          </v-col>
          <!-- Vertical -->
          <v-col cols="12" md="6">
            <UiChildCard title="Vertical">
              <v-range-slider v-model="verticalSlider" direction="vertical" color="success"></v-range-slider>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Colors">
              <v-range-slider color="primary" v-model="slider1" />
              <v-range-slider color="secondary" v-model="slider2" />
              <v-range-slider color="success" v-model="slider3" />
              <v-range-slider color="warning" v-model="slider4" />
              <v-range-slider color="info" v-model="slider5" />
              <v-range-slider color="error" v-model="slider6" />
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Thumb Label">
              <v-range-slider
                :model-value="[0, 1]"
                :step="1"
                :ticks="seasons"
                max="3"
                min="0"
                show-ticks="always"
                thumb-label="always"
                tick-size="1"
                class="pt-5 mt-3"
              >
                <template v-slot:thumb-label="{ modelValue }">
                  <v-icon :icon="season(modelValue)"></v-icon>
                </template>
              </v-range-slider>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.v-range-slider {
  .v-slider-track__tick {
    .v-slider-track__tick-label {
      font-size: 12px;
    }
  }
}
</style>
