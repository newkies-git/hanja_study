<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// theme breadcrumb
const page = ref({ title: 'Layouts' });
const breadcrumbs = ref([
  {
    title: 'Forms',
    disabled: false,
    href: '#'
  },
  {
    title: 'Layouts',
    disabled: true,
    href: '#'
  }
]);

const checkbox1 = ref(true);
const checkbox2 = ref(false);
const checkbox3 = ref(false);
const checkbox4 = ref(true);
const checkbox5 = ref(false);
const checkbox6 = ref(false);
const checkbox7 = ref(true);
const checkbox8 = ref(false);
const checkbox9 = ref(false);
</script>

// ===============================|| Ui Layouts ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12" lg="6">
      <UiParentCard title="Simple Form Layout">
        <v-label class="font-weight-medium mb-2"> Name </v-label>
        <v-text-field
          hint="Please enter your full name"
          persistent-hint
          variant="outlined"
          persistent-placeholder
          placeholder="Enter full name"
          color="primary"
        />
        <v-label class="mb-2 font-weight-medium mt-7"> Email </v-label>
        <v-text-field
          hint="Please enter your Email"
          persistent-hint
          variant="outlined"
          persistent-placeholder
          placeholder="Enter email"
          color="primary"
        />
        <v-label class="mb-2 font-weight-medium mt-7"> Password </v-label>
        <v-text-field
          persistent-hint
          variant="outlined"
          hide-details
          type="password"
          persistent-placeholder
          placeholder="Enter password"
          color="primary"
        />
        <v-label class="mb-2 font-weight-medium mt-7"> Language </v-label>
        <div>
          <v-checkbox v-model="checkbox1" density="compact" hide-details color="primary" label="English" />
          <v-checkbox v-model="checkbox2" density="compact" hide-details color="primary" label="French" />
          <v-checkbox v-model="checkbox3" density="compact" hide-details color="primary" label="Dutch" />
        </div>
      </UiParentCard>
    </v-col>
    <v-col cols="12" lg="6">
      <UiParentCard title="Horizontal Form Layout">
        <h4 class="mb-8 font-weight-medium">A. Personal Info:</h4>
        <v-row class="mb-6" density="compact">
          <v-col cols="12" md="4" class="d-flex align-center">
            <v-label class="font-weight-medium mb-0 mb-md-5"> Name </v-label>
          </v-col>
          <v-col cols="12" md="8">
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
        <v-row class="mb-6" density="compact">
          <v-col cols="12" md="4" class="d-flex align-center">
            <v-label class="font-weight-medium mb-0 mb-md-5"> Email </v-label>
          </v-col>
          <v-col cols="12" md="8">
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
        <h4 class="mb-9 mt-7 font-weight-medium">B. Educational Info:</h4>
        <v-row class="mb-6" density="compact">
          <v-col cols="12" md="4" class="d-flex align-center">
            <v-label class="font-weight-medium mb-0 mb-md-5"> Degree Name </v-label>
          </v-col>
          <v-col cols="12" md="8">
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
        <v-row class="mb-6" density="compact">
          <v-col cols="12" md="4" class="d-flex align-center">
            <v-label class="font-weight-medium mb-0 mb-md-5"> Passing Year </v-label>
          </v-col>
          <v-col cols="12" md="8">
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

        <v-row density="compact">
          <v-col cols="12" lg="4" class="pb-lg-3 pb-0">
            <v-label class="font-weight-medium mt-2"> Language </v-label>
          </v-col>
          <v-col cols="12" lg="8">
            <div class="d-flex ga-4">
              <v-checkbox v-model="checkbox4" density="compact" hide-details color="primary" label="English" class="flex-grow-0" />
              <v-checkbox v-model="checkbox5" density="compact" hide-details color="primary" label="French" class="flex-grow-0" />
              <v-checkbox v-model="checkbox6" density="compact" hide-details color="primary" label="Dutch" class="flex-grow-0" />
            </div>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <v-col cols="12" lg="6">
      <UiParentCard title="Control Divider">
        <v-label class="font-weight-medium mb-2"> Name </v-label>
        <v-text-field
          hint="Please enter your full name"
          persistent-hint
          variant="outlined"
          persistent-placeholder
          placeholder="Enter full name"
          color="primary"
        />
        <v-divider class="my-5" />
        <v-label class="mb-2 font-weight-medium"> Email </v-label>
        <v-text-field
          hint="Please enter your Email"
          persistent-hint
          variant="outlined"
          persistent-placeholder
          placeholder="Enter email"
          color="primary"
        />
        <v-divider class="my-5" />
        <v-label class="mb-2 font-weight-medium"> Password </v-label>
        <v-text-field
          persistent-hint
          variant="outlined"
          hide-details
          type="password"
          persistent-placeholder
          placeholder="Enter password"
          color="primary"
        />
        <v-divider class="my-5" />
        <v-label class="mb-2 font-weight-medium"> Language </v-label>
        <div>
          <v-checkbox v-model="checkbox7" density="compact" hide-details color="primary" label="English" />
          <v-checkbox v-model="checkbox8" density="compact" hide-details color="primary" label="French" />
          <div class="d-flex">
            <v-checkbox v-model="checkbox9" density="compact" hide-details color="primary" label="Dutch" />
          </div>
        </div>
      </UiParentCard>
    </v-col>
    <v-col cols="12" lg="6">
      <UiParentCard title="Input Label Alignment">
        <h4 class="mb-8 font-weight-medium">A. Personal Info:</h4>
        <v-row class="mb-6 align-center" density="compact">
          <v-col cols="12" md="4">
            <v-label class="font-weight-medium d-flex justify-start justify-md-end mb-0 mb-md-5"> Name </v-label>
          </v-col>
          <v-col cols="12" md="6">
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
        <v-row class="mb-6 align-center" density="compact">
          <v-col cols="12" md="4">
            <v-label class="font-weight-medium d-flex justify-start justify-md-end mb-0 mb-md-5"> Email </v-label>
          </v-col>
          <v-col cols="12" md="6">
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
        <h4 class="my-9 font-weight-medium">B. Educational Info:</h4>
        <v-row class="mb-6 align-center" density="compact">
          <v-col cols="12" md="4">
            <v-label class="font-weight-medium d-flex justify-start justify-md-end mb-0 mb-md-5"> Degree Name </v-label>
          </v-col>
          <v-col cols="12" md="6">
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
        <v-row class="mb-6 align-center" density="compact">
          <v-col cols="12" md="4">
            <v-label class="font-weight-medium d-flex justify-start justify-md-end mb-0 mb-md-5"> Passing Year </v-label>
          </v-col>
          <v-col cols="12" md="6">
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

        <v-row class="align-center" density="compact">
          <v-col cols="12" md="4" class="py-md-0 pt-5 pb-0">
            <v-label class="font-weight-medium d-flex justify-start justify-md-end"> Language </v-label>
          </v-col>
          <v-col cols="12" md="8">
            <div class="d-flex ga-4">
              <v-checkbox v-model="checkbox4" density="compact" hide-details color="primary" label="English" class="flex-grow-0" />
              <v-checkbox v-model="checkbox5" density="compact" hide-details color="primary" label="French" class="flex-grow-0" />
              <v-checkbox v-model="checkbox6" density="compact" hide-details color="primary" label="Dutch" class="flex-grow-0" />
            </div>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
