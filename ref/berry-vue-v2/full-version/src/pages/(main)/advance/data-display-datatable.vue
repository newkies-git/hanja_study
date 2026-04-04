<script setup lang="ts">
import { ref, computed } from 'vue';

// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiTableCard from '@/components/shared/UiTableCard.vue';

// import data from commons file
import { headerDesserts, hideTable } from '@/data/tableData';
import {
  gpuItems,
  cpuHeaders,
  cpuItems,
  paginationHeaders,
  paginationDesserts,
  selectedHeaders,
  selectedDesserts,
  selectableHeaders,
  selectableDesserts,
  customSelectDesserts,
  selectStrategiesHeaders,
  selectStrategiesDesserts,
  basicSortingHeaders,
  basicSortingDesserts,
  multiSortHeaders,
  multiSortDesserts,
  sortHeaders,
  sortItems
} from '@/data/dataDisplayTableData';

// theme breadcrumb
const page = ref({ title: 'Data & Display' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Data & display',
    disabled: true,
    href: '#'
  }
]);

const search = ref('');
const filterSearch = ref('');

// custom filter table
const customSearch = ref('');

const filterOnlyCapsText = (value: unknown, query: string) => {
  return value != null && query != null && typeof value === 'string' && value.toString().toLocaleUpperCase().indexOf(query) !== -1;
};

// external pagination
const externalpage = ref(1);
const itemsPerPage = ref(5);
const pageCount = computed(() => {
  return Math.ceil(paginationDesserts.length / itemsPerPage.value);
});

// selected values
const selected = ref([selectedDesserts[0]]);

// basic sorting
const sortBy = ref([{ key: 'calories', order: 'asc' as const }]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiTableCard title="Search Filter">
        <div class="pa-5">
          <h4 class="mb-2">Nutrition</h4>
          <v-text-field v-model="search" label="Search" prepend-inner-icon="$magnify" hide-details single-line></v-text-field>
        </div>

        <v-data-table :headers="hideTable" :items="headerDesserts" :search="search"></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Filter Keys">
        <v-card-title class="d-flex align-center justify-space-between flex-wrap ga-3 pa-5">
          <span> <v-icon icon="$videoInputComponent"></v-icon> &nbsp; Find a Graphics Card </span>
          <v-text-field
            v-model="filterSearch"
            label="Search"
            prepend-inner-icon="$magnify"
            hide-details
            single-line
            style="max-width: 300px; min-width: 250px"
          ></v-text-field>
        </v-card-title>

        <v-divider></v-divider>

        <v-data-table class="filter-table" v-model:search="filterSearch" :filter-keys="['name']" :items="gpuItems">
          <template #[`header.stock`]>
            <div class="text-end">Stock</div>
          </template>

          <template #[`item.image`]="{ item }">
            <v-card class="my-2" elevation="2" rounded>
              <v-img :src="`https://cdn.vuetifyjs.com/docs/images/graphics/gpus/${item.image}`" height="64" cover></v-img>
            </v-card>
          </template>

          <template #[`item.rating`]="{ item }">
            <v-rating :model-value="item.rating" color="warning" density="compact" size="small" readonly></v-rating>
          </template>

          <template #[`item.stock`]="{ item }">
            <div class="text-end">
              <v-chip
                :color="item.stock ? 'success' : 'error'"
                :text="item.stock ? 'In stock' : 'Out of stock'"
                class="text-uppercase"
                size="small"
                label
              ></v-chip>
            </div>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Custom Filter">
        <v-data-table
          class="filter-table"
          :custom-filter="filterOnlyCapsText"
          :headers="cpuHeaders"
          :items="cpuItems"
          :search="customSearch"
          item-value="name"
        >
          <template #top>
            <v-text-field v-model="customSearch" class="pa-5 pb-2" label="Search (UPPER CASE ONLY)" single-line hide-details></v-text-field>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="External pagination">
        <v-data-table
          v-model:page="externalpage"
          :headers="paginationHeaders"
          :items="paginationDesserts"
          :items-per-page="itemsPerPage"
          class="filter-table"
        >
          <template #top>
            <v-number-input
              v-model="itemsPerPage"
              :max="15"
              :min="-1"
              class="pa-5"
              label="Items per page"
              hide-details
              variant="outlined"
              single-line
            ></v-number-input>
          </template>

          <template #bottom>
            <div class="text-center pt-2 pb-5">
              <v-pagination v-model="externalpage" :length="pageCount"></v-pagination>
            </div>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Selected values">
        <v-data-table
          v-model="selected"
          :headers="selectedHeaders"
          :items="selectedDesserts"
          item-value="name"
          items-per-page="5"
          return-object
          show-select
        ></v-data-table>

        <pre class="px-5 pb-5">{{ selected }}</pre>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Selectable rows">
        <v-data-table
          :headers="selectableHeaders"
          :items="selectableDesserts"
          item-selectable="selectable"
          item-value="name"
          items-per-page="5"
          show-select
        ></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Custom select column">
        <v-data-table :items="customSelectDesserts" item-value="name" show-select>
          <template #[`header.data-table-select`]="{ allSelected, selectAll, someSelected }">
            <v-checkbox-btn
              :indeterminate="someSelected && !allSelected"
              :model-value="allSelected"
              color="primary"
              @update:model-value="selectAll(!allSelected)"
            ></v-checkbox-btn>
          </template>

          <template #[`item.data-table-select`]="{ internalItem, isSelected, toggleSelect }">
            <v-checkbox-btn
              :model-value="isSelected(internalItem)"
              color="primary"
              @update:model-value="toggleSelect(internalItem)"
            ></v-checkbox-btn>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Select strategies">
        <v-data-table
          :headers="selectStrategiesHeaders"
          :items="selectStrategiesDesserts"
          item-value="name"
          select-strategy="single"
          show-select
        ></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Basic sorting">
        <v-data-table
          v-model:sort-by="sortBy"
          :headers="basicSortingHeaders"
          :items="basicSortingDesserts"
          class="filter-table"
        ></v-data-table>

        <pre class="px-5 pb-5">{{ sortBy }}</pre>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Multi sort">
        <v-data-table
          :headers="multiSortHeaders"
          :items="multiSortDesserts"
          :sort-by="[
            { key: 'calories', order: 'asc' },
            { key: 'fat', order: 'desc' }
          ]"
          multi-sort
          class="filter-table multi-sorting-table"
        ></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Sort by raw">
        <v-data-table :headers="sortHeaders" :items="sortItems" class="filter-table sorting-table"></v-data-table>
      </UiTableCard>
    </v-col>
  </v-row>
</template>
