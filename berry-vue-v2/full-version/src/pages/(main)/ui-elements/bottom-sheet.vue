<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Bottom sheet' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Bottom sheet',
    disabled: true,
    href: '#'
  }
]);

const sheet = shallowRef(false);
const insetSheet = shallowRef(false);
const listSheet = shallowRef(false);
const tiles = [
  { img: 'keep.png', title: 'Keep' },
  { img: 'inbox.png', title: 'Inbox' },
  { img: 'hangouts.png', title: 'Hangouts' },
  { img: 'messenger.png', title: 'Messenger' },
  { img: 'google.png', title: 'Google+' }
];
</script>

// ===============================|| Ui Bottom sheets ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Bottom sheet">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" sm="6">
            <UiChildCard title="Basic">
              <v-bottom-sheet>
                <template v-slot:activator="{ props: activatorProps }">
                  <div class="text-center">
                    <v-btn v-bind="activatorProps" variant="flat" color="primary" text="Click Me"></v-btn>
                  </div>
                </template>

                <v-card
                  rounded="0"
                  title="Bottom Sheet"
                  text="Lorem ipsum dolor sit amet consectetur, adipisicing elit. Ut, eos? Nulla aspernatur odio rem, culpa voluptatibus eius debitis dolorem perspiciatis asperiores sed consectetur praesentium! Delectus et iure maxime eaque exercitationem!"
                ></v-card>
              </v-bottom-sheet>
            </UiChildCard>
          </v-col>
          <!-- Model -->
          <v-col cols="12" sm="6">
            <UiChildCard title="Model">
              <div class="text-center">
                <v-btn variant="flat" color="primary" text="Click Me" @click="sheet = !sheet"></v-btn>
              </div>

              <v-bottom-sheet v-model="sheet">
                <v-card class="text-center" rounded="0">
                  <v-card-text>
                    <v-btn text="Close" variant="text" @click="sheet = !sheet"></v-btn>

                    <br />
                    <br />

                    <div>This is a bottom sheet using the controlled by v-model instead of activator</div>
                  </v-card-text>
                </v-card>
              </v-bottom-sheet>
            </UiChildCard>
          </v-col>
          <!-- Inset -->
          <v-col cols="12" sm="6">
            <UiChildCard title="Inset">
              <div class="text-center">
                <v-btn variant="flat" color="secondary" text="Click Me" @click="insetSheet = !insetSheet"></v-btn>
              </div>

              <v-bottom-sheet v-model="insetSheet" inset>
                <v-card class="text-center">
                  <v-card-text>
                    <v-btn text="Close" variant="text" @click="insetSheet = !insetSheet"></v-btn>

                    <br />
                    <br />

                    <div>This is a bottom sheet that is using the inset prop</div>
                  </v-card-text>
                </v-card>
              </v-bottom-sheet>
            </UiChildCard>
          </v-col>
          <v-col cols="12" sm="6">
            <UiChildCard title="Music Player">
              <v-bottom-sheet inset>
                <template v-slot:activator="{ props: activatorProps }">
                  <div class="text-center">
                    <v-btn v-bind="activatorProps" color="success" text="Click Me"></v-btn>
                  </div>
                </template>

                <v-sheet>
                  <v-progress-linear model-value="50"></v-progress-linear>

                  <v-list>
                    <v-list-item subtitle="Fitz & The Trantrums" title="The Walker">
                      <template v-slot:append>
                        <div class="d-flex ga-1">
                          <v-btn icon="$rewind" variant="text"></v-btn>

                          <v-btn icon="$pause" variant="text"></v-btn>

                          <v-btn icon="$fastforward" variant="text"></v-btn>
                        </div>
                      </template>
                    </v-list-item>
                  </v-list>
                </v-sheet>
              </v-bottom-sheet>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Open In List">
              <v-bottom-sheet v-model="listSheet">
                <template v-slot:activator="{ props: activatorProps }">
                  <div class="text-center">
                    <v-btn v-bind="activatorProps" variant="flat" color="warning" text="Click Me"></v-btn>
                  </div>
                </template>

                <v-list>
                  <v-list-subheader title="Open in"></v-list-subheader>

                  <v-list-item v-for="tile in tiles" :key="tile.title" :title="tile.title" @click="listSheet = false">
                    <template v-slot:prepend>
                      <v-avatar rounded="0" variant="text">
                        <v-img :src="`https://cdn.vuetifyjs.com/images/bottom-sheets/${tile.img}`" :alt="tile.title" />
                      </v-avatar> </template
                  ></v-list-item>
                </v-list>
              </v-bottom-sheet>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
