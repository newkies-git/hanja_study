<script setup lang="ts">
import { ref, reactive } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { SquareXIcon, XIcon } from 'vue-tabler-icons';

const page = ref({ title: 'Snackbar' });
const breadcrumbs = ref([
  { title: 'Advance', disabled: false, href: '#' },
  { title: 'Snackbar', disabled: true, href: '#' }
]);

// Snackbar types configuration
const snackbarTypes = [
  { color: 'primary', label: 'default', message: 'This is default message' },
  {
    color: 'secondary',
    label: 'secondary',
    message: 'This is secondary message'
  },
  {
    color: 'success',
    label: 'success',
    message: 'This is Success message'
  },
  { color: 'warning', label: 'warning', message: 'This is Warning message' },
  { color: 'info', label: 'info', message: 'This is Info message' },
  { color: 'error', label: 'error', message: 'This is Error message' }
];

// Location configuration
const locations = [
  {
    key: 'topLeft',
    label: 'Top Left',
    location: 'top left' as const,
    message: "I'm Top Left Message"
  },
  {
    key: 'topCenter',
    label: 'Top Center',
    location: 'top' as const,
    message: "I'm Top Center Message"
  },
  {
    key: 'topRight',
    label: 'Top Right',
    location: 'top right' as const,
    message: "I'm Top Right Message"
  },
  {
    key: 'bottomLeft',
    label: 'Bottom Left',
    location: 'bottom left' as const,
    message: "I'm Bottom Left Message"
  },
  {
    key: 'bottom',
    label: 'Bottom',
    location: 'bottom' as const,
    message: "I'm Bottom Center Message"
  },
  {
    key: 'bottomRight',
    label: 'Bottom Right',
    location: 'bottom right' as const,
    message: "I'm Bottom Right Message"
  }
];

// Type definitions
interface SnackbarState {
  basic: Record<string, boolean>;
  withClose: Record<string, boolean>;
  outlined: Record<string, boolean>;
  withAction: Record<string, boolean>;
  tonal: Record<string, boolean>;
  rounded: Record<string, boolean>;
  location: Record<string, boolean>;
  vertical: boolean;
  timeout: boolean;
}

// Reactive snackbar states
const snackbars = reactive<SnackbarState>({
  basic: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  withClose: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  outlined: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  withAction: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  tonal: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  rounded: Object.fromEntries(snackbarTypes.map((type) => [type.color, false])),
  location: Object.fromEntries(locations.map((loc) => [loc.key, false])),
  vertical: false,
  timeout: false
});

// Helper functions
const showSnackbar = (category: keyof SnackbarState, type: string) => {
  const categoryState = snackbars[category];
  if (typeof categoryState === 'object' && categoryState !== null) {
    (categoryState as Record<string, boolean>)[type] = true;
  }
};

