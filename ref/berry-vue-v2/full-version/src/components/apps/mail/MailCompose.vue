<script setup lang="ts">
import { ref } from 'vue';
import { Color, TextStyle } from '@tiptap/extension-text-style';
import StarterKit from '@tiptap/starter-kit';
import { useEditor, EditorContent } from '@tiptap/vue-3';
import EditorMenubar from '@/components/forms/plugins/editor/EditorMenubar.vue';
const ccBcc = ref(false);
const editor = useEditor({
  extensions: [Color, TextStyle.configure(), StarterKit],
  content: ``
});
</script>
<template>
  <v-card elevation="0">
    <v-card-text class="pb-4">
      <v-row>
        <v-col sm="12" cols="12">
          <div class="d-flex align-center">
            <h4>New Message</h4>
            <v-btn icon size="small" class="ms-auto" elevation="0" @click="$emit('closeDialog')">
              <xIcon size="16" />
            </v-btn>
          </div>
        </v-col>
        <v-col sm="12" cols="12">
          <p class="text-secondary text-end cursor-pointer" @click="ccBcc = !ccBcc">CC & BCC</p>
        </v-col>
        <v-col sm="12" cols="12">
          <v-text-field label="To" required variant="outlined" color="primary" hide-details />
        </v-col>
        <v-col sm="12" cols="12">
          <v-text-field label="Subject" required variant="outlined" color="primary" hide-details />
        </v-col>
        <v-col v-if="ccBcc" sm="12" cols="12">
          <div>
            <v-text-field label="CC" required variant="outlined" color="primary" hide-details class="mb-5" />
            <v-text-field label="BCC" required variant="outlined" color="primary" hide-details />
          </div>
        </v-col>
        <v-col sm="12" cols="12">
          <div v-if="editor">
            <EditorMenubar :editor="editor" />
          </div>
          <editor-content :editor="editor" />
        </v-col>
        <v-col sm="12" cols="12">
          <div class="d-flex">
            <v-btn icon elevation="0">
              <UploadIcon size="16" />
            </v-btn>
            <v-btn icon elevation="0">
              <v-icon icon="$attachment"></v-icon>
            </v-btn>
            <v-btn elevation="0" color="primary" class="ms-auto"> Reply </v-btn>
          </div>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>
