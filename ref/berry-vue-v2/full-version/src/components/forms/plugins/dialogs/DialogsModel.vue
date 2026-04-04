<script setup lang="ts">
import { ref } from 'vue';
// Icon Imports
import { ReloadIcon } from 'vue-tabler-icons';

const dialog = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Model -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center">
    <v-btn color="secondary" @click="dialog = true"> Open Dialog </v-btn>

    <v-dialog v-model="dialog" max-width="500">
      <v-card text="Your application will relaunch automatically after the update is complete." title="Update in progress">
        <template #prepend>
          <ReloadIcon />
        </template>
        <v-card-actions>
          <v-btn color="primary" @click="dialog = false"> Ok </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
