<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const valid = ref(false);
const logform = ref();
const email = ref('');
// Email validation rules
const emailRules = ref([
  (v: string) => !!v.trim() || 'E-mail is required',
  (v: string) => {
    const trimmedEmail = v.trim();
    return !/\s/.test(trimmedEmail) || 'E-mail must not contain spaces';
  },
  (v: string) => /.+@.+\..+/.test(v.trim()) || 'E-mail must be valid'
]);

const router = useRouter();

function validate() {
  if (logform.value && logform.value.validate()) {
    router.push('/starter');
  }
}
</script>

<template>
  <h4 class="my-4 mb-8 font-weight-regular text-medium-emphasis">Enter your email address below and we'll send you password reset OTP.</h4>
  <v-form ref="logform" lazy-validation v-model="valid" action="/starter" @submit.prevent="validate" class="mt-7 loginForm">
    <v-text-field
      v-model="email"
      :rules="emailRules"
      label="Email Address / Username"
      class="mt-4 mb-8"
      required
      hide-details="auto"
      @input="email = email.trim()"
    ></v-text-field>

    <v-btn color="secondary" block class="mt-2" variant="flat" size="large" :disabled="!valid" type="submit">Send Mail </v-btn>
  </v-form>
  <div class="mt-5 text-end">
    <v-divider />
    <v-btn variant="plain" to="/login1" class="mt-2 text-capitalize mr-n2">Already have an account?</v-btn>
  </div>
</template>
