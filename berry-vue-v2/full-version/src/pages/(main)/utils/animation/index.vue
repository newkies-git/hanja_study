<script setup lang="ts">
import { ref } from 'vue';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

const page = ref({ title: 'Animation Page' });
const breadcrumbs = ref([
  {
    title: 'Utilities',
    disabled: false,
    href: '#'
  },
  {
    title: 'Animation Page',
    disabled: true,
    href: '#'
  }
]);
const fadeTran = ref(true);
const expandTran = ref(true);
const fabTran = ref(true);
const slidxTran = ref(true);
const slidyTran = ref(true);
const scrolTran = ref(true);
const scrolyTran = ref(true);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12" md="12">
      <UiParentCard title="Animation">
        <v-row>
          <v-col sm="6">
            <UiChildCard title="Slide X Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="slidxTran = !slidxTran"> Slide X Transition </v-btn>
              <br />
              <v-slide-x-transition>
                <img
                  v-show="slidxTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-slide-x-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Slide y Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="slidyTran = !slidyTran"> Slide Y Transition </v-btn>
              <br />
              <v-slide-y-transition>
                <img
                  v-show="slidyTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-slide-y-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Scroll x Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="scrolTran = !scrolTran"> Scroll x Transition </v-btn>
              <br />
              <v-scroll-x-transition>
                <img
                  v-show="scrolTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-scroll-x-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Scroll y Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="scrolyTran = !scrolyTran"> Scroll Y Transition </v-btn>
              <br />
              <v-scroll-y-transition>
                <img
                  v-show="scrolyTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-scroll-y-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Expand Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="expandTran = !expandTran"> Expand-transition </v-btn>
              <br />
              <v-expand-transition>
                <img
                  v-show="expandTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-expand-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Fab Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="fabTran = !fabTran"> Fab-transition </v-btn>
              <br />
              <v-fab-transition>
                <img
                  v-show="fabTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-fab-transition>
            </UiChildCard>
          </v-col>
          <v-col sm="6">
            <UiChildCard title="Fade Transition">
              <v-btn color="primary" variant="outlined" class="ma-2" @click="fadeTran = !fadeTran"> Fade-transition </v-btn>
              <br />
              <v-fade-transition>
                <img
                  v-show="fadeTran"
                  src="@/assets/images/background/img-profile-bg.png"
                  alt="berry"
                  class="rounded-md mt-8 w-md-75 w-100"
                />
              </v-fade-transition>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
