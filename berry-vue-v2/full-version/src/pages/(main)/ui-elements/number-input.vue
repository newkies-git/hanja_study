<script setup lang="ts">
import { ref, computed, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// define consts
const page = ref({ title: 'Number inputs' });

// theme breadcrumb
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Number inputs',
    disabled: true,
    href: '#'
  }
]);

const step = 50;
const value = shallowRef(100);
const roundedValue = computed({
  get: () => value.value,
  set: (v) => (value.value = Math.round(v / step) * step)
});

const precision1 = ref(123);
const precision2 = ref(25.5);
const precision3 = ref(0.052);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs"></BaseBreadcrumb>
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Number Inputs">
        <v-row>
          <v-col cols="12" lg="6">
            <!-- control variant -->
            <UiChildCard title="Control variant">
              <v-row>
                <v-col cols="12">
                  <v-label class="font-weight-medium mb-2"> Default </v-label>
                  <v-number-input control-variant="default" hide-details />
                </v-col>
                <v-col cols="12">
                  <v-label class="font-weight-medium mb-2"> Stacked </v-label>
                  <v-number-input control-variant="stacked" variant="outlined" hide-details />
                </v-col>
                <v-col cols="12">
                  <v-label class="font-weight-medium mb-2"> Split </v-label>
                  <v-number-input control-variant="split" variant="outlined" hide-details />
                </v-col>
                <v-col cols="12">
                  <v-label class="font-weight-medium mb-2"> Hidden </v-label>
                  <v-number-input control-variant="hidden" variant="outlined" hide-details />
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <v-row>
              <v-col cols="12">
                <!-- Reverse -->
                <UiChildCard title="Reverse">
                  <v-row>
                    <v-col cols="12">
                      <v-label class="font-weight-medium mb-2"> Default </v-label>
                      <v-number-input control-variant="default" variant="outlined" hide-details reverse />
                    </v-col>
                    <v-col cols="12">
                      <v-label class="font-weight-medium mb-2"> Stacked </v-label>
                      <v-number-input control-variant="stacked" variant="outlined" hide-details reverse />
                    </v-col>
                  </v-row>
                </UiChildCard>
              </v-col>
              <v-col cols="12">
                <!-- Min/Max -->
                <UiChildCard title="Min/Max">
                  <v-label class="font-weight-medium mb-2">min:10/max:20</v-label>
                  <v-number-input variant="outlined" :max="20" :min="10" :model-value="15" hide-details />
                </UiChildCard>
              </v-col>
            </v-row>
          </v-col>
          <v-col cols="12">
            <!-- Inset -->
            <UiChildCard title="Inset">
              <v-row>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> Default </v-label>
                  <v-number-input control-variant="default" variant="outlined" hide-details inset />
                </v-col>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> Stacked </v-label>
                  <v-number-input control-variant="stacked" variant="outlined" hide-details inset />
                </v-col>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> Split </v-label>
                  <v-number-input control-variant="split" variant="outlined" hide-details inset />
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <!-- Step -->
            <UiChildCard title="Step">
              <v-row>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> step 2; min:10; max:20 </v-label>
                  <v-number-input
                    control-variant="default"
                    :max="20"
                    :min="10"
                    :model-value="15"
                    :step="2"
                    variant="outlined"
                    hide-details
                    inset
                  />
                </v-col>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> step {{ step }}, rounding on blur </v-label>
                  <v-number-input control-variant="stacked" v-model="roundedValue" :step="step" variant="outlined" hide-details inset />
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <!-- Precision -->
            <UiChildCard title="Precision">
              <v-row>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> (precision="2") </v-label>
                  <v-number-input v-model="precision1" :precision="2" variant="outlined" hide-details="auto" />
                  <code class="d-block pt-3">value: {{ precision1 }}</code>
                </v-col>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> (precision="5") </v-label>
                  <v-number-input v-model="precision2" :precision="5" variant="outlined" hide-details="auto" />
                  <code class="d-block pt-3">value: {{ precision2 }}</code>
                </v-col>
                <v-col cols="12" lg="4">
                  <v-label class="font-weight-medium mb-2"> (precision unrestricted) </v-label>
                  <v-number-input v-model="precision3" :precision="null" variant="outlined" hide-details="auto" />
                  <code class="d-block pt-3">value: {{ precision3 }}</code>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
