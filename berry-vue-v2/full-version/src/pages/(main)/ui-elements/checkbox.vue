<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Checkboxes' });
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Checkboxes',
    disabled: true,
    href: '#'
  }
]);

const checkbox = ref(false);
const checkbox2 = ref(true);
const checkbox3 = ref(false);
const checkbox4 = ref(true);
const checked = ref(true);
const unchecked = ref(false);
const includeFiles = ref(true);
const enabled = ref(false);

// checks color data
const checksColor = ref([
  {
    color: 'primary',
    value: true
  },
  {
    color: 'secondary',
    value: true
  },
  {
    color: 'success',
    value: true
  },
  {
    color: 'warning',
    value: true
  },
  {
    color: 'info',
    value: true
  },
  {
    color: 'error',
    value: true
  }
]);
</script>

// ===============================|| Ui Checkbox ||=============================== //
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Checkbox">
        <v-row>
          <!-- Basic checkboxes -->
          <v-col cols="12" lg="4">
            <UiChildCard title="Basic Checkboxes">
              <div class="d-flex ga-4 align-center flex-row flex-wrap">
                <v-checkbox-btn v-model="checkbox" color="success" hide-details />
                <v-checkbox-btn v-model="checkbox2" color="primary" hide-details />
                <v-checkbox-btn v-model="checkbox3" hide-details />
                <v-checkbox-btn v-model="checkbox4" color="secondary" hide-details />
              </div>
            </UiChildCard>
          </v-col>
          <!-- With label -->
          <v-col cols="12" lg="4">
            <UiChildCard title="With label">
              <div class="d-flex ga-4 align-center flex-column flex-sm-row">
                <v-checkbox-btn v-model="checked" color="primary" hide-details label="Checked" />
                <v-checkbox-btn v-model="unchecked" color="primary" disabled hide-details label="Unchecked" />
              </div>
            </UiChildCard>
          </v-col>
          <!-- With Colors -->
          <v-col cols="12" lg="4">
            <UiChildCard title="With Colors">
              <div class="d-flex ga-4 align-center flex-wrap flex-sm-row">
                <v-checkbox-btn
                  aria-label="checkbox"
                  v-for="(btn, index) in checksColor"
                  :key="index"
                  :color="btn.color"
                  hide-details
                  v-model="btn.value"
                ></v-checkbox-btn>
              </div>
            </UiChildCard>
          </v-col>
          <!-- With Inline Textfield -->
          <v-col cols="12">
            <UiChildCard title="With Inline Textfield">
              <div class="d-flex">
                <v-checkbox-btn v-model="includeFiles" class="pr-2" />
                <v-text-field variant="outlined" label="Include files" hide-details />
              </div>
              <div class="d-flex mt-6">
                <v-checkbox-btn v-model="enabled" class="pr-2" />
                <v-text-field
                  variant="outlined"
                  class="floating-elipsis"
                  :disabled="!enabled"
                  hide-details
                  label="I only work if you check the box"
                />
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.floating-elipsis {
  .v-label.v-field-label--floating {
    text-overflow: ellipsis;
    overflow: hidden;
    width: 100px;
    display: -webkit-box;
  }
}
</style>
