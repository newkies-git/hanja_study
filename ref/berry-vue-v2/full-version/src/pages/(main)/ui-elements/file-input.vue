<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { PaperclipIcon } from 'vue-tabler-icons';

// define consts
const page = ref({ title: 'File Input' });

// theme breadcrumb
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'File Input',
    disabled: true,
    href: '#'
  }
]);

const maxSize = 5000000; // 5 MB
const errorMessage = 'Total image size should be less than 5 MB!';

const rules = [
  (value: File | File[] | null) => {
    // Multiple files
    if (value && Array.isArray(value)) {
      const totalSize = value.reduce((acc, current) => acc + current.size, 0);
      return totalSize < maxSize || errorMessage;
    }

    // Single file (if multiple is undefined or set to false)
    return !value || (value as File).size < maxSize || errorMessage;
  }
];

const files = ref([]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs"></BaseBreadcrumb>
  <v-row>
    <v-col cols="12">
      <UiParentCard title="File Input">
        <v-row>
          <v-col cols="12" md="6">
            <!-- variant -->
            <UiChildCard title="Variant">
              <v-file-input label="File input" prepend-icon="$paperClip"></v-file-input>
              <v-file-input label="File input outlined" prepend-icon="$paperClip" variant="outlined"></v-file-input>
              <v-file-input label="File input solo" prepend-icon="$paperClip" variant="solo"></v-file-input>
              <v-file-input label="File input solo filled" prepend-icon="$paperClip" variant="solo-filled"></v-file-input>
              <v-file-input label="File input solo inverted" prepend-icon="$paperClip" variant="solo-inverted"></v-file-input>
              <v-file-input label="File input underlined" prepend-icon="$paperClip" variant="underlined"></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <v-row>
              <v-col cols="12">
                <UiChildCard title="Accept Image Files Only">
                  <v-file-input
                    label="Upload Image"
                    accept="image/*"
                    prepend-icon="$paperClip"
                    variant="outlined"
                    single-line
                  ></v-file-input>
                </UiChildCard>
              </v-col>
              <v-col cols="12">
                <UiChildCard title="Chips & Multiple">
                  <v-file-input
                    label="File input w/ chips"
                    prepend-icon="$paperClip"
                    chips
                    multiple
                    single-line
                    variant="outlined"
                  ></v-file-input>
                </UiChildCard>
              </v-col>
              <v-col cols="12">
                <UiChildCard title="Counter">
                  <v-file-input
                    label="File input"
                    variant="outlined"
                    prepend-icon="$paperClip"
                    single-line
                    counter
                    multiple
                    show-size
                  ></v-file-input>
                </UiChildCard>
              </v-col>
            </v-row>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Density">
              <v-file-input density="compact" label="File input" prepend-icon="$paperClip" variant="outlined" single-line></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Multiple">
              <v-file-input label="File input" variant="outlined" prepend-icon="$paperClip" single-line multiple></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Prepend Icon">
              <v-file-input label="File input" prepend-icon="$camera" variant="outlined" single-line></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Show size">
              <v-file-input label="File input" variant="outlined" prepend-icon="$paperClip" single-line show-size></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Validation">
              <v-file-input
                :rules="rules"
                accept="image/png, image/jpeg, image/bmp"
                label="Photos"
                placeholder="Upload your photos"
                prepend-icon="$camera"
                multiple
                variant="outlined"
                single-line
              ></v-file-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Complex selection slot">
              <v-file-input
                v-model="files"
                :show-size="1000"
                color="deep-purple-accent-4"
                label="File input"
                placeholder="Select your files"
                variant="outlined"
                counter
                multiple
                prepend-icon=""
              >
                <template #prepend-inner>
                  <PaperclipIcon stroke-width="1.5" size="20" />
                </template>
                <template v-slot:selection="{ fileNames }">
                  <template v-for="(fileName, index) in fileNames" :key="fileName">
                    <v-chip v-if="Number(index) < 2" class="me-2" color="deep-purple-accent-4" size="small" label>
                      {{ fileName }}
                    </v-chip>
                    <span v-else-if="index === 2" class="text-label-medium text-grey-darken-3 mx-2"> +{{ files.length - 2 }} File(s) </span>
                  </template>
                </template>
              </v-file-input>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
