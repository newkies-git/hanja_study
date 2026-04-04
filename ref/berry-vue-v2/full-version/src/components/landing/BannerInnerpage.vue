<script setup lang="ts">
// assets
import mailImg from '@/assets/images/landing/img-contact-mail.svg';
const props = defineProps({
  title: String,
  subtitle: String
});
</script>

<template>
  <v-main class="headerBg" style="margin: 0">
    <v-container class="maxWidth">
      <v-row class="my-8 pb-8 text-center" density="comfortable" justify="center">
        <v-col cols="12">
          <h1 class="text-white">
            {{ props.title }}
          </h1>
        </v-col>
        <v-col cols="12" md="6">
          <p class="text-white mb-0">
            {{ props.subtitle }}
          </p>
        </v-col>
        <v-col cols="12" class="position-relative d-none d-sm-block">
          <img :src="mailImg" alt="mailImage" class="mailImg" />
        </v-col>
      </v-row>
      <div class="pt-5">
        <slot />
      </div>
    </v-container>
  </v-main>
</template>
<style lang="scss">
.headerBg {
  background-image: url('@/assets/images/landing/header-bg.jpg');
  background-size: 100% 600px;
  background-attachment: fixed;
  background-repeat: no-repeat;

  padding-top: 74px;
}
.text-display1 {
  font-size: 3.5rem;
}
.mailImg {
  position: absolute;
  top: -40px;
  right: 0px;
  width: 400px;
  max-width: 100%;
  animation: 5s wings ease-in-out infinite;
}
</style>
