<script setup>
import { ref } from 'vue';
import { useDropzone } from 'vue3-dropzone';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import { CameraIcon, ClipboardTextIcon, XIcon } from 'vue-tabler-icons';

// assets
import upload from '@/assets/images/upload/upload.svg';

const page = ref({ title: 'Dropzone' });
const breadcrumbs = ref([
  {
    title: 'Plugins',
    disabled: false,
    href: '#'
  },
  {
    title: 'Dropzone',
    disabled: true,
    href: '#'
  }
]);

// Track single, avatar, and multiple files
const singleFile = ref(null);
const avatarFile = ref(null);
const multipleFiles = ref([]);

// Helper function to create a file object with preview if it's an image
const createFileObject = (file) => ({
  file,
  preview: file.type.startsWith('image/') ? URL.createObjectURL(file) : null
});

// Single file dropzone
const {
  getRootProps: getSingleRootProps,
  getInputProps: getSingleInputProps,
  isDragActive: isSingleDragActive
} = useDropzone({
  onDrop: (acceptedFiles) => {
    if (acceptedFiles.length > 0) {
      singleFile.value = createFileObject(acceptedFiles[0]);
    }
  }
});

// Avatar upload
const { getRootProps: getAvatarRootProps, getInputProps: getAvatarInputProps } = useDropzone({
  accept: 'image/png, image/jpeg, image/jpg, image/gif',
  onDrop: (acceptedFiles) => {
    if (acceptedFiles.length > 0) {
      avatarFile.value = createFileObject(acceptedFiles[0]);
    }
  }
});

// Multiple files dropzone
const {
  getRootProps: getMultipleRootProps,
  getInputProps: getMultipleInputProps,
  isDragActive: isMultipleDragActive
} = useDropzone({
  onDrop: (acceptedFiles) => {
    multipleFiles.value.push(...acceptedFiles.map(createFileObject));
  }
});

// Remove a single & multiple file
const removeFile = (file) => {
  if (singleFile.value && file === singleFile.value.file) {
    singleFile.value = null;
  } else {
    multipleFiles.value = multipleFiles.value.filter((f) => f.file !== file);
  }
};

// Remove Avatar
const removeAvatar = () => {
  avatarFile.value = null;
};

// Remove all files
const removeAllFiles = () => {
  multipleFiles.value = [];
};

// Expose root props and input props
const singleRootProps = getSingleRootProps();
const singleInputProps = getSingleInputProps({ multiple: false });

const avatarRootProps = getAvatarRootProps();
const avatarInputProps = getAvatarInputProps({ multiple: false });

const multipleRootProps = getMultipleRootProps();
const multipleInputProps = getMultipleInputProps();

