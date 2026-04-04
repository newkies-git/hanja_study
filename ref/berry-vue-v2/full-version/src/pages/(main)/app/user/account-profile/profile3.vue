<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';

// tabs import
import ProfileTab from '@/components/apps/user/account-profile/ProfileTab.vue';
import BillingTab from '@/components/apps/user/account-profile/BillingTab.vue';
import SecurityTab from '@/components/apps/user/account-profile/SecurityTab.vue';
import NotificationsTab from '@/components/apps/user/account-profile/NotificationsTab.vue';

// theme breadcrumb
const page = ref({ title: 'Profile 03' });
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
    title: 'Profile 03',
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
          <v-card-text>
            <v-tabs v-model="tab" color="primary">
              <v-tab variant="plain" value="tab-profile"> Profile </v-tab>
              <v-tab variant="plain" value="tab-billing"> Billing </v-tab>
              <v-tab variant="plain" value="tab-security"> Security </v-tab>
              <v-tab variant="plain" value="tab-notifications"> Notifications </v-tab>
            </v-tabs>
            <v-divider />
            <div class="pt-6">
              <v-tabs-window v-model="tab">
                <v-tabs-window-item value="tab-profile">
                  <ProfileTab />
                </v-tabs-window-item>

                <v-tabs-window-item value="tab-billing">
                  <BillingTab />
                </v-tabs-window-item>

                <v-tabs-window-item value="tab-security">
                  <SecurityTab />
                </v-tabs-window-item>

                <v-tabs-window-item value="tab-notifications">
                  <NotificationsTab />
                </v-tabs-window-item>
              </v-tabs-window>
            </div>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
