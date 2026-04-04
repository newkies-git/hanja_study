<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { DotsIcon, MapPinIcon } from 'vue-tabler-icons';

import bgImage from '@/assets/images/background/background1.png';

// theme breadcrumb
const page = ref({ title: 'Cards' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Cards',
    disabled: true,
    href: '#'
  }
]);

// dropdown data
const actionDD = ref([{ title: 'Edit' }, { title: 'Delete' }]);

// color card data
const colors = ref([
  {
    color: 'primary'
  },
  {
    color: 'secondary'
  },
  {
    color: 'error'
  },
  {
    color: 'success'
  },
  {
    color: 'warning'
  }
]);

// variant cards
const variants = ['flat', 'elevated', 'tonal', 'outlined'] as const;
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Cards">
        <v-row>
          <!-- Basic Card Style 3 -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Card Style 3">
              <v-card variant="outlined" class="card-hover-border bg-gray100">
                <v-card-text>
                  <div class="d-flex align-start">
                    <img src="@/assets/images/users/avatar-6.png" width="60" />
                    <div class="ms-auto">
                      <v-menu>
                        <template #activator="{ props }">
                          <v-btn size="x-small" v-bind="props" variant="text">
                            <DotsIcon width="20" stroke-width="1.5" />
                          </v-btn>
                        </template>
                        <v-list>
                          <v-list-item v-for="(item, index) in actionDD" :key="index" :value="index" color="secondary">
                            <v-list-item-title>{{ item.title }}</v-list-item-title>
                          </v-list-item>
                        </v-list>
                      </v-menu>
                    </div>
                  </div>
                  <div class="d-flex align-center justify-space-between mt-3 mb-4">
                    <h4>Joanne</h4>
                    <v-chip color="success" size="small"> Active </v-chip>
                  </div>
                  <div class="d-flex flex-wrap flex-lg-nowrap ga-4">
                    <v-btn variant="tonal" color="facebook" class="flex-fill">
                      <v-icon icon="$facebook"></v-icon>
                    </v-btn>
                    <v-btn variant="tonal" color="twitter" class="flex-fill">
                      <v-icon icon="$twitter"></v-icon>
                    </v-btn>
                    <v-btn variant="tonal" color="linkedin" class="flex-fill">
                      <v-icon icon="$linkedin"></v-icon>
                    </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Basic Card Style 4 -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Card Style 4">
              <v-card variant="outlined" class="card-hover-border bg-gray100">
                <v-card-text>
                  <div class="d-flex align-start">
                    <img src="@/assets/images/users/avatar-4.png" width="40" />
                    <div class="ms-3">
                      <h5 class="mt-n1">Henderson</h5>
                      <div class="text-medium-emphasis text-body-small d-flex align-center">
                        <MapPinIcon size="16" stroke-width="1.5" class="me-1" />
                        <span class="text-truncate w-50">South Antonina</span>
                      </div>
                    </div>
                    <div class="ms-auto">
                      <v-menu>
                        <template #activator="{ props }">
                          <v-btn size="x-small" v-bind="props" variant="text">
                            <DotsIcon width="20" stroke-width="1.5" />
                          </v-btn>
                        </template>
                        <v-list>
                          <v-list-item v-for="(item, index) in actionDD" :key="index" :value="index" color="secondary">
                            <v-list-item-title>{{ item.title }}</v-list-item-title>
                          </v-list-item>
                        </v-list>
                      </v-menu>
                    </div>
                  </div>
                  <div class="d-flex ga-4 mt-3">
                    <v-btn variant="outlined" color="secondary" class="flex-fill">
                      <v-tooltip activator="parent" location="top"> Video Call </v-tooltip>
                      <v-icon icon="$video"></v-icon>
                    </v-btn>
                    <v-btn variant="outlined" color="primary" class="flex-fill">
                      <v-tooltip activator="parent" location="top"> Message </v-tooltip>
                      <v-icon icon="$message"></v-icon>
                    </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Basic Card Style 5 -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Card Style 5">
              <v-card variant="outlined" class="card-hover-border bg-gray100">
                <v-card-text>
                  <div class="d-flex align-start">
                    <img src="@/assets/images/users/avatar-2.png" width="40" />
                    <div class="ms-3">
                      <h5 class="mt-n1">Henderson</h5>
                      <h6 class="text-medium-emphasis text-body-small d-flex align-center">
                        <MapPinIcon size="16" stroke-width="1.5" class="me-1" />
                        <span class="text-truncate w-50">South Antonina</span>
                      </h6>
                    </div>
                    <div class="ms-auto">
                      <v-menu>
                        <template #activator="{ props }">
                          <v-btn size="x-small" v-bind="props" variant="text">
                            <DotsIcon width="20" stroke-width="1.5" />
                          </v-btn>
                        </template>
                        <v-list>
                          <v-list-item v-for="(item, index) in actionDD" :key="index" :value="index" color="secondary">
                            <v-list-item-title>{{ item.title }}</v-list-item-title>
                          </v-list-item>
                        </v-list>
                      </v-menu>
                    </div>
                  </div>
                  <div class="d-flex ga-4 mt-3">
                    <v-btn variant="outlined" prepend-icon="$accountMultiple" color="primary" class="flex-fill"> Followed </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Basic Card Style 1 -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Card Style 1">
              <v-card variant="outlined" class="card-hover-border bg-gray100">
                <v-card-text>
                  <div class="d-flex align-start">
                    <img src="@/assets/images/users/avatar-2.png" width="72" />
                    <div class="ms-auto">
                      <v-menu>
                        <template #activator="{ props }">
                          <v-btn size="x-small" v-bind="props" variant="text">
                            <DotsIcon width="20" stroke-width="1.5" />
                          </v-btn>
                        </template>
                        <v-list>
                          <v-list-item v-for="(item, index) in actionDD" :key="index" :value="index" color="secondary">
                            <v-list-item-title>{{ item.title }}</v-list-item-title>
                          </v-list-item>
                        </v-list>
                      </v-menu>
                    </div>
                  </div>
                  <div class="mb-4 mt-5">
                    <h3>Gaetano</h3>
                    <h6 class="text-medium-emphasis">Investor Division Strategist</h6>

                    <p class="text-body-small mt-3 mb-4">Try to connect the SAS transmitter, maybe it will index the optical hard drive!</p>

                    <h6 class="text-medium-emphasis">Email</h6>
                    <h6>alia_shields25@yahoo.com</h6>
                    <v-row class="mt-3">
                      <v-col cols="6">
                        <h6 class="text-medium-emphasis">Phone</h6>
                        <h6>253-418-5940</h6>
                      </v-col>
                      <v-col cols="6">
                        <h6 class="text-medium-emphasis">Location</h6>
                        <h6>Herminahaven</h6>
                      </v-col>
                    </v-row>
                  </div>
                  <div class="d-flex flex-wrap flex-lg-nowrap ga-4 mt-5">
                    <v-btn variant="outlined" color="primary" class="flex-fill" prepend-icon="$message"> Message </v-btn>
                    <v-btn variant="outlined" color="error" class="flex-fill" prepend-icon="$blockHelper"> Block </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Basic Card Style 2 -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Card Style 2">
              <v-card variant="outlined">
                <v-img src="https://berrydashboard.io/vue/assets/background1-24822d62.png" height="125px" cover />

                <div class="text-center mt-n8 position-relative">
                  <div class="d-flex justify-center">
                    <img src="@/assets/images/profile/user-round.svg" width="72" />
                  </div>
                  <h3 class="mt-4 mb-3">Madyson</h3>
                  <h6 class="text-medium-emphasis mb-2">Product Tactics Facilitator</h6>
                  <v-chip color="success" size="small"> Active </v-chip>
                </div>
                <v-card-text>
                  <div class="d-flex flex-wrap ga-4 mt-4">
                    <v-btn variant="tonal" size="large" color="facebook" class="flex-fill">
                      <v-icon icon="$facebook"></v-icon>
                    </v-btn>
                    <v-btn variant="tonal" size="large" color="twitter" class="flex-fill">
                      <v-icon icon="$twitter"></v-icon>
                    </v-btn>
                    <v-btn variant="tonal" size="large" color="linkedin" class="flex-fill">
                      <v-icon icon="$linkedin"></v-icon>
                    </v-btn>
                  </div>
                  <v-btn variant="outlined" color="primary" class="flex-fill w-100 mt-4" prepend-icon="$message"> Message </v-btn>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Cards">
        <v-row>
          <!-- Body Content -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Body Content">
              <v-card variant="outlined" class="bg-gray100">
                <v-card-text> This is some text within a card body. </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Titles, Text, and Links -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Titles, Text, and Links">
              <v-card variant="outlined" title="Card Title" subtitle="Card Subtitle" class="bg-gray100">
                <v-card-text> Some quick example text to build on the card title and make up content. </v-card-text>
                <v-card-actions>
                  <v-btn variant="text" color="primary"> Card Link </v-btn>
                  <v-btn variant="text" color="secondary"> Another </v-btn>
                </v-card-actions>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Header and Footer -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Header and Footer">
              <v-card variant="outlined" class="bg-gray100">
                <v-card-item>
                  <div>
                    <div class="text-label-medium mb-1">OVERLINE</div>
                    <h5 class="mb-1">Headline</h5>
                    <h6 class="text-label-small">Greyhound divisely hello coldly fonwderfully</h6>
                  </div>
                </v-card-item>

                <v-card-actions>
                  <v-btn variant="flat" color="primary"> Go Somewhere </v-btn>
                </v-card-actions>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Left Align (Default) -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Left Align (Default)">
              <v-card variant="outlined" class="bg-gray100">
                <v-card-item>
                  <v-card-title>Special title treatment</v-card-title>
                </v-card-item>

                <v-card-text>
                  <p class="text-medium-emphasis mb-0">With supporting text below as a natural lead-in to additional content.</p>

                  <v-btn variant="flat" color="primary" class="mt-10"> Go Somewhere </v-btn>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Center Align -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Center Align">
              <v-card variant="outlined" class="text-center bg-gray100">
                <v-card-item>
                  <v-card-title>Special title treatment</v-card-title>
                </v-card-item>

                <v-card-text>
                  <p class="text-medium-emphasis mb-0">With supporting text below as a natural lead-in to additional content.</p>

                  <v-btn variant="flat" color="primary" class="mt-10"> Go Somewhere </v-btn>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <!-- Right Align -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Right Align">
              <v-card variant="outlined" class="text-end bg-gray100">
                <v-card-item>
                  <v-card-title>Special title treatment</v-card-title>
                </v-card-item>

                <v-card-text>
                  <p class="text-medium-emphasis mb-0">With supporting text below as a natural lead-in to additional content.</p>

                  <v-btn variant="flat" color="primary" class="mt-10"> Go Somewhere </v-btn>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>

          <!-- Image Cap -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Image Cap">
              <v-card variant="outlined" class="overflow-hidden">
                <v-img src="https://berrydashboard.io/vue/assets/background1-24822d62.png" cover />
                <v-card-item>
                  <v-card-title>Special title</v-card-title>
                </v-card-item>

                <v-card-text>
                  <p class="text-medium-emphasis mb-8">With supporting text below as a natural lead-in to additional content.</p>

                  <div class="text-medium-emphasis">Last updated 3 mins ago</div>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>

          <!-- Image Cap -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Image Cap">
              <v-card variant="outlined" class="overflow-hidden">
                <v-card-item>
                  <v-card-title>Special title</v-card-title>
                </v-card-item>

                <v-card-text>
                  <p class="text-medium-emphasis mb-8">With supporting text below as a natural lead-in to additional content.</p>

                  <div class="text-medium-emphasis">Last updated 3 mins ago</div>
                </v-card-text>
                <v-img src="https://berrydashboard.io/vue/assets/background1-24822d62.png" cover />
              </v-card>
            </UiChildCard>
          </v-col>

          <!-- Image Overlap -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Image Overlap">
              <v-card variant="outlined" class="overflow-hidden">
                <v-img height="300" src="https://berrydashboard.io/vue/assets/background1-24822d62.png" cover>
                  <v-layout full-height>
                    <div>
                      <v-card-item>
                        <v-card-title class="text-white"> Special title </v-card-title>
                      </v-card-item>

                      <v-card-text>
                        <p class="text-medium-emphasis text-white mb-8">
                          With supporting text below as a natural lead-in to additional content.
                        </p>
                      </v-card-text>
                      <v-card-actions>
                        <div class="text-medium-emphasis text-white">Last updated 3 mins ago</div>
                      </v-card-actions>
                    </div>
                  </v-layout>
                </v-img>
              </v-card>
            </UiChildCard>
          </v-col>

          <!-- Color Card -->
          <v-col cols="12">
            <UiChildCard title="Color Card">
              <v-row>
                <v-col v-for="card in colors" :key="card.color" cols="12" lg="4" md="6">
                  <v-card :color="card.color">
                    <v-card-item class="text-white">
                      {{ card.color }}
                    </v-card-item>
                    <v-divider />
                    <v-card-item>
                      <v-card-title class="text-18 text-white"> {{ card.color }} Card Title </v-card-title>
                    </v-card-item>
                    <v-card-text class="text-white">
                      Some quick example text to build on the card title and make up the bulk of the card's content.
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <!-- Variant Card -->
          <v-col cols="12">
            <UiChildCard title="Card Variants">
              <v-row>
                <v-col v-for="card in variants" :key="card" cols="12" lg="4" md="6">
                  <v-card color="primary" :variant="card">
                    <v-card-item>
                      {{ card }}
                    </v-card-item>
                    <v-divider />
                    <v-card-item>
                      <v-card-title class="text-18"> {{ card }} Card Title </v-card-title>
                    </v-card-item>
                    <v-card-text>
                      Some quick example text to build on the card title and make up the bulk of the card's content.
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Href">
              <v-card
                append-icon="$openInNew"
                class="mx-auto"
                href="https://github.com/vuetifyjs/vuetify/"
                max-width="344"
                prepend-icon="$github"
                rel="noopener"
                subtitle="Check out the official repository"
                target="_blank"
                variant="tonal"
                color="primary"
                title="Vuetify on GitHub"
              ></v-card>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Link">
              <v-card
                class="mx-auto"
                max-width="344"
                subtitle="Same looks, no anchor"
                title="Hover and click me"
                variant="tonal"
                color="primary"
                link
              ></v-card>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Disabled">
              <v-card
                class="mx-auto"
                max-width="344"
                subtitle="The card stays disabled"
                title="Disabled card"
                variant="outlined"
                color="primary"
                disabled
                link
              ></v-card>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Image">
              <v-card
                class="mx-auto overflow-hidden"
                color="warning"
                :image="bgImage"
                max-width="340"
                subtitle="Take a walk down the beach"
                title="Evening sunset"
                variant="flat"
              >
                <template v-slot:actions>
                  <v-btn append-icon="$chevronRight" color="primary" text="Book Activity" variant="flat" block></v-btn>
                </template>
              </v-card>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Avatar and icon">
              <v-row align="center" justify="center">
                <v-col cols="12" md="6">
                  <v-card
                    append-icon="$check"
                    class="mx-auto"
                    prepend-icon="$account"
                    subtitle="prepend-icon and append-icon"
                    title="Icons"
                    variant="outlined"
                  >
                    <v-card-text>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.</v-card-text>
                  </v-card>
                </v-col>

                <v-col cols="12" md="6">
                  <v-card class="mx-auto" subtitle="prepend and append" title="Icons" variant="outlined">
                    <template v-slot:prepend>
                      <v-icon color="primary" icon="$account"></v-icon>
                    </template>
                    <template v-slot:append>
                      <v-icon color="success" icon="$check"></v-icon>
                    </template>
                    <v-card-text>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.</v-card-text>
                  </v-card>
                </v-col>

                <v-col cols="12" md="6">
                  <v-card
                    append-avatar="https://cdn.vuetifyjs.com/images/john.jpg"
                    class="mx-auto"
                    prepend-avatar="https://cdn.vuetifyjs.com/images/logos/v-alt.svg"
                    subtitle="prepend-avatar and append-avatar"
                    title="Avatars"
                    variant="outlined"
                  >
                    <v-card-text>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.</v-card-text>
                  </v-card>
                </v-col>

                <v-col cols="12" md="6">
                  <v-card class="mx-auto" subtitle="prepend and append" title="Avatars" variant="outlined">
                    <template v-slot:prepend>
                      <v-avatar color="blue-darken-2">
                        <v-icon icon="$alarm"></v-icon>
                      </v-avatar>
                    </template>
                    <template v-slot:append>
                      <v-avatar size="24">
                        <v-img alt="John" src="https://cdn.vuetifyjs.com/images/john.png"></v-img>
                      </v-avatar>
                    </template>
                    <v-card-text>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.</v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
