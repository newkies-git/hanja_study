<script setup>
import { ref, shallowRef } from 'vue';
import user1 from '@/assets/images/users/avatar-5.png';
const status = ref('online');
const items = shallowRef([{ title: 'online' }, { title: 'away' }, { title: 'busy' }, { title: 'offline' }]);
</script>
<template>
  <!---Topbar Row-->
  <div class="d-flex ga-2 align-center">
    <!---User Avatar-->
    <v-badge
      dot
      location="bottom end"
      dot-size="9"
      :color="status === 'away' ? 'warning' : status === 'busy' ? 'error' : status === 'online' ? 'success' : 'containerBg'"
    >
      <v-avatar>
        <img :src="user1" alt="pro" width="50" />
      </v-avatar>
    </v-badge>
    <!---Name & Last seen-->
    <div>
      <h5 class="text-headline-large">John Doe</h5>
    </div>
    <div class="ms-auto">
      <v-menu>
        <template #activator="{ props }">
          <v-btn icon v-bind="props" variant="text">
            <ChevronDownIcon size="20" />
          </v-btn>
        </template>
        <v-list width="150" rounded="md">
          <v-list-item v-for="(item, index) in items" :key="index" :value="index">
            <v-list-item-title @click="status = item.title">
              {{ item.title }}
            </v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </div>
  </div>
</template>
