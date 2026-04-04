<script setup lang="ts">
import { ref } from 'vue';
import { useDisplay } from 'vuetify';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import MailSidebar from '@/components/apps/mail/MailSidebar.vue';
import MailListing from '@/components/apps/mail/MailListing.vue';

const page = ref({ title: 'Mail Page' });
const { lgAndUp } = useDisplay();
const breadcrumbs = ref([
  {
    title: 'Applications',
    disabled: false,
    href: '#'
  },
  {
    title: 'Mail',
    disabled: true,
    href: '#'
  }
]);
const toggleSide = ref(false);
const sDrawer = ref(false);
</script>
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />

  <div class="d-flex flex-row ga-6">
    <div v-if="!toggleSide && lgAndUp" class="mailSidebar w-100">
      <v-card variant="flat">
        <PerfectScrollbar style="height: calc(100vh - 250px)" :options="{ suppressScrollX: true }">
          <v-card-text class="pa-5">
            <MailSidebar />
          </v-card-text>
        </PerfectScrollbar>
      </v-card>
    </div>
    <div class="flex-fill overflow-auto">
      <v-card variant="flat">
        <!---Toggle Button For mobile-->
        <v-btn icon variant="text" class="d-lg-none d-md-flex d-sm-flex" @click="sDrawer = !sDrawer">
          <Menu2Icon size="20" />
        </v-btn>

        <div class="overflow-auto">
          <MailListing @s-toggle="toggleSide = !toggleSide" />
        </div>
      </v-card>
    </div>
  </div>

  <v-navigation-drawer v-if="!lgAndUp" v-model="sDrawer" temporary width="300" top>
    <PerfectScrollbar style="height: calc(100vh - 100px)">
      <v-card-text class="pa-5">
        <MailSidebar />
      </v-card-text>
    </PerfectScrollbar>
  </v-navigation-drawer>
</template>
<style lang="scss">
.custom-main {
  margin: 0;
}
.mailSidebar {
  max-width: 325px;
}
</style>
