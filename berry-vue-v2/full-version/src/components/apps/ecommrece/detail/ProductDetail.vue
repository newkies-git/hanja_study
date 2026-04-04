<script setup>
import { ref, shallowRef, onMounted, computed } from 'vue';
import { useEcomStore } from '@/stores/apps/eCommerce';
import { useRoute } from 'vue-router';
import ProductCarousel from './ProductCarousel.vue';
import ProductTab from './ProductTab.vue';

const store = useEcomStore();
const route = useRoute();
const size = shallowRef(['10', '09', '08', '07']);
const selectedSize = shallowRef(['10']);
const setColor = ref(1);
onMounted(() => {
  store.fetchProducts();
});

const getProduct = computed(() => {
  const productId = Number(route.params.id);
  // Assuming product IDs start from 1
  return store.products.find((product) => product.id === productId);
});

function selectColor(e) {
  setColor.value = e;
}
</script>
<template>
  <div v-if="getProduct">
    <v-row>
      <v-col lg="5" sm="12" cols="12">
        <ProductCarousel />
      </v-col>
      <v-col lg="7" sm="12" cols="12">
        <div class="d-flex align-top">
          <div>
            <v-chip v-if="getProduct.isStock" color="success"> In Stock </v-chip>
            <v-chip v-else color="error"> Out of Stock </v-chip>
            <h3 class="my-2 mb-3">
              {{ getProduct.name }}
              <v-chip color="info" variant="outlined" size="small"> New </v-chip>
            </h3>
          </div>
          <v-btn size="small" icon class="ms-auto">
            <HeartIcon />
          </v-btn>
        </div>
        <p class="v-col-lg-10 px-0">
          {{ getProduct.description }}
        </p>
        <div class="text-medium-emphasis align-center d-flex mb-3 ga-2">
          <v-rating v-model="getProduct.rating" color="warning" half-increments density="compact" />
          <small>({{ getProduct.rating }}+)</small>
        </div>
        <div class="d-flex align-center ga-2">
          <h2 class="text-primary">${{ getProduct.salePrice }}</h2>
          <p class="text-decoration-line-through text-medium-emphasis mb-0">${{ getProduct.offerPrice }}</p>
          <small class="text-medium-emphasis">(Inclusive of all taxes)</small>
        </div>
        <v-divider class="my-3" />
        <v-row>
          <v-col cols="12">
            <table class="productCustomize">
              <tbody>
                <tr>
                  <td>Colors<span class="text-error">*</span></td>
                  <td>
                    <template v-for="(color, i) in getProduct.colors" :key="i">
                      <v-avatar variant="flat" :color="color" size="x-small" class="me-1 cursor-pointer" @click="selectColor(i)">
                        <template v-if="setColor == i">
                          <CheckIcon size="13" />
                        </template>
                      </v-avatar>
                    </template>
                  </td>
                </tr>
                <tr>
                  <td>Size<span class="text-error">*</span></td>
                  <td>
                    <v-select v-model="selectedSize" hide-details :items="size" variant="outlined" style="width: 90px" />
                  </td>
                </tr>
                <tr>
                  <td>Quantity</td>
                  <td>
                    <v-number-input
                      v-model="getProduct.qty"
                      control-variant="split"
                      variant="outlined"
                      hide-details
                      @change="(val) => store.updateQty(getProduct.id, val)"
                      :min="0"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </v-col>
          <v-col cols="6">
            <v-btn block color="primary" @click="store.AddToCart(getProduct)"> Add To Cart </v-btn>
          </v-col>
          <v-col cols="6">
            <v-btn block color="secondary" to="/ecommerce/checkout" @click="store.AddToCart(getProduct)"> Buy Now </v-btn>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ProductTab />
  </div>
</template>
<style lang="scss">
.productCustomize tr td {
  padding: 15px 20px;
  vertical-align: center;
}
</style>
