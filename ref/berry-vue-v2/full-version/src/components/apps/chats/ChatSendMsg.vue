<script setup lang="ts">
import { ref } from 'vue';
import { useChatStore } from '@/stores/apps/chat';

const msg = ref('');
const store = useChatStore();

const emit = defineEmits<{
  (e: 'message-sent'): void;
}>();
function addItemAndClear() {
  if (msg.value.length === 0) return;
  store.sendMsg(store.chatContent + 1, msg.value);
  msg.value = '';
  emit('message-sent'); // ← This triggers handleNewMessage → scrollToBottom
}
</script>

<template>
  <form class="d-flex align-center ga-2 pa-4" @submit.prevent="addItemAndClear">
    <v-btn icon variant="text" size="small"><MoodSmileIcon size="20" /></v-btn>

    <v-text-field hide-details v-model="msg" @keydown.enter.exact.prevent="addItemAndClear" label="Type a Message"></v-text-field>
    <v-btn icon variant="text" size="small"><PaperclipIcon size="20" /></v-btn>
    <v-btn icon variant="text" @click="addItemAndClear" aria-label="send" size="small" color="primary" type="submit">
      <SendIcon size="20" />
    </v-btn>
  </form>
</template>
