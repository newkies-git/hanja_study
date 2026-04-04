<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { MailIcon } from 'vue-tabler-icons';

// combo data
const items = ref([
  'The Dark Knight',
  'Control with Control',
  'Combo with Solo',
  'The Dark',
  'Fight Club',
  'demo@company.com',
  'Pulp Fiction'
]);
const items2 = ref([
  'The Dark Knight',
  'Control with Control',
  'Combo with Solo',
  'The Dark',
  'Fight Club',
  'demo@company.com',
  'Pulp Fiction'
]);

const items3 = [
  { type: 'subheader', title: 'Group 1' },
  { title: 'Item 1.1', value: 11 },
  { title: 'Item 1.2', value: 12 },
  { title: 'Item 1.3', value: 13 },
  { title: 'Item 1.4', value: 14 },
  { type: 'divider', text: 'or' },
  { type: 'subheader', title: 'Group 2' },
  { title: 'Item 2.1', value: 21 },
  { title: 'Item 2.2', value: 22 },
  { title: 'Item 2.3', value: 23 }
];

const srcs = {
  1: 'https://cdn.vuetifyjs.com/images/lists/1.jpg',
  2: 'https://cdn.vuetifyjs.com/images/lists/2.jpg',
  3: 'https://cdn.vuetifyjs.com/images/lists/3.jpg',
  4: 'https://cdn.vuetifyjs.com/images/lists/4.jpg',
  5: 'https://cdn.vuetifyjs.com/images/lists/5.jpg'
};

const people = ref([
  { name: 'Sandra Adams', group: 'Group 1', avatar: srcs[1] },
  { name: 'Ali Connors', group: 'Group 1', avatar: srcs[2] },
  { name: 'Trevor Hansen', group: 'Group 1', avatar: srcs[3] },
  { name: 'Tucker Smith', group: 'Group 1', avatar: srcs[2] },
  { name: 'Britta Holt', group: 'Group 2', avatar: srcs[4] },
  { name: 'Jane Smith ', group: 'Group 2', avatar: srcs[5] },
  { name: 'John Smith', group: 'Group 2', avatar: srcs[1] },
  { name: 'Sandra Williams', group: 'Group 2', avatar: srcs[3] }
]);

const value = ref('The Dark Knight');
const cap_value = ref('demo@company.com');
const cap_value2 = ref('demo@company.com');
const multi_value = ref(['The Dark Knight', 'Fight Club']);
const friends = ref(['Sandra Adams', 'Britta Holt']);
const isUpdating = ref(false);

// theme breadcrumb
const page = ref({ title: 'Autocomplete' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Autocomplete',
    disabled: true,
    href: '#'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Autocomplete">
        <v-row>
          <!-- Combo Box -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Combo Box">
              <v-autocomplete v-model="value" :items="items" color="primary" variant="outlined" hide-details />
            </UiChildCard>
          </v-col>
          <!-- Combo with Multiple Options -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Combo with Multiple Options">
              <v-autocomplete
                v-model="multi_value"
                :items="items2"
                variant="outlined"
                color="primary"
                label="Outlined"
                multiple
                hide-details
                closable-chips
              >
                <template #chip>
                  <v-chip label color="secondary" class="mb-1" />
                </template>
              </v-autocomplete>
            </UiChildCard>
          </v-col>
          <!-- With Caption -->
          <v-col cols="12" lg="4">
            <UiChildCard title="With Caption">
              <v-autocomplete v-model="cap_value" :items="items" color="primary" label="Email Address" variant="outlined" hide-details />

              <v-autocomplete
                v-model="cap_value2"
                :items="items"
                color="primary"
                label="Email Address"
                variant="outlined"
                hide-details
                class="mt-5"
              >
                <template #prepend-inner>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-autocomplete>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="Subheaders and dividers">
              <v-autocomplete
                :items="items3"
                label="Special items like in VList"
                variant="outlined"
                color="primary"
                chips
                multiple
                hide-details
              ></v-autocomplete>

              <v-autocomplete
                :items="items3"
                label="I have custom divider"
                variant="outlined"
                class="mt-5"
                color="primary"
                chips
                multiple
                hide-details
              >
                <template v-slot:divider="{ props }">
                  <div class="d-flex ga-4 align-center">
                    <v-divider></v-divider>
                    {{ props.text }}
                    <v-divider></v-divider>
                  </div>
                </template>
              </v-autocomplete>

              <v-autocomplete
                :items="items3"
                label="I have custom subheader"
                variant="outlined"
                class="mt-5"
                color="primary"
                chips
                multiple
                hide-details
              >
                <template v-slot:subheader="{ props }">
                  <v-list-subheader class="font-weight-bold bg-primary">{{ props.title }}</v-list-subheader>
                </template>
              </v-autocomplete>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <UiChildCard title="With options">
              <v-label class="text-label-small mb-1">Item and selection</v-label>
              <v-autocomplete
                aria-label="autocomplete"
                v-model="friends"
                :disabled="isUpdating"
                :items="people"
                chips
                variant="outlined"
                closable-chips
                item-title="name"
                item-value="name"
                class="remove-details"
                label="Select"
                color="secondary"
                single-line
                multiple
                hide-details
              >
                <template v-slot:chip="{ props, item }">
                  <v-chip v-bind="props" color="secondary" :prepend-avatar="item.avatar" :text="item.name"></v-chip>
                </template>

                <template v-slot:item="{ props, item }">
                  <v-list-item v-bind="props" :prepend-avatar="item?.avatar" :title="item?.name" :subtitle="item?.group"></v-list-item>
                </template>
              </v-autocomplete>
              <v-label class="text-label-small mt-5 mb-1">With close</v-label>
              <v-autocomplete
                clearable
                aria-label="autocomplete"
                clear-icon="$close"
                variant="outlined"
                label="Autocomplete"
                single-line
                color="primary"
                :items="['California', 'Colorado', 'Florida', 'Georgia', 'Texas', 'Wyoming']"
                hide-details
              ></v-autocomplete>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
