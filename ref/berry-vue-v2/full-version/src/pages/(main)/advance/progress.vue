<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, shallowRef, watch } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Progress' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Progress',
    disabled: true,
    href: '#'
  }
]);

// progress data
const pcolors = ref([
  {
    color: 'primary',
    value: 25
  },
  {
    color: 'primary',
    value: 50
  },
  {
    color: 'primary',
    value: 75
  },
  {
    color: 'primary',
    value: 100
  }
]);

const Circularvalue = ref(0);

let Circularinterval = -1;
onMounted(() => {
  Circularinterval = setInterval(() => {
    if (Circularvalue.value === 100) {
      return (Circularvalue.value = 0);
    }
    Circularvalue.value += 10;
  }, 1000);
});
onBeforeUnmount(() => {
  clearInterval(Circularinterval);
});

// linear progress data

const progressBars = ref([
  { color: 'primary', value: 55 },
  { color: 'secondary', value: 70 },
  { color: 'success', value: 30 },
  { color: 'warning', value: 80 }
]);

const skill = ref(20);
const knowledge = ref(33);
const power = ref(78);

const Linearvalue = ref(10);
const bufferValue = ref(20);
const Linearinterval = ref(0);

watch(Linearvalue, (val) => {
  if (val < 100) return;
  Linearvalue.value = 0;
  bufferValue.value = 10;
  startBuffer();
});

onMounted(() => {
  startBuffer();
});
onBeforeUnmount(() => {
  clearInterval(Linearinterval.value);
});

function startBuffer() {
  clearInterval(Linearinterval.value);
  Linearinterval.value = setInterval(() => {
    Linearvalue.value += Math.random() * (15 - 5) + 5;
    bufferValue.value += Math.random() * (15 - 5) + 6;
  }, 2000);
}

