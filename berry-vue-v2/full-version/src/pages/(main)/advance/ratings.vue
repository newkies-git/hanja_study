<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Ratings' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Ratings',
    disabled: true,
    href: '#'
  }
]);

// rating data
const rating = ref(3);
const rating2 = ref(4);
const rating3 = ref(5);
const rating4 = ref(2);
const rating5 = ref(2);
const rating6 = ref(3);
const rating7 = ref(3.5);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Ratings">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Basic">
              <div class="text-center">
                <v-rating v-model="rating" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Color -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Color">
              <div class="text-center">
                <v-rating v-model="rating2" color="primary" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Clearable -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Clearable">
              <div class="text-center">
                <v-rating v-model="rating3" clearable />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Read Only -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Read Only">
              <div class="text-center">
                <v-rating v-model="rating4" readonly />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Hover -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Hover">
              <div class="text-center">
                <v-rating v-model="rating5" color="warning" hover />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Label -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Label">
              <div class="text-center">
                <v-rating
                  v-model="rating6"
                  class="ma-2"
                  :item-labels="['sad', '', '', '', 'happy']"
                  item-label-position="top"
                  color="warning"
                  hover
                />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Icons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Icons">
              <div class="text-center">
                <v-rating
                  v-model="rating7"
                  class="d-block"
                  color="error"
                  empty-icon="$heartOutline"
                  full-icon="$heart"
                  half-icon="$heartHalf"
                  half-increments
                  hover
                />

                <v-rating
                  v-model="rating7"
                  class="d-block"
                  color="secondary"
                  empty-icon="$circleOutline"
                  full-icon="$circle"
                  half-icon="$circleHalf"
                  half-increments
                  hover
                />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Size -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Size">
              <div class="text-center">
                <v-rating class="d-block" color="primary" value="3" size="x-small" />

                <v-rating class="d-block" color="primary" value="3" size="small" />

                <v-rating class="d-block" color="primary" value="3" size="large" />

                <v-rating class="d-block" color="primary" value="3" size="x-large" />
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
@media (max-width: 480px) {
  .v-rating {
    .v-rating__item {
      .v-btn--icon {
        width: unset;
        height: unset;
      }
    }
  }
}
</style>
