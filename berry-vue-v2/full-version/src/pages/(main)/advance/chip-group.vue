<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Chip groups' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Chip groups',
    disabled: true,
    href: '#'
  }
]);

const tags = ['Work', 'Home Improvement', 'Vacation', 'Food', 'Drawers', 'Shopping', 'Art', 'Tech', 'Creative Writing'];
const mandatorySelect = shallowRef([2]);
const multipleSelect = shallowRef([1, 2, 4]);

const amenities = shallowRef([1, 4]);
const neighborhoods = shallowRef([1]);

const sizes = ['04', '06', '08', '10', '12', '14'];

const selection = ref('08');
const typeSelection = shallowRef(2);

const topics = [
  '🎤 Advice',
  '🐕 Animals',
  '🤖 Anime',
  '🎨 Art & Design',
  '💄 Beauty',
  '🏢 Business',
  '📚 Books',
  '💃 Hobbies',
  '🎮 Gaming',
  '🎥 Movies',
  '🎵 Music',
  '📺 TV',
  '🌮 Food',
  '😂 Funny',
  '💖 Health & Lifestyle',
  '🎓 School',
  '📰 News',
  '🌲 Nature',
  '🎨 Photography',
  '🎏 Sports'
];
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Chip groups">
        <v-row>
          <v-col cols="12" md="6" lg="4">
            <UiChildCard title="Default">
              <v-chip-group>
                <v-chip>Chip 1</v-chip>
                <v-chip>Chip 2</v-chip>
                <v-chip>Chip 3</v-chip>
                <v-chip>Chip 4</v-chip>
              </v-chip-group>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6" lg="8">
            <UiChildCard title="Column">
              <v-chip-group selected-class="text-secondary" column>
                <v-chip v-for="tag in tags" :key="tag">
                  {{ tag }}
                </v-chip>
              </v-chip-group>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Mandatory">
              <v-chip-group v-model="mandatorySelect" selected-class="text-primary" mandatory column>
                <v-chip v-for="tag in tags" :key="tag" :text="tag"></v-chip>
              </v-chip-group>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Multiple">
              <v-chip-group v-model="multipleSelect" selected-class="text-primary" multiple column>
                <v-chip v-for="tag in tags" :key="tag" :text="tag"></v-chip>
              </v-chip-group>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Outline chip groups & selection">
              <v-row>
                <v-col cols="12" md="6">
                  <h4>Select size</h4>
                  <v-chip-group
                    v-model="selection"
                    selected-class="v-chip--selected v-chip--variant-tonal text-primary"
                    variant="outlined"
                    mandatory
                    column
                  >
                    <v-chip v-for="size in sizes" :key="size" :text="size" :value="size"></v-chip>
                  </v-chip-group>
                </v-col>
                <v-col cols="12" md="6">
                  <h4>Select type</h4>
                  <v-chip-group
                    v-model="typeSelection"
                    selected-class="v-chip--selected v-chip--variant-flat bg-secondary"
                    variant="outlined"
                    mandatory
                    column
                  >
                    <v-chip text="Extra Soft"></v-chip>
                    <v-chip text="Soft"></v-chip>
                    <v-chip text="Medium"></v-chip>
                    <v-chip text="Hard"></v-chip>
                  </v-chip-group>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Filter results">
              <v-card class="mx-auto overflow-hidden" max-width="400" variant="outlined">
                <v-toolbar color="primary">
                  <v-btn icon="$close"></v-btn>

                  <v-toolbar-title>Filter results</v-toolbar-title>
                </v-toolbar>

                <v-card-text>
                  <h3 class="mb-2">Choose amenities</h3>

                  <v-chip-group v-model="amenities" column multiple>
                    <v-chip text="Elevator" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Washer / Dryer" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Fireplace" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Wheelchair access" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Dogs ok" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Cats ok" variant="outlined" color="primary" filter></v-chip>
                  </v-chip-group>
                </v-card-text>

                <v-card-text>
                  <h3 class="mb-2">Choose neighborhoods</h3>

                  <v-chip-group v-model="neighborhoods" column multiple>
                    <v-chip text="Snowy Rock Place" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Honeylane Circle" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Donna Drive" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Elaine Street" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Court Street" variant="outlined" color="primary" filter></v-chip>

                    <v-chip text="Kennedy Park" variant="outlined" color="primary" filter></v-chip>
                  </v-chip-group>
                </v-card-text>
              </v-card>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Reddit style categories">
              <v-sheet class="mx-auto" max-width="400" rounded="md" border>
                <div class="py-4">
                  <div class="px-4">
                    <h4>What are you into?</h4>
                    <p class="text-label-small">Select topics to continue</p>
                  </div>

                  <PerfectScrollbar class="mt-5" style="height: 280px" :options="{ suppressScrollX: true }">
                    <v-chip-group class="px-4" column>
                      <v-chip v-for="topic in topics" :key="topic" :text="topic" :value="topic"></v-chip>
                    </v-chip-group>
                  </PerfectScrollbar>
                </div>

                <v-divider></v-divider>

                <div class="pa-2">
                  <v-btn color="warning" rounded="t-0 b-md" size="x-large" text="Continue" variant="flat" block></v-btn>
                </div>
              </v-sheet>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
