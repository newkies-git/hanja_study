<script setup lang="ts">
import type { CsvPreview } from '../../composables/dashboardTypes';

defineProps<{
  firebaseInitError: string | null | undefined;
  csvFileName: string;
  csvPreview: CsvPreview | null;
  csvImporting: boolean;
  successMessage: string;
  importStatus: {
    phase: 'idle' | 'validating' | 'uploading' | 'done';
    fileName: string;
    totalRows: number;
    validRows: number;
    invalidRows: number;
    uniqueDocs: number;
    duplicates: number;
    committedDocs: number;
    totalBatches: number;
    committedBatches: number;
  } | null;
  lastImportDocIdsCount: number;
  lastImportSummary: {
    fileName: string;
    totalRows: number;
    uniqueDocs: number;
    duplicates: number;
    committedDocs: number;
    invalidRows: number;
    startedAtIso: string;
    finishedAtIso: string;
  } | null;
}>();

const emit = defineEmits<{
  (e: 'select', ev: Event): void;
  (e: 'upload'): void;
  (e: 'deleteLastImportAll'): void;
}>();
</script>

<template>
  <div class="mt-6 bg-surface-container-lowest rounded-3xl p-6 shadow-ambient">
    <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div class="flex items-center gap-3">
        <label class="text-[10px] font-bold tracking-[0.25em] uppercase text-on-surface-variant">CSV</label>
        <input
          type="file"
          accept=".csv,text/csv"
          class="block text-xs"
          :disabled="csvImporting || !!firebaseInitError"
          @change="emit('select', $event)"
        />
        <span v-if="csvFileName" class="text-xs text-on-surface-variant">
          선택됨: <span class="font-semibold text-on-surface">{{ csvFileName }}</span>
        </span>
      </div>
      <button
        class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-gradient-to-b from-primary to-primary-container text-on-primary shadow-ambient disabled:opacity-50"
        :disabled="csvImporting || !csvPreview || !!firebaseInitError"
        @click="emit('upload')"
      >
        <span v-if="csvImporting">CSV 업로드 중...</span>
        <span v-else>CSV 업로드 (Upsert)</span>
      </button>
    </div>
    <div v-if="importStatus" class="mt-4 text-sm text-on-surface-variant bg-surface-container-low rounded-2xl p-4">
      <div class="flex items-center justify-between gap-3">
        <div class="font-semibold text-on-surface">업로드 현황</div>
        <div class="text-[11px] font-mono">{{ importStatus.phase }}</div>
      </div>
      <div class="mt-2 text-xs leading-6">
        총 <span class="font-semibold text-on-surface">{{ importStatus.totalRows }}</span>행 중
        유효 <span class="font-semibold text-on-surface">{{ importStatus.validRows }}</span> /
        오류 <span class="font-semibold text-on-surface">{{ importStatus.invalidRows }}</span><br />
        유니크(문서) <span class="font-semibold text-on-surface">{{ importStatus.uniqueDocs }}</span> /
        중복(행) <span class="font-semibold text-on-surface">{{ importStatus.duplicates }}</span><br />
        커밋 <span class="font-semibold text-on-surface">{{ importStatus.committedDocs }}</span>건
        <span v-if="importStatus.totalBatches" class="text-on-surface-variant/60">
          (batch {{ importStatus.committedBatches }}/{{ importStatus.totalBatches }})
        </span>
      </div>
    </div>
    <div v-if="csvPreview" class="mt-3 text-xs text-on-surface-variant">
      헤더: <span class="font-mono">{{ csvPreview.headers.join(', ') }}</span><br />
      행 수: <span class="font-semibold text-on-surface">{{ csvPreview.rows.length }}</span>
    </div>
    <div v-if="successMessage" class="mt-4 text-sm text-emerald-700 bg-emerald-50 rounded-2xl p-4">
      {{ successMessage }}
    </div>
    <div v-if="lastImportSummary" class="mt-3 text-[11px] text-on-surface-variant">
      최근 업로드: <span class="font-semibold text-on-surface">{{ lastImportSummary.fileName }}</span>
      <span class="px-2 text-on-surface-variant/60">•</span>
      커밋 <span class="font-semibold text-on-surface">{{ lastImportSummary.committedDocs }}</span>
      <span class="px-2 text-on-surface-variant/60">•</span>
      유니크 <span class="font-semibold text-on-surface">{{ lastImportSummary.uniqueDocs }}</span>
      <span class="px-2 text-on-surface-variant/60">•</span>
      중복 <span class="font-semibold text-on-surface">{{ lastImportSummary.duplicates }}</span>
    </div>
    <div class="mt-4 flex items-center justify-end gap-2">
      <button
        class="text-xs font-semibold uppercase tracking-wider px-4 py-3 rounded-2xl bg-error/10 text-error hover:bg-error/15 transition-colors disabled:opacity-50"
        :disabled="csvImporting || lastImportDocIdsCount === 0 || !!firebaseInitError"
        @click="emit('deleteLastImportAll')"
      >
        업로드내역 전체삭제 ({{ lastImportDocIdsCount }})
      </button>
    </div>
  </div>
</template>

