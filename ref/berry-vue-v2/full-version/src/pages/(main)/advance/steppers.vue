<script setup lang="ts">
import { ref, computed } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Steppers' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Steppers',
    disabled: true,
    href: '#'
  }
]);

const shipping = ref<string>('5');
const step = ref<string | number>(1);

interface Product {
  name: string;
  price: number;
  quantity: number;
}

const items = ['Review Order', 'Select Shipping', 'Submit'];

const products: Product[] = [
  {
    name: 'Product 1',
    price: 10,
    quantity: 2
  },
  {
    name: 'Product 2',
    price: 15,
    quantity: 10
  }
];

const subtotal = computed(() => products.reduce((acc, product) => acc + product.quantity * product.price, 0));
const total = computed(() => subtotal.value + Number(shipping.value));

const mobileItems = Array.from({ length: 10 }).map((_, i) => ({
  title: `Step ${i + 1}`,
  subtitle: `Step ${i + 1} subtitle`,
  value: i + 1
}));

const e1 = ref(1);
const steps = ref(2);

const disabled = computed(() => {
  return e1.value === 1 ? 'prev' : e1.value === steps.value ? 'next' : undefined;
});
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Steppers">
        <v-row>
          <v-col cols="12">
            <UiChildCard title="Non editable steps">
              <v-stepper model-value="2" flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad group" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Editable steps">
              <v-stepper flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1" complete editable></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad group" value="2" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3" editable></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Alternate label">
              <v-stepper alt-labels flat>
                <v-stepper-header>
                  <v-stepper-item title="Ad unit details" value="1"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Ad sizes" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Ad templates" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Linear steppers">
              <v-stepper flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad group" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
              <br />
              <v-stepper model-value="2" flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad group" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
              <br />
              <v-stepper model-value="3" flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad group" value="2" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Optional steps">
              <v-stepper model-value="1" flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item subtitle="Optional" title="Create an ad group" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
              <br />
              <v-stepper model-value="2" flat>
                <v-stepper-header>
                  <v-stepper-item title="Select campaign settings" value="1" complete></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item subtitle="Optional" title="Create an ad group" value="2"></v-stepper-item>
                  <v-divider></v-divider>
                  <v-stepper-item title="Create an ad" value="3"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Items">
              <v-stepper v-model="step" :items="items" show-actions flat border="sm">
                <template v-slot:[`item.1`]>
                  <h4>Order</h4>
                  <br />
                  <v-sheet border>
                    <v-table>
                      <thead>
                        <tr>
                          <th>Description</th>
                          <th class="text-end">Quantity</th>
                          <th class="text-end">Price</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="(product, index) in products" :key="index">
                          <td v-text="product.name"></td>
                          <td class="text-end" v-text="product.quantity"></td>
                          <td class="text-end" v-text="product.quantity * product.price"></td>
                        </tr>
                        <tr class="text-error">
                          <th>Total</th>
                          <th></th>
                          <th class="text-end">${{ subtotal }}</th>
                        </tr>
                      </tbody>
                    </v-table>
                  </v-sheet>
                </template>
                <template v-slot:[`item.2`]>
                  <h4>Shipping</h4>
                  <br />
                  <v-radio-group color="primary" v-model="shipping" label="Delivery Method">
                    <v-radio label="Standard Shipping" value="5"></v-radio>
                    <v-radio label="Priority Shipping" value="10"></v-radio>
                    <v-radio label="Express Shipping" value="15"></v-radio>
                  </v-radio-group>
                </template>
                <template v-slot:[`item.3`]>
                  <h4>Confirm</h4>
                  <br />
                  <v-sheet border>
                    <v-table>
                      <thead>
                        <tr>
                          <th>Description</th>
                          <th class="text-end">Quantity</th>
                          <th class="text-end">Price</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="(product, index) in products" :key="index">
                          <td v-text="product.name"></td>
                          <td class="text-end" v-text="product.quantity"></td>
                          <td class="text-end" v-text="product.quantity * product.price"></td>
                        </tr>
                        <tr>
                          <td>Shipping</td>
                          <td></td>
                          <td class="text-end" v-text="shipping"></td>
                        </tr>
                        <tr class="text-error">
                          <th>Total</th>
                          <th></th>
                          <th class="text-end">${{ total }}</th>
                        </tr>
                      </tbody>
                    </v-table>
                  </v-sheet>
                </template>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Mobile">
              <v-stepper flat mobile>
                <v-stepper-header>
                  <template v-for="(item, i) in mobileItems" :key="i">
                    <v-divider v-if="i"></v-divider>

                    <v-stepper-item v-bind="item"></v-stepper-item>
                  </template>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Errors">
              <v-stepper model-value="3" flat>
                <v-stepper-header>
                  <v-stepper-item title="Job Search" value="1" complete></v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item :rules="[() => false]" subtitle="Missing Details" title="Submit Application" value="2"></v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item title="Interview Process" value="3"></v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item title="Hiring Decision" value="4"></v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Dynamic steps">
              <v-select v-model="steps" :items="[2, 3, 4, 5, 6]" label="# of steps" variant="outlined"></v-select>
              <v-divider />
              <v-stepper v-model="e1" flat>
                <template v-slot:default="{ prev, next }">
                  <v-stepper-header>
                    <template v-for="n in steps" :key="`${n}-step`">
                      <v-stepper-item :complete="e1 > n" :step="`Step {{ n }}`" :value="n" editable></v-stepper-item>

                      <v-divider v-if="n !== steps" :key="n"></v-divider>
                    </template>
                  </v-stepper-header>

                  <v-stepper-window>
                    <v-stepper-window-item v-for="n in steps" :key="`${n}-content`" :value="n">
                      <v-card color="containerBg" height="200" rounded="sm"></v-card>
                    </v-stepper-window-item>
                  </v-stepper-window>

                  <v-stepper-actions :disabled="disabled" @click:next="next" @click:prev="prev"></v-stepper-actions>
                </template>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Alternative label with errors">
              <v-stepper alt-labels flat>
                <v-stepper-header>
                  <v-stepper-item value="1" complete>
                    <template v-slot:title> Ad type </template>
                  </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="2" complete>
                    <template v-slot:title> Ad style </template>
                  </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item :rules="[() => false]" value="3">
                    <template v-slot:title> Custom channels </template>

                    <template v-slot:subtitle> Alert message </template>
                  </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="46">
                    <template v-slot:title> Get code </template>
                  </v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Non linear">
              <v-stepper non-linear flat>
                <v-stepper-header>
                  <v-stepper-item value="1" editable> Select campaign settings </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="2" editable> Create an ad group </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="3" editable> Create an ad </v-stepper-item>
                </v-stepper-header>
              </v-stepper>

              <v-stepper flat non-linear>
                <v-stepper-header>
                  <v-stepper-item value="1" complete editable> Select campaign settings </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="2" editable> Create an ad group </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="3" complete editable> Create an ad </v-stepper-item>
                </v-stepper-header>
              </v-stepper>

              <v-stepper flat value="3" non-linear>
                <v-stepper-header>
                  <v-stepper-item value="1" complete editable> Select campaign settings </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="2" complete editable> Create an ad group </v-stepper-item>

                  <v-divider></v-divider>

                  <v-stepper-item value="3" complete editable> Create an ad </v-stepper-item>
                </v-stepper-header>
              </v-stepper>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.v-stepper--flat {
  .v-stepper-header {
    box-shadow:
      0px 0px 0px 0px var(--v-shadow-key-umbra-opacity, rgba(0, 0, 0, 0.2)),
      0px 0px 0px 0px var(--v-shadow-key-penumbra-opacity, rgba(0, 0, 0, 0.14)),
      0px 0px 0px 0px var(--v-shadow-key-ambient-opacity, rgba(0, 0, 0, 0.12));
  }
}
.v-stepper-item--error {
  color: rgba(var(--v-theme-error), 1);
}

@media (max-width: 575px) {
  .v-stepper--alt-labels {
    .v-stepper-item {
      flex-basis: 90px;
      padding: 4px;
    }
    .v-stepper-header {
      .v-divider {
        margin: 16px -16px 0;
      }
    }
    .v-stepper-item__content {
      word-break: break-word;
    }
  }
}
</style>
