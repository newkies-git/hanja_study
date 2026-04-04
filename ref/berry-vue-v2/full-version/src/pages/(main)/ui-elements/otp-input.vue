<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// define consts
const page = ref({ title: 'OTP Input' });

// theme breadcrumb
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'OTP Input',
    disabled: true,
    href: '#'
  }
]);

const loading = shallowRef(false);
const otp = shallowRef('31');
const loaderOtp = shallowRef('31');

function onClick() {
  loading.value = true;

  setTimeout(() => {
    loading.value = false;
  }, 2000);
}
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs"></BaseBreadcrumb>
  <v-row>
    <v-col cols="12">
      <UiParentCard title="OTP Input">
        <v-row>
          <v-col cols="12" md="6">
            <!-- Basic -->
            <UiChildCard title="Basic">
              <v-otp-input></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Length">
              <v-otp-input length="7" model-value="3214214"></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Focus All">
              <v-otp-input model-value="425" focus-all focused></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Error">
              <v-otp-input model-value="221" error></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Variants">
              <v-otp-input model-value="8011" variant="filled"></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Divider">
              <v-otp-input v-model="otp" divider="•" length="4" variant="outlined"></v-otp-input>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="6">
            <UiChildCard title="Loader">
              <div class="text-center">
                <v-otp-input v-model="loaderOtp" :loading="loading" length="5" variant="underlined"></v-otp-input>

                <v-btn
                  :disabled="loaderOtp.length < 5 || loading"
                  class="my-5"
                  color="primary"
                  text="Submit"
                  variant="tonal"
                  @click="onClick"
                ></v-btn>
              </div>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
