<script setup>
import { useI18n } from 'vue-i18n';
const { t } = useI18n();

const props = defineProps({ item: Object });
</script>

<template>
  <v-list-subheader color="darkText" class="smallCap">
    {{ t(props.item.header) }}
  </v-list-subheader>
</template>
