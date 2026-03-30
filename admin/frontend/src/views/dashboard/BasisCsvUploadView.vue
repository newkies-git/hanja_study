<script setup lang="ts">
import { ref } from 'vue';
import { db, firebaseInitError } from '../../firebase';
import { useCascadeDelete } from '../../composables/useCascadeDelete';
import { useCsvImport } from '../../composables/useCsvImport';
import CsvImportCard from '../../components/dashboard/CsvImportCard.vue';

const BASIS_COLLECTION = 'hanja_basis';
const EXTEND_COLLECTION = 'hanja_extend';
const STROKE_COLLECTION = 'hanja_stroke';
const WORD_COLLECTION = 'hanja_word';

const errorMessage = ref('');
const successMessage = ref('');

const { cascadeDeleteByHanjaIds } = useCascadeDelete({
  db,
  firebaseInitError,
  basisCollection: BASIS_COLLECTION,
  extendCollection: EXTEND_COLLECTION,
  strokeCollection: STROKE_COLLECTION,
  wordCollection: WORD_COLLECTION,
});

async function refresh() {
  // CSV 업로드 화면은 목록을 강제 리프레시할 필요가 없어 no-op 처리
}

const {
  csvFileName,
  csvPreview,
  csvImporting,
  importStatus,
  lastImportDocIds,
  lastImportSummary,
  onCsvSelected,
  importCsvUpsert,
  deleteLastImportAll,
} = useCsvImport({
  db,
  firebaseInitError,
  basisCollection: BASIS_COLLECTION,
  refresh,
  deleteByHanjaIds: cascadeDeleteByHanjaIds,
  errorMessage,
  successMessage,
});
</script>

<template>
  <div class="space-y-6">
    <div class="bg-surface-container-low rounded-3xl p-6">
      <div class="text-[10px] font-bold text-on-surface-variant tracking-[0.25em] uppercase">Hanja Basis</div>
      <h2 class="mt-1 text-2xl font-headline font-extrabold tracking-tight">CSV 업로드</h2>
      <p class="text-sm text-on-surface-variant mt-2">
        업로드 대상: <span class="font-mono">{{ BASIS_COLLECTION }}</span>
      </p>
    </div>

    <div v-if="errorMessage" class="text-sm text-error whitespace-pre-line">
      {{ errorMessage }}
    </div>

    <CsvImportCard
      :firebaseInitError="firebaseInitError"
      :csvFileName="csvFileName"
      :csvPreview="csvPreview"
      :csvImporting="csvImporting"
      :successMessage="successMessage"
      :importStatus="importStatus"
      :lastImportDocIdsCount="lastImportDocIds.length"
      :lastImportSummary="lastImportSummary"
      @select="onCsvSelected"
      @upload="importCsvUpsert"
      @deleteLastImportAll="deleteLastImportAll"
    />
  </div>
</template>

