<script setup lang="ts">
import { ref } from 'vue';

const textblock = ref('16657');
const textaname = ref(' Dardan Ranch');
const textstreet1 = ref('Nathaniel Ports');
const textstreet2 = ref('nr. Oran Walks');
const textpostcode = ref('395005');

const city = ref(['Los Angeles', 'Chicago', 'Phoenix', 'San Antonoi']);
const country = ref(['India', 'France', 'USA', 'UAE']);

const textcity = ref<string>('Los Angeles');
const textcountry = ref<string>('Los Angeles');

const checkbox = ref(true);
</script>

<template>
  <div>
    <v-row class="mt-2">
      <v-col cols="12" lg="6">
        <v-text-field v-model="textblock" type="text" color="primary" label="Block No#" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textaname" type="text" color="primary" label="Apartment Name" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textstreet1" type="email" color="primary" label="Street Line 1" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textstreet2" type="text" color="primary" label="Street Line 2" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="4">
        <v-text-field v-model="textpostcode" type="text" color="primary" label="Postcode" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="4">
        <v-select v-model="textcity" color="primary" :items="city" label="Select City" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="4">
        <v-select v-model="textcountry" color="primary" :items="country" label="Select Country" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12">
        <v-checkbox v-model="checkbox" color="primary" density="compact" label="Same as billing address" />
      </v-col>
    </v-row>
  </div>
</template>
