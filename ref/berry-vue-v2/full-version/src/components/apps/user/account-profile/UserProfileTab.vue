<script setup lang="ts">
import { ref } from 'vue';

// icons
import { AlertCircleIcon } from 'vue-tabler-icons';

const textlname = ref('Schorl');
const textfname = ref('Delaney');
const textemail = ref('demo@company.com');
const textphone = ref('000-00-00000');
const textcompany = ref('company.ltd');
const textsite = ref('www.company.com');
</script>

<template>
  <div>
    <div class="d-flex flex-row">
      <img src="@/assets/images/users/avatar-1.png" width="80" alt="user-img" />
      <h6 class="ms-4 d-flex align-center text-medium-emphasis">
        <AlertCircleIcon width="20" stroke-width="1.5" class="me-2" /> Image size Limit should be 125kb Max.
      </h6>
    </div>
    <v-row class="mt-6">
      <v-col cols="12" lg="6">
        <v-text-field v-model="textlname" type="text" color="primary" label="Last Name" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textfname" type="text" color="primary" label="First Name" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textemail" type="email" color="primary" label="Email Address" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textphone" type="text" color="primary" label="Phone Number" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textcompany" type="text" color="primary" label="Company Name" variant="outlined" hide-details />
      </v-col>
      <v-col cols="12" lg="6">
        <v-text-field v-model="textsite" type="url" color="primary" label="Site Information" variant="outlined" hide-details />
      </v-col>
    </v-row>
  </div>
</template>
