<script setup lang="ts">
import { ref, shallowRef, onMounted, computed } from 'vue';

// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiTableCard from '@/components/shared/UiTableCard.vue';

// import data from commons file
import {
  items,
  headers,
  headertable,
  densityHeaders,
  plants,
  hideTable,
  desserts,
  selectionItems,
  groupheaders,
  groupdesserts,
  DEFAULT_HEADERS,
  headerDesserts,
  slotHeaders,
  employees,
  vegetableheaders,
  vegetableitems,
  toolheaders,
  tools,
  groupSummaryHeaders,
  loadingitems,
  actionHeaders,
  initialBooks,
  genreOptions,
  expandableHeaders,
  movies
} from '@/data/tableData';

// theme breadcrumb
const page = ref({ title: 'Data Tables' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Data Tables',
    disabled: true,
    href: '#'
  }
]);

const selected = ref([]);
const headerSlot = ref(DEFAULT_HEADERS());
const sortByRef = ref([{ key: 'name', order: 'asc' as const }]);
const groupByRef = ref([{ key: 'category', order: 'asc' as const }]);
const toolGroupByRef = ref([{ key: 'type', order: 'asc' as const }]);

function onClickReset() {
  headerSlot.value = DEFAULT_HEADERS();
}

function remove(key: string) {
  headerSlot.value = headerSlot.value.filter((header) => header.key !== key);
}

function getColor(calories: number) {
  if (calories > 100) return 'error';
  else if (calories > 50) return 'warning';
  else return 'success';
}

// loading table
const loading = shallowRef(false);

function onClick() {
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
  }, 2000);
}

// crud actions table
const currentYear = new Date().getFullYear();

interface Book {
  id?: number;
  title: string;
  author: string;
  genre: string;
  year: number;
  pages: number;
}

function createNewRecord(): Book {
  return {
    title: '',
    author: '',
    genre: '',
    year: currentYear,
    pages: 1
  };
}

const books = ref<Book[]>([]);
const formModel = ref<Book>(createNewRecord());
const dialog = shallowRef(false);
const isEditing = computed(() => !!formModel.value.id);

onMounted(() => {
  reset();
});

function add() {
  formModel.value = createNewRecord();
  dialog.value = true;
}

function edit(id: number) {
  const found = books.value.find((book) => book.id === id);
  if (!found) return;

  formModel.value = {
    id: found.id,
    title: found.title,
    author: found.author,
    genre: found.genre,
    year: found.year,
    pages: found.pages
  };

  dialog.value = true;
}

function actionRemove(id: number) {
  const index = books.value.findIndex((book) => book.id === id);
  if (index !== -1) {
    books.value.splice(index, 1);
  }
}

function save() {
  if (isEditing.value) {
    const index = books.value.findIndex((book) => book.id === formModel.value.id);
    if (index !== -1) {
      books.value[index] = { ...formModel.value };
    }
  } else {
    const newId = books.value.length > 0 ? Math.max(...books.value.filter((b) => b.id).map((b) => b.id!)) + 1 : 1;
    books.value.push({ ...formModel.value, id: newId });
  }

  dialog.value = false;
}

