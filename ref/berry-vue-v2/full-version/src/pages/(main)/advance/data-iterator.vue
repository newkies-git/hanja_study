<script setup lang="ts">
import { ref, shallowRef } from 'vue';

// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

import { ClockHour3Icon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Data Iterators' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Data Iterators',
    disabled: true,
    href: '#'
  }
]);

const itemsPerPage = shallowRef(4);
const mice = [
  {
    name: 'Logitech G Pro X',
    color: '14, 151, 210',
    dpi: 16000,
    buttons: 8,
    weight: '63g',
    wireless: true,
    price: 149.99,
    description: 'Logitech G Pro X',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/3.png'
  },
  {
    name: 'Razer DeathAdder V2',
    color: '12, 146, 47',
    dpi: 20000,
    buttons: 8,
    weight: '82g',
    wireless: false,
    price: 69.99,
    description: 'Razer DeathAdder V2',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/2.png'
  },
  {
    name: 'Corsair Dark Core RGB',
    color: '107, 187, 226',
    dpi: 18000,
    buttons: 9,
    weight: '133g',
    wireless: true,
    price: 89.99,
    description: 'Corsair Dark Core RGB',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/1.png'
  },
  {
    name: 'SteelSeries Rival 3',
    color: '228, 196, 69',
    dpi: 8500,
    buttons: 6,
    weight: '77g',
    wireless: false,
    price: 29.99,
    description: 'SteelSeries Rival 3',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/4.png'
  },
  {
    name: 'HyperX Pulsefire FPS Pro',
    color: '156, 82, 251',
    dpi: 16000,
    buttons: 6,
    weight: '95g',
    wireless: false,
    price: 44.99,
    description: 'HyperX Pulsefire FPS Pro',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/6.png'
  },
  {
    name: 'Zowie EC2',
    color: '166, 39, 222',
    dpi: 3200,
    buttons: 5,
    weight: '90g',
    wireless: false,
    price: 69.99,
    description: 'Zowie EC2',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/7.png'
  },
  {
    name: 'Roccat Kone AIMO',
    color: '131, 9, 10',
    dpi: 16000,
    buttons: 10,
    weight: '130g',
    wireless: false,
    price: 79.99,
    description: 'Roccat Kone AIMO',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/8.png'
  },
  {
    name: 'Logitech G903',
    color: '232, 94, 102',
    dpi: 12000,
    buttons: 11,
    weight: '110g',
    wireless: true,
    price: 129.99,
    description: 'Logitech G903',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/9.png'
  },
  {
    name: 'Cooler Master MM711',
    color: '58, 192, 239',
    dpi: 16000,
    buttons: 6,
    weight: '60g',
    wireless: false,
    price: 49.99,
    description: 'Cooler Master MM711',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/5.png'
  },
  {
    name: 'Glorious Model O',
    color: '161, 252, 250',
    dpi: 12000,
    buttons: 6,
    weight: '67g',
    wireless: false,
    price: 49.99,
    description: 'Glorious Model O',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/15.png'
  },
  {
    name: 'HP Omen Photon',
    color: '201, 1, 2',
    dpi: 16000,
    buttons: 11,
    weight: '128g',
    wireless: true,
    price: 99.99,
    description: 'HP Omen Photon',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/10.png'
  },
  {
    name: 'Asus ROG Chakram',
    color: '10, 181, 19',
    dpi: 16000,
    buttons: 9,
    weight: '121g',
    wireless: true,
    price: 159.99,
    description: 'Asus ROG Chakram',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/11.png'
  },
  {
    name: 'Razer Naga X',
    color: '100, 101, 102',
    dpi: 16000,
    buttons: 16,
    weight: '85g',
    wireless: false,
    price: 79.99,
    description: 'Razer Naga X',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/12.png'
  },
  {
    name: 'Mad Catz R.A.T. 8+',
    color: '136, 241, 242',
    dpi: 16000,
    buttons: 11,
    weight: '145g',
    wireless: false,
    price: 99.99,
    description: 'Mad Catz R.A.T. 8+',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/13.png'
  },
  {
    name: 'Alienware 610M',
    color: '109, 110, 114',
    dpi: 16000,
    buttons: 7,
    weight: '120g',
    wireless: true,
    price: 99.99,
    description: 'Alienware 610M',
    src: 'https://cdn.vuetifyjs.com/docs/images/graphics/mice/14.png'
  }
];

function onClickSeeAll() {
  itemsPerPage.value = itemsPerPage.value === 4 ? mice.length : 4;
}

