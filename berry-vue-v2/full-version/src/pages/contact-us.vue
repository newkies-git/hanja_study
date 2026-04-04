<script setup lang="ts">
import Appbar from '@/components/landing/AppBarMenu.vue';
import BannerInnerpage from '@/components/landing/BannerInnerpage.vue';
</script>

<template>
  <v-layout>
    <Appbar />
    <BannerInnerpage
      title="Talk to our account expert"
      subtitle="The starting point for your next project based on easy-to-customize Vuetify-UI © helps you build apps faster and better.
"
    >
      <v-row>
        <v-col lg="10" offset-lg="1">
          <v-card elevation="5" class="pa-6">
            <v-row>
              <v-col cols="12" lg="6" md="6">
                <v-text-field label="Name" hide-details />
              </v-col>
              <v-col cols="12" lg="6" md="6">
                <v-text-field label="Company Name" hide-details />
              </v-col>
              <v-col cols="12" lg="6" md="6">
                <v-text-field label="Email Id" hide-details />
              </v-col>
              <v-col cols="12" lg="6" md="6">
                <v-text-field label="Phone number" type="number" hide-details />
              </v-col>
              <v-col cols="12" lg="6" md="6">
                <v-select label="Company Size" hide-details variant="outlined" color="primary" :items="['1-5', '5-10', '10+']" />
              </v-col>
              <v-col cols="12" lg="6" md="6">
                <v-select
                  label="Project Budget"
                  variant="outlined"
                  hide-details
                  color="primary"
                  :items="['Below $1000', '$1000 - $5000', 'Not Spacified']"
                />
              </v-col>
              <v-col cols="12" lg="12" md="12">
                <v-textarea label="Message" hide-details variant="outlined" color="primary" />
              </v-col>
              <v-col cols="12" lg="8" md="8">
                By submitting this, you agree to the
                <router-link to="/contact-us"> Privacy Policy </router-link> and
                <router-link to="/contact-us"> Cookie Policy </router-link>
              </v-col>
              <v-col cols="12" lg="4" md="4" class="text-end">
                <v-btn variant="flat" color="secondary"> Get Started </v-btn>
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>
    </BannerInnerpage>
  </v-layout>
</template>
