<script setup lang="ts">
import { ref } from 'vue';

import { XIcon } from 'vue-tabler-icons';

const dialog = ref(false);
const notifications = ref(false);
const sound = ref(true);
const widgets = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Fullscreen -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center">
    <v-dialog v-model="dialog" fullscreen :scrim="false" transition="dialog-bottom-transition">
      <template #activator="{ props }">
        <v-btn color="primary" dark v-bind="props"> Settings </v-btn>
      </template>
      <v-card rounded="0">
        <v-toolbar dark color="primary" style="flex: unset">
          <v-btn icon color="inherit" @click="dialog = false">
            <XIcon width="20" />
          </v-btn>
          <v-toolbar-title>Settings</v-toolbar-title>
          <v-spacer />
          <v-toolbar-items>
            <v-btn dark variant="text" @click="dialog = false"> Save </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card-item>
          <v-list lines="two" subheader>
            User Controls
            <v-list-item
              title="Content filtering"
              class="pa-0"
              subtitle="Set the content filtering level to restrict apps that can be downloaded"
            />
            <v-list-item title="Password" class="pa-0" subtitle="Require password for purchase or use password to restrict purchase" />
          </v-list>
          <v-divider />
          <v-list lines="two" subheader>
            General
            <v-list-item title="Notifications" class="pa-0" subtitle="Notify me about updates to apps or games that I downloaded">
              <template #prepend>
                <v-checkbox v-model="notifications" hide-details />
              </template>
            </v-list-item>
            <v-list-item title="Sound" class="pa-0" subtitle="Auto-update apps at any time. Data charges may apply">
              <template #prepend>
                <v-checkbox v-model="sound" hide-details />
              </template>
            </v-list-item>
            <v-list-item title="Auto-add widgets" class="pa-0" subtitle="Automatically add home screen widgets">
              <template #prepend>
                <v-checkbox v-model="widgets" hide-details />
              </template>
            </v-list-item>
          </v-list>
        </v-card-item>
      </v-card>
    </v-dialog>
  </div>
</template>
