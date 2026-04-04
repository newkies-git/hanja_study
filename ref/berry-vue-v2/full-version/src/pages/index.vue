<script setup lang="ts">
import Appbar from '@/components/landing/AppBarMenu.vue';
import HomeBanner from '@/components/landing/HomeBanner.vue';
import Features from '@/components/landing/FeatureSection.vue';
import Demos from '@/components/landing/DemoSection.vue';
import KeyFeatures from '@/components/landing/KeyFeatures.vue';
import Pepole from '@/components/landing/PepoleSection.vue';
import Footer from '@/components/landing/FooterSection.vue';
import 'aos/dist/aos.css';
import { onMounted } from 'vue';
import AOS from 'aos';
import CardSection from '@/components/landing/CardSection.vue';
import CustomizeSection from '@/components/landing/CustomizeSection.vue';
import FrameworkSection from '@/components/landing/FrameworkSection.vue';

onMounted(() => {
  AOS.init();
});
</script>

<template>
  <v-layout>
    <Appbar />
    <v-main style="margin: 0">
      <HomeBanner />
      <CardSection />
      <CustomizeSection />
      <Features />
      <Demos />
      <Pepole />
      <KeyFeatures />
      <FrameworkSection />
      <Footer />
    </v-main>
  </v-layout>
</template>
