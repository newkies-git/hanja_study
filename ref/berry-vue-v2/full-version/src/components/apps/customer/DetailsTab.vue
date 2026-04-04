<script setup lang="ts">
import { ref } from 'vue';
// common components
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { CalendarEventIcon, DeviceMobileIcon, MailIcon } from 'vue-tabler-icons';

const invoices = ref([
  {
    name: 'Logo Design',
    quantity: 6,
    amount: 200
  },
  {
    name: 'Landing Page',
    quantity: 7,
    amount: 100
  },
  {
    name: 'Admin Template',
    quantity: 5,
    amount: 150
  }
]);
</script>

<template>
  <UiChildCard title="Customer">
    <template #action>
      <h5>Placed on 12.07.2018 10:00</h5>
    </template>

    <div class="d-flex align-center flex-column flex-sm-row text-medium-emphasis ga-4">
      <div class="d-flex align-center">
        <CalendarEventIcon stroke-width="1.5" width="18" />
        <span class="text-body-large ms-2">Sophia Hale</span>
      </div>
      <div class="d-flex align-center">
        <DeviceMobileIcon stroke-width="1.5" width="18" />
        <span class="text-body-large ms-2">070 123 4567</span>
      </div>
      <div class="d-flex align-center">
        <MailIcon stroke-width="1.5" width="18" />
        <span class="text-body-large ms-2">example@mail.com</span>
      </div>
    </div>
    <v-divider class="my-4" />
    <v-row>
      <v-col cols="12" sm="4">
        <h4 class="mb-2">Payment method</h4>
        <h6 class="text-medium-emphasis d-inline-block">Credit Card</h6>
        <h5 class="mt-3 mb-2">
          <span class="font-weight-semibold me-2">Transaction ID :</span>
          <span class="text-medium-emphasis">000001-TXT</span>
        </h5>
        <h5>
          <span class="font-weight-semibold me-2">Amount :</span>
          <span class="text-medium-emphasis">$2500</span>
        </h5>
      </v-col>
      <v-col cols="12" sm="4">
        <h4 class="mb-2">Shipping method</h4>
        <h6 class="text-medium-emphasis">Carrier</h6>
        <h5 class="mt-3 mb-2">
          <span class="font-weight-semibold me-2">Tracking Code :</span>
          <span class="text-medium-emphasis">FX-012345-6</span>
        </h5>
        <h5>
          <span class="font-weight-semibold me-2">Date :</span>
          <span class="text-medium-emphasis">12.15.2018</span>
        </h5>
      </v-col>
      <v-col cols="12" sm="4">
        <h5 class="mt-3 mb-2">
          <span class="font-weight-semibold me-2">Fulfillment status :</span>
          <span class="text-body-large text-medium-emphasis">Delivered</span>
        </h5>
        <h5>
          <span class="font-weight-semibold me-2">Payment status :</span>
          <v-chip color="success" variant="outlined" size="small"> Paid </v-chip>
        </h5>
      </v-col>
    </v-row>
    <v-divider class="my-4" />
    <v-row>
      <v-col cols="12" sm="6" md="4">
        <h4 class="mb-2">Billing address</h4>
        <h5 class="mt-3 mb-2">
          <span class="font-weight-semibold me-2">First name :</span>
          <span class="text-medium-emphasis">Joseph</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">Last name :</span>
          <span class="text-medium-emphasis">William</span>
        </h5>
        <h5 class="mt-5 mb-2">
          <span class="font-weight-semibold me-2">Address :</span>
          <span class="text-medium-emphasis">4898 Joanne Lane street</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">City :</span>
          <span class="text-medium-emphasis">Boston</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">Country :</span>
          <span class="text-medium-emphasis">United States</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">State :</span>
          <span class="text-medium-emphasis">Massachusetts</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">Zip code :</span>
          <span class="text-medium-emphasis">02110</span>
        </h5>
        <h5 class="mt-5 mb-2">
          <span class="font-weight-semibold me-2">Phone :</span>
          <span class="text-medium-emphasis">+1 (070) 123-4567</span>
        </h5>
      </v-col>
      <v-col cols="12" sm="6" md="4">
        <h4 class="mb-2">Shipping address</h4>
        <h5 class="mt-3 mb-2">
          <span class="font-weight-semibold me-2">First name :</span>
          <span class="text-medium-emphasis">Sara</span>
        </h5>
        <h5>
          <span class="font-weight-semibold me-2">Last name :</span>
          <span class="text-medium-emphasis">Soudan</span>
        </h5>
        <h5 class="mt-5 mb-2">
          <span class="font-weight-semibold me-2">Address :</span>
          <span class="text-medium-emphasis">4898 Joanne Lane street</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">City :</span>
          <span class="text-medium-emphasis">Boston</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">Country :</span>
          <span class="text-medium-emphasis">United States</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">State :</span>
          <span class="text-medium-emphasis">Massachusetts</span>
        </h5>
        <h5 class="mb-2">
          <span class="font-weight-semibold me-2">Zip code :</span>
          <span class="text-medium-emphasis">02110</span>
        </h5>
        <h5 class="mt-5 mb-2">
          <span class="font-weight-semibold me-2">Phone :</span>
          <span class="text-medium-emphasis">+1 (070) 123-4567</span>
        </h5>
      </v-col>
    </v-row>
  </UiChildCard>
  <!-- shopping list -->
  <v-card elevation="0" class="mt-6">
    <v-card variant="outlined">
      <v-card-item class="py-3">
        <v-card-title class="text-headline-medium"> Products </v-card-title>
      </v-card-item>
      <v-divider />
      <v-table class="text-no-wrap">
        <thead>
          <tr>
            <th class="text-start text-body-large">Description</th>
            <th class="text-start text-body-large">Quantity</th>
            <th class="text-start text-body-large">Amount</th>
            <th class="text-start text-body-large">Total</th>
            <th class="text-start" />
          </tr>
        </thead>
        <tbody>
          <tr v-for="invoice in invoices" :key="invoice.name">
            <td class="py-3">
              <h5>
                {{ invoice.name }}
              </h5>
              <p class="mt-1 mb-0">lorem ipsum dolor sit amat, connecter adieu siccing eliot</p>
            </td>
            <td class="py-3">
              {{ invoice.quantity }}
            </td>
            <td class="py-3">${{ invoice.amount }}</td>
            <td class="py-3">${{ invoice.amount * invoice.quantity }}</td>
            <td class="py-3">
              <v-btn color="primary" variant="text" icon>
                <TrashIcon width="20" stroke-width="1.5" />
              </v-btn>
            </td>
          </tr>
        </tbody>
      </v-table>
      <v-divider />
      <v-card-text>
        <v-sheet class="bg-lightprimary pa-3 pa-sm-6" rounded="sm">
          <v-row class="justify-end">
            <v-col cols="6" sm="3" lg="2" class="text-end">
              <h5 class="py-2">Sub Total :</h5>
              <h5 class="py-2">Taxes (10%) :</h5>
              <h5 class="py-2 text-no-wrap">Discount (5%) :</h5>
              <h5 class="py-2 text-primary mt-7">Total</h5>
            </v-col>
            <v-col cols="6" sm="3" lg="2" class="text-end">
              <h5 class="py-2 text-disabled">$2,650.00</h5>
              <h5 class="py-2 text-disabled">$265.00</h5>
              <h5 class="py-2 text-disabled">$145.75</h5>
              <h5 class="py-2 text-primary mt-7">$2,769.25</h5>
            </v-col>
          </v-row>
        </v-sheet>
      </v-card-text>
    </v-card>
  </v-card>
</template>
