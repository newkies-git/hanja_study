<script setup lang="ts">
import { ref } from 'vue';

const textcpass = ref('textcmpass');
const textnpass = ref(' 2345');
const textcmpass = ref('12345');
</script>

<template>
  <div>
    <v-row class="mt-2 mb-6">
      <v-col cols="12" lg="6">
        <v-text-field v-model="textcpass" type="password" label="Current Password" variant="outlined" hide-details />
      </v-col>
    </v-row>
    <v-row class="mt-3">
      <v-col cols="12" lg="6">
        <v-text-field v-model="textnpass" type="password" label="New Password" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textcmpass" type="password" label="Confirm Password" variant="outlined" hide-details />
      </v-col>
    </v-row>
    <v-btn color="primary" variant="outlined" size="large" class="text-body-large mt-4"> Change Password </v-btn>
  </div>
</template>
