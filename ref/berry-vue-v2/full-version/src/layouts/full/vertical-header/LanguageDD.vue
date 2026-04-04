<script setup lang="ts">
import { shallowRef } from 'vue';
import { useI18n } from 'vue-i18n';

const { locale } = useI18n();

const languageDD = shallowRef([
  { title: 'English', subtext: 'UK', value: 'en' },
  { title: 'français', subtext: 'French', value: 'fr' },
  { title: 'Română', subtext: 'Romanian', value: 'ro' },
  { title: '中国人', subtext: 'Chinese', value: 'zhHans' }
]);

const setLocale = (value: string) => {
  locale.value = value;
};
</script>

<template>
  <!-- ---------------------------------------------- -->
  <!-- language DD -->
  <!-- ---------------------------------------------- -->
  <v-list>
    <v-list-item
      v-for="(item, index) in languageDD"
      :key="index"
      color="secondary"
      :active="locale === item.value"
      class="d-flex align-center"
      @click="setLocale(item.value)"
    >
      <v-list-item-title>
        <h5 class="font-weight-regular">
          {{ item.title }}
          <span class="text-disabled text-body-large pl-2">({{ item.subtext }})</span>
        </h5>
      </v-list-item-title>
    </v-list-item>
  </v-list>
</template>
