<script setup lang="ts">
import { shallowRef } from 'vue';

// icons
import { AlertCircleIcon, BugIcon, ClockIcon, ThumbUpIcon } from 'vue-tabler-icons';

const messages = shallowRef([
  {
    color: 'success',
    icon: ThumbUpIcon,
    title: 'You’re getting more and more followers',
    time: '8:50'
  },
  {
    color: 'primary',
    icon: ClockIcon,
    title: 'Design mobile Application',
    time: 'Sat, 5 Mar'
  },
  {
    color: 'error',
    icon: BugIcon,
    title: 'Jenny assign you a task Mockup Design.',
    time: 'Sun, 17 Feb'
  },
  {
    color: 'warning',
    icon: AlertCircleIcon,
    title: 'Design logo',
    time: 'Sat, 18 Mar '
  },
  {
    color: 'success',
    icon: ThumbUpIcon,
    title: 'Design mobile Application',
    time: '8:50'
  }
]);
</script>

<template>
  <v-timeline truncate-line="both" side="end" line-inset="5" class="my-3">
    <v-timeline-item v-for="(message, i) in messages" :key="i" size="large" fill-dot :dot-color="message.color" :value="message">
      <template #icon>
        <component :is="message.icon" stroke-width="2" size="20" class="text-white" />
      </template>
      <v-card elevation="0" rounded="0">
        <span class="text-body-small text-medium-emphasis">{{ message.time }}</span>
        <h5 class="font-weight-regular text-wrap pe-3">
          {{ message.title }}
        </h5>
      </v-card>
    </v-timeline-item>
  </v-timeline>
</template>
