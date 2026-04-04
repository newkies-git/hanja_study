<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const valid = ref(false);
const logform = ref();
const password = ref('');
const conpassword = ref('');
const show1 = ref(false);
const passwordRules = ref([
  (v: string) => !!v || 'Password is required',
  (v: string) => (v && v.length <= 10) || 'Password must be less than 10 characters'
]);
const confirmpasswordRules = ref([
  (v: string) => !!v || 'Password is required',
  (v: string) => (v && v.length <= 10) || 'Password must be less than 10 characters'
]);

const router = useRouter();

function validate() {
  // logform.value.validate();
  if (logform.value && logform.value.validate()) {
    router.push('/starter');
  }
}
</script>

<template>
  <h4 class="my-4 mb-8 font-weight-regular text-medium-emphasis">Enter your email address below and we'll send you password reset OTP.</h4>
  <v-form ref="logform" lazy-validation v-model="valid" action="/starter" @submit.prevent="validate" class="mt-7 loginForm">
    <v-text-field
      v-model="password"
      :rules="passwordRules"
      label="Password"
      required
      hide-details="auto"
      :append-inner-icon="show1 ? '$eye' : '$eyeOff'"
      :type="show1 ? 'text' : 'password'"
      @click:append-inner="show1 = !show1"
      class="pwdInput mb-4"
    ></v-text-field>

    <v-text-field
      v-model="conpassword"
      :rules="confirmpasswordRules"
      label="Confirm Password"
      required
      hide-details="auto"
      class="pwdInput"
    ></v-text-field>

    <v-btn color="secondary" block class="mt-5" variant="flat" size="large" :disabled="!valid" type="submit">Reset Password </v-btn>
  </v-form>
</template>
