<script setup lang="ts"></script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Transitions -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center d-flex align-center flex-wrap ga-2 justify-center">
    <v-dialog transition="dialog-bottom-transition" width="300">
      <template #activator="{ props }">
        <v-btn color="primary" v-bind="props"> From the bottom </v-btn>
      </template>
      <template #default="{ isActive }">
        <v-card>
          <v-toolbar color="primary" class="px-4"> Opening from the bottom </v-toolbar>
          <v-card-item>
            <h2 class="py-6">Hello world!</h2>
          </v-card-item>
          <v-card-actions class="justify-end">
            <v-btn variant="flat" @click="isActive.value = false"> Close </v-btn>
          </v-card-actions>
        </v-card>
      </template>
    </v-dialog>

    <v-dialog transition="dialog-top-transition" width="300">
      <template #activator="{ props }">
        <v-btn color="secondary" class="ms-2" v-bind="props"> From the top </v-btn>
      </template>
      <template #default="{ isActive }">
        <v-card>
          <v-toolbar color="secondary" class="px-4"> Opening from the top </v-toolbar>
          <v-card-item>
            <h2 class="py-6">Hello world!</h2>
          </v-card-item>
          <v-card-actions class="justify-end">
            <v-btn variant="flat" @click="isActive.value = false"> Close </v-btn>
          </v-card-actions>
        </v-card>
      </template>
    </v-dialog>
  </div>
</template>
