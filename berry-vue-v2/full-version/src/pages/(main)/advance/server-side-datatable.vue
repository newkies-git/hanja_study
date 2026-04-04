<script setup lang="ts">
import { ref, watch } from 'vue';

// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiTableCard from '@/components/shared/UiTableCard.vue';

// theme breadcrumb
const page = ref({ title: 'Server side' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Server side',
    disabled: true,
    href: '#'
  }
]);

const desserts = [
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: '1'
  },
  {
    name: 'Jelly bean',
    calories: 375,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: '0'
  },
  {
    name: 'KitKat',
    calories: 518,
    fat: 26,
    carbs: 65,
    protein: 7,
    iron: '6'
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: '7'
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: '16'
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: '1'
  },
  {
    name: 'Lollipop',
    calories: 392,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: '2'
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: '8'
  },
  {
    name: 'Honeycomb',
    calories: 408,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    iron: '45'
  },
  {
    name: 'Donut',
    calories: 452,
    fat: 25,
    carbs: 51,
    protein: 4.9,
    iron: '22'
  }
];
type Dessert = {
  name: string;
  calories: number;
  fat: number;
  carbs: number;
  protein: number;
  iron: string;
};

type SortItem = {
  key: string;
  order: 'asc' | 'desc';
};

const FakeAPI = {
  async fetch({ page, itemsPerPage, sortBy }: { page: number; itemsPerPage: number; sortBy: SortItem[] }) {
    return new Promise<{ items: Dessert[]; total: number }>((resolve) => {
      setTimeout(() => {
        const start = (page - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        const items = desserts.slice();
        if (sortBy.length > 0) {
          const { key: sortKey, order: sortOrder } = sortBy[0]!;
          items.sort((a: Dessert, b: Dessert) => {
            const aValue = a[sortKey as keyof Dessert];
            const bValue = b[sortKey as keyof Dessert];
            return sortOrder === 'desc' ? Number(bValue) - Number(aValue) : Number(aValue) - Number(bValue);
          });
        }
        const paginated = items.slice(start, end === -1 ? undefined : end);
        resolve({ items: paginated, total: items.length });
      }, 500);
    });
  }
};
const itemsPerPage = ref(5);
const headers = ref([
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    sortable: false,
    key: 'name'
  },
  { title: 'Calories', key: 'calories', align: 'end' as const },
  { title: 'Fat (g)', key: 'fat', align: 'end' as const },
  { title: 'Carbs (g)', key: 'carbs', align: 'end' as const },
  { title: 'Protein (g)', key: 'protein', align: 'end' as const },
  { title: 'Iron (%)', key: 'iron', align: 'end' as const }
]);
const search = ref('');
const serverItems = ref<Dessert[]>([]);
const loading = ref(true);
const totalItems = ref(0);
function loadItems({ page, itemsPerPage, sortBy }: { page: number; itemsPerPage: number; sortBy: SortItem[] }) {
  loading.value = true;
  FakeAPI.fetch({ page, itemsPerPage, sortBy }).then(({ items, total }) => {
    serverItems.value = items;
    totalItems.value = total;
    loading.value = false;
  });
}

// server side search
type SearchParams = {
  name?: string;
  calories?: string;
};
const FakeAPISEARCH = {
  async fetch({ page, itemsPerPage, sortBy, search }: { page: number; itemsPerPage: number; sortBy: SortItem[]; search: SearchParams }) {
    return new Promise<{ items: Dessert[]; total: number }>((resolve) => {
      setTimeout(() => {
        const start = (page - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        const items = desserts.slice().filter((item) => {
          if (search.name && !item.name.toLowerCase().includes(search.name.toLowerCase())) {
            return false;
          }
          if (search.calories && !(item.calories >= Number(search.calories))) {
            return false;
          }
          return true;
        });
        if (sortBy.length > 0) {
          const { key: sortKey, order: sortOrder } = sortBy[0]!;
          items.sort((a, b) => {
            const aValue = a[sortKey as keyof Dessert];
            const bValue = b[sortKey as keyof Dessert];
            return sortOrder === 'desc' ? Number(bValue) - Number(aValue) : Number(aValue) - Number(bValue);
          });
        }
        const paginated = items.slice(start, end === -1 ? undefined : end);
        resolve({ items: paginated, total: items.length });
      }, 500);
    });
  }
};
const searchitemsPerPage = ref(5);
const searchHeaders = ref([
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    sortable: false,
    key: 'name'
  },
  { title: 'Calories', key: 'calories', align: 'end' as const },
  { title: 'Fat (g)', key: 'fat', align: 'end' as const },
  { title: 'Carbs (g)', key: 'carbs', align: 'end' as const },
  { title: 'Protein (g)', key: 'protein', align: 'end' as const },
  { title: 'Iron (%)', key: 'iron', align: 'end' as const }
]);
const serverSearchItems = ref<Dessert[]>([]);
const loadingsearch = ref(true);
const searchTotalItems = ref(0);
const name = ref('');
const calories = ref('');
const searchTable = ref('');
function searchloadItems({ page, itemsPerPage, sortBy }: { page: number; itemsPerPage: number; sortBy: SortItem[] }) {
  loadingsearch.value = true;
  FakeAPISEARCH.fetch({
    page,
    itemsPerPage,
    sortBy,
    search: { name: name.value, calories: calories.value }
  }).then(({ items, total }) => {
    serverSearchItems.value = items;
    searchTotalItems.value = total;
    loadingsearch.value = false;
  });
}
watch(name, () => {
  searchTable.value = String(Date.now());
});
watch(calories, () => {
  searchTable.value = String(Date.now());
});
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiTableCard title="Server-side paginate and sort">
        <v-data-table-server
          v-model:items-per-page="itemsPerPage"
          :headers="headers"
          :items="serverItems"
          :items-length="totalItems"
          :loading="loading"
          :search="search"
          item-value="name"
          @update:options="loadItems"
          class="filter-table"
        ></v-data-table-server>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Server-side search">
        <v-data-table-server
          v-model:items-per-page="searchitemsPerPage"
          :headers="searchHeaders"
          :items="serverSearchItems"
          :items-length="searchTotalItems"
          :loading="loadingsearch"
          :search="searchTable"
          item-value="name"
          @update:options="searchloadItems"
          class="filter-table"
        >
          <template v-slot:tfoot>
            <tr>
              <td>
                <v-text-field v-model="name" class="ma-2" placeholder="Search name..." single-line hide-details></v-text-field>
              </td>
              <td>
                <v-text-field
                  v-model="calories"
                  class="ma-2"
                  placeholder="Minimum calories"
                  type="number"
                  single-line
                  hide-details
                ></v-text-field>
              </td>
            </tr>
          </template>
        </v-data-table-server>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Loading">
        <v-data-table-server :items-length="0" item-key="name" loading-text="Loading... Please wait" loading></v-data-table-server>
      </UiTableCard>
    </v-col>
  </v-row>
</template>
