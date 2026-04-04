<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// theme breadcrumb
const page = ref({ title: 'File Upload' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'File Upload',
    disabled: true,
    href: '#'
  }
]);

// define density union matching VFileUpload's accepted values
type Density = 'default' | 'comfortable' | 'compact';

const density = shallowRef<Density>('default');
const model = shallowRef<File | undefined>(undefined);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12" md="6">
      <UiParentCard title="Default (Single file upload)">
        <v-file-upload density="default" icon="$cloudUpload"></v-file-upload>
      </UiParentCard>
    </v-col>
    <v-col cols="12" md="6">
      <UiParentCard title="Density">
        <div class="text-center pa-2 mb-2">
          <v-btn-toggle v-model="density" density="comfortable" border divided rounded>
            <v-btn value="default">Default</v-btn>

            <v-btn value="comfortable">Comfortable</v-btn>

            <v-btn value="compact">Compact</v-btn>
          </v-btn-toggle>
        </div>

        <v-file-upload :density="density" class="px-3" icon="$cloudUpload"></v-file-upload>
      </UiParentCard>
    </v-col>
    <v-col cols="12" md="6">
      <UiParentCard title="Content">
        <v-file-upload
          browse-text="Local Filesystem"
          divider-text="or choose locally"
          icon="$upload"
          title="Drag and Drop Here"
        ></v-file-upload>
      </UiParentCard>
    </v-col>
    <v-col cols="12" md="6">
      <UiParentCard title="Item">
        <v-file-upload v-model="model" icon="$cloudUpload" clearable multiple show-size>
          <template v-slot:item="{ props: itemProps }">
            <v-file-upload-item v-bind="itemProps" lines="one" nav>
              <template v-slot:prepend>
                <v-avatar size="32" rounded></v-avatar>
              </template>

              <template v-slot:clear="{ props: clearProps }">
                <v-btn color="primary" v-bind="clearProps"></v-btn>
              </template>
            </v-file-upload-item>
          </template>
        </v-file-upload>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
