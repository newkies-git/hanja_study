<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
const { t } = useI18n();

import Icon from '../IconSet.vue';

const props = defineProps({ item: Object, level: Number });

const baseURL = import.meta.env.BASE_URL;

const propsForLink = computed(() => {
  // open in new tab with full URL
  if (props.item.getURL) {
    return {
      href: baseURL + props.item.to.replace(/^\//, ''),
      target: '_blank'
    };
  }

  // external links
  if (props.item.type === 'external') {
    return {
      href: props.item.to,
      target: '_blank'
    };
  }

  // internal vue-router navigation
  return {
    to: props.item.to
  };
});
</script>

<template>
  <!---Single Item-->
  <v-list-item v-bind="propsForLink" rounded class="mb-1" color="secondary" :disabled="props.item.disabled">
    <template #prepend>
      <Icon :item="props.item.icon" :level="props.level" />
    </template>
    <v-list-item-title>
      {{ t(props.item.title) }}
      <v-badge :color="props.item.chipColor" v-if="props.item.chipColor === 'success'" :aria-label="props.item.chip" inline dot></v-badge>
    </v-list-item-title>
    <v-list-item-subtitle v-if="props.item.subCaption" class="text-label-small mt-n1 hide-menu">
      {{ t(props.item.subCaption) }}
    </v-list-item-subtitle>
    <template v-if="props.item.chip && props.item.chipColor !== 'success'" #append>
      <v-chip
        :color="props.item.chipColor"
        class="sidebarchip hide-menu"
        size="x-small"
        :variant="props.item.chipVariant"
        :prepend-icon="props.item.chipIcon"
      >
        {{ props.item.chip }}
      </v-chip>
    </template>
  </v-list-item>
</template>
