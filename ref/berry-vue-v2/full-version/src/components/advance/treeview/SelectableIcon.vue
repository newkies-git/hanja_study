<script setup>
import { ref, watch } from 'vue';

const icons = ['$beer', '$glassMug', '$liquor', '$glassMugVariant'];

const breweries = ref([]);
const tree = ref([]);
const types = ref([]);
const opened = ref([]);
const items = ref([
  {
    id: 1,
    name: 'All Breweries',
    children: []
  }
]);

watch(breweries, (val) => {
  types.value = val
    .reduce((acc, cur) => {
      const type = cur.brewery_type;
      if (!acc.includes(type)) acc.push(type);
      return acc;
    }, [])
    .sort();

  const children = types.value.map((type) => ({
    id: type,
    name: getName(type),
    children: getChildren(type)
  }));
  const rootObj = items.value[0];
  rootObj.children = children;
  items.value = [rootObj];
});

function load() {
  if (breweries.value.length) return;

  return fetch('https://api.openbrewerydb.org/v1/breweries')
    .then((res) => res.json())
    .then((data) => (breweries.value = data))
    .catch((err) => console.log(err));
}

function getChildren(type) {
  const _breweries = [];
  for (const brewery of breweries.value) {
    if (brewery.brewery_type !== type) continue;
    _breweries.push({
      ...brewery,
      name: getName(brewery.name)
    });
  }
  return _breweries.sort((a, b) => {
    return a.name > b.name ? 1 : -1;
  });
}

function getIcon() {
  return icons[Math.floor(Math.random() * icons.length)];
}

function getName(name) {
  return `${name.charAt(0).toUpperCase()}${name.slice(1)}`;
}

function onClickClose(selection) {
  tree.value = tree.value.filter((item) => item.id !== selection.id);
}
</script>
<template>
  <v-card variant="outlined">
    <v-card-item class="py-3">
      <v-card-title class="text-headline-medium"> Selectable Icon </v-card-title>
    </v-card-item>
    <v-divider />
    <v-card-text class="pa-0">
      <v-toolbar color="surface-light" density="compact" title="Local hotspots" flat></v-toolbar>

      <v-row density="comfortable">
        <v-col cols="12" sm="6">
          <v-treeview
            v-model:selected="tree"
            v-model:opened="opened"
            :items="items"
            :load-children="load"
            false-icon="$bookmarkOutline"
            indeterminate-icon="$bookmarkMinus"
            item-title="name"
            item-value="id"
            select-strategy="classic"
            true-icon="$bookmark"
            return-object
            selectable
          ></v-treeview>
        </v-col>

        <v-col cols="12" sm="6">
          <v-card-text class="bg-containerBg">
            <h6 v-if="tree.length === 0" class="font-weight-light text-grey pa-4 text-center">Select your favorite breweries</h6>

            <div class="d-flex flex-wrap ga-1">
              <v-scroll-x-transition group hide-on-leave>
                <v-chip
                  v-for="selection in tree"
                  :key="selection.id"
                  :prepend-icon="getIcon()"
                  :text="selection.name"
                  color="primary"
                  size="small"
                  border
                  closable
                  label
                  @click:close="onClickClose(selection)"
                ></v-chip>
              </v-scroll-x-transition>
            </div>
          </v-card-text>
        </v-col>
      </v-row>

      <v-divider></v-divider>

      <div class="d-flex justify-space-between pa-5">
        <v-btn text="Reset" color="secondary" variant="flat" @click="tree = []"></v-btn>
        <v-btn append-icon="$contentSave" color="primary" text="Save" variant="flat" border></v-btn>
      </div>
    </v-card-text>
  </v-card>
</template>
