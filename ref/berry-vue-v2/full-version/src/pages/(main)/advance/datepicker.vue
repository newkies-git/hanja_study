<script setup lang="ts">
import { ref, shallowRef } from 'vue';

import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

const page = ref({ title: 'Date pickers' });

const breadcrumbs = shallowRef([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Date pickers',
    disabled: true,
    href: '#'
  }
]);
</script>
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12" xl="4" md="6" sm="12">
      <UiParentCard title="Default">
        <v-date-picker width="320" />
      </UiParentCard>
    </v-col>
    <v-col cols="12" xl="4" md="6" sm="12">
      <UiParentCard title="Color">
        <v-date-picker width="320" color="primary" />
      </UiParentCard>
    </v-col>
    <v-col cols="12" xl="4" md="6" sm="12">
      <UiParentCard title="Show adjacent months">
        <v-date-picker width="320" show-adjacent-months />
      </UiParentCard>
    </v-col>
  </v-row>
</template>
<style lang="scss">
.v-date-picker-month__day {
  width: 43px;
  height: 43px;
  .v-btn {
    --v-btn-size: 0.65rem;
  }
}
@media (max-width: 480px) {
  .v-date-picker {
    width: 275px !important;
  }
  .v-date-picker-month__days {
    justify-content: start;
  }
  .v-date-picker-month__day {
    width: 35px;
    height: 35px;
  }
  .v-date-picker-controls,
  .v-picker-title,
  .v-picker__header {
    width: 280px;
  }
}
</style>
