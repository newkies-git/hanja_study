<script setup lang="ts">
import { ref, computed } from 'vue';
import { useDisplay } from 'vuetify';

// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// assets
import profileBg from '@/assets/images/profile/img-profile-bg.png';
import contentBg from '@/assets/images/background/background6.png';
import welcomeBg from '@/assets/images/background/background7.png';
import heightBg from '@/assets/images/background/background1.png';
import userImage from '@/assets/images/users/user.jpg';

// theme breadcrumb
const page = ref({ title: 'Parallax' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Parallax',
    disabled: true,
    href: '#'
  }
]);

const display = useDisplay();
const avatarSize = computed(() => {
  if (display.xs.value) return 80;
  if (display.sm.value) return 200;
  return 300;
});
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Basic">
        <v-parallax :src="profileBg" alt="parallax image" />
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Content">
        <v-parallax :src="contentBg" alt="parallax image">
          <div class="d-flex flex-column fill-height justify-center align-center text-white">
            <h3 class="font-weight-thin mb-2">Vuetify</h3>
            <h6 class="subheading">Build your application today!</h6>
          </div>
        </v-parallax>
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Welcome (portfolio hero section)">
        <v-parallax :src="welcomeBg" alt="parallax image">
          <v-container class="fill-height ps-sm-10">
            <v-row class="fill-height justify-center align-center" density="compact">
              <v-col cols="12" sm="6" class="text-center text-sm-start order-2 order-sm-1">
                <h3 class="text-sm-display-large mb-0">Jane Smith</h3>
                <h5 class="text-sm-display-small mb-4">
                  <span class="font-weight-thin">Web Developer</span>
                </h5>
                <v-btn variant="flat" color="secondary"> Contact Me </v-btn>
              </v-col>
              <v-col class="text-center order-1 order-sm-2" cols="12" sm="6">
                <v-avatar :size="avatarSize" class="elevation-12 mx-auto">
                  <v-img :src="userImage"></v-img>
                </v-avatar>
              </v-col>
            </v-row>
          </v-container>
        </v-parallax>
      </UiParentCard>
    </v-col>
    <v-col cols="12">
      <UiParentCard title="Custom height">
        <v-parallax height="300" :src="heightBg" alt="parallax image" />
      </UiParentCard>
    </v-col>
  </v-row>
</template>
