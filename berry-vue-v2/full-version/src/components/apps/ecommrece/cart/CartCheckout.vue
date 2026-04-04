<script setup lang="ts">
import { ref } from 'vue';
import { useEcomStore } from '@/stores/apps/eCommerce';
import StepFirst from './steps/StepFirst.vue';
import StepSecond from './steps/StepSecond.vue';
import Payment from './steps/PaymentCard.vue';

const store = useEcomStore();
const tab = ref('tab-1');
function changeTab(e: string) {
  tab.value = e;
}
</script>
<template>
  <v-card variant="flat" class="mt-2">
    <v-card-text>
      <v-tabs v-model="tab" color="primary" class="customTab">
        <v-tab value="tab-1" rounded="md" class="mb-3 mx-2 text-start" height="70">
          <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
          <div>
            <div>User Profile</div>
            <h6 class="text-lightText text-medium-emphasis">Profile Settings</h6>
          </div>
        </v-tab>

        <v-tab value="tab-2" rounded="md" class="mb-3 mx-2 text-start" height="70" :disabled="store.cart.length < 1">
          <FileDescriptionIcon stroke-width="1.5" width="20" class="v-icon--start" />
          <div>
            <div>Billing</div>
            <h6 class="text-lightText text-medium-emphasis">Billing Information</h6>
          </div>
        </v-tab>

        <v-tab value="tab-3" rounded="md" class="mb-3 mx-2 text-start" height="70" :disabled="store.cart.length < 1">
          <CreditCardIcon stroke-width="1.5" width="20" class="v-icon--start" />
          <div>
            <div>Payment</div>
            <h6 class="text-lightText text-medium-emphasis">Add & Update Card</h6>
          </div>
        </v-tab>
      </v-tabs>
      <v-tabs-window v-model="tab">
        <v-tabs-window-item value="tab-1" class="pa-1">
          <StepFirst />
          <v-row class="mt-sm-6 mt-3 text-sm-start text-center" density="compact">
            <v-col cols="12" sm="6">
              <v-btn color="primary" variant="tonal" to="/ecommerce/products">Continue Shopping</v-btn>
            </v-col>
            <v-col cols="12" sm="6" class="text-sm-end">
              <v-btn color="primary" @click="changeTab('tab-2')" v-if="store.cart.length >= 1">CheckOut</v-btn>
            </v-col>
          </v-row>
        </v-tabs-window-item>
        <v-tabs-window-item value="tab-2" class="pa-1">
          <StepSecond />
          <v-row class="mt-3">
            <v-col cols="6">
              <v-btn color="primary" variant="tonal" @click="changeTab('tab-1')">Back</v-btn>
            </v-col>
            <v-col cols="6" class="text-end">
              <v-btn color="primary" @click="changeTab('tab-3')">Place an Order</v-btn>
            </v-col>
          </v-row>
        </v-tabs-window-item>
        <v-tabs-window-item value="tab-3" class="pa-1">
          <Payment />
        </v-tabs-window-item>
      </v-tabs-window>
    </v-card-text>
  </v-card>
</template>
<style lang="scss">
.customTab {
  min-height: 68px;
}
</style>