const search = shallowRef('');
const games = [
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/4.png',
    title: 'The Sci-Fi Shooter Experience',
    subtitle: 'Dive into a futuristic world of intense battles and alien encounters.',
    advanced: false,
    duration: '8 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/2.png',
    title: 'Epic Adventures in Open Worlds',
    subtitle: 'Embark on a journey through vast, immersive landscapes and quests.',
    advanced: true,
    duration: '10 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/3.png',
    title: 'Surviving the Space Station Horror',
    subtitle: 'Navigate a haunted space station in this chilling survival horror game.',
    advanced: false,
    duration: '9 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/5.png',
    title: 'Neon-Lit High-Speed Racing Thrills',
    subtitle: 'Experience adrenaline-pumping races in a futuristic, neon-soaked city.',
    advanced: true,
    duration: '12 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/6.png',
    title: 'Retro-Style Platformer Adventures',
    subtitle: 'Jump and dash through pixelated worlds in this classic-style platformer.',
    advanced: false,
    duration: '11 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/7.png',
    title: 'Medieval Strategic War Campaigns',
    subtitle: 'Lead armies into epic battles and conquer kingdoms in this strategic war game.',
    advanced: true,
    duration: '10 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/1.png',
    title: 'Underwater VR Exploration Adventure',
    subtitle: 'Dive deep into the ocean and discover the mysteries of the underwater world.',
    advanced: true,
    duration: '11 minutes'
  },
  {
    img: 'https://cdn.vuetifyjs.com/docs/images/graphics/games/8.png',
    title: '1920s Mystery Detective Chronicles',
    subtitle: 'Solve crimes and uncover secrets in the glamorous 1920s era.',
    advanced: false,
    duration: '9 minutes'
  }
];
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Data iterators">
        <v-row>
          <v-col cols="12">
            <UiChildCard title="Header and footer">
              <v-data-iterator :items="mice" :items-per-page="itemsPerPage">
                <template v-slot:header="{ page, pageCount, prevPage, nextPage }">
                  <h4 class="font-weight-bold d-flex flex-wrap justify-space-between ga-3 mb-4 align-center">
                    <div class="text-truncate">Most popular mice</div>

                    <div class="d-flex align-center">
                      <v-btn class="me-8" variant="text" @click="onClickSeeAll"> See all </v-btn>

                      <div class="d-inline-flex">
                        <v-btn :disabled="page === 1" class="me-2" icon="$arrowleft" size="small" variant="tonal" @click="prevPage"></v-btn>

                        <v-btn :disabled="page === pageCount" icon="$arrowright" size="small" variant="tonal" @click="nextPage"></v-btn>
                      </div>
                    </div>
                  </h4>
                </template>

                <template v-slot:default="{ items }">
                  <v-row>
                    <v-col v-for="(item, i) in items" :key="i" cols="12" sm="6" lg="3">
                      <v-sheet border>
                        <v-img
                          :gradient="`to top right, rgba(255, 255, 255, .1), rgba(${item.raw.color}, .15)`"
                          :src="item.raw.src"
                          height="150"
                          cover
                        ></v-img>

                        <v-list-item :title="item.raw.name" density="comfortable" lines="two" subtitle="Lorem ipsum dil orei namdie dkaf">
                          <template v-slot:title>
                            <strong class="text-display-small">
                              {{ item.raw.name }}
                            </strong>
                          </template>
                        </v-list-item>

                        <v-table class="text-label-small" density="compact">
                          <tbody>
                            <tr align="end">
                              <th>DPI:</th>

                              <td>{{ item.raw.dpi }}</td>
                            </tr>

                            <tr align="end">
                              <th>Buttons:</th>

                              <td>{{ item.raw.buttons }}</td>
                            </tr>

                            <tr align="end">
                              <th>Weight:</th>

                              <td>{{ item.raw.weight }}</td>
                            </tr>

                            <tr align="end">
                              <th>Wireless:</th>

                              <td>{{ item.raw.wireless ? 'Yes' : 'No' }}</td>
                            </tr>

                            <tr align="end">
                              <th>Price:</th>

                              <td>${{ item.raw.price }}</td>
                            </tr>
                          </tbody>
                        </v-table>
                      </v-sheet>
                    </v-col>
                  </v-row>
                </template>

                <template v-slot:footer="{ page, pageCount }">
                  <v-footer class="justify-space-between text-label-large mt-4" color="containerBg">
                    Total mice: {{ mice.length }}

                    <div>Page {{ page }} of {{ pageCount }}</div>
                  </v-footer>
                </template>
              </v-data-iterator>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <v-card variant="outlined">
              <v-card-item class="py-3">
                <v-card-title class="text-headline-medium"> Controllable props </v-card-title>
              </v-card-item>
              <v-divider />
              <v-card-text class="pa-0">
                <v-data-iterator :items="games" :items-per-page="3" :search="search">
                  <template v-slot:header>
                    <v-toolbar class="py-2 px-6" color="containerBg">
                      <v-text-field
                        v-model="search"
                        density="comfortable"
                        placeholder="Search"
                        prepend-inner-icon="$magnify"
                        style="max-width: 300px"
                        variant="outlined"
                        clearable
                        hide-details
                      ></v-text-field>
                    </v-toolbar>
                  </template>

                  <template v-slot:default="{ items }">
                    <v-container class="py-2 px-6" fluid>
                      <v-row density="compact">
                        <v-col v-for="item in items" :key="item.raw.title" cols="auto" md="4">
                          <v-card class="pb-3" border flat>
                            <v-img :src="item.raw.img"></v-img>

                            <v-list-item :subtitle="item.raw.subtitle" class="mb-2">
                              <template v-slot:title>
                                <strong class="text-display-small mb-2">{{ item.raw.title }}</strong>
                              </template>
                            </v-list-item>

                            <div class="d-flex justify-space-between px-4">
                              <div class="d-flex align-center text-label-small text-medium-emphasis ga-1 me-1">
                                <ClockHour3Icon size="14" />

                                <div class="text-truncate">
                                  {{ item.raw.duration }}
                                </div>
                              </div>

                              <v-btn class="text-none" size="small" text="Read" variant="flat" border> </v-btn>
                            </div>
                          </v-card>
                        </v-col>
                      </v-row>
                    </v-container>
                  </template>

                  <template v-slot:footer="{ page, pageCount, prevPage, nextPage }">
                    <div class="d-flex align-center justify-center pa-4">
                      <v-btn
                        :disabled="page === 1"
                        density="comfortable"
                        icon="$arrowleft"
                        variant="tonal"
                        rounded
                        @click="prevPage"
                      ></v-btn>

                      <h6 class="mx-2 text-label-small">Page {{ page }} of {{ pageCount }}</h6>

                      <v-btn
                        :disabled="page >= pageCount"
                        density="comfortable"
                        icon="$arrowright"
                        variant="tonal"
                        rounded
                        @click="nextPage"
                      ></v-btn>
                    </div>
                  </template>
                </v-data-iterator>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
