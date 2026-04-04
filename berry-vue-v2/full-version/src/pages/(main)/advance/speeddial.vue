<script setup lang="ts">
import { ref, computed } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import { BookmarkIcon, HeartIcon, PlusIcon, PrinterIcon, ShareIcon } from 'vue-tabler-icons';

// Define the Anchor type based on Vuetify's expected locations
type Anchor = 'top' | 'bottom' | 'left' | 'right' | 'center';

// theme breadcrumb
const page = ref({ title: 'Speed Dial' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Speed Dial',
    disabled: true,
    href: '#'
  }
]);

const isSpeedDialOpen = ref(true);

// Define and initialize reactive references for location positions
const selectedItem = ref<Anchor>('bottom');
const selectedItem2 = ref<Anchor>('center');

// Define arrays of valid locations
const itemsAndLocations: Anchor[] = ['top', 'bottom', 'left', 'right'];
const itemsAndLocations2: Anchor[] = ['top', 'bottom', 'center', 'left', 'right'];

// Create reactive references for location arrays
const items = ref(itemsAndLocations);
const items2 = ref(itemsAndLocations2);

// Define and initialize reactive reference for transition type
const transitionItem = ref('fade-transition');

// Define array of valid transition types
const itemsAndTransition = [
  'fade-transition',
  'scale-transition',
  'slide-x-transition',
  'slide-y-transition',
  'slide-x-reverse-transition',
  'slide-y-reverse-transition'
];

// Create reactive reference for transition array
const items3 = ref(itemsAndTransition);

// Concatenate two locations into one valid Anchor type
const getLocation = (loc1: Anchor, loc2: Anchor): NonNullable<Anchor> | undefined => {
  const validLocations: Anchor[] = ['top', 'bottom', 'left', 'right', 'center'];
  if (validLocations.includes(loc1) && validLocations.includes(loc2)) {
    return `${loc1} ${loc2}` as NonNullable<Anchor>;
  }
  return undefined;
};

// Compute combined location from selected items
const combinedLocation = computed(() => {
  return getLocation(selectedItem.value, selectedItem2.value);
});

// Compute transition type string from selected transition item
const transition = computed(() => {
  return `${transitionItem.value}`;
});

// Compute visibility of speed dial based on selected locations
const showSpeedDial = computed(() => !!selectedItem.value || !!selectedItem2.value);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <v-row>
        <!-- Default -->
        <v-col cols="12" md="6">
          <UiParentCard title="Default">
            <v-sheet height="205" class="fab-icon text-center mt-4">
              <v-fab size="large" color="primary" rounded="circle" min-width="50" style="height: auto" height="50">
                <PlusIcon />
                <v-speed-dial
                  v-model="isSpeedDialOpen"
                  activator="parent"
                  z-index="1"
                  min-width="34"
                  location="bottom center"
                  transition="fade-transition"
                >
                  <v-btn key="1" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <HeartIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Like</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="2" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <ShareIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Share</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="3" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <PrinterIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Print</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="4" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <BookmarkIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Save</span>
                    </v-tooltip>
                  </v-btn>
                </v-speed-dial>
              </v-fab>
            </v-sheet>
          </UiParentCard>
        </v-col>

        <!-- On hover -->
        <v-col cols="12" md="6">
          <UiParentCard title="Open on hover">
            <v-sheet height="205" class="fab-icon text-center mt-4">
              <v-fab size="large" color="primary" rounded="circle" min-width="50" style="height: auto" height="50">
                <PlusIcon />
                <v-speed-dial
                  open-on-hover
                  activator="parent"
                  scroll-strategy="none"
                  z-index="1"
                  min-width="34"
                  location="bottom center"
                  transition="fade-transition"
                >
                  <v-btn key="1" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <HeartIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Like</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="2" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <ShareIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Share</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="3" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <PrinterIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Print</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="4" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <BookmarkIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Save</span>
                    </v-tooltip>
                  </v-btn>
                </v-speed-dial>
              </v-fab>
            </v-sheet>
          </UiParentCard>
        </v-col>

        <!-- Positions -->
        <v-col cols="12" md="6">
          <UiParentCard title="Different Positions">
            <v-row>
              <v-col sm="6">
                <v-label class="mb-2">Location</v-label>
                <v-autocomplete
                  aria-label="autocomplete"
                  v-model="selectedItem"
                  :items="items"
                  hide-details
                  color="primary"
                  variant="outlined"
                  rounded="sm"
                  single-line
                />
              </v-col>
              <v-col sm="6">
                <v-label class="mb-2">Location 2</v-label>
                <v-autocomplete
                  aria-label="autocomplete"
                  v-model="selectedItem2"
                  :items="items2"
                  hide-details
                  color="primary"
                  variant="outlined"
                  rounded="sm"
                  single-line
                />
              </v-col>
            </v-row>

            <v-sheet height="400" class="fab-icon text-center">
              <v-fab size="large" color="primary" rounded="circle" min-width="50" height="50">
                <PlusIcon />
                <v-speed-dial
                  activator="parent"
                  min-width="34"
                  v-if="showSpeedDial"
                  :location="combinedLocation"
                  transition="fade-transition"
                >
                  <v-btn key="1" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary"
                    ><HeartIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Like</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="2" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <ShareIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Share</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="3" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <PrinterIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Print</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="4" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <BookmarkIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Save</span>
                    </v-tooltip>
                  </v-btn>
                </v-speed-dial>
              </v-fab>
            </v-sheet>
          </UiParentCard>
        </v-col>
        <!-- Animation -->
        <v-col cols="12" md="6">
          <UiParentCard title="Animation">
            <v-label class="mb-2">Transition</v-label>
            <v-autocomplete
              aria-label="autocomplete"
              v-model="transitionItem"
              :items="items3"
              hide-details
              color="primary"
              variant="outlined"
              rounded="sm"
              single-line
            />
            <v-sheet height="400" class="fab-icon text-center">
              <v-fab size="large" color="primary" rounded="circle" min-width="50" height="50">
                <PlusIcon />
                <v-speed-dial activator="parent" min-width="34" location="bottom center" :transition="transition">
                  <v-btn key="1" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary"
                    ><HeartIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Like</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="2" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <ShareIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Share</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="3" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <PrinterIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Print</span>
                    </v-tooltip>
                  </v-btn>
                  <v-btn key="4" rounded="circle" class="px-0" min-width="34" height="34" variant="tonal" color="secondary">
                    <BookmarkIcon size="18" />
                    <v-tooltip activator="parent" aria-label="tooltip" location="start" content-class="smallTooltip">
                      <span class="text-label-small">Save</span>
                    </v-tooltip>
                  </v-btn>
                </v-speed-dial>
              </v-fab>
            </v-sheet>
          </UiParentCard>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>
<style lang="scss">
.fab-icon {
  .v-btn.v-btn--size-large {
    padding: 0;
  }
}
</style>
