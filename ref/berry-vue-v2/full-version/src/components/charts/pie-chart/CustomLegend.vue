<script setup lang="ts">
import { shallowRef, toRef, computed } from 'vue';
import { useDisplay } from 'vuetify';

const display = useDisplay();
const selectedGroup = shallowRef('Transactions');
const currentItems = toRef(() =>
  selectedGroup.value === 'Transactions'
    ? [
        {
          id: 1,
          title: 'House & Bills',
          value: 40,
          color: 'rgba(var(--v-theme-lightText), .2)',
          pattern: 'url(#pattern-0)'
        },
        {
          id: 2,
          title: 'Transportation',
          value: 25,
          color: 'rgba(var(--v-theme-warning), var(--v-low-opacity))'
        },
        {
          id: 3,
          title: 'Entertainment',
          value: 20,
          color: 'rgba(var(--v-theme-warning), var(--v-medium-opacity))'
        },
        {
          id: 4,
          title: 'Food',
          value: 10,
          color: 'rgba(var(--v-theme-warning), var(--v-high-opacity))'
        },
        {
          id: 5,
          title: 'Other',
          value: 5,
          color: 'rgba(var(--v-theme-lightwarning), var(--v-high-opacity))'
        }
      ]
    : [
        { id: 1, title: 'OSS Donations', value: 37, color: '#767119' },
        { id: 2, title: 'Travel', value: 22, color: '#9e850d' },
        { id: 3, title: 'Investment', value: 20, color: '#cb9700' },
        { id: 4, title: 'Books', value: 11, color: '#ffa600' }
      ]
);

const legendPosition = computed(() => (display.smAndUp.value ? 'right' : 'bottom'));
</script>
<template>
  <div class="d-flex justify-center">
    <v-card class="pa-0" elevation="0" rounded="md">
      <v-card-title class="d-flex align-center flex-wrap ga-3 justify-space-between">
        <div class="text-truncate">Expenses</div>
        <v-select
          v-model="selectedGroup"
          :items="['Transactions', 'Other']"
          density="compact"
          max-width="200"
          variant="outlined"
          flat
          hide-details
          single-line
        ></v-select>
      </v-card-title>

      <v-pie
        :key="selectedGroup"
        :items="currentItems"
        :legend="{ position: legendPosition }"
        :tooltip="{ subtitleFormat: '[value]%' }"
        class="pa-3 mt-3 justify-center"
        gap="2"
        inner-cut="70"
        item-key="id"
        rounded="2"
        size="180"
        animation
        hide-slice
        reveal
      >
        <template v-slot:center>
          <div class="text-center">
            <h3>130</h3>
            <div class="opacity-70 mt-1 mb-n1">Total</div>
          </div>
        </template>

        <template v-slot:legend="{ items, toggle, isActive }">
          <v-list class="py-0 mb-n5 mb-md-0 bg-transparent" density="compact" width="300">
            <v-list-item
              v-for="item in items"
              :key="item.key"
              :class="['my-1', { 'opacity-40': !isActive(item) }]"
              :title="item.title"
              rounded="sm"
              link
              @click="toggle(item)"
            >
              <template v-slot:prepend>
                <v-avatar :color="item.color" :size="16"></v-avatar>
              </template>
              <template v-slot:append>
                <div class="font-weight-bold">{{ item.value }}%</div>
              </template>
            </v-list-item>
          </v-list>
        </template>
      </v-pie>
    </v-card>
  </div>

  <div class="h-0">
    <svg height="0" version="1.1" width="0" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <pattern id="pattern-0" height="20" patternTransform="rotate(145) scale(.2)" patternUnits="userSpaceOnUse" width="20">
          <path d="M0 10h20zm0 20h20zm0 20h20zm0 20h20z" fill="none" stroke="rgb(var(--v-theme-surface))" stroke-width="3" />
        </pattern>
      </defs>
    </svg>
  </div>
</template>
