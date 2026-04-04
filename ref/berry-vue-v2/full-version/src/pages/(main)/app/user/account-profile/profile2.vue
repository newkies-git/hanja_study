<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';

// tabs import
import UserProfileTab from '@/components/apps/user/account-profile/UserProfileTab.vue';
import PaymentTab from '@/components/apps/user/account-profile/PaymentTab.vue';
import ChangePasswordTab from '@/components/apps/user/account-profile/ChangePasswordTab.vue';
import BillingForm from '@/components/apps/user/account-profile/BillingForm.vue';

// theme breadcrumb
const page = ref({ title: 'Profile 02' });
const breadcrumbs = ref([
  {
    title: 'Users',
    disabled: false,
    href: '#'
  },
  {
    title: 'Account',
    disabled: false,
    href: '#'
  },
  {
    title: 'Profile 02',
    disabled: true,
    href: '#'
  }
]);

// tabs data
const tab = ref('tab-profile');
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <v-card variant="flat">
        <v-card variant="outlined">
          <v-card-item>
            <v-card-title>Account Settings</v-card-title>
          </v-card-item>
          <v-divider />
          <div>
            <v-row gap="0">
              <v-col cols="12" sm="4" class="border-right pe-sm-0 py-sm-0">
                <v-card-text class="pb-sm-6 pb-0">
                  <v-tabs v-model="tab" direction="vertical" color="primary">
                    <v-tab value="tab-profile" rounded="md" class="text-start overflow-hidden" height="70">
                      <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>User Profile</div>
                        <h6 class="text-disabled">Profile Settings</h6>
                      </div>
                    </v-tab>
                    <v-tab value="tab-billing" rounded="md" class="text-start overflow-hidden" height="70">
                      <FileDescriptionIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Billing</div>
                        <h6 class="text-disabled">Billing Information</h6>
                      </div>
                    </v-tab>
                    <v-tab value="tab-payment" rounded="md" class="text-start overflow-hidden" height="70">
                      <CreditCardIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Payment</div>
                        <h6 class="text-disabled">Add & Update Card</h6>
                      </div>
                    </v-tab>
                    <v-tab value="tab-change-password" rounded="md" class="mb-3 text-start overflow-hidden" height="70">
                      <KeyIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Change Password</div>
                        <h6 class="text-disabled">Update Profile Security</h6>
                      </div>
                    </v-tab>
                  </v-tabs>
                </v-card-text>
              </v-col>
              <v-col cols="12" sm="8" class="ps-sm-0 py-sm-0">
                <v-card-text class="pt-sm-6 pt-0">
                  <v-tabs-window v-model="tab">
                    <v-tabs-window-item value="tab-profile">
                      <UserProfileTab />
                    </v-tabs-window-item>
                    <v-tabs-window-item value="tab-billing">
                      <BillingForm />
                    </v-tabs-window-item>
                    <v-tabs-window-item value="tab-payment">
                      <PaymentTab />
                    </v-tabs-window-item>
                    <v-tabs-window-item value="tab-change-password">
                      <ChangePasswordTab />
                    </v-tabs-window-item>
                  </v-tabs-window>
                </v-card-text>
              </v-col>
            </v-row>
          </div>

          <v-divider />
          <div class="pa-6 text-sm-end text-center">
            <v-btn color="primary"> Continue </v-btn>
          </div>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
