<script setup lang="ts">
import { ref } from 'vue';

const sub1 = ref(true);
const sub2 = ref(false);
const sub3 = ref(false);
const sub4 = ref(false);

const checkbox1 = ref(false);
</script>

<template>
  <v-row>
    <v-col cols="12" lg="8">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Subscription Preference Center</h5>
          </div>
          <v-divider />
          <v-card-text>
            <h5 class="mb-5">I would like to receive:</h5>

            <v-checkbox
              v-model="sub1"
              color="primary"
              hide-details
              density="compact"
              class="text-truncate"
              style="width: calc(100% - 15px)"
            >
              <template #label>
                <span class="text-truncate">Product Announcements and Updates</span>
              </template>
            </v-checkbox>
            <v-checkbox
              v-model="sub2"
              color="primary"
              hide-details
              density="compact"
              class="text-truncate"
              style="width: calc(100% - 15px)"
            >
              <template #label>
                <span class="text-truncate">Events and Meetups</span>
              </template>
            </v-checkbox>
            <v-checkbox
              v-model="sub3"
              color="primary"
              hide-details
              density="compact"
              class="text-truncate"
              style="width: calc(100% - 15px)"
            >
              <template #label>
                <span class="text-truncate">User Research Surveys</span>
              </template>
            </v-checkbox>
            <v-checkbox
              v-model="sub4"
              color="primary"
              hide-details
              density="compact"
              class="text-truncate"
              style="width: calc(100% - 15px)"
            >
              <template #label>
                <span class="text-truncate">Hatch Startup Program</span>
              </template>
            </v-checkbox>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
    <v-col cols="12" lg="4">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-6">
            <h5>Opt me out instead</h5>
          </div>
          <v-divider />
          <v-card-text>
            <v-checkbox v-model="checkbox1" hide-details density="compact" class="text-truncate" style="width: calc(100% - 15px)">
              <template #label>
                <span class="text-truncate">Unsubscribe me from all of the above</span>
              </template>
            </v-checkbox>

            <v-btn color="primary" class="mt-4"> Update My Prefereces </v-btn>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
