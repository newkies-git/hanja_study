<script setup lang="ts"></script>
<template>
  <v-row>
    <v-col cols="12">
      <v-card variant="flat" class="pa-5">
        <div class="d-flex ga-6 mb-5 align-center pb-4 border-bottom">
          <v-btn icon variant="flat" size="large" rounded="md" class="text-primary" color="lightprimary">
            <UsersIcon size="18" />
          </v-btn>
          <div>
            <h3 class="text-primary mb-n1">239K</h3>
            <small>Friends</small>
          </div>
          <v-btn icon variant="flat" class="ms-auto">
            <ChevronRightIcon size="18" />
          </v-btn>
        </div>
        <div class="d-flex ga-6 align-center">
          <v-btn icon variant="flat" size="large" rounded="md" class="text-secondary" color="lightsecondary">
            <UserPlusIcon size="18" />
          </v-btn>
          <div>
            <h3 class="text-secondary mb-n1">234K</h3>
            <small>Followers</small>
          </div>
          <v-btn icon variant="flat" class="ms-auto">
            <ChevronRightIcon size="18" />
          </v-btn>
        </div>
      </v-card>
    </v-col>
    <v-col cols="12">
      <v-card variant="flat" class="pa-5 text-body-medium">
        <h4>About</h4>
        <p class="my-5 text-body-medium">
          It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.
        </p>
        <div class="d-flex ga-4 mb-5">
          <v-icon class="text-secondary" icon="$earth"> </v-icon>
          <a href="https://codedthemes.com/" class="link text-truncate">https://codedthemes.com/</a>
        </div>
        <div class="d-flex ga-4 mb-5">
          <v-icon class="text-error" icon="$instagram"> </v-icon>
          <a href="https://www.instagram.com/codedthemes" class="link text-truncate">https://www.instagram.com/codedthemes</a>
        </div>
        <div class="d-flex ga-4 mb-5">
          <v-icon class="text-primary" icon="$facebook"> </v-icon>
          <a href=" https://www.facebook.com/codedthemes" class="link text-truncate"> https://www.facebook.com/codedthemes</a>
        </div>
        <div class="d-flex ga-4 mb-5">
          <v-icon icon="$linkedin"></v-icon>
          <a href="https://in.linkedin.com/company/codedthemes" class="link text-truncate">https://in.linkedin.com/company/codedthemes</a>
        </div>
      </v-card>
    </v-col>
  </v-row>
</template>
