<script setup lang="ts">
import { ref } from 'vue';
import user1 from '@/assets/images/users/avatar-1.png';
const textName = ref('John Doe');
const textEmail = ref('name@example.com');
const textCompany = ref('Materially Inc.');
const textCountry = ref('USA');
const textPhone = ref('4578-420-410 ');
const textBirthday = ref('31/01/2001');
</script>

<template>
  <v-row>
    <v-col cols="12" lg="4">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-6">
            <h5>Profile Picture</h5>
          </div>
          <v-divider />
          <v-card-text class="text-center">
            <img :src="user1" width="100" />
            <h6 class="text-disabled my-4">Upload/Change Your Profile Image</h6>
            <v-btn color="primary" size="small"> Upload Avatar </v-btn>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
    <v-col cols="12" lg="8">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="px-5 py-6">
            <h5>Edit Account Details</h5>
          </div>
          <v-divider />
          <v-card-text>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="textName"
                  type="text"
                  label="Name"
                  hint="Helper Text"
                  color="primary"
                  variant="outlined"
                  persistent-hint
                />
              </v-col>
              <v-col cols="12">
                <v-text-field v-model="textEmail" type="email" label="Email Address" color="primary" variant="outlined" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textCompany" type="text" label="Company" color="primary" variant="outlined" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textCountry" type="text" label="Country" color="primary" variant="outlined" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textPhone" type="text" label="Phone Number" color="primary" variant="outlined" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textBirthday" type="text" label="Birthday" color="primary" variant="outlined" hide-details />
              </v-col>
            </v-row>
            <v-btn color="primary" class="mt-5"> Change Details </v-btn>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
