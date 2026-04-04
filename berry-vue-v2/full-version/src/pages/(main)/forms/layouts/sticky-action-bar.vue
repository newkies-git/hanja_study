<script setup lang="ts">
import { ref } from 'vue';
import { useDisplay } from 'vuetify';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';

// icons
import { ClipboardListIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Sticky Action Bar' });
const breadcrumbs = ref([
  {
    title: 'Layouts',
    disabled: false,
    href: '#'
  },
  {
    title: 'Sticky Action Bar',
    disabled: true,
    href: '#'
  }
]);

const { smAndDown } = useDisplay();

const checkbox1 = ref(false);
const checkbox2 = ref(false);
const checkbox3 = ref(false);
const checkbox4 = ref(false);
const checkbox5 = ref(false);
const checkbox6 = ref(false);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <v-card variant="outlined" elevation="0" class="bg-surface overflow-visible">
        <v-toolbar flat class="px-2 stickyHeader bg-surface rounded-md" color="inherit" density="comfortable">
          <v-toolbar-title class="text-18 font-weight-medium">Sticky Action Bar:</v-toolbar-title>
          <template v-slot:append>
            <v-btn variant="text" color="error" class="me-3" size="small" rounded="md">Cancel</v-btn>
            <v-btn variant="flat" color="primary" size="small" rounded="md">Submit</v-btn>
          </template>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card-text>
          <div class="pb-0 pb-sm-6">
            <v-row class="pb-4 pb-sm-0">
              <v-col cols="3" lg="4">
                <div class="d-flex align-center justify-end">
                  <v-btn icon color="secondary" rounded="sm" variant="flat">
                    <ClipboardListIcon stroke-width="1.5" size="22" />
                  </v-btn>
                </div>
              </v-col>
              <v-col cols="8" lg="6">
                <h3 class="text-18 mb-sm-n1 mt-n1">Personal Information</h3>
                <span class="text-body-large text-medium-emphasis">Sticky Action Bar Lorem Ipsum is simply</span>
              </v-col>
            </v-row>
          </div>
          <v-divider />
          <v-row class="pt-0 pt-sm-7 mb-4 mb-md-0">
            <v-col sm="3" lg="4" />
            <v-col cols="12" lg="6" sm="9">
              <h4 class="font-weight-medium mb-2">A. Personal Info:</h4>
            </v-col>
          </v-row>

          <v-row class="mb-6 align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4" class="py-0">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end mb-0 mb-sm-5"> Name </v-label>
            </v-col>
            <v-col cols="12" sm="7" lg="6">
              <v-text-field
                hint="Please enter your full name"
                persistent-hint
                variant="outlined"
                persistent-placeholder
                placeholder="Enter full name"
                color="primary"
              />
            </v-col>
          </v-row>
          <v-row class="align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end mb-0 mb-sm-5"> Email </v-label>
            </v-col>
            <v-col cols="12" sm="7" lg="6">
              <v-text-field
                hint="Please enter your Email"
                persistent-hint
                variant="outlined"
                persistent-placeholder
                placeholder="Enter email"
                color="primary"
              />
            </v-col>
          </v-row>
          <v-divider class="mt-9" />
          <v-row class="pt-0 pt-sm-7 mb-4 mb-sm-0">
            <v-col sm="3" lg="4" />
            <v-col lg="8" cols="12" sm="9">
              <h4 class="font-weight-medium mb-2">B. Educational Info:</h4>
            </v-col>
          </v-row>
          <v-row class="mb-6 align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4" class="py-0">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end mb-0 mb-sm-5"> Degree Name </v-label>
            </v-col>
            <v-col cols="12" sm="7" lg="6">
              <v-text-field
                hint="Please enter your Degree name"
                persistent-hint
                variant="outlined"
                persistent-placeholder
                placeholder="Enter Degree name"
                color="primary"
              />
            </v-col>
          </v-row>
          <v-row class="mb-6 align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end mb-0 mb-sm-5"> Passing Year </v-label>
            </v-col>
            <v-col cols="12" sm="7" lg="6">
              <v-text-field
                hint="Please enter Passing Year"
                persistent-hint
                variant="outlined"
                persistent-placeholder
                placeholder="Enter Passing Year"
                color="primary"
              />
            </v-col>
          </v-row>

          <v-row class="mb-6 align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end"> Language </v-label>
            </v-col>
            <v-col cols="12" sm="9" lg="6">
              <div class="d-flex ga-4">
                <v-checkbox v-model="checkbox1" density="compact" hide-details color="primary" label="English" class="flex-grow-0" />
                <v-checkbox v-model="checkbox2" density="compact" hide-details color="primary" label="French" class="flex-grow-0" />
                <v-checkbox v-model="checkbox3" density="compact" hide-details color="primary" label="Dutch" class="flex-grow-0" />
              </div>
            </v-col>
          </v-row>

          <v-row class="align-center" :density="smAndDown ? 'compact' : 'default'">
            <v-col cols="12" sm="3" lg="4">
              <v-label class="font-weight-medium d-flex justify-start justify-sm-end"> Hobby </v-label>
            </v-col>
            <v-col cols="12" sm="9" lg="6">
              <div class="d-flex ga-4 flex-wrap">
                <v-checkbox v-model="checkbox4" density="compact" hide-details color="primary" label="Reading" class="flex-grow-0" />
                <v-checkbox v-model="checkbox5" density="compact" hide-details color="primary" label="Dancing" class="flex-grow-0" />
                <v-checkbox v-model="checkbox6" density="compact" hide-details color="primary" label="Swimming" class="flex-grow-0" />
              </div>
            </v-col>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-row>
            <v-col cols="12" sm="3" lg="4" class="d-none d-sm-block"></v-col>
            <v-col cols="12" sm="9" lg="8" class="text-sm-start text-center">
              <div class="d-flex ga-2">
                <v-btn variant="text" color="error" rounded="md">Cancel</v-btn>
                <v-btn variant="flat" color="primary" class="me-2" rounded="md">Submit</v-btn>
              </div>
            </v-col>
          </v-row>
        </v-card-actions>
      </v-card>
    </v-col>
  </v-row>
</template>
<style scoped>
.stickyHeader {
  position: sticky;
  top: 80px;
  z-index: 2;
}
</style>
