<script setup lang="ts">
import { shallowRef } from 'vue';

import Avatar1 from '@/assets/images/users/avatar-1.png';
import Avatar2 from '@/assets/images/users/avatar-2.png';
import Avatar3 from '@/assets/images/users/avatar-3.png';
import Avatar4 from '@/assets/images/users/avatar-4.png';
import Avatar5 from '@/assets/images/users/avatar-5.png';

const customers = shallowRef([
  {
    avatar: Avatar1,
    name: 'Alex Thompson',
    time: '5 mins ago',
    msg: 'Cheers!',
    status: 'online'
  },
  {
    avatar: Avatar2,
    name: 'John Doue',
    time: 'Today',
    msg: 'stay hungry stay foolish!',
    status: 'online'
  },
  {
    avatar: Avatar3,
    name: 'Alex Thompson',
    time: 'Yesterday',
    msg: 'Cheers!',
    status: ''
  },
  {
    avatar: Avatar4,
    name: 'John Doue',
    time: '02-05-2021',
    msg: 'stay hungry stay foolish!',
    status: ''
  },
  {
    avatar: Avatar5,
    name: 'Shirley Hoe',
    time: '5 mins ago',
    msg: 'Cheers!',
    status: ''
  }
]);
</script>

<template>
  <v-list class="py-0" lines="two">
    <v-list-item v-for="(customer, i) in customers" :key="i" :value="customer" rounded="sm" color="secondary" class="no-spacer">
      <template #prepend>
        <v-avatar size="40" class="me-3 py-2">
          <img :src="customer.avatar" width="40" alt="Julia" />
        </v-avatar>
      </template>
      <div class="d-inline-flex align-center justify-space-between w-100">
        <h5>
          {{ customer.name }}
        </h5>
        <v-avatar v-if="customer.status == 'online'" size="10" color="success" variant="flat" />
        <span v-else class="text-body-small text-medium-emphasis">{{ customer.time }}</span>
      </div>

      <p class="text-body-small text-medium-emphasis mb-0">
        {{ customer.msg }}
      </p>
    </v-list-item>
  </v-list>
</template>