// reset table
function reset() {
  dialog.value = false;
  formModel.value = createNewRecord();
  books.value = [...initialBooks];
}
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiTableCard title="Default">
        <v-data-table :items="items"></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Headers">
        <v-data-table :headers="headers" :items="headertable" item-key="name" hide-default-footer></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Density">
        <v-data-table :headers="densityHeaders" :items="plants" density="compact" item-key="name"></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Hide default header and footer">
        <v-data-table :headers="hideTable" :items="desserts" hide-default-footer hide-default-header></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Selection">
        <v-data-table v-model="selected" :items="selectionItems" item-value="name" show-select></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Group by">
        <v-data-table
          :group-by="groupByRef"
          :headers="groupheaders"
          :items="groupdesserts"
          :sort-by="sortByRef"
          item-value="name"
        ></v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Headers slot">
        <v-data-table :headers="headerSlot" :items="headerDesserts" item-value="name" items-per-page="5" hover>
          <template #top>
            <v-expand-transition>
              <div v-if="headers.length < 6">
                <div class="pa-4">
                  <v-btn size="small" text="Reset" variant="outlined" color="primary" border @click="onClickReset"></v-btn>
                </div>

                <v-divider></v-divider>
              </div>
            </v-expand-transition>
          </template>

          <template #headers="{ columns, isSorted, getSortIcon, toggleSort }">
            <tr>
              <template v-for="column in columns" :key="column.key ?? undefined">
                <th>
                  <div class="d-flex align-center">
                    <span class="me-2 cursor-pointer" @click="toggleSort(column)" v-text="column.title"></span>

                    <v-icon v-if="isSorted(column)" :icon="getSortIcon(column)" color="medium-emphasis"></v-icon>

                    <v-icon
                      v-if="(column as any).removable"
                      color="medium-emphasis"
                      icon="$close"
                      @click="column.key && remove(column.key)"
                    ></v-icon>
                  </div>
                </th>
              </template>
            </tr>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Item slot">
        <v-data-table
          :headers="slotHeaders"
          :items="employees"
          class="text-label-small"
          density="compact"
          item-value="name"
          hide-default-footer
          hover
        >
          <template #item="{ item }">
            <tr class="text-no-wrap">
              <td>{{ item.id }}</td>
              <td>{{ item.name }}</td>
              <td>{{ item.department }}</td>
              <td>{{ item.role }}</td>
              <td
                :class="{
                  'text-end': true,
                  'bg-success': item.salary > 80000,
                  'bg-warning': item.salary > 70000 && item.salary <= 80000,
                  'bg-error': item.salary <= 70000
                }"
                v-text="`$${item.salary.toLocaleString()}`"
              ></td>
              <td>{{ item.hireDate }}</td>
              <td class="text-end">{{ item.hoursPerWeek }}</td>
              <td>{{ item.location }}</td>
              <td>{{ item.status }}</td>
              <td class="text-end">
                <v-chip :text="item.score.toFixed(2)" append-icon="$openInNew" size="x-small" href="#!"></v-chip>
              </td>
            </tr>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Item key slot">
        <v-data-table :headers="vegetableheaders" :items="vegetableitems">
          <template #[`item.calories`]="{ value }">
            <v-chip :border="`${getColor(value)} thin opacity-25`" :color="getColor(value)" :text="value" size="x-small"></v-chip>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Group header slot">
        <v-data-table
          :group-by="toolGroupByRef"
          :headers="toolheaders"
          :items="tools"
          :items-per-page="-1"
          item-value="name"
          hide-default-footer
        >
          <template #group-header="{ item, columns, toggleGroup, isGroupOpen }">
            <tr>
              <td :colspan="columns.length" class="cursor-pointer" v-ripple @click="toggleGroup(item)">
                <div class="d-flex align-center">
                  <v-btn
                    :icon="isGroupOpen(item) ? '$expand' : '$next'"
                    color="medium-emphasis"
                    density="comfortable"
                    size="small"
                    variant="outlined"
                  ></v-btn>

                  <span class="ms-4">Tool Type: {{ item.value }}</span>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Group summary slot">
        <v-data-table
          :group-by="toolGroupByRef"
          :headers="groupSummaryHeaders"
          :items="tools"
          :items-per-page="-1"
          item-value="name"
          hide-default-footer
        >
          <template #group-summary="{ item, columns }">
            <tr class="font-weight-bold text-error">
              <td
                v-for="(c, index) in columns"
                :key="c.key || index"
                :class="['v-data-table__td', c.align ? `v-data-table-column--align-${c.align}` : '']"
              >
                <span v-if="c.key === 'name'">Totals</span>
                <span v-if="c.key === 'weight'">{{ item.items.reduce((sum, n) => sum + n.raw.weight, 0) }}</span>
                <span v-if="c.key === 'length'">{{ item.items.reduce((sum, n) => sum + n.raw.length, 0) }}</span>
                <span v-if="c.key === 'price'">{{ item.items.reduce((sum, n) => sum + n.raw.price, 0) }}</span>
              </td>
            </tr>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Loading slot">
        <div class="text-center my-4">
          <v-btn
            :disabled="loading"
            prepend-icon="$refresh"
            text="Refresh"
            variant="text"
            color="secondary"
            border
            @click="onClick"
          ></v-btn>
        </div>

        <v-sheet border rounded>
          <v-data-table :items="loadingitems" :loading="loading">
            <template #loading>
              <v-skeleton-loader type="table-row@10"></v-skeleton-loader>
            </template>

            <template #[`item.horsepower`]="{ value }">
              <div class="text-medium-emphasis">
                <span>{{ value }}</span>

                <v-icon icon="$horseVariantFast" end></v-icon>
              </div>
            </template>

            <template #[`item.torque`]="{ value }">
              <div class="text-medium-emphasis">
                <span>{{ value }}</span>

                <v-icon icon="$tire" end></v-icon>
              </div>
            </template>
          </v-data-table>
        </v-sheet>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="CRUD Actions">
        <v-sheet border rounded>
          <v-data-table :headers="actionHeaders" :hide-default-footer="books.length < 11" :items="books">
            <template #top>
              <v-toolbar color="containerBg" flat>
                <v-toolbar-title>
                  <v-icon color="medium-emphasis" icon="$bookMultipleOutline" size="x-small" start></v-icon>

                  Popular books
                </v-toolbar-title>

                <v-btn class="me-5" prepend-icon="$plus" text="Add a Book" variant="outlined" color="primary" @click="add"></v-btn>
              </v-toolbar>
            </template>

            <template #[`item.title`]="{ value }">
              <v-chip :text="value" border="primary thin opacity-25" color="primary" prepend-icon="$bookOutline" label>
                <template #prepend>
                  <v-icon></v-icon>
                </template>
              </v-chip>
            </template>

            <template #[`item.actions`]="{ item }">
              <div class="d-flex ga-2 justify-end">
                <v-icon color="success" variant="text" icon="$pencilOutline" size="small" @click="item.id && edit(item.id)"></v-icon>

                <v-icon color="error" variant="text" icon="$deleteOutline" size="small" @click="item.id && actionRemove(item.id)"></v-icon>
              </div>
            </template>

            <template #no-data>
              <v-btn prepend-icon="$backupRestore" text="Reset data" variant="outlined" color="primary" @click="reset"></v-btn>
            </template>
          </v-data-table>
        </v-sheet>

        <v-dialog v-model="dialog" max-width="500">
          <v-card :subtitle="`${isEditing ? 'Update' : 'Create'} your favorite book`" :title="`${isEditing ? 'Edit' : 'Add'} a Book`">
            <v-card-actions class="pt-4">
              <v-row>
                <v-col cols="12">
                  <v-text-field v-model="formModel.title" variant="outlined" label="Title"></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-text-field v-model="formModel.author" variant="outlined" label="Author"></v-text-field>
                </v-col>

                <v-col cols="12" md="6">
                  <v-select v-model="formModel.genre" variant="outlined" :items="genreOptions" label="Genre"></v-select>
                </v-col>

                <v-col cols="12" md="6">
                  <v-number-input v-model="formModel.year" :max="currentYear" :min="1" variant="outlined" label="Year"></v-number-input>
                </v-col>

                <v-col cols="12" md="6">
                  <v-number-input v-model="formModel.pages" :min="1" variant="outlined" label="Pages"></v-number-input>
                </v-col>
              </v-row>
            </v-card-actions>

            <v-divider></v-divider>

            <v-card-actions class="pt-4">
              <v-btn text="Save" variant="flat" color="primary" @click="save"></v-btn>
              <v-btn text="Cancel" variant="flat" color="error" @click="dialog = false"></v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </UiTableCard>
    </v-col>
    <v-col cols="12">
      <UiTableCard title="Expandable rows">
        <v-data-table :headers="expandableHeaders" :items="movies" item-value="title" hide-default-footer show-expand>
          <template #[`item.data-table-expand`]="{ internalItem, isExpanded, toggleExpand }">
            <v-btn
              :append-icon="isExpanded(internalItem) ? '$chevronUp' : '$chevronDown'"
              :text="isExpanded(internalItem) ? 'Collapse' : 'More info'"
              class="text-none"
              color="medium-emphasis"
              size="small"
              variant="text"
              width="105"
              border
              slim
              @click="toggleExpand(internalItem)"
            ></v-btn>
          </template>

          <template #expanded-row="{ columns, item }">
            <tr>
              <td :colspan="columns.length" class="py-2">
                <v-sheet rounded="sm" border>
                  <v-table density="compact">
                    <tbody class="bg-containerBg">
                      <tr>
                        <th>Rating</th>
                        <th>Synopsis</th>
                        <th>Cast</th>
                      </tr>
                    </tbody>

                    <tbody>
                      <tr>
                        <td class="py-2">
                          <v-rating
                            :model-value="item.details.rating"
                            color="warning"
                            density="comfortable"
                            size="small"
                            half-increments
                            readonly
                          ></v-rating>
                        </td>
                        <td class="py-2">{{ item.details.synopsis }}</td>
                        <td class="py-2">{{ item.details.cast.join(', ') }}</td>
                      </tr>
                    </tbody>
                  </v-table>
                </v-sheet>
              </td>
            </tr>
          </template>
        </v-data-table>
      </UiTableCard>
    </v-col>
  </v-row>
</template>
