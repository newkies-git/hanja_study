<script setup>
import { ref, watch } from 'vue';
const props = defineProps({
  dialogs: Object
});
const text = ref(
  'If youre coming from a Series 3, the choice is more difficult. The Series 4 is undoubtedly the better device. And if you care about fall detection, the ECG app, or a larger screen then upgrading makes sense. But I think most people will remain satisfied with their Series 3s.'
);
const items = ref(['Pending', 'Published', 'Confirm']);
const ratting = ref(3.5);

const emit = defineEmits(['update:dialogs', 'close']);
const dialogVisible = ref(props.dialogs.dialog);

// Watch for changes in the prop and update the local state accordingly
watch(
  () => props.dialogs.dialog,
  (newValue) => {
    dialogVisible.value = newValue;
  }
);

watch(dialogVisible, (newValue) => {
  emit('update:dialogs', { ...props.dialogs, dialog: newValue });
});
</script>
<template>
  <v-dialog v-model="dialogVisible" max-width="400">
    <v-card>
      <v-card-text>
        <h3 class="mb-8">Edit Review</h3>
        <v-text-field variant="outlined" label="Product" model-value="Apple Watch Series 4" />
        <v-text-field variant="outlined" label="Author" model-value="Joseph William" />
        <v-textarea v-model="text" variant="outlined" label="Text of Review" />
        <div class="mb-2">Rating</div>
        <v-rating v-model="ratting" background-color="orange lighten-3" color="warning" density="compact" half-increments hover size="16" />
        <br />
        <v-select :items="items" label="Outlined variant" variant="outlined" model-value="Pending" class="mt-5" />
      </v-card-text>
      <v-card-actions>
        <v-btn color="primary" variant="flat" @click="$emit('close')"> Create </v-btn
        ><v-btn variant="flat" @click="$emit('close')"> Cancel </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
