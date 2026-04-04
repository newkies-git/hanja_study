<script setup lang="ts">
import { shallowRef } from 'vue';
// common components
import UiChildCard from '@/components/shared/UiChildCard.vue';

// customized treeview
const separateRoots = shallowRef(false);
const actionIcons = shallowRef(true);
const prependIcons = shallowRef(true);
const indentLines = shallowRef(true);

const customizefiles = shallowRef<Record<string, string>>({
  html: '$languagehtml5',
  js: '$nodejs',
  pdf: '$filepdf',
  png: '$fileimage',
  mov: '$videoOutline',
  mp4: '$videoOutline'
});

function getIcon(item: { title: string; children?: unknown }, isOpen: boolean): string {
  if (item.children) return isOpen ? '$folderopen' : '$folder';
  const parts = item.title.split('.');
  const ext = parts[parts.length - 1];
  return customizefiles.value[ext ?? ''] ?? '$fileoutline';
}

const items1 = [
  {
    id: 5,
    title: 'Documents',
    children: [
      {
        id: 6,
        title: 'vuetify',
        children: [
          {
            id: 7,
            title: 'src',
            children: [{ id: 8, title: 'index.js' }]
          }
        ]
      },
      {
        id: 101,
        title: 'material1',
        children: [
          {
            id: 111,
            title: 'src',
            children: [
              { id: 112, title: 'v-chip.js' },
              { id: 113, title: 'v-slider.js' }
            ]
          }
        ]
      },
      {
        id: 10,
        title: 'material2',
        children: [
          {
            id: 11,
            title: 'src',
            children: [
              { id: 12, title: 'v-btn.js' },
              { id: 13, title: 'v-card.js' },
              { id: 14, title: 'v-window.js' }
            ]
          }
        ]
      }
    ]
  }
];

const items2 = [
  {
    id: 115,
    title: 'Documents',
    children: [
      {
        id: 116,
        title: 'Financial',
        children: [{ id: 17, title: 'November.pdf' }]
      },
      {
        id: 117,
        title: 'Taxes',
        children: [
          { id: 118, title: 'December.pdf' },
          { id: 119, title: 'January.pdf' }
        ]
      },
      {
        id: 120,
        title: 'Later',
        children: [{ id: 121, title: 'Company logo.png' }]
      }
    ]
  },
  {
    id: 15,
    title: 'Downloads',
    children: [
      { id: 16, title: '2022-03-01 Report.pdf' },
      { id: 18, title: 'Tutorial.html' }
    ]
  },
  {
    id: 19,
    title: 'Videos',
    children: [
      {
        id: 20,
        title: 'Tutorials',
        children: [
          { id: 21, title: 'Basic layouts.mp4' },
          { id: 23, title: 'Empty folder', children: [] },
          { id: 22, title: 'Advanced techniques.mp4' }
        ]
      },
      { id: 24, title: 'Intro.mov' },
      { id: 25, title: 'Conference introduction.mov' }
    ]
  }
];
</script>

<template>
  <UiChildCard title="Customized Treeview">
    <v-sheet class="px-sm-6 px-3 py-2 border-b" color="surface">
      <div class="d-flex gx-3 flex-wrap">
        <div class="d-flex align-center ga-3">
          <span class="mr-3">Lines:</span>
          <v-chip-group v-model="indentLines" column>
            <v-chip :value="false" text="none" filter label />
            <v-chip :value="true" text="default" filter label />
            <v-chip text="simple" value="simple" filter label />
          </v-chip-group>
        </div>
        <v-spacer class="d-md-block d-none" />
        <div class="d-flex align-center ga-md-6 ga-sm-4 ga-1 flex-wrap">
          <v-switch v-model="actionIcons" color="success" density="comfortable" label="action icons" hide-details />
          <v-switch v-model="prependIcons" color="success" density="comfortable" label="prepend icons" hide-details />
          <v-switch
            v-model="separateRoots"
            :disabled="indentLines !== true"
            color="success"
            density="comfortable"
            label="separate roots"
            hide-details
          />
        </div>
      </div>
    </v-sheet>
    <v-row class="justify-center ga-lg-8 pt-4" fluid>
      <v-col cols="12" lg="4" md="6">
        <v-treeview
          :hide-actions="!actionIcons"
          :indent-lines="indentLines"
          :items="items1"
          :separate-roots="separateRoots"
          density="compact"
          item-value="id"
          max-width="400"
          open-all
          open-on-click
        >
          <template v-if="prependIcons" v-slot:prepend="{ item, isOpen }">
            <v-icon :icon="getIcon(item, isOpen)" />
          </template>
        </v-treeview>
      </v-col>

      <v-col cols="12" lg="4" md="6">
        <v-treeview
          :hide-actions="!actionIcons"
          :indent-lines="indentLines"
          :items="items2"
          :separate-roots="separateRoots"
          density="compact"
          item-value="id"
          open-all
          open-on-click
        >
          <template v-if="prependIcons" v-slot:prepend="{ item, isOpen }">
            <v-icon :icon="getIcon(item, isOpen)" />
          </template>
        </v-treeview>
      </v-col>
    </v-row>
  </UiChildCard>
</template>