const closeSnackbar = (category: keyof SnackbarState, type: string) => {
  const categoryState = snackbars[category];
  if (typeof categoryState === 'object' && categoryState !== null) {
    (categoryState as Record<string, boolean>)[type] = false;
  }
};
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Snackbar">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Basic">
              <div class="d-flex flex-row align-center flex-wrap ga-sm-4 ga-3">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="flat"
                  :color="type.color"
                  @click="showSnackbar('basic', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                variant="flat"
                elevation-1
                rounded="md"
                v-model="snackbars.basic[type.color]"
                location="bottom right"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- With Close -->
          <v-col cols="12" lg="6">
            <UiChildCard title="With Close">
              <div class="d-flex flex-row align-center ga-sm-4 ga-3 flex-wrap">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="flat"
                  :color="type.color"
                  @click="showSnackbar('withClose', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                variant="flat"
                elevation-1
                rounded="md"
                v-model="snackbars.withClose[type.color]"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
                <template v-slot:actions>
                  <v-btn
                    :color="type.color === 'warning' || type.color === 'info' ? 'dark' : 'white'"
                    variant="text"
                    @click="closeSnackbar('withClose', type.color)"
                  >
                    <XIcon size="20" stroke-width="1.5" />
                  </v-btn>
                </template>
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- Location -->
          <v-col cols="12">
            <UiChildCard title="Location">
              <div class="d-flex flex-row flex-wrap align-center ga-sm-4 ga-3">
                <v-btn v-for="loc in locations" :key="loc.key" color="primary" variant="flat" @click="showSnackbar('location', loc.key)">
                  {{ loc.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="loc in locations"
                :key="loc.key"
                color="primary"
                variant="flat"
                rounded="md"
                :location="loc.location"
                v-model="snackbars.location[loc.key]"
              >
                {{ loc.message }}
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- Outlined -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Outlined">
              <div class="d-flex flex-row align-center flex-wrap ga-sm-4 ga-3">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="outlined"
                  :color="type.color"
                  @click="showSnackbar('outlined', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                variant="outlined"
                elevation-1
                rounded="md"
                v-model="snackbars.outlined[type.color]"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- With Close + Action -->
          <v-col cols="12" lg="6">
            <UiChildCard title="With Close + Action">
              <div class="d-flex flex-row align-center flex-wrap ga-sm-4 ga-3">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="outlined"
                  :color="type.color"
                  @click="showSnackbar('withAction', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                variant="outlined"
                elevation-1
                rounded="md"
                v-model="snackbars.withAction[type.color]"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
                <template v-slot:actions>
                  <v-btn variant="text" size="small" @click="closeSnackbar('withAction', type.color)"> Undo </v-btn>
                  <v-btn variant="text" @click="closeSnackbar('withAction', type.color)">
                    <SquareXIcon size="20" stroke-width="1.5" />
                  </v-btn>
                </template>
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- Tonal -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Tonal">
              <div class="d-flex flex-row align-center ga-sm-4 ga-3 flex-wrap">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="tonal"
                  :color="type.color"
                  @click="showSnackbar('tonal', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                variant="tonal"
                elevation-1
                rounded="md"
                v-model="snackbars.tonal[type.color]"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
                <template v-slot:actions>
                  <v-btn variant="text" @click="closeSnackbar('tonal', type.color)">
                    <XIcon size="20" stroke-width="1.5" />
                  </v-btn>
                </template>
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <!-- Rounded -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rounded">
              <div class="d-flex flex-row align-center ga-sm-4 ga-3 flex-wrap">
                <v-btn
                  v-for="type in snackbarTypes"
                  :key="type.color"
                  variant="tonal"
                  rounded="pill"
                  :color="type.color"
                  @click="showSnackbar('rounded', type.color)"
                >
                  {{ type.label }}
                </v-btn>
              </div>

              <v-snackbar
                v-for="type in snackbarTypes"
                :key="type.color"
                :color="type.color"
                rounded="pill"
                variant="tonal"
                :timeout="2000"
                v-model="snackbars.rounded[type.color]"
              >
                <v-icon class="me-1" icon="$checkboxMarkedCircleOutline"></v-icon>
                {{ type.message }}
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <v-col cols="12" sm="6">
            <UiChildCard title="Vertical">
              <v-btn color="secondary" variant="tonal" @click="snackbars.vertical = true"> Open Snackbar </v-btn>

              <v-snackbar v-model="snackbars.vertical" color="secondary" variant="tonal" vertical>
                <h5 class="pb-2">This is a snackbar message</h5>
                <p class="mb-0">This is a longer paragraph explaining something</p>
                <template v-slot:actions>
                  <v-btn color="indigo" variant="text" @click="snackbars.vertical = false"> Close </v-btn>
                </template>
              </v-snackbar>
            </UiChildCard>
          </v-col>
          <v-col cols="12" sm="6">
            <UiChildCard title="Timeout">
              <v-btn color="success" variant="tonal" @click="snackbars.timeout = true"> Open Snackbar </v-btn>

              <v-snackbar v-model="snackbars.timeout" :timeout="2000" color="success" variant="tonal">
                <p class="mb-0">My timeout is set to 2000.</p>
                <template v-slot:actions>
                  <v-btn color="indigo" variant="text" @click="snackbars.timeout = false"> Close </v-btn>
                </template>
              </v-snackbar>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
