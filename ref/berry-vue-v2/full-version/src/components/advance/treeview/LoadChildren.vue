<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// assets
import avatar1 from '@/assets/images/users/avatar-1.png';
import avatar2 from '@/assets/images/users/avatar-2.png';
import avatar3 from '@/assets/images/users/avatar-3.png';
import avatar4 from '@/assets/images/users/avatar-4.png';
import avatar5 from '@/assets/images/users/avatar-5.png';

type User = {
  id: string;
  avatar: string;
  name: string;
  email: string;
  location: string;
};

// Reactive user list for treeview children
const users = ref<User[]>([]);
const response = await fetch('https://mock-data-api-nextjs.vercel.app/api/user-list/s1/list');
if (!response.ok) {
  throw new Error(`HTTP error! status: ${response.status}`);
}
const avatar = ref<string | undefined>(undefined);
const active = ref<string[]>([]); // id is string now
const open = ref<string[]>([]);

const items = computed(() => [
  {
    id: 'users',
    name: 'Users',
    children: users.value
  }
]);

const selected = computed<User | undefined>(() => {
  const id = active.value[0];
  return users.value.find((user) => user.id === id);
});

// Safe avatar URL
const avatarMap: Record<string, string> = {
  'avatar-1.png': avatar1,
  'avatar-2.png': avatar2,
  'avatar-3.png': avatar3,
  'avatar-4.png': avatar4,
  'avatar-5.png': avatar5,
  'avatar-6.png': avatar1,
  'avatar-7.png': avatar2,
  'avatar-8.png': avatar3,
  'avatar-9.png': avatar4,
  'avatar-10.png': avatar5
  // ...
};
function generateAvatarUrl(user: User): string {
  return avatarMap[user.avatar] ?? '';
}
const pause = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

// Fetch users from API directly
async function fetchUsers(item: unknown): Promise<void> {
  if (typeof item === 'object' && item !== null) {
    const node = item as { children?: User[] };
    if (!node.children) node.children = [];
    if (node.children.length > 0) return;

    await pause(5000);

    const response = await fetch('https://mock-data-api-nextjs.vercel.app/api/user-list/s1/list');
    const data: { users_s1: User[] } = await response.json();

    // Set only the users array
    users.value = data.users_s1;

    node.children.splice(0, node.children.length, ...users.value);
  }
}

watch(selected, (user) => {
  if (user) {
    avatar.value = generateAvatarUrl(user);
  } else {
    avatar.value = undefined;
  }
});

// Initial fetch on mount for root users node
onMounted(async () => {
  await fetchUsers({ children: users.value });
});
</script>

<template>
  <UiChildCard title="Load children">
    <v-row justify="space-between" density="comfortable">
      <v-col cols="12" md="5">
        <v-treeview
          v-model:activated="active"
          v-model:opened="open"
          :items="items"
          :load-children="fetchUsers"
          density="compact"
          item-title="name"
          item-value="id"
          activatable
          border
          fluid
          open-on-click
          rounded
        />
      </v-col>

      <v-col cols="12" md="7" class="text-center d-flex">
        <v-card color="surface-light" rounded flat height="100%" class="flex-1-1 d-flex justify-center align-center text-headline-small">
          <template #text>
            <div v-if="!selected">Select a User</div>
            <template v-else>
              <v-avatar :image="avatar" class="mb-2 d-inline-block" size="88" alt="user image" />
              <h3 class="text-headline-medium mb-2">{{ selected.name }}</h3>
              <h5 class="text-medium-emphasis mb-1"><span class="text-darkText">Email :</span> {{ selected.email }}</h5>
              <h5 class="text-medium-emphasis">
                <span class="text-darkText">Location :</span>
                {{ selected.location }}
              </h5>
            </template>
          </template>
        </v-card>
      </v-col>
    </v-row>
  </UiChildCard>
</template>
