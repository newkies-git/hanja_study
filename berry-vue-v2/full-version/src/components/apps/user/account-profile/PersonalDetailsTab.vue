<script setup lang="ts">
import { ref } from 'vue';

// icons
import { BrandFacebookIcon, BrandTwitterIcon, BrandLinkedinIcon } from 'vue-tabler-icons';

const location = ref(['Washington', 'India', 'Africa', 'New York', 'Malaysia']);
const experience = ref(['Starterup', '2 years', '3 years', '4 years', '5 years']);

const textFname = ref('John Deo');
const textExperience = ref<string>('Starterup');
const textLocation = ref<string>('Washington');
const textBio = ref(
  'I consider myself as a creative, professional and a flexible person. I can adapt with any kind of brief and design style'
);
const textContact = ref('(+99) 9999 999 999');
const textEmail = ref('demo@sample.com');
const textURL = ref('https://demo.com');
const textAddress = ref('3379  Monroe Avenue, Fort Myers, Florida(33912)');
</script>

<template>
  <v-row>
    <v-col cols="12" lg="6">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Personal Information</h5>
          </div>

          <v-divider />
          <v-card-text>
            <v-row>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textFname" color="primary" label="Name" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-select v-model="textLocation" color="primary" :items="location" label="Location" variant="outlined" hide-details />
              </v-col>
              <v-col cols="12">
                <v-textarea v-model="textBio" color="primary" label="Bio" variant="outlined" hide-details rows="3" />
              </v-col>
              <v-col cols="12">
                <v-select v-model="textExperience" color="primary" :items="experience" label="Experience" variant="outlined" hide-details />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
    <v-col cols="12" lg="6">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Contact Information</h5>
          </div>
          <v-divider />
          <v-card-text>
            <v-row>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textContact" color="primary" label="Contact Phone" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12" lg="6">
                <v-text-field v-model="textEmail" color="primary" label="Email" variant="outlined" type="email" hide-details />
              </v-col>
              <v-col cols="12">
                <v-text-field v-model="textURL" color="primary" label="Portfolio URL" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12">
                <v-textarea v-model="textAddress" color="primary" label="Address" variant="outlined" rows="3" type="text" hide-details />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
    <v-col cols="12" lg="6">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Social Information</h5>
          </div>
          <v-divider />
          <v-card-text>
            <v-row align="center" class="mb-3" density="compact">
              <v-col cols="auto" sm="1">
                <v-avatar color="primary" rounded="md" variant="flat" size="35">
                  <BrandFacebookIcon width="20" stroke-width="1.5" />
                </v-avatar>
              </v-col>
              <v-col cols="9" sm="8">
                <v-text-field color="primary" label="Facebook Profile URL" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12" sm="3" class="text-start text-sm-end">
                <v-btn color="secondary"> Connect </v-btn>
              </v-col>
            </v-row>
            <v-row align="center" class="mb-3" density="compact">
              <v-col cols="auto" sm="1">
                <v-avatar color="primary" rounded="md" variant="flat" size="35">
                  <BrandTwitterIcon width="20" stroke-width="1.5" />
                </v-avatar>
              </v-col>
              <v-col cols="9" sm="8">
                <v-text-field color="primary" label="Twitter Profile URL" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12" sm="3" class="text-start text-sm-end">
                <v-btn color="secondary"> Connect </v-btn>
              </v-col>
            </v-row>
            <v-row align="center" density="compact">
              <v-col cols="auto" sm="1">
                <v-avatar color="primary" rounded="md" variant="flat" size="35">
                  <BrandLinkedinIcon width="20" stroke-width="1.5" />
                </v-avatar>
              </v-col>
              <v-col cols="9" sm="8">
                <v-text-field color="primary" label="Linkedin Profile URL" variant="outlined" type="text" hide-details />
              </v-col>
              <v-col cols="12" sm="3" class="text-start text-sm-end">
                <v-btn color="secondary"> Connect </v-btn>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
