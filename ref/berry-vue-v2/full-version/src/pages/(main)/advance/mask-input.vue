<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';
import CustomMask from '@/components/CustomMask.vue';

// theme breadcrumb
const page = ref({ title: 'Mask inputs' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Mask inputs',
    disabled: true,
    href: '#'
  }
]);

const model = shallowRef(null);
const customMask = shallowRef(null);
const tokenModel = shallowRef(null);
const contactMask = shallowRef(null);
const hexMask = shallowRef(null);
const ipModel = shallowRef(null);
const ipv4Model = shallowRef(null);
const ipv6Model = shallowRef(null);

// validation of IP address
const validateIP = (ip: string): boolean => {
  if (!ip) return false;
  const parts = ip.split('.');
  return (
    parts.length === 4 &&
    parts.every((part: string) => {
      const num = parseInt(part);
      return num >= 0 && num <= 255;
    })
  );
};

// credit card form mask
const cardNumber = shallowRef(null);
const expiryDate = shallowRef(null);
const cvv = shallowRef(null);

const validateExpiryDate = (date: string) => {
  if (!date || date.length !== 5) return false;

  const [month = '', year = ''] = date.split('/');
  const currentDate = new Date();
  const currentYear = currentDate.getFullYear() % 100;
  const currentMonth = currentDate.getMonth() + 1;

  const monthNum = parseInt(month);
  const yearNum = parseInt(year);

  return monthNum >= 1 && monthNum <= 12 && yearNum >= currentYear && !(yearNum === currentYear && monthNum < currentMonth);
};
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Mask Inputs">
        <v-row>
          <v-col cols="12" lg="6">
            <UiChildCard title="Using Built in Masks">
              <v-label class="text-label-small mb-2">Phone number with code</v-label>
              <v-mask-input v-model="model" mask="phone" placeholder="(###) ### - ####" variant="outlined" hide-details></v-mask-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="Using Custom Tokens">
              <v-mask-input
                v-model="tokenModel"
                :mask="{
                  mask: 'LLL-NNN',
                  tokens: {
                    L: {
                      pattern: /[A-Z]/,
                      convert: (v) => v.toUpperCase()
                    },
                    N: {
                      pattern: /[0-9]/,
                      convert: (v) => v
                    }
                  }
                }"
                label="License Plate"
                persistent-hint
                variant="outlined"
                single-line
                hide-details
              ></v-mask-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="Using Custom Masks">
              <div class="mb-4">
                <v-label class="text-label-small mb-1">Product Code</v-label>
                <v-mask-input
                  v-model="customMask"
                  mask="AAA-###"
                  placeholder="ABC-123"
                  variant="outlined"
                  hide-details
                  single-line
                ></v-mask-input>
              </div>
              <div class="mb-4">
                <v-label class="text-label-small mb-1">Contact number</v-label>
                <v-mask-input
                  v-model="contactMask"
                  mask="+91 #### ###-###"
                  placeholder="+91 #### ###-###"
                  variant="outlined"
                  hide-details
                  single-line
                ></v-mask-input>
              </div>
              <div>
                <v-label class="text-label-small mb-1">Hex color</v-label>
                <v-mask-input
                  v-model="hexMask"
                  :mask="{
                    mask: 'SHHHHHH',
                    tokens: {
                      S: {
                        pattern: /#/,
                        convert: () => '#'
                      },
                      H: {
                        pattern: /[0-9a-fA-F]/,
                        convert: (v) => v.toUpperCase()
                      }
                    }
                  }"
                  placeholder="#FFFFFF"
                  variant="outlined"
                  hide-details
                  single-line
                ></v-mask-input>
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="IP Address">
              <div class="mb-4">
                <v-label class="text-label-small mb-1">Valid Ip address</v-label>
                <v-mask-input
                  v-model="ipModel"
                  :rules="[(v) => !!v || 'IP address is required', (v) => validateIP(v) || 'Invalid IP address']"
                  hint="Enter a valid IP address"
                  mask="###.###.###.###"
                  placeholder="192.168.001.001"
                  persistent-hint
                  return-masked-value
                  variant="outlined"
                ></v-mask-input>
              </div>
              <div class="mb-4">
                <v-label class="text-label-small mb-1">Ipv4 address</v-label>
                <v-mask-input
                  v-model="ipv4Model"
                  mask="####.####.####.####"
                  placeholder="####.####.####.####"
                  variant="outlined"
                  hide-details
                ></v-mask-input>
              </div>
              <div>
                <v-label class="text-label-small mb-1">Ipv6 address</v-label>
                <v-mask-input
                  v-model="ipv6Model"
                  mask="####:####:####:####:####:####:####:####"
                  placeholder="####:####:####:####:####:####:####:####"
                  variant="outlined"
                  hide-details
                ></v-mask-input>
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Credit Card Form">
              <v-row>
                <v-col cols="12">
                  <v-mask-input
                    v-model="cardNumber"
                    :rules="[
                      (v) => !!v || 'Card number is required',
                      (v) => v.replace(/\s/g, '').length === 16 || 'Card number must be 16 digits'
                    ]"
                    hint="Enter 16-digit card number"
                    mask="#### #### #### ####"
                    placeholder="XXXX XXXX XXXX XXXX"
                    prepend-inner-icon="$creditCardOutline"
                    persistent-hint
                    variant="outlined"
                  ></v-mask-input>
                </v-col>

                <v-col cols="12" sm="6">
                  <v-mask-input
                    v-model="expiryDate"
                    :rules="[(v) => !!v || 'Expiry date is required', (v) => validateExpiryDate(v) || 'Invalid expiry date']"
                    hint="Enter expiry date"
                    mask="##/##"
                    placeholder="MM/YY"
                    prepend-inner-icon="$calendarBlank"
                    persistent-hint
                    return-masked-value
                    variant="outlined"
                  ></v-mask-input>
                </v-col>

                <v-col cols="12" sm="6">
                  <v-mask-input
                    v-model="cvv"
                    :rules="[(v) => !!v || 'CVV is required', (v) => v.length === 3 || 'CVV must be 3 digits']"
                    hint="3-digit security code"
                    mask="###"
                    placeholder="CVC"
                    prepend-inner-icon="$lockOutline"
                    persistent-hint
                    variant="outlined"
                  ></v-mask-input>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <CustomMask />
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
