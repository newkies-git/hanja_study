<script setup lang="ts">
import { ref } from 'vue';

import visaImg from '@/assets/images/pages/visa.png';
import discoverImg from '@/assets/images/pages/discover.png';
import masterImg from '@/assets/images/pages/mastercard.png';

// icons
import { ArrowNarrowRightIcon } from 'vue-tabler-icons';

const bills = ref([
  {
    title: 'Bill Due',
    color: 'error',
    subtitle: '$150.00',
    moveto: 'Pay Now'
  },
  {
    title: 'Total Credits',
    color: 'warning',
    subtitle: '1570 GB',
    moveto: 'Full Report'
  },
  {
    title: 'Plan',
    color: 'success',
    subtitle: 'Basic',
    moveto: 'Upgrade ?'
  }
]);

const methods = ref([
  {
    img: visaImg,
    name: 'Visa card',
    excode: '5269 07XX XXXX 8110',
    default: true,
    divider: true
  },
  {
    img: discoverImg,
    name: 'Discover',
    excode: '6109 07XX XXXX 8020',
    default: false,
    divider: true
  },
  {
    img: masterImg,
    name: 'Mastercard',
    excode: '7278 07XX XXXX 4290',
    default: false,
    divider: false
  }
]);

const billhistory = ref([
  {
    orderno: '12877227695',
    date: '26 Feb 2021 9:16 am',
    price: '56.32',
    wait: true
  },
  {
    orderno: '12901477937',
    date: '30 Jan 2021 2:54 pm',
    price: '75.56',
    wait: false
  },
  {
    orderno: '12767886919',
    date: '22 Jan 2021 12:01 pm',
    price: '34.23',
    wait: false
  }
]);
</script>

<template>
  <v-row>
    <v-col v-for="(bill, i) in bills" :key="i" cols="12" lg="4">
      <div :class="'pa-5 rounded-md v-alert--border v-alert--border-start  position-relative bg-light' + bill.color">
        <div :class="'v-alert__border bg-' + bill.color" />
        <span>{{ bill.title }}</span>
        <h2 class="mb-3 font-weight-medium">
          {{ bill.subtitle }}
        </h2>
        <span :class="'text-body-large text-decoration-none d-flex align-center cursor-pointer text-' + bill.color">
          {{ bill.moveto }}
          <ArrowNarrowRightIcon width="20" stroke-width="1.5" class="ms-1" />
        </span>
      </div>
    </v-col>
    <v-col cols="12">
      <v-card variant="flat">
        <v-card variant="outlined" class="overflow-hidden">
          <v-list>
            <v-list-item class="d-sm-flex d-block">
              <template #title>
                <h5 class="mt-1 mb-3 mb-sm-0 me-2">Payment Methods</h5>
              </template>
              <template #append>
                <v-btn size="small" color="primary"> Add New Method </v-btn>
              </template>
            </v-list-item>
          </v-list>
          <v-divider />
          <v-card-text class="pa-0">
            <v-list class="list-content" lines="two">
              <template v-for="(method, i) in methods" :key="i">
                <v-list-item>
                  <template #prepend>
                    <img :src="method.img" :alt="method.img" width="50" class="me-2" />
                  </template>
                  <template #title>
                    <div class="d-none d-sm-block">
                      <h5 class="mt-1">
                        {{ method.name }}
                      </h5>
                      <h6 class="text-disabled">Ending in {{ method.excode }}</h6>
                    </div>
                  </template>
                  <template #append>
                    <div class="d-flex align-center">
                      <v-chip v-if="method.default" color="primary" size="small" variant="tonal"> Default </v-chip>
                      <v-chip v-else color="secondary" size="small" variant="tonal"> make default </v-chip>
                      <v-divider vertical class="mx-4 my-1" style="height: 20px" />
                      <v-btn size="small" color="primary"> Edit </v-btn>
                    </div>
                  </template>
                </v-list-item>
                <v-divider v-if="method.divider" />
              </template>
            </v-list>
          </v-card-text>
        </v-card>
      </v-card>
    </v-col>

    <v-col cols="12">
      <v-card variant="flat">
        <v-card variant="outlined">
          <div class="pa-5">
            <h5 class="mt-1">Billing History</h5>
          </div>

          <v-divider />

          <v-table class="text-no-wrap">
            <thead>
              <tr>
                <th class="text-start">Order No.</th>
                <th class="text-start">Date</th>
                <th class="text-start">Price</th>
                <th class="text-start">Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="history in billhistory" :key="history.orderno">
                <td>{{ history.orderno }}</td>
                <td>{{ history.date }}</td>
                <td>${{ history.price }}</td>
                <td>
                  <v-chip v-if="history.wait" color="warning" size="small"> Awaiting </v-chip>
                  <v-chip v-else color="success" size="small"> Paid </v-chip>
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-card>
      </v-card>
    </v-col>
  </v-row>
</template>
