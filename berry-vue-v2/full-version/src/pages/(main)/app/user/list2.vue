<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useUserCardStore } from '@/stores/apps/UserCard';
import user1 from '@/assets/images/users/avatar-1.png';
import user2 from '@/assets/images/users/avatar-2.png';
import user3 from '@/assets/images/users/avatar-3.png';
// common components
import UiParentCard from '@/components/shared/UiParentCard.vue';

const store = useUserCardStore();

onMounted(() => {
  store.fetchlist2Cards();
});
const searchValue = ref('');
type ListItem = {
  image: string;
  badgeStatus: string;
  name: string;
  designation: string;
  subContent: string;
  email: string;
  phone: number;
  location: string;
  progressValue: number;
  // Add other properties as needed
};
const listCards = computed<ListItem[]>(() => {
  return store.list2;
});

const page1 = ref(1);
</script>
<template>
  <v-row>
    <v-col cols="12" md="12">
      <UiParentCard title="Customer List">
        <template v-slot:action>
          <v-row class="justify-end">
            <v-col cols="12" md="3" sm="5">
              <v-text-field
                hide-details
                persistent-placeholder
                placeholder="Search"
                prepend-inner-icon="$magnify"
                v-model="searchValue"
                class="w-100 mt-sm-0 mt-2"
              >
              </v-text-field>
            </v-col>
          </v-row>
        </template>
        <v-row v-for="card in listCards" :key="card.name">
          <v-col md="3" sm="5" cols="12" class="mt-2">
            <div class="d-flex align-start ga-4">
              <img :src="card.image" alt="avatar" width="50" />

              <div>
                <h5>
                  {{ card.name }}
                  <v-btn icon v-if="card.badgeStatus == 'active'" flat color="success" size="small" readonly class="verifybtn">
                    <CheckIcon size="10" />
                  </v-btn>
                </h5>
                <small class="text-subtitle">{{ card.designation }}</small>
                <p class="text-body-small mt-2">{{ card.subContent }}</p>
              </div>
            </div>
          </v-col>
          <v-col md="2" sm="3" cols="6">
            <small>Email</small>
            <h6>{{ card.email }}</h6>
            <small class="mt-2 d-block">Phone</small>
            <h6>{{ card.phone }}</h6>
          </v-col>
          <v-col md="2" sm="3" cols="6">
            <small>Location</small>
            <h6>{{ card.location }}</h6>
            <div class="avatarBox mt-4">
              <v-avatar variant="flat" size="small">
                <v-img :src="user1" alt="John"></v-img>
              </v-avatar>
              <v-avatar variant="flat" size="small">
                <v-img :src="user2" alt="John"></v-img>
              </v-avatar>
              <v-avatar variant="flat" size="small">
                <v-img :src="user3" alt="John"></v-img>
              </v-avatar>
              <v-avatar color="lightsecondary" variant="flat" size="small">
                <span class="text-headline-medium">2</span>
              </v-avatar>
            </div>
          </v-col>
          <v-col md="5" sm="6" cols="12">
            <div class="d-flex align-center ga-4 mb-5">
              <span>Progress</span>
              <v-progress-linear
                class="progress-position"
                :model-value="card.progressValue"
                background-color="pink lighten-3"
                color="secondary"
              ></v-progress-linear>
              <span>{{ card.progressValue }}</span>
            </div>
            <v-row>
              <v-col col="6">
                <v-btn color="secondary" variant="outlined" block size="small"><MessageIcon size="16" class="me-1" /> Message</v-btn>
              </v-col>
              <v-col col="6">
                <v-btn color="error" variant="outlined" block size="small"><BanIcon size="16" class="me-1" /> Block</v-btn>
              </v-col>
            </v-row>
          </v-col>
          <v-col md="12" cols="12"><v-divider class="py-2" /></v-col>
        </v-row>
        <v-pagination density="compact" class="left-pagination" v-model="page1" active-color="primary" rounded="circle" :length="6">
        </v-pagination>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
<style lang="scss">
.verifybtn {
  height: 12px !important;
  width: 12px !important;
  margin-top: -3px;
}
.avatarBox {
  .v-avatar {
    margin-left: -5px;
  }
}
.left-pagination .v-pagination__list {
  justify-content: start;
}
.progress-position {
  min-width: 80px;
}
</style>
