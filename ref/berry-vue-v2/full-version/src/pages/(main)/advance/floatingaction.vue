<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

import { CameraIcon, CircleCheckIcon, FileTextIcon, FilterIcon, Focus2Icon, UserIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Floating Action Buttons' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Floating Action',
    disabled: true,
    href: '#'
  }
]);

const hidden = ref(false);
const folders = shallowRef([
  {
    icon: CameraIcon,
    subtitle: 'Jan 9, 2024',
    title: 'Photos',
    color: 'warning'
  },
  {
    icon: FilterIcon,
    subtitle: 'Jan 7, 2024',
    title: 'Work',
    color: 'primary'
  },
  {
    icon: Focus2Icon,
    subtitle: 'July 20, 2024',
    title: 'Vacation',
    color: 'info'
  }
]);
const folders2 = shallowRef([
  {
    icon: FileTextIcon,
    subtitle: 'Jan 7, 2024',
    title: 'Vacation itinerary',
    color: 'primary'
  },
  {
    icon: CircleCheckIcon,
    subtitle: 'July 20, 2024',
    title: 'Kitchen remodel',
    color: 'info'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <v-row>
        <!-- Variant -->
        <v-col cols="12" md="6">
          <UiParentCard title="Basic variant">
            <div class="d-flex ga-2 align-start flex-wrap">
              <div style="min-width: 42px; height: 42px">
                <v-fab color="primary" icon>
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Default</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="outlined">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Outlined</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="tonal">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Tonal</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="flat">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Flat</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="text">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Text</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="plain">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">Plain</span>
                  </v-tooltip>
                </v-fab>
              </div>
            </div>
          </UiParentCard>
        </v-col>
        <!-- Size -->
        <v-col cols="12" md="6">
          <UiParentCard title="Size">
            <div class="d-flex ga-2 align-center" style="height: 58px">
              <div style="min-width: 58px; height: 58px">
                <v-fab icon color="primary" variant="tonal" size="x-large">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">x-large</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 50px; height: 50px">
                <v-fab icon color="primary" variant="tonal" size="large">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">large</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="primary" variant="tonal">
                  <UserIcon />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">default</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 34px; height: 34px">
                <v-fab icon color="primary" variant="tonal" size="small">
                  <UserIcon size="14" />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">small</span>
                  </v-tooltip>
                </v-fab>
              </div>
              <div style="min-width: 26px; height: 26px">
                <v-fab icon color="primary" variant="tonal" size="x-small">
                  <UserIcon size="14" />
                  <v-tooltip activator="parent" aria-label="tooltip" location="bottom" content-class="smallTooltip">
                    <span class="text-label-small">x-small</span>
                  </v-tooltip>
                </v-fab>
              </div>
            </div>
          </UiParentCard>
        </v-col>
        <v-col cols="12">
          <UiParentCard title="Color">
            <div class="d-flex ga-2 align-start flex-wrap">
              <div style="min-width: 42px; height: 42px">
                <v-fab color="primary" variant="flat" icon><UserIcon /></v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="secondary" variant="flat"><UserIcon /></v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="success" variant="flat"><UserIcon /></v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="warning" variant="flat"><UserIcon /></v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="info" variant="flat"><UserIcon /></v-fab>
              </div>
              <div style="min-width: 42px; height: 42px">
                <v-fab icon color="error" variant="flat"><UserIcon /></v-fab>
              </div>
            </div>
          </UiParentCard>
        </v-col>
        <!-- Display Animation -->
        <v-col cols="12" md="6">
          <UiParentCard title="Display animation">
            <v-card class="mx-auto overflow-hidden" variant="outlined" max-width="360">
              <v-layout>
                <v-app-bar absolute color="surface" extended>
                  <v-app-bar-nav-icon />

                  <template v-slot:extension>
                    <v-fab
                      :active="!hidden"
                      color="primary"
                      class="ml-4"
                      icon="$plus"
                      location="bottom start"
                      size="small"
                      absolute
                      offset
                    />
                  </template>
                </v-app-bar>

                <v-main style="margin: 0">
                  <v-sheet class="pa-4 text-center" color="containerBg" height="300">
                    <v-btn :text="hidden ? 'Show' : 'Hide'" color="surface-variant" width="80" @click="hidden = !hidden" />
                  </v-sheet>

                  <v-sheet height="125">
                    <v-fab :active="!hidden" class="mr-4" color="primary" icon="$plus" location="top end" absolute offset />
                  </v-sheet>
                </v-main>
              </v-layout>
            </v-card>
          </UiParentCard>
        </v-col>
        <!-- Small variant -->
        <v-col cols="12" md="6">
          <UiParentCard title="Small variant">
            <v-card class="mx-auto overflow-hidden" variant="outlined" max-width="365">
              <v-toolbar color="containerBg" extended light>
                <v-app-bar-nav-icon color="grey-darken-4" />

                <v-toolbar-title>My files</v-toolbar-title>

                <v-spacer />

                <v-btn color="grey-darken-4" icon="$magnify" />

                <template v-slot:extension>
                  <v-fab class="ml-4" color="primary" icon="$plus" location="bottom left" size="40" absolute offset></v-fab>
                </template>
              </v-toolbar>

              <v-list lines="two" subheader aria-label="list" aria-busy="true">
                <v-list-subheader title="Folders" inset />

                <v-list-item v-for="folder in folders" :key="folder.title" :subtitle="folder.subtitle">
                  <template v-slot:prepend>
                    <v-avatar
                      size="40"
                      :color="folder.color"
                      :class="`text-${folder.color} border-solid border-${folder.color} border-thin border-opacity-100`"
                      variant="tonal"
                    >
                      <component :is="folder.icon" size="18" />
                    </v-avatar>
                  </template>

                  <template v-slot:title>
                    <h6 class="mb-0">{{ folder.title }}</h6>
                  </template>
                  <template v-slot:subtitle>
                    <span class="text-body-small">{{ folder.subtitle }}</span>
                  </template>
                </v-list-item>

                <v-divider inset />

                <v-list-subheader title="Files" inset></v-list-subheader>

                <v-list-item v-for="folder in folders2" :key="folder.title" :subtitle="folder.subtitle">
                  <template v-slot:prepend>
                    <v-avatar
                      size="40"
                      :color="folder.color"
                      :class="`text-${folder.color} border-solid border-${folder.color} border-thin border-opacity-100`"
                      variant="tonal"
                    >
                      <component :is="folder.icon" size="18" />
                    </v-avatar>
                  </template>

                  <template v-slot:title>
                    <h6 class="mb-0">{{ folder.title }}</h6>
                  </template>
                  <template v-slot:subtitle>
                    <span class="text-body-small">{{ folder.subtitle }}</span>
                  </template>
                </v-list-item>
              </v-list>
            </v-card>
          </UiParentCard>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>
