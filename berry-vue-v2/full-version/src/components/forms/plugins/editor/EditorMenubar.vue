<script setup lang="ts">
import { shallowRef, ref } from 'vue';
import { Editor } from '@tiptap/vue-3';

const props = defineProps<{
  editor: Editor | null;
}>();

const level: 1 | 2 | 3 | 4 | 5 | 6 = 1;
const rerenderTrigger = ref(0);

// Re-render buttons when selection updates
if (props.editor) {
  props.editor.on('selectionUpdate', () => {
    rerenderTrigger.value++;
  });
}

const items = shallowRef([
  {
    title: 'Bold',
    action: () => {
      if (!props.editor) return;
      return props.editor.chain().focus().toggleBold().run();
    },
    isActive: () => props.editor?.isActive('bold'),
    canRun: () => props.editor?.can().chain().focus().toggleBold().run()
  },
  {
    title: 'Italic',
    action: () => props.editor?.chain().focus().toggleItalic().run(),
    isActive: () => props.editor?.isActive('italic'),
    canRun: () => props.editor?.can().chain().focus().toggleItalic().run()
  },
  {
    title: 'Strike',
    action: () => props.editor?.chain().focus().toggleStrike().run(),
    isActive: () => props.editor?.isActive('strike'),
    canRun: () => props.editor?.can().chain().focus().toggleStrike().run()
  },
  {
    title: 'Code',
    action: () => props.editor?.chain().focus().toggleCode().run(),
    isActive: () => props.editor?.isActive('code'),
    canRun: () => props.editor?.can().chain().focus().toggleCode().run()
  },
  {
    title: 'Clear Marks',
    action: () => props.editor?.chain().focus().unsetAllMarks().run()
  },
  {
    title: 'Clear Nodes',
    action: () => props.editor?.chain().focus().clearNodes().run()
  },
  {
    title: 'Paragraph',
    action: () => props.editor?.chain().focus().setParagraph().run(),
    isActive: () => props.editor?.isActive('paragraph')
  },
  {
    title: `H${level}`,
    action: () => props.editor?.chain().focus().toggleHeading({ level }).run(),
    isActive: () => props.editor?.isActive('heading', { level })
  },
  {
    title: 'Bullet List',
    action: () => props.editor?.chain().focus().toggleBulletList().run(),
    isActive: () => props.editor?.isActive('bulletList')
  },
  {
    title: 'Ordered List',
    action: () => props.editor?.chain().focus().toggleOrderedList().run(),
    isActive: () => props.editor?.isActive('orderedList')
  },
  {
    title: 'Code Block',
    action: () => props.editor?.chain().focus().toggleCodeBlock().run(),
    isActive: () => props.editor?.isActive('codeBlock')
  },
  {
    title: 'Blockquote',
    action: () => props.editor?.chain().focus().toggleBlockquote().run(),
    isActive: () => props.editor?.isActive('blockquote')
  },
  {
    title: 'Horizontal Rule',
    action: () => props.editor?.chain().focus().setHorizontalRule().run()
  },
  {
    title: 'Hard Break',
    action: () => props.editor?.chain().focus().setHardBreak().run()
  },
  {
    title: 'Undo',
    action: () => props.editor?.chain().focus().undo().run(),
    canRun: () => props.editor?.can().chain().focus().undo().run()
  },
  {
    title: 'Redo',
    action: () => props.editor?.chain().focus().redo().run(),
    canRun: () => props.editor?.can().chain().focus().redo().run()
  },
  {
    title: 'Purple',
    action: () => props.editor?.chain().focus().setColor('#958DF1').run(),
    isActive: () => props.editor?.isActive('textStyle', { color: '#958DF1' })
  }
]);
</script>
<template>
  <div class="d-flex ga-2 flex-wrap pa-5 menuBar" v-if="props.editor && rerenderTrigger >= 0">
    <template v-for="(item, index) in items" :key="index">
      <button :class="{ 'is-active': item.isActive?.() }" :disabled="item.canRun ? !item.canRun() : false" @click="item.action">
        {{ item.title }}
      </button>
    </template>
  </div>
</template>
<style lang="scss">
.divider {
  width: 2px;
  height: 1.25rem;
  background-color: rgba(#000, 0.1);
  margin-left: 0.5rem;
  margin-right: 0.75rem;
}
.menuBar {
  border: 1px solid rgb(var(--v-theme-inputBorder), 0.3);
  border-bottom: 0;
  border-radius: 12px 12px 0 0;
  button {
    padding: 10px;
    line-height: 1.15;
    background-color: rgb(var(--v-theme-inputBorder), 0.3);
    border-radius: 4px;
    border: none;
    &.is-active {
      color: #fff;
      background-color: rgb(var(--v-theme-primary));
    }
    &:disabled {
      opacity: 0.5;
    }
  }
}
</style>
