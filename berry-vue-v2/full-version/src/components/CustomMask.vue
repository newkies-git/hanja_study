<template>
  <UiChildCard title="Custom">
    <v-text-field
      v-model="maskedValue"
      color="primary"
      variant="outlined"
      label="Make Mask to apply bottom input"
      hide-details
      class="mb-5"
    />
    <v-text-field v-model="inputValue" @input="applyMask" color="primary" label="Masked Input" variant="outlined" hide-details />
  </UiChildCard>
</template>

<script setup>
import { ref } from 'vue';

import UiChildCard from '@/components/shared/UiChildCard.vue';

const maskedValue = ref('');
const inputValue = ref('');

const applyMask = (event) => {
  if (!maskedValue.value) return;

  const value = event.target.value.replace(/\D/g, '');
  let masked = '';
  let valueIndex = 0;

  for (let i = 0; i < maskedValue.value.length && valueIndex < value.length; i++) {
    if (maskedValue.value[i] === '#') {
      masked += value[valueIndex];
      valueIndex++;
    } else {
      masked += maskedValue.value[i];
    }
  }

  inputValue.value = masked;
};

defineExpose({
  maskedValue,
  inputValue
});
</script>
