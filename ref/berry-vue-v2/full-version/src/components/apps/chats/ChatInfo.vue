<script setup lang="ts">
import { shallowRef, computed, onMounted } from 'vue';
import { useChatStore } from '@/stores/apps/chat';

import Avatar1 from '@/assets/images/background/background1.png';
import Avatar2 from '@/assets/images/background/background2.png';
import Avatar3 from '@/assets/images/background/background3.png';

const attach = shallowRef([
  {
    avatar: Avatar1,
    name: 'File Name.jpg',
    time: '4/16/2021 07:47:03'
  },
  {
    avatar: Avatar2,
    name: 'File Name.ai',
    time: '4/16/2021 07:47:03'
  },
  {
    avatar: Avatar3,
    name: 'File Name.pdf',
    time: '4/16/2021 07:47:03'
  }
]);

const store = useChatStore();
onMounted(() => {
  store.fetchChats();
});

interface ChatItem {
  // Define the properties of a chat item here
  thumb: string;
  status: string;
  name: string;
  excerpt: string;
  // ... other properties as needed
}

const chatDetail = computed<ChatItem | undefined>(() => {
  return store.chats[store.chatContent];
});
</script>
<template>
  <div v-if="chatDetail" class="customHeight pa-4">
    <div class="pa-4">
      <div class="text-center">
        <img :src="chatDetail.thumb" alt="pro" width="110" class="pa-2 border border-secondary rounded-circle" />
        <div class="mb-2">
          <v-badge
            dot
            dot-size="9"
            :color="
              chatDetail.status === 'away'
                ? 'warning'
                : chatDetail.status === 'busy'
                  ? 'error'
                  : chatDetail.status === 'online'
                    ? 'success'
                    : 'containerBg'
            "
          >
          </v-badge>
        </div>
        <h6 class="text-medium-emphasis font-weight-light">
          {{ chatDetail.status }}
        </h6>

        <h5 class="font-weight-medium my-3">{{ chatDetail.name }}</h5>
        <h5 class="font-weight-light">{{ chatDetail.excerpt }}</h5>
      </div>
    </div>
    <v-list density="compact" nav>
      <v-list-subheader class="text-headline-medium">Information</v-list-subheader>
      <v-list-item value="home">
        <template v-slot:prepend>
          <MapPinIcon size="20" class="me-2 text-medium-emphasis" />
        </template>
        <h5 class="d-inline-block font-weight-regular">32188 Sips Parkways, U.S</h5>
      </v-list-item>
      <v-list-item value="about">
        <template v-slot:prepend>
          <PhoneIcon size="20" class="me-2 text-medium-emphasis" />
        </template>
        <h5 class="d-inline-block font-weight-regular">995-250-1803</h5>
      </v-list-item>
      <v-list-item value="email">
        <template v-slot:prepend>
          <MailIcon size="20" class="me-2 text-medium-emphasis" />
        </template>
        <h5 class="d-inline-block font-weight-regular">O’Keefe@codedtheme.com</h5>
      </v-list-item>
    </v-list>
    <v-divider />
    <v-list density="compact" lines="two">
      <v-list-subheader class="text-headline-medium">Attachment</v-list-subheader>
      <v-list-item v-for="(file, i) in attach" :value="file" :key="i" rounded="sm" color="secondary">
        <template v-slot:prepend>
          <div class="me-3 py-2">
            <img :src="file.avatar" width="42" height="42" alt="Julia" class="rounded-sm" />
          </div>
        </template>
        <div class="w-100">
          <h6 class="text-body-large">{{ file.name }}</h6>
          <span class="text-body-small text-medium-emphasis">{{ file.time }}</span>
        </div>
      </v-list-item>
    </v-list>
  </div>
</template>
