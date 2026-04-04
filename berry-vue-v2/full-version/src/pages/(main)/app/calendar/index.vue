<script setup lang="ts">
import { ref } from 'vue';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import BasicCalendar from '@/components/apps/calendar/BasicCalendar.vue';
import DragDrop from '@/components/apps/calendar/Drag&DropCalendar.vue';

const page = ref({ title: 'Calendar' });

const breadcrumbs = ref([
  { title: 'Application', disabled: false, href: '#' },
  { title: 'Calendar', disabled: true, href: '#' }
]);
</script>
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <BasicCalendar />
    </v-col>
    <v-col cols="12">
      <DragDrop />
    </v-col>
  </v-row>
</template>
