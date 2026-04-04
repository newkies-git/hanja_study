<script setup lang="ts">
import { ref } from 'vue';
import { SettingsIcon, LogoutIcon, UserIcon } from 'vue-tabler-icons';
import { useAuthStore } from '@/stores/auth';

const swt1 = ref(true);
const swt2 = ref(false);
const authStore = useAuthStore();
</script>

<template>
  <!-- ---------------------------------------------- -->
  <!-- profile DD -->
  <!-- ---------------------------------------------- -->
  <div class="pt-4">
    <div class="px-4">
      <h4 class="mb-n1">Good Morning, <span class="font-weight-regular">John Doe</span></h4>
      <span class="text-body-small text-medium-emphasis">Project admin</span>

      <v-text-field persistent-placeholder placeholder="Search" class="my-3" color="primary" variant="outlined" hide-details>
        <template #prepend-inner>
          <SearchIcon stroke-width="1.5" size="20" class="text-lightText SearchIcon" />
        </template>
      </v-text-field>
    </div>

    <v-divider class="mx-4" />
    <PerfectScrollbar style="height: calc(100vh - 300px); max-height: 515px">
      <div class="px-4 pb-4">
        <div class="bg-lightwarning rounded-md pa-5 my-3 circle sm-circle lg-circle">
          <h4>Upgrade your plan</h4>
          <h6 class="text-body-small text-medium-emphasis me-11 pe-11 mb-3 mt-2">70% discount for 1 years subscriptions.</h6>
          <v-btn color="warning" variant="flat"> Go Premium </v-btn>
        </div>

        <v-divider />

        <div class="bg-lightprimary rounded-md px-5 py-3 my-3">
          <div class="d-flex align-center justify-space-between">
            <h5>Start DND Mode</h5>
            <div>
              <v-switch v-model="swt1" color="primary" hide-details />
            </div>
          </div>
          <div class="d-flex align-center justify-space-between">
            <h5>Allow Notifications</h5>
            <div>
              <v-switch v-model="swt2" color="primary" hide-details />
            </div>
          </div>
        </div>

        <v-divider />

        <v-list class="mt-3">
          <v-list-item to="/app/user/account-profile/profile1" color="secondary" rounded="md">
            <template #prepend>
              <SettingsIcon size="20" class="me-2" />
            </template>

            <v-list-item-title class="text-body-small"> Account Settings </v-list-item-title>
          </v-list-item>

          <v-list-item to="/app/user/social/posts" color="secondary" rounded="md">
            <template #prepend>
              <UserIcon size="20" class="me-2" />
            </template>

            <v-list-item-title class="text-body-small"> Social Profile </v-list-item-title>

            <template #append>
              <v-chip color="warning" text="02" variant="flat" size="small" />
            </template>
          </v-list-item>

          <v-list-item color="secondary" rounded="md" @click="authStore.logout()">
            <template #prepend>
              <LogoutIcon size="20" class="me-2" />
            </template>

            <v-list-item-title class="text-body-small"> Logout </v-list-item-title>
          </v-list-item>
        </v-list>
      </div>
    </PerfectScrollbar>
  </div>
</template>
