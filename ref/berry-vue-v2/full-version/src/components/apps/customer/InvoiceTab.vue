<script setup lang="ts">
import { ref } from 'vue';

import Logo from '@/layouts/full/logo/LogoMain.vue';

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
  <v-row class="justify-center">
    <v-col cols="12" lg="8">
      <v-card id="printMe" variant="outlined">
        <v-card-item class="py-4">
          <div class="d-md-flex align-center justify-space-between">
            <h4>Invoice #125863478945</h4>
            <div class="d-md-block d-none">
              <Logo />
            </div>
          </div>
        </v-card-item>
        <v-divider />
        <v-card-text>
          <h5 class="mb-1">Demo Company Inc.</h5>
          <h5 class="text-medium-emphasis">1065 Mandan Road, Columbia MO,</h5>
          <h5 class="text-medium-emphasis">Missouri. (123)-65202</h5>
          <a href="/" class="text-primary">demo@company.com</a>
          <h5 class="text-medium-emphasis">(+91) 9999 999 999</h5>
          <v-row class="mt-4">
            <v-col cols="12" md="4">
              <h5 class="mb-1">Customer :</h5>
              <h5 class="mb-1 mt-3">John Doe</h5>
              <h5 class="text-medium-emphasis">1065 Mandan Road, Columbia MO,</h5>
              <h5 class="text-medium-emphasis">Missouri. (123)-65202</h5>
              <h5 class="text-medium-emphasis">(+61) 9999 567 891</h5>
              <a href="/" class="text-primary">demo@company.com</a>
            </v-col>
            <v-col cols="12" md="4">
              <h5 class="mb-1">Order Details :</h5>
              <v-row class="mt-3">
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2"> Date : </v-col>
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2"> November 14 </v-col>
              </v-row>
              <v-row class="">
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2"> Status : </v-col>
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2">
                  <v-chip color="warning" size="small" variant="outlined"> Pending </v-chip>
                </v-col>
              </v-row>
              <v-row class="">
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2"> Order Id : </v-col>
                <v-col cols="6" class="text-medium-emphasis text-body-large pa-2">
                  <a href="/">#146859</a>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
          <v-table class="mt-5 text-no-wrap">
            <thead>
              <tr>
                <th class="text-start text-uppercase text-body-large">Description</th>
                <th class="text-start text-uppercase text-body-large">Quantity</th>
                <th class="text-start text-uppercase text-body-large">Amount</th>
                <th class="text-start text-uppercase text-body-large">Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="invoice in invoices" :key="invoice.name">
                <td class="py-3">
                  <h5>
                    {{ invoice.name }}
                  </h5>
                  <p class="mt-1 mb-0">lorem ipsum dolor sit amat, connecter adieu</p>
                </td>
                <td class="py-3">
                  {{ invoice.quantity }}
                </td>
                <td class="py-3">${{ invoice.amount }}</td>
                <td class="py-3">${{ invoice.amount * invoice.quantity }}</td>
              </tr>
            </tbody>
          </v-table>
          <v-sheet class="bg-lightprimary pa-3 pa-sm-6 mt-6" rounded="sm">
            <v-row class="justify-end">
              <v-col cols="6" sm="3" class="text-end">
                <h5 class="py-2">Sub Total :</h5>
                <h5 class="py-2">Taxes (10%) :</h5>
                <h5 class="py-2 text-no-wrap">Discount (5%) :</h5>
                <h5 class="py-2 text-primary mt-7">Total</h5>
              </v-col>
              <v-col cols="6" sm="2" lg="2" class="text-end">
                <h5 class="py-2 text-disabled">$2,650.00</h5>
                <h5 class="py-2 text-disabled">$265.00</h5>
                <h5 class="py-2 text-disabled">$145.75</h5>
                <h5 class="py-2 text-primary mt-7">$2,769.25</h5>
              </v-col>
            </v-row>
          </v-sheet>

          <h5 class="mb-1 mt-4">Terms and Condition :</h5>
          <h5 class="text-medium-emphasis font-weight-regular">
            lorem ipsum dolor sit connecter adieu siccing eliot, sed do elusion tempore incident ut laborer et dolors magna aliquot.
          </h5>
        </v-card-text>
      </v-card>
      <div class="text-center mt-6">
        <v-btn v-print="'#printMe'" color="primary"> Print </v-btn>
      </div>
    </v-col>
  </v-row>
</template>
