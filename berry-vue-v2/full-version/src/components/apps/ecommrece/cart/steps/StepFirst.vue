<script setup lang="ts">
import { computed } from 'vue';
import { useEcomStore } from '@/stores/apps/eCommerce';
import CartEmpty from '../CartEmpty.vue';
import OrderSummaryVue from './OrderSummary.vue';

const store = useEcomStore();
const cart = computed(() => store.cart);
</script>
<template>
  <div v-if="cart.length > 0">
    <h5 class="my-8">Cart Item ({{ cart.length }})</h5>
    <v-divider />
    <v-table>
      <thead>
        <tr>
          <th class="text-start">Product</th>
          <th class="text-start">Price</th>
          <th class="text-start">Quantity</th>
          <th class="text-start">Total</th>
          <th class="text-end" />
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in cart" :key="item.name">
          <td>
            <div class="d-flex align-center my-3 ga-2">
              <img alt="product" class="rounded-md custom-img-box" :src="item.image" />
              <div class="ma-2">
                <h5>
                  {{ item.name }}
                </h5>
                <small>size: 8 | Color: Dark Red</small>
              </div>
            </div>
          </td>
          <td>
            <h5>${{ item.salePrice }}</h5>
            <p class="text-decoration-line-through text-medium-emphasis">${{ item.offerPrice }}</p>
          </td>
          <td>
            <v-btn-toggle variant="outlined" divided color="primary">
              <v-btn size="small" :disabled="item.qty < 2" @click="store.decrementQty(item.id)">
                <MinusIcon size="18" />
              </v-btn>

              <v-btn size="small">
                {{ item.qty }}
              </v-btn>

              <v-btn size="small" @click="store.incrementQty(item, cart)">
                <PlusIcon size="18" />
              </v-btn>
            </v-btn-toggle>
          </td>
          <td class="text-headline-medium">${{ item.salePrice * item.qty }}</td>
          <td class="text-end">
            <v-btn small icon flat>
              <TrashIcon size="18" @click="store.deleteCart(item.id)" />
            </v-btn>
          </td>
        </tr>
      </tbody>
    </v-table>
    <OrderSummaryVue />
  </div>
  <div v-else class="d-flex justify-center">
    <CartEmpty />
  </div>
</template>
<style lang="scss">
.custom-img-box {
  width: 60px;
  height: 60px;
}

.v-btn-group {
  .v-btn--disabled {
    opacity: 0.5;
  }
}
</style>
