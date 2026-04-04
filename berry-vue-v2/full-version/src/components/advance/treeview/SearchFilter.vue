<script setup lang="ts">
import { shallowRef } from 'vue';
// common components
import UiChildCard from '@/components/shared/UiChildCard.vue';

// filter data
const filteritems = [
  {
    id: 1,
    title: 'Vuetify Human Resources',
    children: [
      {
        id: 2,
        title: 'Core team',
        children: [
          {
            id: 201,
            title: 'John'
          },
          {
            id: 202,
            title: 'Kael'
          },
          {
            id: 203,
            title: 'Nekosaur'
          },
          {
            id: 204,
            title: 'Jacek'
          },
          {
            id: 205,
            title: 'Andrew'
          }
        ]
      },
      {
        id: 3,
        title: 'Administrators',
        children: [
          {
            id: 301,
            title: 'Blaine'
          },
          {
            id: 302,
            title: 'Yuchao'
          }
        ]
      },
      {
        id: 4,
        title: 'Contributors',
        children: [
          {
            id: 401,
            title: 'Phlow'
          },
          {
            id: 402,
            title: 'Brandon'
          },
          {
            id: 403,
            title: 'Sean'
          }
        ]
      }
    ]
  }
];
const filteropen = shallowRef([1, 2]);
const search = shallowRef<string | undefined>('');
const caseSensitive = shallowRef(false);

function filter(value: string, search: string) {
  return caseSensitive.value ? value.indexOf(search) > -1 : value.toLowerCase().indexOf(search.toLowerCase()) > -1;
}
</script>

<template>
  <UiChildCard title="Search and filter">
    <v-card class="mx-auto overflow-hidden" variant="outlined" rounded="sm" max-width="500">
      <v-sheet class="pa-4" color="gray100">
        <v-text-field
          v-model="search"
          clear-icon="$closecircleoutline"
          label="Search Company Directory"
          variant="outlined"
          clearable
          flat
          rounded="0"
          hide-details
        />

        <v-checkbox-btn v-model="caseSensitive" class="mt-2" density="compact" label="Case sensitive search" />
      </v-sheet>

      <v-treeview v-model:opened="filteropen" :custom-filter="filter" :items="filteritems" :search="search" item-value="id" open-on-click>
        <template v-slot:prepend="{ item }">
          <v-icon v-if="item.children" :icon="`${item.id === 1 ? '$homevariant' : '$foldernetwork'}`" />
        </template>
      </v-treeview>
    </v-card>
  </UiChildCard>
</template>
