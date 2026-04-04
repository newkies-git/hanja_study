<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Alert' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Alert',
    disabled: true,
    href: '#'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Alert">
        <v-row>
          <!-- Basic -->
          <v-col cols="12">
            <UiChildCard title="Basic">
              <v-alert type="success" class="text-white mb-4"> I'm a success alert. </v-alert>
              <v-alert type="info" class="text-white mb-4"> I'm a info alert. </v-alert>
              <v-alert type="warning" class="text-white mb-4"> I'm a warning alert. </v-alert>
              <v-alert type="error" class="text-white mb-4"> I'm a error alert. </v-alert>
            </UiChildCard>
          </v-col>
          <!-- Description -->
          <v-col cols="12">
            <UiChildCard title="Description">
              <v-alert type="success" variant="tonal" class="mb-4">
                <h5 class="text-capitalize">success</h5>
                <div>This is an success alert — check it out!</div>
              </v-alert>
              <v-alert type="info" variant="tonal" class="mb-4">
                <h5 class="text-capitalize">info</h5>
                <div>This is an info alert — check it out!</div>
              </v-alert>
              <v-alert type="warning" variant="tonal" class="mb-4">
                <h5 class="text-capitalize">warning</h5>
                <div>This is an warning alert — check it out!</div>
              </v-alert>
              <v-alert type="error" variant="tonal" class="mb-4">
                <h5 class="text-capitalize">error</h5>
                <div>This is an error alert — check it out!</div>
              </v-alert>
            </UiChildCard>
          </v-col>
          <!-- With Action -->
          <v-col cols="12">
            <UiChildCard title="With Action" class="alert-with-action">
              <v-alert type="success" variant="tonal" density="compact" class="mb-4 single-line-alert" closable>
                <div>This is an success alert.</div>
                <template #append>
                  <v-btn variant="text" color="success" class="ms-auto"> Undo </v-btn>
                </template>
              </v-alert>
              <v-alert type="info" variant="tonal" density="compact" class="mb-4 single-line-alert" closable>
                <div>This is an info alert.</div>
                <template #append>
                  <v-btn variant="text" color="info" class="ms-auto"> Undo </v-btn>
                </template>
              </v-alert>
              <v-alert type="warning" variant="tonal" density="compact" class="mb-4 single-line-alert" closable>
                <div>This is an warning alert.</div>
                <template #append>
                  <v-btn variant="text" color="warning" class="ms-auto"> Undo </v-btn>
                </template>
              </v-alert>
              <v-alert type="error" variant="tonal" density="compact" class="mb-4 single-line-alert" closable>
                <div>This is an error alert.</div>
                <template #append>
                  <v-btn variant="text" color="error" class="ms-auto"> Undo </v-btn>
                </template>
              </v-alert>
            </UiChildCard>
          </v-col>
          <!-- With Icons -->
          <v-col cols="12">
            <UiChildCard title="With Icons">
              <v-alert color="success" variant="tonal" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$checkboxMarkedCircleOutline"> </v-icon>
                </template>
                <div>This is an success alert.</div>
              </v-alert>
              <v-alert color="info" variant="tonal" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertCircleOutline"> </v-icon>
                </template>
                <div>This is an info alert.</div>
              </v-alert>
              <v-alert color="warning" variant="tonal" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertOutline"> </v-icon>
                </template>
                <div>This is an warning alert.</div>
              </v-alert>
              <v-alert color="error" variant="tonal" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertCircleOutline"> </v-icon>
                </template>
                <div>This is an error alert.</div>
              </v-alert>
            </UiChildCard>
          </v-col>
          <!-- Outlined -->
          <v-col cols="12">
            <UiChildCard title="Outlined">
              <v-alert type="success" variant="outlined" density="compact" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$checkboxMarkedCircleOutline"> </v-icon>
                </template>
                <div>This is an success alert.</div>
              </v-alert>
              <v-alert type="info" variant="outlined" density="compact" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertCircleOutline"> </v-icon>
                </template>
                <div>This is an info alert.</div>
              </v-alert>
              <v-alert type="warning" variant="outlined" density="compact" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertOutline"> </v-icon>
                </template>
                <div>This is an warning alert.</div>
              </v-alert>
              <v-alert type="error" variant="outlined" density="compact" class="mb-4">
                <template #prepend>
                  <v-icon class="text-24" icon="$alertCircleOutline"> </v-icon>
                </template>
                <div>This is an error alert.</div>
              </v-alert>
              <v-alert border="top" type="warning" variant="outlined" prominent>
                Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Suspendisse non nisl sit amet velit hendrerit
                rutrum. Nullam vel sem. Pellentesque dapibus hendrerit tortor.
              </v-alert>
            </UiChildCard>
          </v-col>
          <!-- Border color -->
          <v-col cols="12">
            <UiChildCard title="Border color">
              <v-alert border="start" border-color="primary">
                Aliquam eu nunc. Fusce commodo aliquam arcu. In consectetuer turpis ut velit. Nulla facilisi.. Morbi mollis tellus ac
                sapien. Fusce vel dui. Praesent ut ligula non mi varius sagittis. Vivamus consectetuer hendrerit lacus. Suspendisse enim
                turpis, dictum sed, iaculis a, condimentum nec, nisi.
              </v-alert>

              <br />

              <v-alert border="top" border-color="success">
                Vestibulum ullamcorper mauris at ligula. Nam pretium turpis et arcu. Ut varius tincidunt libero. Curabitur ligula sapien,
                tincidunt non, euismod vitae, posuere imperdiet, leo. Morbi nec metus.
              </v-alert>

              <br />

              <v-alert border="bottom" border-color="warning">
                Sed in libero ut nibh placerat accumsan. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Phasellus leo
                dolor, tempus non, auctor et, hendrerit quis, nisi. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis
                gravida magna mi a libero. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis.
              </v-alert>

              <br />

              <v-alert border="end" border-color="error">
                Fusce commodo aliquam arcu. Pellentesque posuere. Phasellus tempus. Donec posuere vulputate arcu.
              </v-alert>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