const Chunkvalue = shallowRef(63);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Progress Circular">
        <v-row>
          <!-- Circular -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Circular">
              <div class="d-flex flex-row flex-wrap align-center ga-4 justify-center">
                <div v-for="progress in pcolors" :key="progress.color">
                  <v-progress-circular :model-value="progress.value" :color="progress.color" />
                </div>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Circular Indeterminate -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Indeterminate">
              <div class="d-flex flex-row flex-wrap align-center ga-4 justify-center">
                <div v-for="progress in pcolors" :key="progress.color">
                  <v-progress-circular indeterminate :model-value="progress.value" :color="progress.color" />
                </div>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Circular Size -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Size & Width">
              <div class="d-flex flex-row flex-wrap align-center ga-4 justify-center">
                <v-progress-circular :size="50" model-value="30" color="primary" />

                <v-progress-circular :width="3" model-value="50" color="secondary" />

                <v-progress-circular :size="70" :width="7" model-value="70" color="error" />

                <v-progress-circular :width="3" color="warning" model-value="80" />

                <v-progress-circular :size="50" model-value="75" color="success" />
              </div>
            </UiChildCard>
          </v-col>

          <!-- Circular Rotate -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rotate">
              <div class="d-flex flex-row flex-wrap align-center ga-4 justify-center">
                <v-progress-circular
                  :model-value="Circularvalue"
                  :rotate="360"
                  :size="100"
                  :width="15"
                  bg-color="containerBg"
                  color="success"
                >
                  {{ Circularvalue }}
                </v-progress-circular>

                <v-progress-circular
                  :model-value="Circularvalue"
                  :rotate="-90"
                  :size="100"
                  :width="15"
                  bg-color="containerBg"
                  color="primary"
                >
                  {{ Circularvalue }}
                </v-progress-circular>

                <v-progress-circular :model-value="Circularvalue" :rotate="90" :size="100" :width="15" bg-color="containerBg" color="error">
                  {{ Circularvalue }}
                </v-progress-circular>

                <v-progress-circular
                  :model-value="Circularvalue"
                  :rotate="180"
                  :size="100"
                  :width="15"
                  bg-color="containerBg"
                  color="warning"
                >
                  {{ Circularvalue }}
                </v-progress-circular>
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Progress Linear">
        <v-row>
          <!-- Linear -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Default">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear v-model="power" color="primary" height="25" />

                <v-progress-linear v-model="skill" color="secondary" height="25">
                  <template v-slot:default="{ value }">
                    <strong>{{ Math.ceil(value) }}%</strong>
                  </template>
                </v-progress-linear>

                <v-progress-linear v-model="knowledge" color="warning" height="25">
                  <strong>{{ Math.ceil(knowledge) }}%</strong>
                </v-progress-linear>
              </div>
            </UiChildCard>
          </v-col>

          <!-- Linear Intermidiate -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Buffering">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear v-model="Linearvalue" color="primary" :buffer-value="bufferValue" />
                <v-progress-linear v-model="Linearvalue" color="secondary" :buffer-value="bufferValue" />
                <v-progress-linear v-model="Linearvalue" color="warning" :buffer-value="bufferValue" />
                <v-progress-linear v-model="Linearvalue" color="success" :buffer-value="bufferValue" />
              </div>
            </UiChildCard>
          </v-col>

          <!-- Linear Intermidiate -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Intermidiate">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear color="primary" indeterminate />
                <v-progress-linear color="success" indeterminate />
              </div>
            </UiChildCard>
          </v-col>

          <!-- Linear Reverse -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Reverse">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear color="primary" reverse model-value="15" />
                <v-progress-linear color="success" reverse indeterminate model-value="25" />
              </div>
            </UiChildCard>
          </v-col>

          <!-- Linear Rounded -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Linear Rounded">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear
                  v-for="(item, index) in progressBars"
                  :key="index"
                  :color="item.color"
                  rounded
                  :model-value="item.value"
                />
              </div>
            </UiChildCard>
          </v-col>

          <!-- Linear Stream -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Linear Stream">
              <div class="d-flex flex-column align-center ga-4 justify-center">
                <v-progress-linear buffer-value="0" color="darksecondary" stream />
                <v-progress-linear buffer-value="0" color="primary" model-value="20" stream />
                <v-progress-linear buffer-value="50" color="secondary" stream />
                <v-progress-linear buffer-value="60" color="success" model-value="40" stream />
              </div>
            </UiChildCard>
          </v-col>

          <v-col cols="12" lg="6">
            <UiChildCard title="Chunks">
              <v-progress-linear v-model="Chunkvalue" chunk-width="4" color="primary" height="15" rounded="lg" clickable />
              <br />
              <v-progress-linear v-model="Chunkvalue" chunk-gap="2" chunk-width="50" color="secondary" height="10" clickable rounded />
              <br />
              <v-progress-linear
                v-model="Chunkvalue"
                bg-color="#888"
                chunk-count="50"
                chunk-gap="3"
                color="success"
                height="25"
                rounded="sm"
                clickable
              />
              <br />
              <v-progress-linear
                v-model="Chunkvalue"
                bg-color="#888"
                chunk-count="15"
                chunk-gap="6"
                color="warning"
                height="25"
                rounded="sm"
                clickable
              />
              <br />
              <div class="d-flex ga-2 align-center">
                <v-progress-linear v-model="Chunkvalue" chunk-count="5" chunk-gap="9" color="info" height="25" rounded="sm" clickable>
                  <small>{{ Chunkvalue.toFixed() }}%</small>
                </v-progress-linear>
                <v-btn icon="$play" size="x-small" @click="Chunkvalue = 0"></v-btn>
                <v-btn icon="$complete" size="x-small" @click="Chunkvalue = 100"></v-btn>
              </div>
            </UiChildCard>
          </v-col>

          <v-col cols="12" lg="6">
            <UiChildCard title="Striped">
              <v-progress-linear color="primary" height="10" model-value="10" striped />
              <br />
              <v-progress-linear color="secondary" height="10" model-value="20" striped />
              <br />
              <v-progress-linear color="success" height="10" model-value="45" striped />
              <br />
              <v-progress-linear color="warning" height="10" model-value="60" striped />
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.v-progress-linear__background,
.v-progress-linear__buffer {
  [dir='rtl'] & {
    right: 0;
    left: unset;
  }
}
</style>
