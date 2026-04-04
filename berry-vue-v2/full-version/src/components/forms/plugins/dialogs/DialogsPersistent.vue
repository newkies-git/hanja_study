<script setup lang="ts">
import { ref } from 'vue';
import { MapPinFilledIcon } from 'vue-tabler-icons';

const dialog = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Persistent -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center">
    <v-dialog v-model="dialog" max-width="400" persistent>
      <template #activator="{ props }">
        <v-btn color="primary" v-bind="props"> Open Dialog </v-btn>
      </template>
      <v-card
        text="Let Google help apps determine location. This means sending anonymous location data to Google, even when no apps are running."
        title="Use Google's location service?"
      >
        <template v-slot:prepend>
          <MapPinFilledIcon />
        </template>
        <template v-slot:actions>
          <v-btn @click="dialog = false"> Disagree </v-btn>

          <v-btn @click="dialog = false"> Agree </v-btn>
        </template>
      </v-card>
    </v-dialog>
  </div>
</template>