const isSingleDragActiveRef = ref(isSingleDragActive);
const isMultipleDragActiveRef = ref(isMultipleDragActive);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs"></BaseBreadcrumb>
  <v-row>
    <v-col cols="12" md="6">
      <UiParentCard title="Upload Single File">
        <v-card v-bind="singleRootProps" variant="outlined" :ripple="false">
          <v-card-item>
            <input v-bind="singleInputProps" />
            <p v-if="isSingleDragActiveRef">Drop the file here ...</p>
            <div class="d-sm-flex align-center justify-sm-start justify-center" v-else>
              <v-img
                :src="upload"
                alt="upload"
                class="me-sm-4 ms-sm-0 ms-auto me-auto"
                style="max-height: 80px; max-width: 80px; width: 80px"
              />
              <div class="text-sm-start text-center mt-sm-0 mt-3">
                <h5 class="mb-1">Drag & Drop or Select file</h5>
                <p class="text-lightText mb-0">
                  Drop files here or click
                  <span class="text-body-large text-primary text-decoration-underline">browse</span>
                  through your machine
                </p>
              </div>
            </div>
          </v-card-item>
        </v-card>
        <div class="mt-5" v-if="singleFile">
          <h4>Previews:</h4>
          <v-list aria-label="preview list" aria-busy="true">
            <v-list-item class="preview" rounded="md" border="borderLight solid thin opacity-100">
              <template v-slot:prepend>
                <v-img v-if="singleFile.preview" :src="singleFile.preview" :alt="singleFile.file.name" class="preview-image me-2" />
                <div v-else class="me-2 text-lightText">
                  <ClipboardTextIcon size="40" />
                </div>
              </template>
              <p class="mb-0">{{ singleFile.file.name }}</p>
              <template v-slot:append>
                <v-btn
                  variant="tonal"
                  icon
                  aria-label="close"
                  color="error"
                  size="small"
                  density="compact"
                  class="ms-2"
                  @click="removeFile(singleFile.file)"
                >
                  <XIcon size="14" />
                </v-btn>
              </template>
            </v-list-item>
          </v-list>
        </div>
      </UiParentCard>
    </v-col>
    <v-col cols="12" md="6">
      <UiParentCard title="Upload Avatar">
        <div class="d-flex align-center">
          <div v-bind="avatarRootProps" class="d-inline-block rounded-circle me-4">
            <input v-bind="avatarInputProps" />
            <v-avatar
              variant="tonal"
              color="primary"
              rounded="circle"
              class="overflow-hidden dashed border-dashed border-primary border-thin border-opacity-100 profile-box"
            >
              <img v-if="avatarFile?.preview" :src="avatarFile.preview" :alt="avatarFile.file.name" class="rounded-circle" />
              <div v-else class="text-lightText">
                <CameraIcon />
                <p class="text-body1 mt-1 mb-0">Upload</p>
              </div>
            </v-avatar>
          </div>
          <div>
            <h6 class="text-label-small">Allowed 'image/*'</h6>
            <h6 class="text-label-small">*.png, *.jpeg, *.jpg, *.gif</h6>
            <div class="d-flex ga-2 mt-2">
              <v-btn color="primary" variant="flat">Submit</v-btn>
              <v-btn color="error" variant="text" @click="removeAvatar">Cancel</v-btn>
            </div>
          </div>
        </div>
      </UiParentCard>
    </v-col>
    <v-col cols="12" md="6">
      <UiParentCard title="Upload Multiple Files">
        <v-card v-bind="multipleRootProps" variant="outlined" :ripple="false">
          <v-card-item>
            <input v-bind="multipleInputProps" />
            <p v-if="isMultipleDragActiveRef">Drop the files here ...</p>
            <div class="d-sm-flex align-center justify-sm-start justify-center" v-else>
              <v-img
                :src="upload"
                alt="upload"
                class="me-sm-4 ms-sm-0 ms-auto me-auto"
                style="max-height: 80px; max-width: 80px; width: 80px"
              />
              <div class="text-sm-start text-center mt-sm-0 mt-3">
                <h5 class="mb-1">Drag & Drop or Select files</h5>
                <p class="text-lightText mb-0">
                  Drop files here or click
                  <span class="text-body-large text-primary text-decoration-underline">browse</span>
                  through your machine
                </p>
              </div>
            </div>
          </v-card-item>
        </v-card>
        <div class="mt-5" v-if="multipleFiles.length">
          <h4 class="mb-2">Previews:</h4>
          <div class="d-flex flex-wrap ga-3">
            <v-card
              v-for="file in multipleFiles"
              :key="file.file.name"
              style="width: 150px; min-width: 150px"
              color="containerBg"
              variant="flat"
              class="overflow-visible"
            >
              <v-card-item class="pa-3 text-center">
                <v-img v-if="file.preview" :src="file.preview" :alt="file.file.name" class="preview-image mx-auto" />
                <div v-else class="mx-2 text-lightText">
                  <ClipboardTextIcon size="40" />
                </div>
                <p class="mt-1 mb-0">{{ file.file.name }}</p>
                <v-btn
                  variant="tonal"
                  class="position-absolute close-icon"
                  size="small"
                  icon
                  aria-label="close"
                  color="error"
                  density="compact"
                  @click="removeFile(file.file)"
                >
                  <XIcon size="16" />
                </v-btn>
              </v-card-item>
            </v-card>
          </div>
          <div class="text-center mt-3">
            <v-btn color="primary" variant="tonal" @click="removeAllFiles">Remove All</v-btn>
          </div>
        </div>
      </UiParentCard>
    </v-col>
  </v-row>
</template>

<style lang="scss" scoped>
.preview-image {
  width: 60px;
  height: 60px;
}
.close-icon {
  top: -6px;
  right: -6px;
  [dir='rtl'] & {
    left: -6px;
    right: unset;
  }
}
.profile-box {
  width: 118px;
  height: 118px;
  @media (max-width: 600px) {
    width: 100px;
    height: 100px;
  }
}
</style>
