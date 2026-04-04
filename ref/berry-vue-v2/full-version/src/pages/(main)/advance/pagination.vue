<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Pagination' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Pagination',
    disabled: true,
    href: '#'
  }
]);

// pagination data
const pagination = ref(1);
const pagination1 = ref(1);
const pagination2 = ref(1);
const pagination3 = ref(1);
const pagination4 = ref(1);
const pagination5 = ref(1);
const pagination6 = ref(1);
const pagination7 = ref(1);
const pagination8 = ref(1);
const pagination9 = ref(1);
const pagination10 = ref(1);
const pagination11 = ref(1);
const pagination12 = ref(1);
const pagination13 = ref(1);
const pagination14 = ref(1);
const pagination15 = ref(1);
const pagination16 = ref(1);
const pagination17 = ref(1);
const pagination18 = ref(1);
const pagination19 = ref(1);
const pagination20 = ref(1);
const pagination21 = ref(1);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Pagination">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Basic">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination" :length="4" />
                <v-pagination v-model="pagination1" active-color="primary" :length="6" />
                <v-pagination v-model="pagination2" active-color="secondary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Outlined -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Outlined">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination3" variant="outlined" :length="6" />
                <v-pagination v-model="pagination4" variant="outlined" active-color="primary" :length="6" />
                <v-pagination v-model="pagination5" variant="outlined" active-color="secondary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Rounded -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rounded">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination6" rounded="circle" :length="6" />
                <v-pagination v-model="pagination7" rounded="circle" active-color="primary" :length="6" />
                <v-pagination v-model="pagination8" rounded="circle" active-color="secondary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Square -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Square">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination9" rounded="0" :length="6" />
                <v-pagination v-model="pagination10" rounded="0" active-color="primary" :length="6" />
                <v-pagination v-model="pagination11" rounded="0" active-color="secondary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Flat -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Flat">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination12" variant="flat" :length="6" />
                <v-pagination v-model="pagination13" variant="flat" active-color="primary" :length="6" />
                <v-pagination v-model="pagination14" variant="flat" active-color="secondary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Size -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Size">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination15" active-color="primary" density="compact" :length="6" />
                <v-pagination v-model="pagination16" active-color="primary" density="comfortable" :length="6" />
                <v-pagination v-model="pagination17" active-color="primary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Disabled -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Disabled">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination18" disabled active-color="primary" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Icons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Icons">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination19" active-color="primary" prev-icon="$menuLeft" next-icon="$menuRight" :length="6" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Length -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Length">
              <div class="text-center ma-n1">
                <v-pagination v-model="pagination20" active-color="primary" :length="15" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- Total visible -->
          <v-col cols="12" lg="8">
            <UiChildCard title="Total visible">
              <div class="text-center overflow-auto">
                <v-pagination v-model="pagination21" active-color="primary" :length="15" :total-visible="7" />
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
