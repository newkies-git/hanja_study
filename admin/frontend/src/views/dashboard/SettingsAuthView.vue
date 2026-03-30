<script setup lang="ts">
import { auth, firebaseInitError } from '../../firebase';
import AuthDebugCard from '../../components/dashboard/AuthDebugCard.vue';
import { useAuthDebug } from '../../composables/useAuthDebug';

const { currentUser, tokenResult, tokenError, isAdminClaim, refreshToken } = useAuthDebug(auth);
void refreshToken(false);
</script>

<template>
  <div class="space-y-6">
    <div class="bg-surface-container-low rounded-3xl p-6">
      <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Settings</div>
      <h2 class="mt-1 text-2xl font-headline font-extrabold tracking-tight">Authentication</h2>
      <p class="text-sm text-on-surface-variant mt-2">관리자 권한/토큰/커스텀 클레임을 확인합니다.</p>
    </div>

    <AuthDebugCard
      :firebaseInitError="firebaseInitError"
      :currentUser="currentUser"
      :tokenResult="tokenResult"
      :tokenError="tokenError"
      :isAdminClaim="isAdminClaim"
      @refreshToken="refreshToken"
    />
  </div>
</template>

