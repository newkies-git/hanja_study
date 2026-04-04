<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { Volume2Icon, VolumeIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Slider' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Slider',
    disabled: true,
    href: '#'
  }
]);

const VOLUME_MIN = 40;
const VOLUME_MAX = 218;
const READONLY_VALUE = 30;

const satisfactionEmojis = ['😭', '😢', '☹️', '🙁', '😐', '🙂', '😊', '😁', '😄', '😍'];

const tickLabels = {
  0: 'Figs',
  1: 'Lemon',
  2: 'Pear',
  3: 'Apple'
};

// Reactive slider values
const basicSlider = ref(50);
const disabledSlider = ref(40);
const volume = ref(40);
const min = ref(-50);
const max = ref(90);
const progressSlider = ref(40);
const stepSlider = ref(0);
const verticalSlider1 = ref(40);
const verticalSlider2 = ref(40);
const thumbSlider1 = ref(40);
const thumbSlider2 = ref(83);
const thumbSlider3 = ref(65);
const thumbSlider4 = ref(80);

const colorSlider1 = ref(40);
const colorSlider2 = ref(50);
const colorSlider3 = ref(30);
</script>

// ===============================|| Ui Slider ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Slider">
        <v-row>
          <!-- Basic Slider -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="Basic Slider">
              <v-slider v-model="basicSlider" color="primary" label="basic" />
            </UiChildCard>
          </v-col>
          <!-- Disabled -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="Disabled">
              <v-slider v-model="disabledSlider" color="primary" label="basic" disabled />
            </UiChildCard>
          </v-col>
          <!-- Volume -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="Volume">
              <v-slider v-model="volume" color="info" :min="VOLUME_MIN" :max="VOLUME_MAX" :step="1">
                <template #prepend>
                  <v-btn size="small" icon variant="text" color="info">
                    <Volume2Icon stroke-width="1.5" size="20" />
                  </v-btn>
                </template>

                <template #append>
                  <v-btn size="small" icon variant="text" color="info">
                    <VolumeIcon stroke-width="1.5" size="20" />
                  </v-btn>
                </template>
              </v-slider>
            </UiChildCard>
          </v-col>
          <!-- With Label -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="With Label">
              <v-slider v-model="progressSlider" label="Progress" class="align-center mx-0" :max="max" :min="min" step="1" color="primary">
                <template #append>
                  <v-text-field v-model="progressSlider" variant="plain" hide-details />
                </template>
              </v-slider>
            </UiChildCard>
          </v-col>
          <!-- With Step -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="Step">
              <v-slider color="success" v-model="stepSlider" :max="1" :min="0" :step="0.2" thumb-label></v-slider>
            </UiChildCard>
          </v-col>
          <!-- Readonly -->
          <v-col cols="12" lg="4" md="6">
            <UiChildCard title="Readonly">
              <v-slider label="Readonly" color="warning" :model-value="READONLY_VALUE" readonly></v-slider>
            </UiChildCard>
          </v-col>
          <!-- Slider colors -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Colors">
              <v-slider v-model="colorSlider1" color="warning" label="Color"></v-slider>

              <v-slider v-model="colorSlider2" label="Track color" track-color="success"></v-slider>

              <v-slider v-model="colorSlider3" label="Thumb color" thumb-color="info"></v-slider>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="Thumb">
              <div class="d-flex flex-column">
                <div>
                  <h6 class="text-label-small">Show thumb when using slider</h6>
                  <v-slider v-model="thumbSlider1" thumb-label color="primary"></v-slider>
                </div>

                <div>
                  <h6 class="text-label-small">Always show thumb label</h6>
                  <v-slider v-model="thumbSlider2" thumb-label="always" color="secondary"></v-slider>
                </div>

                <div>
                  <h6 class="text-label-small">Custom thumb size</h6>
                  <v-slider v-model="thumbSlider3" :thumb-size="36" thumb-label="always" color="success"></v-slider>
                </div>

                <div>
                  <h6 class="text-label-small">Custom thumb label</h6>
                  <v-slider v-model="thumbSlider4" thumb-label="always" color="warning">
                    <template #thumb-label="{ modelValue }">
                      {{ satisfactionEmojis[Math.min(Math.floor(modelValue / 10), 9)] }}
                    </template>
                  </v-slider>
                </div>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Vertical Slider -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Vertical Slider">
              <div class="d-flex">
                <v-slider v-model="verticalSlider1" direction="vertical" label="Regular" color="primary" />
                <v-slider v-model="verticalSlider2" direction="vertical" label="Regular" color="primary" disabled />
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="8">
            <UiChildCard title="Ticks">
              <div>
                <h6 class="text-label-small">Show ticks when using slider</h6>

                <v-slider step="10" show-ticks color="primary"></v-slider>

                <h6 class="text-label-small">Always show ticks</h6>

                <v-slider show-ticks="always" step="10" color="secondary"></v-slider>

                <h6 class="text-label-small">Tick size</h6>

                <v-slider show-ticks="always" step="10" tick-size="4" color="success"></v-slider>

                <h6 class="text-label-small">Tick labels</h6>

                <v-slider :max="3" :ticks="tickLabels" show-ticks="always" step="1" tick-size="4" color="warning"></v-slider>
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
