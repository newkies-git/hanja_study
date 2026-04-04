<script setup lang="ts">
import { shallowRef } from 'vue';
import { FileDescriptionIcon, UserCircleIcon } from 'vue-tabler-icons';

const ninecards = shallowRef([
  {
    earn: '1,658',
    text: 'Daily user',
    icon: UserCircleIcon,
    color: 'secondary'
  },
  {
    earn: '1K',
    text: 'Daily page view',
    icon: FileDescriptionIcon,
    color: 'primary'
  }
]);
</script>

<template>
  <v-row>
    <v-col v-for="(card9, i) in ninecards" :key="i" cols="12" sm="6" lg="12" :value="card9">
      <v-card elevation="0" :class="' overflow-hidden  position-relative bg-' + card9.color">
        <v-card variant="outlined" class="text-center border-0">
          <component :is="card9.icon" stroke-width="2" size="89" class="text-white opacity-50 icon-scale" />
          <v-card-text>
            <h3 class="my-2">
              {{ card9.earn }}
            </h3>
            <span>{{ card9.text }}</span>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
