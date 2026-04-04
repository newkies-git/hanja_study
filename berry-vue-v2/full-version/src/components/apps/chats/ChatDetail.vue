<script setup lang="ts">
import { ref, computed, onMounted, shallowRef, watch, nextTick } from 'vue';
import { useDisplay } from 'vuetify';
import { useChatStore } from '@/stores/apps/chat';
import type { ChatDetailType, ChatHistory } from '@/types/chats/ChatTypes';
import ChatSendMsg from './ChatSendMsg.vue';
import ChatInfo from './ChatInfo.vue';
import ChatListing from './ChatListing.vue';
import ChatProfile from './ChatProfile.vue';

const { lgAndUp } = useDisplay();
const items = shallowRef([{ title: 'Name' }, { title: 'Date' }, { title: 'Rating' }, { title: 'Unread' }]);

const infodrawer = ref(false);

const store = useChatStore();
onMounted(() => {
  store.fetchChats();
});

const chatDetail = computed<ChatDetailType | null>(() => {
  const chat = store.chats[store.chatContent];
  if (chat) {
    // Ensure chatHistory follows the correct structure
    const chatHistory: ChatHistory[] = [];
    for (const historyItem of chat.chatHistory) {
      const formattedHistoryItem: ChatHistory = {
        from: { from: historyItem.from.from, to: historyItem.from.to, id: 0 },
        to: { from: historyItem.to.from, to: historyItem.to.to, id: 1 }
      };

      chatHistory.push(formattedHistoryItem);
    }
    return { ...chat, chatHistory };
  } else {
    return null;
  }
});

const sDrawer = ref(false);

interface PerfectScrollbarExpose {
  update: () => void;
  $el: HTMLElement;
}

const ps = ref<PerfectScrollbarExpose | null>(null);

const scrollToBottom = async () => {
  await nextTick();
  const el = ps.value?.$el;
  if (el) el.scrollTop = el.scrollHeight;
};

watch(
  () => chatDetail.value?.chatHistory?.length ?? 0, // Fix 1: Safe chain + fallback
  async (newLength: number, oldLength: number) => {
    // Fix 2: Explicit number typing
    if (newLength > oldLength) {
      await nextTick();
      scrollToBottom();
    }
  },
  { immediate: false }
);

// Update the existing chatContent watcher to also handle new messages
watch(
  () => store.chatContent,
  async () => {
    scrollToBottom();
  }
);

const isAtBottom = ref(true);

const checkScrollPosition = () => {
  const el = ps.value?.$el;
  if (el) {
    const { scrollTop, scrollHeight, clientHeight } = el;
    isAtBottom.value = scrollTop + clientHeight >= scrollHeight - 5;
  }
};

// Update PerfectScrollbar options
const psOptions = computed(() => ({
  suppressScrollX: true,
  handlers: ['click-rail', 'drag-thumb', 'keyboard', 'wheel', 'touch'],
  wheelPropagation: false,
  onScroll: checkScrollPosition // Track scroll position
}));

const handleNewMessage = async () => {
  await nextTick();
  scrollToBottom();
};
</script>
<template>
  <div v-if="chatDetail" class="customHeight">
    <div class="d-sm-flex align-center ga-4 pa-4">
      <!---Toggle Button-->
      <v-btn icon @click="$emit('sToggle')" variant="text" class="d-none d-lg-flex">
        <Menu2Icon size="20" />
      </v-btn>

      <div class="d-flex align-center">
        <!---Toggle Button For mobile-->
        <v-btn icon variant="text" class="d-lg-none d-md-flex d-sm-flex" @click="sDrawer = !sDrawer">
          <Menu2Icon size="20" />
        </v-btn>

        <!---Topbar Row-->
        <div class="d-flex ga-2 align-center">
          <!---User Avatar-->
          <v-badge
            dot
            :color="
              chatDetail.status === 'away'
                ? 'warning'
                : chatDetail.status === 'busy'
                  ? 'error'
                  : chatDetail.status === 'online'
                    ? 'success'
                    : 'containerBg'
            "
            location="bottom end"
            dot-size="9"
          >
            <v-avatar>
              <img :src="chatDetail.thumb" alt="pro" width="50" />
            </v-avatar>
          </v-badge>
          <!---Name & Last seen-->
          <div>
            <h5 class="mb-n1">{{ chatDetail.name }}</h5>
            <small class="text-medium-emphasis"> Last Seen: {{ chatDetail.lastMessage }} </small>
          </div>
        </div>
      </div>
      <!---Topbar Icons-->
      <div class="ms-auto ga-2 d-flex">
        <v-btn icon variant="text">
          <PhoneIcon size="20" />
        </v-btn>
        <v-btn icon variant="text">
          <VideoPlusIcon size="20" />
        </v-btn>
        <v-btn icon variant="text" @click.stop="infodrawer = !infodrawer">
          <AlertCircleIcon size="20" />
        </v-btn>
        <v-menu>
          <template v-slot:activator="{ props }">
            <v-btn icon variant="text" v-bind="props"><DotsIcon size="20" /></v-btn>
          </template>

          <v-list>
            <v-list-item v-for="(item, index) in items" :key="index" :value="index">
              <v-list-item-title>{{ item.title }}</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </div>
      <!---Topbar Icons-->
    </div>
    <v-divider />
    <!---Chat History-->
    <PerfectScrollbar ref="ps" :key="store.chatContent" class="chat-height" :options="psOptions">
      <div v-for="(chat, index) in chatDetail.chatHistory" :key="index" class="pa-5">
        <div v-for="(from, index) in chat" :key="index">
          <div v-for="ch in from.from" :key="ch" class="d-flex">
            <v-sheet class="bg-lightsecondary rounded-md pa-3 mb-1 text-end">
              <p class="text-body-medium mb-0">{{ ch }}</p>
              <small class="text-medium-emphasis">{{ chatDetail.lastMessage }}</small>
            </v-sheet>
          </div>
          <div v-for="chTo in from.to" :key="chTo" class="justify-end d-flex text-end">
            <v-sheet class="bg-lightprimary rounded-md pa-3 mb-1">
              <p class="text-body-medium mb-0">{{ chTo }}</p>
              <small class="text-medium-emphasis">
                {{ chatDetail.lastMessage }}
              </small>
            </v-sheet>
          </div>
        </div>
      </div>
    </PerfectScrollbar>
    <!---Chat send-->
    <ChatSendMsg @message-sent="handleNewMessage" />
    <!-- Info Sidebar -->
    <v-navigation-drawer v-model="infodrawer" temporary location="end" width="300" style="position: absolute; top: 0; height: 100%">
      <ChatInfo />
    </v-navigation-drawer>

    <v-navigation-drawer v-if="!lgAndUp" v-model="sDrawer" temporary width="300" top>
      <PerfectScrollbar style="height: calc(100vh - 100px)">
        <v-card-text class="pa-5">
          <ChatProfile />
          <ChatListing />
        </v-card-text>
      </PerfectScrollbar>
    </v-navigation-drawer>
  </div>
</template>
<style lang="scss">
.chat-height {
  height: calc(100vh - 415px);
  @media (max-width: 600px) {
    height: calc(100vh - 455px);
  }
}
.customHeight {
  height: calc(100vh - 256px);
}
</style>
