<script setup lang="ts">
import { ref } from 'vue';

const email1 = ref(true);
const email2 = ref(false);
const email3 = ref(false);
const email4 = ref(false);
const email5 = ref(true);
const email6 = ref(false);
const email7 = ref(false);
const email8 = ref(false);

const checkbox1 = ref(false);
const checkbox2 = ref(true);
const checkbox3 = ref(false);
const checkbox4 = ref(false);
const checkbox5 = ref(false);
</script>

<template>
  <v-row>
    <v-col cols="12">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Email Settings</h5>
          </div>
          <v-divider />
          <v-card-text class="checkbox-wrapper">
            <h5 class="mb-5">Setup Email Notification</h5>
            <v-switch v-model="email1" color="primary" hide-details>
              <template #label>
                <span>Email Notification</span>
              </template>
            </v-switch>

            <v-switch v-model="email2" color="primary" hide-details>
              <template #label>
                <span>Send Copy To Personal Email</span>
              </template>
            </v-switch>

            <v-divider class="mt-6" />

            <h5 class="my-6 text-uppercase">Activity Related Emails</h5>
            <h5 class="mb-1">When to email?</h5>
            <v-switch v-model="email3" color="primary" hide-details>
              <template #label>
                <span>have new notifications</span>
              </template>
            </v-switch>

            <v-switch v-model="email4" color="primary" hide-details>
              <template #label>
                <span>you're sent a direct message</span>
              </template>
            </v-switch>

            <v-switch v-model="email5" color="primary" hide-details>
              <template #label>
                <span>Someone adds you as a connection</span>
              </template>
            </v-switch>

            <h5 class="mb-1 mt-6">When to escalate emails?</h5>
            <v-switch v-model="email6" color="primary" hide-details>
              <template #label>
                <span>Upon new order</span>
              </template>
            </v-switch>

            <v-switch v-model="email7" color="primary" hide-details>
              <template #label>
                <span>New membership approval</span>
              </template>
            </v-switch>

            <v-switch v-model="email8" color="primary" hide-details>
              <template #label>
                <span>Member registration</span>
              </template>
            </v-switch>

            <v-divider class="my-5" />
            <h5 class="my-6 text-uppercase">Updates from system notification</h5>
            <h5 class="mb-1">Email you with?</h5>
            <v-checkbox v-model="checkbox1" color="primary" hide-details>
              <template #label>
                <span>News about PCT-themes products and feature updates</span>
              </template>
            </v-checkbox>
            <v-checkbox v-model="checkbox2" color="primary" hide-details>
              <template #label>
                <span>Tips on getting more out of PCT-themes</span>
              </template>
            </v-checkbox>
            <v-checkbox v-model="checkbox3" color="primary" hide-details>
              <template #label>
                <span>Things you missed since you last logged into PCT-themes</span>
              </template>
            </v-checkbox>
            <v-checkbox v-model="checkbox4" color="primary" hide-details>
              <template #label>
                <span>News about products and other services</span>
              </template>
            </v-checkbox>
            <v-checkbox v-model="checkbox5" color="primary" hide-details>
              <template #label>
                <span>Tips and Document business products</span>
              </template>
            </v-checkbox>

            <v-divider class="my-5" />
            <div class="text-end">
              <v-btn color="primary"> Update </v-btn>
              <v-btn color="error" variant="text" class="ms-2"> Clear </v-btn>
            </div>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.checkbox-wrapper {
  .v-checkbox {
    margin-top: 8px;
    .v-selection-control {
      min-height: unset;
    }
  }
}
</style>
