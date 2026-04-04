<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Time pickers' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Time pickers',
    disabled: true,
    href: '#'
  }
]);

const timeStep = ref('10:10');
const allowedStep = (m: number) => m % 10 === 0;

const start = ref<string | undefined>(undefined);
const end = ref<string | undefined>(undefined);

const picker = ref(null);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Time pickers">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Basic">
              <v-time-picker />
            </UiChildCard>
          </v-col>
          <!-- Allowed times -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Allowed times">
              <v-time-picker v-model="timeStep" :allowed-minutes="allowedStep" format="24hr" />
            </UiChildCard>
          </v-col>
          <!-- Colors -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Colors">
              <v-time-picker color="success" />
            </UiChildCard>
          </v-col>
          <!-- No header -->
          <v-col cols="12" lg="6">
            <UiChildCard title="No header">
              <v-time-picker hide-header />
            </UiChildCard>
          </v-col>
          <!-- Range -->
          <v-col cols="12">
            <UiChildCard title="Range">
              <v-row>
                <v-col cols="12" lg="6">
                  <h2>Start:</h2>
                  <v-time-picker v-model="start" :max="end" />
                </v-col>
                <v-col cols="12" lg="6">
                  <h2>End:</h2>
                  <v-time-picker v-model="end" :min="start" />
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <!-- Scrollable -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Scrollable">
              <v-time-picker v-model="picker" scrollable />
            </UiChildCard>
          </v-col>
          <!-- Use seconds -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Use seconds">
              <v-time-picker use-seconds />
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
/* Ensure touch interactions on this page's time pickers don't require calling
  preventDefault from passive listeners. Scoped to page classes to limit impact. */
.v-time-picker {
  touch-action: manipulation;
  overscroll-behavior: contain;
}
</style>
