<script setup lang="ts">
import { useContactStore } from '@/stores/apps/contact';
const store = useContactStore();
// dropdown data

const props = defineProps({
  getContacts: Object
});

defineEmits(['openDrawer']);
</script>
<template>
  <v-row class="mt-2">
    <v-col
      v-for="contact in props.getContacts"
      :key="contact.name"
      class="mt-lg-3"
      cols="12"
      :sm="typeof contact === 'string' ? '12' : '6'"
      :xl="typeof contact === 'string' ? '12' : '3'"
      :md="typeof contact === 'string' ? '12' : 'auto'"
    >
      <h3 v-if="typeof contact === 'string'" class="text-primary mt-lg-5 mt-4 d-block">
        {{ contact }}
      </h3>
      <v-card v-else variant="outlined" class="card-hover-border bg-gray100">
        <v-card-text>
          <div class="d-flex">
            <img :src="contact.avatar" :alt="contact.avatar" width="72" />
            <div class="ms-auto">
              <v-menu class="rounded-md">
                <template #activator="{ props }">
                  <v-btn icon size="x-small" v-bind="props" variant="text">
                    <DotsIcon width="20" stroke-width="1.5" />
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item value="Edit" color="secondary" @click="($emit('openDrawer'), store.SelectContact(contact.id))">
                    <v-list-item-title>Edit</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </div>
          </div>
          <div class="mb-4 mt-5">
            <h3>
              {{ contact.name }}
            </h3>
            <h6 class="text-medium-emphasis">{{ contact.role }}</h6>
            <br />
            <h6 class="text-medium-emphasis">Email</h6>
            <h6>
              {{ contact.work_email }}
            </h6>
            <v-row class="mt-3">
              <v-col cols="6">
                <h6 class="text-medium-emphasis">Phone</h6>
                <h6>
                  {{ contact.personal_phone }}
                </h6>
              </v-col>
              <v-col cols="6">
                <h6 class="text-medium-emphasis">Location</h6>
                <h6>
                  {{ contact.location }}
                </h6>
              </v-col>
            </v-row>
          </div>
          <div class="d-flex ga-4 mt-5">
            <v-btn variant="outlined" color="primary" class="flex-fill" prepend-icon="$messageOutline"> Message </v-btn>
            <v-btn variant="outlined" color="secondary" class="flex-fill" prepend-icon="$phoneOutline"> Call </v-btn>
          </div>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>
