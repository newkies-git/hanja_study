<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth, firebaseInitError } from '../firebase';

const router = useRouter();
const email = ref('');
const password = ref('');
const errorMessage = ref('');
const isLoading = ref(false);
const showPassword = ref(false);

const handleLogin = async () => {
  if (!auth) {
    errorMessage.value = firebaseInitError ?? 'Firebase 초기화에 실패했습니다.';
    return;
  }
  isLoading.value = true;
  errorMessage.value = '';
  try {
    await signInWithEmailAndPassword(auth, email.value, password.value);
    await router.push('/dashboard');
  } catch (error: any) {
    errorMessage.value = error.message || '로그인에 실패했습니다.';
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="bg-background font-body text-on-surface min-h-screen flex flex-col overflow-hidden">
    <main class="flex-grow flex items-center justify-center relative px-6">
      <div class="absolute top-0 left-0 w-full h-full overflow-hidden z-0">
        <div class="absolute -top-10 -left-10 font-bold text-[12rem] leading-none opacity-[0.03] select-none pointer-events-none">
          學
        </div>
        <div class="absolute bottom-20 right-20 font-bold text-[12rem] leading-none opacity-[0.03] select-none pointer-events-none">
          書
        </div>
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/5 rounded-full blur-[100px]"></div>
      </div>

      <div class="relative z-10 w-full max-w-5xl flex flex-col md:flex-row shadow-2xl rounded-xl overflow-hidden bg-surface-container-lowest border border-outline-variant/20">
        <div class="hidden md:flex md:w-5/12 bg-gradient-to-b from-primary to-primary-container p-12 flex-col justify-between text-on-primary">
          <div>
            <div class="flex items-center gap-3 mb-12">
              <div class="w-10 h-10 bg-white/20 backdrop-blur rounded-lg flex items-center justify-center">
                <span class="material-symbols-outlined text-white" style="font-variation-settings: 'FILL' 1;">history_edu</span>
              </div>
              <span class="font-headline font-extrabold text-xl tracking-tight">Hanja Archive</span>
            </div>
            <h1 class="font-headline text-4xl font-bold leading-tight mb-6">The Scholarly <br />Curator</h1>
            <p class="text-on-primary-container/80 text-sm leading-relaxed max-w-xs">
              Access the Editorial Database Management System. Orchestrating thousands of years of Sino-Korean etymology with modern precision.
            </p>
          </div>
          <div class="space-y-4">
            <div class="flex items-center gap-4 py-3 px-4 rounded-lg bg-white/10 backdrop-blur-sm border border-white/10">
              <span class="material-symbols-outlined text-white/70">verified_user</span>
              <span class="text-xs font-medium tracking-wide uppercase">Institutional Access Only</span>
            </div>
            <div class="text-[10px] text-white/40 uppercase tracking-[0.2em]">
              Lexicon Authority
            </div>
          </div>
        </div>

        <div class="w-full md:w-7/12 p-8 md:p-16 flex flex-col justify-center bg-surface-container-lowest">
          <div class="mb-10">
            <h2 class="font-headline text-2xl font-bold text-on-surface mb-2">Admin Authentication</h2>
            <p class="text-on-surface-variant text-sm">관리자 계정으로 로그인해 대시보드에 접근합니다.</p>
          </div>

          <div v-if="firebaseInitError" class="mb-6 text-sm text-amber-700 bg-amber-50 border border-amber-200 rounded-md p-3">
            {{ firebaseInitError }}
          </div>
          <div v-if="errorMessage" class="mb-6 text-sm text-red-700 bg-red-50 border border-red-200 rounded-md p-3 whitespace-pre-line">
            {{ errorMessage }}
          </div>

          <form class="space-y-6" @submit.prevent="handleLogin">
            <div class="space-y-2">
              <label class="block text-xs font-semibold text-on-secondary-container uppercase tracking-wider" for="email">
                Email Address
              </label>
              <div class="relative group">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <span class="material-symbols-outlined text-outline text-lg">alternate_email</span>
                </div>
                <input
                  id="email"
                  v-model="email"
                  name="email"
                  type="email"
                  autocomplete="email"
                  required
                  placeholder="scholar@hanja-archive.org"
                  class="block w-full pl-11 pr-4 py-4 bg-surface-container-high border-none rounded-lg text-on-surface placeholder:text-outline/60 focus:ring-2 focus:ring-primary/40 transition-all duration-300"
                />
              </div>
            </div>

            <div class="space-y-2">
              <div class="flex justify-between items-center">
                <label class="block text-xs font-semibold text-on-secondary-container uppercase tracking-wider" for="password">
                  Password
                </label>
                <span class="text-xs font-medium text-outline select-none">Forgot password?</span>
              </div>
              <div class="relative group">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <span class="material-symbols-outlined text-outline text-lg">lock</span>
                </div>
                <input
                  id="password"
                  v-model="password"
                  name="password"
                  :type="showPassword ? 'text' : 'password'"
                  autocomplete="current-password"
                  required
                  placeholder="••••••••"
                  class="block w-full pl-11 pr-12 py-4 bg-surface-container-high border-none rounded-lg text-on-surface placeholder:text-outline/60 focus:ring-2 focus:ring-primary/40 transition-all duration-300"
                />
                <button
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-outline hover:text-on-surface"
                  type="button"
                  @click="showPassword = !showPassword"
                >
                  <span class="material-symbols-outlined text-lg">
                    {{ showPassword ? 'visibility_off' : 'visibility' }}
                  </span>
                </button>
              </div>
            </div>

            <div class="pt-4">
              <button
                class="w-full bg-gradient-to-b from-primary to-primary-container text-on-primary font-headline font-bold py-4 px-6 rounded-lg flex items-center justify-center gap-2 group hover:shadow-lg hover:shadow-primary/20 transition-all active:scale-[0.98] disabled:opacity-50"
                type="submit"
                :disabled="isLoading || !!firebaseInitError"
              >
                <span v-if="isLoading">로그인 중...</span>
                <span v-else class="inline-flex items-center gap-2">
                  Login to Dashboard
                  <span class="material-symbols-outlined text-lg group-hover:translate-x-1 transition-transform">arrow_forward</span>
                </span>
              </button>
            </div>

            <div class="pt-6 border-t border-outline-variant/20">
              <div class="flex items-center gap-4 text-sm text-on-surface-variant">
                <span class="w-2 h-2 rounded-full bg-secondary"></span>
                <span>{{ auth ? 'Secure connection ready.' : 'Awaiting Firebase configuration...' }}</span>
              </div>
            </div>
          </form>
        </div>
      </div>
    </main>

    <footer class="flex justify-between items-center px-8 md:px-12 py-6 w-full bg-background border-t border-outline-variant/20">
      <div class="text-on-surface-variant font-inter text-xs tracking-wide uppercase">
        © 2026 Hanja Lexicon Authority. Editorial Database Management System.
      </div>
      <div class="hidden sm:flex gap-8">
        <a class="text-on-surface-variant hover:text-primary underline-offset-4 hover:underline font-inter text-xs tracking-wide uppercase" href="#">
          Privacy Policy
        </a>
        <a class="text-on-surface-variant hover:text-primary underline-offset-4 hover:underline font-inter text-xs tracking-wide uppercase" href="#">
          Terms of Access
        </a>
        <span class="text-on-surface font-inter text-xs tracking-wide uppercase">Institutional Login</span>
      </div>
    </footer>
  </div>
</template>
