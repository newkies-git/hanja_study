<script setup>
import Icon from '../../vertical-sidebar/IconSet.vue';
const props = defineProps({ item: Object, level: Number });
</script>

<template>
  <!---Single Item-->
  <a
    v-if="item.type === 'external'"
    :href="item.to"
    class="navItemLink rounded-md"
    target="_blank"
    rel="noopener noreferrer"
    :aria-disabled="item.disabled ? 'true' : 'false'"
  >
    <i class="navIcon"> <Icon :item="props.item.icon" :level="props.level" /></i>
    <span>
      {{ item.title }}
      <v-badge :color="props.item.chipColor" v-if="props.item.chipColor === 'success'" :aria-label="props.item.chip" inline dot></v-badge>
    </span>
    <small v-if="item.subCaption" class="text-label-small mt-n1 hide-menu">
      {{ item.subCaption }}
    </small>
    <template v-if="props.item.chip && props.item.chipColor !== 'success'">
      <v-chip
        :color="item.chipColor"
        class="sidebarchip hide-menu ms-auto"
        size="x-small"
        :variant="item.chipVariant"
        :prepend-icon="item.chipIcon"
      >
        {{ item.chip }}
      </v-chip>
    </template>
  </a>

  <router-link v-else :to="`${item.to}`" class="navItemLink rounded-md" :disabled="item.disabled">
    <i class="navIcon"> <Icon :item="props.item.icon" :level="props.level" /></i>
    <span>
      {{ item.title }}
      <v-badge :color="props.item.chipColor" v-if="props.item.chipColor === 'success'" :aria-label="props.item.chip" inline dot></v-badge>
    </span>
    <small v-if="item.subCaption" class="text-label-small mt-n1 hide-menu">
      {{ item.subCaption }}
    </small>
    <template v-if="props.item.chip && props.item.chipColor !== 'success'">
      <v-chip
        :color="item.chipColor"
        class="sidebarchip hide-menu ms-auto"
        size="x-small"
        :variant="item.chipVariant"
        :prepend-icon="item.chipIcon"
      >
        {{ item.chip }}
      </v-chip>
    </template>
  </router-link>
</template>
