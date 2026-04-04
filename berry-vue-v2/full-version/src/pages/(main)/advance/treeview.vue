<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';
import SearchFilter from '@/components/advance/treeview/SearchFilter.vue';
import TitleTreeview from '@/components/advance/treeview/TitleTreeview.vue';
import SelectionType from '@/components/advance/treeview/SelectionType.vue';
import LoadChildren from '@/components/advance/treeview/LoadChildren.vue';
import ToggleTreeview from '@/components/advance/treeview/ToggleTreeview.vue';
import SelectableIcon from '@/components/advance/treeview/SelectableIcon.vue';
import CustomizedTreeview from '@/components/advance/treeview/CustomizedTreeview.vue';

// theme breadcrumb
const page = ref({ title: 'Treeview' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Treeview',
    disabled: true,
    href: '#'
  }
]);

// common treeview data
const treeData = ref([
  {
    id: 1,
    title: 'Applications :',
    children: [
      { id: 2, title: 'Calendar : app' },
      { id: 3, title: 'Chrome : app' },
      { id: 4, title: 'Webstorm : app' }
    ]
  },
  {
    id: 5,
    title: 'Documents :',
    children: [
      {
        id: 6,
        title: 'vuetify :',
        children: [
          {
            id: 7,
            title: 'src :',
            children: [
              { id: 8, title: 'index : ts' },
              { id: 9, title: 'bootstrap : ts' }
            ]
          }
        ]
      },
      {
        id: 10,
        title: 'material2 :',
        children: [
          {
            id: 11,
            title: 'src :',
            children: [
              { id: 12, title: 'v-btn : ts' },
              { id: 13, title: 'v-card : ts' },
              { id: 14, title: 'v-window : ts' }
            ]
          }
        ]
      }
    ]
  },
  {
    id: 15,
    title: 'Downloads :',
    children: [
      { id: 16, title: 'October : pdf' },
      { id: 17, title: 'November : pdf' },
      { id: 18, title: 'Tutorial : html' }
    ]
  },
  {
    id: 19,
    title: 'Videos :',
    children: [
      {
        id: 20,
        title: 'Tutorials :',
        children: [
          { id: 21, title: 'Basic layouts : mp4' },
          { id: 22, title: 'Advanced techniques : mp4' },
          { id: 23, title: 'All about app : dir' }
        ]
      },
      { id: 24, title: 'Intro : mov' },
      { id: 25, title: 'Conference introduction : avi' }
    ]
  }
]);

// icon treeview data
const open = shallowRef(['public']);
const files = shallowRef<Record<string, string>>({
  html: '$languagehtml5',
  js: '$nodejs',
  json: '$codejson',
  md: '$languagemarkdown',
  pdf: '$filepdf',
  png: '$fileimage',
  txt: '$filedocumentoutline',
  xls: '$filexcel'
});

const items = [
  {
    title: '.git'
  },
  {
    title: 'node_modules'
  },
  {
    title: 'public',
    children: [
      {
        title: 'static',
        children: [
          {
            title: 'logo.png',
            file: 'png'
          }
        ]
      },
      {
        title: 'favicon.ico',
        file: 'png'
      },
      {
        title: 'index.html',
        file: 'html'
      }
    ]
  },
  {
    title: '.gitignore',
    file: 'txt'
  },
  {
    title: 'babel.config.js',
    file: 'js'
  },
  {
    title: 'package.json',
    file: 'json'
  },
  {
    title: 'README.md',
    file: 'md'
  },
  {
    title: 'vue.config.js',
    file: 'js'
  },
  {
    title: 'yarn.lock',
    file: 'txt'
  }
];

const denseopen = shallowRef([1, 19, 24, 25]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Treeview">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Basic">
              <v-treeview :items="treeData" item-value="id" />
            </UiChildCard>
          </v-col>
          <!-- Activatable -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Activatable">
              <v-treeview :items="treeData" item-value="id" activatable />
            </UiChildCard>
          </v-col>
          <!-- Color -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Color">
              <v-treeview :items="treeData" item-value="id" color="warning" activatable />
            </UiChildCard>
          </v-col>
          <!-- Dense mode -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Dense mode">
              <v-treeview v-model:opened="denseopen" :items="treeData" item-value="id" density="compact" activatable />
            </UiChildCard>
          </v-col>
          <!-- Append and prepend -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Append and prepend">
              <v-treeview v-model:opened="open" :items="items" density="compact" item-value="title" activatable open-on-click>
                <template v-slot:prepend="{ item, isOpen }">
                  <v-icon v-if="!item.file" :icon="isOpen ? '$folderopen' : '$folder'" />

                  <v-icon v-else :icon="files[item.file]" />
                </template>
              </v-treeview>
            </UiChildCard>
          </v-col>
          <!-- Search and filter -->
          <v-col cols="12" md="6" lg="4">
            <SearchFilter />
          </v-col>
          <!-- Open all -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Open all">
              <v-treeview :items="treeData" item-value="id" open-all></v-treeview>
            </UiChildCard>
          </v-col>
          <!-- Selected color -->
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Selected color">
              <v-treeview :items="treeData" item-value="id" selected-color="error" selectable open-all></v-treeview>
            </UiChildCard>
          </v-col>
          <!-- Title -->
          <v-col cols="12" md="6" lg="4">
            <TitleTreeview />
          </v-col>
          <!-- Selection type -->
          <v-col cols="12">
            <SelectionType />
          </v-col>
          <!-- Load children -->
          <v-col cols="12">
            <Suspense>
              <template #default>
                <LoadChildren />
              </template>
            </Suspense>
          </v-col>
          <!-- Toggle -->
          <v-col cols="12">
            <ToggleTreeview />
          </v-col>
          <v-col cols="12">
            <SelectableIcon />
          </v-col>
          <!-- Customized Treeview -->
          <v-col cols="12">
            <CustomizedTreeview />
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
