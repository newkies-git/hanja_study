<script setup lang="ts">
import { ref, shallowRef } from 'vue';
import profileBg from '@/assets/images/profile/img-profile-bg.png';
import UserImage from '@/assets/images/profile/img-user.png';
import { FriendsIcon, InboxIcon, PhotoIcon, UserPlusIcon, UsersIcon } from 'vue-tabler-icons';
const tab = ref(null);
const items = shallowRef([
  { tab: 'Profile', icon: InboxIcon, href: '/app/user/social/posts' },
  { tab: 'Followers', icon: UsersIcon, href: '/app/user/social/followers' },
  { tab: 'Friends', icon: FriendsIcon, href: '/app/user/social/friends' },
  { tab: 'Gallery', icon: PhotoIcon, href: '/app/user/social/gallery' },
  {
    tab: 'Friend Request',
    icon: UserPlusIcon,
    href: '/app/user/social/friend-requests'
  }
]);
</script>

<template>
  <v-card class="mt-4" variant="flat">
    <div class="pa-4 pb-0">
      <img :src="profileBg" alt="profile" class="w-100 rounded-md" />
      <v-row class="mt-4">
        <v-col lg="3" md="3" cols="12" class="text-center text-md-end">
          <div class="userImage">
            <img :src="UserImage" alt="profile" class="rounded-md" />
          </div>
        </v-col>
        <v-col lg="9" md="9" cols="12">
          <v-row>
            <v-col md="5" cols="12" class="text-center text-md-start">
              <h5>John Doe</h5>
              <small class="opacity-50">Android Developer</small>
            </v-col>
            <v-col md="7" cols="12">
              <div class="text-center text-md-end">
                <v-btn color="primary" variant="outlined" class="me-2"> Message </v-btn>
                <v-btn color="primary" prepend-icon="$plus"> Send Request </v-btn>
              </div>
            </v-col>
            <v-col md="12" class="pb-0">
              <v-tabs v-model="tab" color="primary" class="profiletab">
                <v-tab v-for="item in items" :key="item.tab" :to="item.href">
                  <component :is="item.icon" size="18" stroke-width="1.5" class="me-2" />
                  {{ item.tab }}
                </v-tab>
              </v-tabs>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
    </div>
  </v-card>
</template>
<style lang="scss">
.userImage {
  margin: -70px 0px 0px auto;
}
.profiletab .v-slide-group__content {
  justify-content: end;
  .v-btn--variant-text .v-btn__overlay {
    background: transparent;
  }
}

@media (max-width: 600px) {
  .userImage img {
    width: 72px;
    height: 72px;
  }
}
</style>
