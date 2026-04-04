<script setup lang="ts">
import { shallowRef } from 'vue';

import Avatar1 from '@/assets/images/users/avatar-1.png';
import Avatar2 from '@/assets/images/users/avatar-2.png';
import Avatar3 from '@/assets/images/users/avatar-3.png';
import Avatar4 from '@/assets/images/users/avatar-4.png';

const activities = shallowRef([
  {
    avatar: Avatar1,
    name: 'John Deo',
    time: '2 mins ago',
    subtext: 'Lorem Ipsum is simply dummy text.'
  },
  {
    avatar: Avatar2,
    name: 'John Deo',
    time: '7 mins ago',
    subtext: 'Lorem Ipsum is simply dummy text.'
  },
  {
    avatar: Avatar3,
    name: 'John Deo',
    time: '9 mins ago',
    subtext: 'Lorem Ipsum is simply dummy text.'
  },
  {
    avatar: Avatar4,
    name: 'John Deo',
    time: '10 mins ago',
    subtext: 'Lorem Ipsum is simply dummy text.'
  }
]);
</script>

<template>
  <v-list class="py-0" lines="two">
    <v-list-item v-for="(activity, i) in activities" :key="i" :value="activity" rounded="sm">
      <template #prepend>
        <v-badge dot color="success" location="bottom end" dot-size="9">
          <v-avatar size="40">
            <img :src="activity.avatar" width="40" alt="Julia" />
          </v-avatar>
        </v-badge>
      </template>
      <div class="d-inline-flex align-center justify-space-between w-100">
        <h5>
          {{ activity.name }}
        </h5>
        <span class="text-body-small text-medium-emphasis d-flex align-center">
          <ClockIcon stroke-width="1.5" size="17" class="me-1" />
          {{ activity.time }}
        </span>
      </div>

      <p class="text-body-small text-medium-emphasis mb-0">
        {{ activity.subtext }}
      </p>
    </v-list-item>
  </v-list>
</template>
