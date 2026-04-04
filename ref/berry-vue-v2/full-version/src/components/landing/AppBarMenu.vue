<script setup lang="ts">
import { ref } from 'vue';
import Logo from '@/layouts/full/logo/LogoMain.vue';
import { useDisplay } from 'vuetify';
import { HomeIcon } from 'vue-tabler-icons';

const { mdAndUp } = useDisplay();
const drawer = ref(false);
</script>

<template>
  <v-app-bar elevation="0" flat height="74" class="border-bottom" style="position: fixed">
    <v-container class="fill-height maxWidth">
      <div class="d-flex align-center ga-2 w-100">
        <Logo />
        <!---/Search part -->
        <v-spacer />
        <!-- ---------------------------------------------- -->
        <!---right part -->
        <!-- ---------------------------------------------- -->
        <template v-if="mdAndUp">
          <v-btn variant="text" color="primary" to="/"> Home </v-btn>
          <v-btn variant="text" to="/dashboard/default"> Dashboard </v-btn>
          <v-btn variant="text" href="https://codedthemes.gitbook.io/berry-vuetify/"> Documentation </v-btn>
          <v-btn variant="flat" color="secondary" target="_" href="https://codedthemes.com/item/berry-vue-admin-dashboard/">
            Purchase Now
          </v-btn>
        </template>
        <template v-else>
          <v-btn color="lightsecondary" icon rounded="sm" variant="flat" size="small" @click="drawer = true">
            <Menu2Icon size="20" stroke-width="1.5" />
          </v-btn>
        </template>
      </div>
    </v-container>
  </v-app-bar>

  <v-navigation-drawer v-if="!mdAndUp" v-model="drawer" class="right-sidebar" location="right" floating>
    <v-list color="primary">
      <v-list-item to="/">
        <template #prepend>
          <HomeIcon size="20" stroke-width="1.5px" />
        </template>

        <v-list-item-title class="ms-3"> Home </v-list-item-title>
      </v-list-item>
      <v-list-item to="/dashboard/default">
        <template #prepend>
          <DashboardIcon size="20" stroke-width="1.5px" />
        </template>

        <v-list-item-title class="ms-3"> Dashboard </v-list-item-title>
      </v-list-item>
      <v-list-item href="https://codedthemes.gitbook.io/berry-vuetify/">
        <template #prepend>
          <BookIcon size="20" stroke-width="1.5px" />
        </template>

        <v-list-item-title class="ms-3"> Documentation </v-list-item-title>
      </v-list-item>
      <v-list-item href="https://vuetifyjs.com">
        <template #prepend>
          <CreditCardIcon size="20" stroke-width="1.5px" />
        </template>

        <v-list-item-title class="ms-3" to="https://codedthemes.com/item/berry-vue-admin-dashboard/"> Purchase Now </v-list-item-title>
      </v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>
<style lang="scss">
.right-sidebar {
  &.v-navigation-drawer--active {
    position: fixed !important;
  }
}
</style>
