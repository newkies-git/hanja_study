<script setup lang="ts">
import { useContactStore } from '@/stores/apps/contact';
const store = useContactStore();
const props = defineProps({
  getContacts: Object
});

defineEmits(['openDrawer']);
</script>

<template>
  <div v-for="contact in props.getContacts" :key="contact.name">
    <h3 v-if="typeof contact === 'string'" class="text-primary mt-5 mb-0">
      {{ contact }}
    </h3>
    <div v-else class="d-flex align-center ga-4 py-4 bb">
      <img :src="contact.avatar" :alt="contact.avatar" width="48" class="me-2" />
      <div class="cursor-pointer w-50" @click="($emit('openDrawer'), store.SelectContact(contact.id))">
        <h4>
          {{ contact.name }}
        </h4>
        <h6 class="opacity-60">
          {{ contact.role }}
        </h6>
      </div>

      <div class="d-flex align-center ga-2 ms-auto">
        <v-btn color="primary" variant="outlined" size="small" icon rounded="sm">
          <MessageIcon stroke-width="1.5" width="20" />
          <v-tooltip activator="parent" location="top"> Message </v-tooltip>
        </v-btn>

        <v-btn color="secondary" variant="outlined" size="small" icon rounded="sm">
          <PhoneIcon stroke-width="1.5" width="20" />
          <v-tooltip activator="parent" location="top"> Call </v-tooltip>
        </v-btn>
      </div>
    </div>
  </div>
</template>
<style lang="scss">
.bb {
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
}
</style>
