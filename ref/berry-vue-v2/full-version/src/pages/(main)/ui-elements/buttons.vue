<script setup lang="ts">
import { ref, watch } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { AccessPointIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Buttons' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Buttons',
    disabled: true,
    href: '#'
  }
]);

// buttons color data
const btnsColor = ref(['primary', 'secondary', 'success', 'error', 'warning']);

// buttons color data
const btnsSize = ref(['x-small', 'small', 'large', 'x-large']);

const loading = ref(false);
const customLoading = ref(false);
function load() {
  loading.value = true;
  setTimeout(() => (loading.value = false), 3000);
}

watch(customLoading, (val) => {
  if (!val) return;
  setTimeout(() => (customLoading.value = false), 2000);
});
</script>

// ===============================|| Ui Buttons ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Buttons">
        <v-row>
          <!-- Base Buttons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Base">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn v-for="btn in btnsColor" :key="btn" :color="btn">
                  {{ btn }}
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Flat Buttons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Flat">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn v-for="btn in btnsColor" :key="btn" :color="btn" variant="flat">
                  {{ btn }}
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Outlined Buttons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Outlined">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn v-for="btn in btnsColor" :key="btn" :color="btn" variant="outlined">
                  {{ btn }}
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- With Icons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="With Icons">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn flat color="primary"> <AccessPointIcon stroke-width="1.5" size="22" /> Button </v-btn>
                <v-btn flat color="primary"> Button <AccessPointIcon stroke-width="1.5" size="22" /> </v-btn>
                <v-btn flat color="primary">
                  <AccessPointIcon stroke-width="1.5" size="22" />
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Sizes -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Size">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn v-for="btn in btnsSize" :key="btn" :size="btn" color="primary"> Button </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Text Buttons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Text Button">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn v-for="btn in btnsColor" :key="btn" :color="btn" variant="text">
                  {{ btn }}
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Shadow Button -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Shadow Button">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn variant="flat" color="primary" class="primary-shadow"> Primary </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Rounded Button -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rounded">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn color="primary" rounded="0">Rounded 0</v-btn>
                <v-btn color="primary" rounded="xs">Rounded xs</v-btn>
                <v-btn color="primary" rounded="sm">Rounded sm</v-btn>
                <v-btn color="primary">Button</v-btn>
                <v-btn color="primary" rounded="lg">Rounded lg</v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Ripple Button -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Ripple">
              <div class="d-flex ga-sm-4 ga-3 align-center flex-wrap flex-row fill-height">
                <v-btn color="primary">With Ripple</v-btn>
                <v-btn color="primary" :ripple="false">Without Ripple</v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Icon color Button -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Icon color">
              <v-btn append-icon="$accountCircle" prepend-icon="$checkCircle">
                <template v-slot:prepend>
                  <v-icon color="success"></v-icon>
                </template>

                Button

                <template v-slot:append>
                  <v-icon color="warning"></v-icon>
                </template>
              </v-btn>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="8">
            <UiChildCard title="Spaced">
              <div class="d-flex flex-wrap align-center ga-3">
                <v-btn height="70" prepend-icon="$prev" variant="outlined" spaced="start" width="220">
                  <span class="text-right">
                    <div class="mb-1">Previous</div>
                    <small class="text-medium-emphasis">spaced: start</small>
                  </span>
                </v-btn>

                <v-btn append-icon="$next" height="70" prepend-icon="$prev" variant="outlined" spaced="both" width="220">
                  <span>
                    <div class="mb-1">Navigate</div>
                    <small class="text-medium-emphasis">spaced: both</small>
                  </span>
                </v-btn>

                <v-btn append-icon="$next" height="70" spaced="end" variant="outlined" width="220">
                  <span class="text-left">
                    <div class="mb-1">Next</div>
                    <small class="text-medium-emphasis">spaced: end</small>
                  </span>
                </v-btn>
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="4">
            <UiChildCard title="Onclick Loaders">
              <div class="d-flex flex-wrap ga-3">
                <div>
                  <h5 class="mb-1 text-medium-emphasis">Default</h5>
                  <v-btn :loading="loading" class="flex-grow-1" height="48" variant="tonal" color="primary" @click="load">
                    Take Checkup
                  </v-btn>
                </div>
                <div>
                  <h5 class="mb-1 text-medium-emphasis">Custom</h5>
                  <v-btn
                    color="primary"
                    class="flex-grow-1"
                    height="48"
                    variant="tonal"
                    :loading="customLoading"
                    @click="customLoading = !customLoading"
                  >
                    Custom Loader
                    <template v-slot:loader>
                      <v-progress-linear indeterminate></v-progress-linear>
                    </template>
                  </v-btn>
                </div>
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
