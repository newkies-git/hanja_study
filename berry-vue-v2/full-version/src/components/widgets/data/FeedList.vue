<script setup lang="ts">
import { shallowRef } from 'vue';

// import icons
import { BellIcon, FileDescriptionIcon, ShoppingCartIcon } from 'vue-tabler-icons';

const feeds = shallowRef([
  {
    color: 'primary',
    icon: BellIcon,
    name: 'You have 3 pending tasks.',
    time: '5 mins ago'
  },
  {
    color: 'error',
    icon: ShoppingCartIcon,
    name: 'New order received',
    time: 'Today'
  },
  {
    color: 'success',
    icon: FileDescriptionIcon,
    name: 'You have 3 pending tasks.',
    time: 'Yesterday'
  },
  {
    color: 'primary',
    icon: BellIcon,
    name: 'New order received',
    time: '02-05-2021'
  },
  {
    color: 'warning',
    icon: ShoppingCartIcon,
    name: 'Order cancelled',
    time: '5 mins ago'
  }
]);
</script>

<template>
  <v-list class="py-0" lines="two">
    <v-list-item v-for="(feed, i) in feeds" :key="i" :value="feed" class="no-spacer">
      <template #prepend>
        <v-avatar size="40" :color="feed.color" variant="flat" class="me-3 py-2">
          <component :is="feed.icon" stroke-width="2" size="20" class="text-white" />
        </v-avatar>
      </template>
      <template #append>
        <p class="text-body-small text-medium-emphasis ms-auto mb-0">
          {{ feed.time }}
        </p>
      </template>
      <h5 class="font-weight-regular">
        {{ feed.name }}
      </h5>
    </v-list-item>
  </v-list>
</template>
