<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// icons
import { TrashIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Create Invoice' });
const breadcrumbs = ref([
  {
    title: 'Customer',
    disabled: false,
    href: '#'
  },
  {
    title: 'Create Invoice',
    disabled: true,
    href: '#'
  }
]);

const textinvoice = ref('');
const textcustomer = ref('');
const textcustomermail = ref('');
const textcustomerno = ref('');
const textcustomeradd = ref('');
const textdate = ref('23/09/2022');
const textterms = ref('I acknowledge terms and conditions.');

const status = ref(['Pending', 'Refund', 'Paid']);
const textstatus = ref<string>('Pending');

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
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Create Invoice">
        <v-row>
          <v-col cols="12" lg="4">
            <v-label class="text-body-large text-high-emphasis mb-2"> Invoice Number<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textinvoice"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="Invoice #"
            />
          </v-col>
        </v-row>
        <v-divider class="my-6" />
        <v-row>
          <v-col cols="12" lg="4">
            <v-label class="text-body-large text-high-emphasis mb-2"> Customer Name<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textcustomer"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="Alex Z."
            />
          </v-col>
          <v-col cols="12" lg="4">
            <v-label class="text-body-large text-high-emphasis mb-2"> Customer Email<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textcustomermail"
              type="email"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="alex@company.com"
            />
          </v-col>
          <v-col cols="12" lg="4">
            <v-label class="text-body-large text-high-emphasis mb-2"> Customer Contact Numer<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textcustomerno"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="+00 0000 0000"
            />
          </v-col>
          <v-col cols="12">
            <v-label class="text-body-large text-high-emphasis mb-2"> Customer Address<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textcustomeradd"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="Enter Address"
            />
          </v-col>
        </v-row>
        <v-divider class="my-6" />
        <v-row>
          <v-col cols="12" lg="6">
            <v-label class="text-body-large text-high-emphasis mb-2"> Invoice Date<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textdate"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="Enter Address"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <v-label class="text-body-large text-high-emphasis mb-2"> Status<span class="ms-1">*</span> </v-label>
            <v-select v-model="textstatus" color="primary" :items="status" variant="outlined" hide-details />
          </v-col>
        </v-row>
        <v-divider class="my-6" />

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
                <v-btn color="error" variant="text" icon>
                  <TrashIcon width="20" stroke-width="1.5" />
                </v-btn>
              </td>
            </tr>
          </tbody>
        </v-table>
        <v-divider class="my-6" />
        <v-btn color="primary" variant="text"> + Add Item </v-btn>
        <v-divider class="my-6" />
        <v-sheet class="bg-lightprimary pa-3 pa-sm-6" rounded="sm">
          <v-row class="justify-end">
            <v-col cols="auto" class="text-end">
              <h5 class="py-2">Sub Total :</h5>
              <h5 class="py-2 text-no-wrap">Taxes (10%) :</h5>
              <h5 class="py-2 text-no-wrap">Discount (5%) :</h5>
              <h5 class="py-2 text-primary mt-7">Total</h5>
            </v-col>
            <v-col cols="auto" class="text-end">
              <h5 class="py-2 text-disabled">$2,650.00</h5>
              <h5 class="py-2 text-disabled">$265.00</h5>
              <h5 class="py-2 text-disabled">$145.75</h5>
              <h5 class="py-2 text-primary mt-7">$2,769.25</h5>
            </v-col>
          </v-row>
        </v-sheet>
        <v-divider class="my-6" />
        <v-row>
          <v-col cols="12">
            <v-label class="text-body-large text-high-emphasis mb-2"> Terms and Condition:<span class="ms-1">*</span> </v-label>
            <v-text-field
              v-model="textterms"
              type="text"
              color="primary"
              hide-details
              variant="outlined"
              persistent-placeholder
              placeholder="Alex Z."
            />
          </v-col>
        </v-row>
        <v-divider class="my-6" />
        <div class="text-end">
          <v-btn color="primary"> Add Invoice </v-btn>
        </div>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
