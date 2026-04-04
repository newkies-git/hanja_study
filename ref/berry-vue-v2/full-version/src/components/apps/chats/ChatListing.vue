<script setup>
import { ref, onMounted, computed } from 'vue';
import { useChatStore } from '@/stores/apps/chat';

const store = useChatStore();

onMounted(() => {
  store.fetchChats();
});

const getChats = computed(() => {
  return store.getChats;
});

const chatItem = getChats;
const searchValue = ref('');
const filteredChats = computed(() => {
  return chatItem.value.filter((chat) => {
    return chat.name.toLowerCase().includes(searchValue.value.toLowerCase());
  });
});
</script>
<template>
  <div class="py-3 mt-2">
    <v-text-field v-model="searchValue" prepend-inner-icon="$magnify" persistent-placeholder placeholder="Search Contact" hide-details />
  </div>
  <v-list>
    <!---Single Item-->
    <v-list-item
      v-for="chat in filteredChats"
      :key="chat.id"
      :value="chat.id"
      color="secondary"
      class="text-no-wrap chatItem"
      lines="two"
      :active="store.chatContent === chat.id - 1"
      @click="store.SelectChat(chat.id)"
    >
      <!---Avatar-->
      <template #prepend>
        <v-badge
          dot
          :color="
            chat.status === 'away' ? 'warning' : chat.status === 'busy' ? 'error' : chat.status === 'online' ? 'success' : 'containerBg'
          "
          location="bottom end"
          dot-size="9"
        >
          <v-avatar>
            <img :src="chat.thumb" alt="pro" width="50" />
          </v-avatar>
        </v-badge>
      </template>
      <!---Name-->
      <v-list-item-title class="text-headline-medium">
        {{ chat.name }}
      </v-list-item-title>
      <!---Subtitle-->
      <v-list-item-subtitle class="text-label-small text-medium-emphasis">
        {{ chat.excerpt }}
      </v-list-item-subtitle>
      <!---Last seen--->
      <template #append>
        <div class="d-flex flex-column text-end">
          <small class="text-medium-emphasis">{{ chat.lastMessage }}</small>
          <v-badge v-if="chat.unReadChatCount" color="secondary" :content="chat.unReadChatCount" inline />
        </div>
      </template>
    </v-list-item>
  </v-list>
</template>
<style>
.chatItem {
  padding: 16px !important;
  border-bottom: 1px solid rgb(var(--v-theme-inputBorder), 0.1);
}
</style>
