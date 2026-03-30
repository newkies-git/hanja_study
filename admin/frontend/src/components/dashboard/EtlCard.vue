<script setup lang="ts">
defineProps<{
  firebaseInitError: string | null | undefined;
  basisCollection: string;
  extendCollection: string;
  strokeCollection: string;
  wordCollection: string;
  etlRunning: boolean;
  etlProgress: { processed: number; written: number; errors: number } | null;
  etlMessage: string;
}>();

const emit = defineEmits<{
  (e: 'etlCurrent'): void;
  (e: 'etlAll'): void;
}>();
</script>

<template>
  <div class="mt-6 bg-surface-container-low rounded-3xl p-6">
    <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
      <div>
        <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">ETL</div>
        <div class="mt-1 text-lg font-headline font-extrabold tracking-tight">hanja_extend 생성/갱신</div>
        <div class="text-sm text-on-surface-variant mt-2">
          source <span class="font-mono">{{ basisCollection }}</span>
          <span class="text-on-surface-variant/60 px-2">•</span>
          target <span class="font-mono">{{ extendCollection }}</span>
        </div>
        <div class="text-[11px] text-on-surface-variant mt-2">
          planned: <span class="font-mono">{{ strokeCollection }}</span>, <span class="font-mono">{{ wordCollection }}</span>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <button
          class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-surface-container-lowest hover:bg-surface-container-high transition-colors disabled:opacity-50"
          :disabled="etlRunning || !!firebaseInitError"
          @click="emit('etlCurrent')"
        >
          ETL (현재 페이지)
        </button>
        <button
          class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-gradient-to-b from-primary to-primary-container text-on-primary shadow-ambient disabled:opacity-50"
          :disabled="etlRunning || !!firebaseInitError"
          @click="emit('etlAll')"
        >
          ETL (전체)
        </button>
      </div>
    </div>
    <div v-if="etlProgress" class="mt-4 text-sm text-on-surface-variant">
      processed <span class="font-semibold text-on-surface">{{ etlProgress.processed }}</span>
      <span class="px-2 text-on-surface-variant/60">•</span>
      written <span class="font-semibold text-on-surface">{{ etlProgress.written }}</span>
      <span class="px-2 text-on-surface-variant/60">•</span>
      errors <span class="font-semibold text-on-surface">{{ etlProgress.errors }}</span>
    </div>
    <div v-if="etlMessage" class="mt-3 text-sm text-on-surface-variant whitespace-pre-line">
      {{ etlMessage }}
    </div>
  </div>
</template>

