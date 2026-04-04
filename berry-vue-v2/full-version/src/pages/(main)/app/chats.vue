<script setup lang="ts">
import { ref } from 'vue';
import { useDisplay } from 'vuetify';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import ChatListing from '@/components/apps/chats/ChatListing.vue';
import ChatDetail from '@/components/apps/chats/ChatDetail.vue';
import ChatProfile from '@/components/apps/chats/ChatProfile.vue';

const page = ref({ title: 'Chats Page' });
const { lgAndUp } = useDisplay();
const breadcrumbs = ref([
  {
    title: 'Applications',
    disabled: false,
    href: '#'
  },
  {
    title: 'Chat',
    disabled: true,
    href: '#'
  }
]);
const toggleSide = ref(false);
</script>
<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />

  <div class="d-flex flex-row ga-6">
    <div v-if="!toggleSide && lgAndUp" class="chatSidebar">
      <v-card variant="flat">
        <PerfectScrollbar style="height: calc(100vh - 256px)" :options="{ suppressScrollX: true }">
          <v-card-text class="pa-5">
            <ChatProfile />
            <ChatListing />
          </v-card-text>
        </PerfectScrollbar>
      </v-card>
    </div>
    <div class="flex-fill">
      <v-card variant="flat">
        <ChatDetail @s-toggle="toggleSide = !toggleSide" />
      </v-card>
    </div>
  </div>
</template>
<style lang="scss">
@use '@/scss/grid/mixins' as breakpoints;
.custom-main {
  margin: 0;
}
.chatSidebar {
  max-width: 350px;
  @include breakpoints.min('lg') {
    .v-card {
      min-width: 291px;
    }
  }
}
</style>
