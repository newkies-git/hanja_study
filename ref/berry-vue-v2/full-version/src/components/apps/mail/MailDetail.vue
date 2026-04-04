<script setup lang="ts">
import { shallowRef } from 'vue';
// third-party
import { format } from 'date-fns';
const props = defineProps({
  selectedMail: Object || Array
});
const sorting = shallowRef([{ title: 'Name' }, { title: 'Date' }, { title: 'Rating' }, { title: 'Unread' }]);

defineEmits(['toggleDetail']);
</script>

<template>
  <div class="topbarMail d-flex ga-4 align-center w-100">
    <v-btn icon flat size="small" @click="$emit('toggleDetail')">
      <ChevronLeftIcon size="18" />
    </v-btn>
    <div class="d-flex align-center ga-4 w-100">
      <img :src="props.selectedMail?.profile.avatar" :alt="props.selectedMail?.profile.avatar" width="40" />
      <div>
        <h4 class="mb-n1">
          {{ props.selectedMail?.profile.name }}
        </h4>
        <small>From: {{ props.selectedMail?.profile.email }}</small>
      </div>
      <div class="ms-auto text-body-small text-medium-emphasis">
        {{ format(new Date(selectedMail?.time!), 'd MMM') }}
      </div>
    </div>
  </div>
  <div class="d-flex align-center ga-2 mt-3">
    <h3 class="py-4 me-auto">
      {{ selectedMail?.subject }}
    </h3>
    <v-btn icon size="small" flat>
      <v-icon v-if="selectedMail?.starred" color="warning" icon="$star"> </v-icon>
      <v-icon icon="$starOutline" v-else> </v-icon>
    </v-btn>
    <v-btn icon size="small" flat>
      <v-icon v-if="selectedMail?.important" color="secondary" icon="$label"> </v-icon>
      <v-icon icon="$labelOutline" v-else> </v-icon>
    </v-btn>
    <v-btn id="menu-activator" icon size="small" flat>
      <DotsIcon size="16" />
    </v-btn>
    <v-menu activator="#menu-activator" width="100">
      <v-list>
        <v-list-item v-for="(item, index) in sorting" :key="index" :value="index">
          <v-list-item-title>{{ item.title }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
  </div>
  <div class="py-4 text-body-large">
    <span class="font-weight-light">Dear {{ selectedMail?.profile.name }},</span><br /><br />
    <p class="font-weight-light">{{ selectedMail?.message }}</p>
    <br />
    <p class="font-weight-light mb-1">Kindly Regards,</p>
    <p class="font-weight-light">{{ selectedMail?.sender.name }}</p>
  </div>
  <div class="py-3">
    <h5>
      <v-icon icon="$attachment"></v-icon>
      {{ selectedMail?.attachments.length }} Attachement
    </h5>
    <v-row class="mt-4">
      <v-col v-for="attach in selectedMail?.attachments" :key="attach.title" cols="6" sm="3">
        <v-card class="overflow-hidden">
          <v-img :src="attach.image" height="100px" cover />
          <div class="pa-3">
            <div class="d-flex align-center">
              <h5 class="me-auto text-truncate">
                {{ attach.title }}
              </h5>
              <v-btn icon size="small" flat>
                <DownloadIcon size="16" />
              </v-btn>
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>
  </div>
  <div class="py-3 d-flex ga-4">
    <v-btn color="primary" variant="outlined"> <v-icon icon="$reply"></v-icon> Reply </v-btn>
    <v-btn color="primary" variant="outlined"> <v-icon icon="$forward"></v-icon> Forward </v-btn>
  </div>
</template>
