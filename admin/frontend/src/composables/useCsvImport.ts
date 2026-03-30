import { ref } from 'vue';
import { doc, writeBatch, type Firestore } from 'firebase/firestore';
import type { CsvPreview, RawHanjaDraft } from './dashboardTypes';
import { draftToFirestore, requiredDraftErrors, unicodeDocIdFromHanja } from './useDashboardUtils';

export function useCsvImport(args: {
  db: Firestore | null | undefined;
  firebaseInitError: string | null | undefined;
  basisCollection: string;
  refresh: () => Promise<void>;
  deleteByHanjaIds: (ids: string[]) => Promise<void>;
  errorMessage: { value: string };
  successMessage: { value: string };
}) {
  const { db, firebaseInitError, basisCollection, refresh, deleteByHanjaIds, errorMessage, successMessage } = args;

  const csvFileName = ref('');
  const csvPreview = ref<CsvPreview | null>(null);
  const csvImporting = ref(false);
  const importStatus = ref<{
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
  } | null>(null);

  // 마지막 업로드에서 실제 upsert 대상으로 확정된 문서ID 목록(유니크)
  const lastImportDocIds = ref<string[]>([]);
  const lastImportSummary = ref<{
    fileName: string;
    totalRows: number;
    uniqueDocs: number;
    duplicates: number;
    committedDocs: number;
    invalidRows: number;
    startedAtIso: string;
    finishedAtIso: string;
  } | null>(null);

  function parseCsv(text: string): CsvPreview {
    const rows: string[][] = [];
    let row: string[] = [];
    let field = '';
    let i = 0;
    let inQuotes = false;

    const pushField = () => {
      row.push(field);
      field = '';
    };
    const pushRow = () => {
      const isAllEmpty = row.every((c) => !c.trim());
      if (!isAllEmpty) rows.push(row);
      row = [];
    };

    while (i < text.length) {
      const ch = text[i];
      if (inQuotes) {
        if (ch === '"') {
          const next = text[i + 1];
          if (next === '"') {
            field += '"';
            i += 2;
            continue;
          }
          inQuotes = false;
          i += 1;
          continue;
        }
        field += ch;
        i += 1;
        continue;
      }

      if (ch === '"') {
        inQuotes = true;
        i += 1;
        continue;
      }
      if (ch === ',') {
        pushField();
        i += 1;
        continue;
      }
      if (ch === '\n') {
        pushField();
        pushRow();
        i += 1;
        continue;
      }
      if (ch === '\r') {
        i += 1;
        continue;
      }
      field += ch;
      i += 1;
    }
    pushField();
    pushRow();

    if (!rows.length) return { headers: [], rows: [] };
    const headers = rows[0].map((h) => h.trim());
    const out: Record<string, string>[] = [];
    for (const r of rows.slice(1)) {
      const obj: Record<string, string> = {};
      for (let c = 0; c < headers.length; c++) {
        const k = headers[c] || `col_${c}`;
        obj[k] = (r[c] ?? '').trim();
      }
      const allEmpty = Object.values(obj).every((v) => !v);
      if (!allEmpty) out.push(obj);
    }
    return { headers, rows: out };
  }

  function pick(obj: Record<string, string>, keys: string[]): string {
    for (const k of keys) {
      if (obj[k] != null && obj[k].trim() !== '') return obj[k].trim();
      const kk = k.toLowerCase();
      for (const realKey of Object.keys(obj)) {
        if (realKey.toLowerCase() === kk && obj[realKey].trim() !== '') return obj[realKey].trim();
      }
    }
    return '';
  }

  function csvRowToDraft(r: Record<string, string>): RawHanjaDraft {
    return {
      hanja: pick(r, ['한자', 'hanja']).trim(),
      음: pick(r, ['음', 'reading']).trim(),
      훈: pick(r, ['훈', 'meaning']).trim(),
      전체: pick(r, ['전체']).trim(),
      훈음: pick(r, ['훈음']).trim(),
      구분: pick(r, ['구분', 'level']).trim(),
    };
  }

  async function onCsvSelected(ev: Event) {
    errorMessage.value = '';
    successMessage.value = '';
    const input = ev.target as HTMLInputElement;
    const f = input.files?.[0] ?? null;
    if (!f) return;
    csvFileName.value = f.name;
    const text = await f.text();
    try {
      csvPreview.value = parseCsv(text);
    } catch (e: any) {
      csvPreview.value = null;
      errorMessage.value = e?.message || String(e);
    }
  }

  async function importCsvUpsert() {
    errorMessage.value = '';
    successMessage.value = '';
    try {
      if (!db) throw new Error(firebaseInitError ?? 'Firestore 초기화 실패');
      if (!csvPreview.value) {
        errorMessage.value = 'CSV를 먼저 선택하세요.';
        return;
      }
      if (!csvPreview.value.headers.length) {
        errorMessage.value = 'CSV 헤더가 비어 있습니다.';
        return;
      }
      csvImporting.value = true;
      importStatus.value = {
        phase: 'validating',
        fileName: csvFileName.value || '(unknown)',
        totalRows: 0,
        validRows: 0,
        invalidRows: 0,
        uniqueDocs: 0,
        duplicates: 0,
        committedDocs: 0,
        totalBatches: 0,
        committedBatches: 0,
      };
      const startedAt = new Date();

      const drafts = csvPreview.value.rows.map(csvRowToDraft);
      importStatus.value.totalRows = drafts.length;
      const valid: RawHanjaDraft[] = [];
      const invalid: { idx: number; errors: string[]; id: string }[] = [];
      drafts.forEach((d, idx) => {
        const errs = requiredDraftErrors(d);
        if (errs.length) invalid.push({ idx, errors: errs, id: d.hanja });
        else valid.push(d);
      });
      importStatus.value.validRows = valid.length;
      importStatus.value.invalidRows = invalid.length;

      if (invalid.length) {
        const head = invalid
          .slice(0, 5)
          .map((x) => `#${x.idx + 2}(${x.id || 'no-id'}): ${x.errors.join(', ')}`)
          .join('\n');
        errorMessage.value =
          `CSV 검증 실패: ${invalid.length}개 행이 누락/오류입니다.\n` + head + (invalid.length > 5 ? '\n...' : '');
        return;
      }

      const byDocId = new Map<string, RawHanjaDraft>();
      for (const d of valid) {
        const docId = unicodeDocIdFromHanja(d.hanja);
        if (!docId) continue;
        byDocId.set(docId, d);
      }
      const unique = Array.from(byDocId.entries());
      lastImportDocIds.value = unique.map(([docId]) => docId);
      importStatus.value.uniqueDocs = unique.length;
      importStatus.value.duplicates = Math.max(0, drafts.length - unique.length);
      importStatus.value.phase = 'uploading';

      const CHUNK = 450;
      importStatus.value.totalBatches = Math.ceil(unique.length / CHUNK);
      importStatus.value.committedBatches = 0;
      for (let i = 0; i < unique.length; i += CHUNK) {
        const batch = writeBatch(db);
        const chunk = unique.slice(i, i + CHUNK);
        for (const [docId, d] of chunk) {
          batch.set(doc(db, basisCollection, docId), draftToFirestore(d), { merge: true });
        }
        await batch.commit();
        importStatus.value.committedBatches += 1;
        importStatus.value.committedDocs = Math.min(unique.length, importStatus.value.committedBatches * CHUNK);
      }

      await refresh();
      const finishedAt = new Date();
      lastImportSummary.value = {
        fileName: csvFileName.value || '(unknown)',
        totalRows: drafts.length,
        uniqueDocs: unique.length,
        duplicates: Math.max(0, drafts.length - unique.length),
        committedDocs: unique.length,
        invalidRows: 0,
        startedAtIso: startedAt.toISOString(),
        finishedAtIso: finishedAt.toISOString(),
      };
      importStatus.value.phase = 'done';
      successMessage.value =
        `업로드 완료: ${lastImportSummary.value.committedDocs.toLocaleString()}건 업서트 ` +
        `(총 ${lastImportSummary.value.totalRows.toLocaleString()}행 중 ` +
        `${lastImportSummary.value.committedDocs.toLocaleString()}건 성공, ` +
        `중복 ${lastImportSummary.value.duplicates.toLocaleString()}행)`;
    } catch (e: any) {
      const msg = e?.message || String(e);
      if (msg.includes('Missing or insufficient permissions')) {
        errorMessage.value =
          msg +
          '\n\n해결 방법:\n' +
          '1) Firestore rules 배포: firebase deploy --only firestore:rules --project chusa-1817\n' +
          '2) admin 계정에 커스텀 클레임 설정: admin=true\n' +
          '   - python/set_firebase_custom_claims.py 로 설정 후 재로그인';
      } else {
        errorMessage.value = msg;
      }
    } finally {
      csvImporting.value = false;
    }
  }

  async function deleteLastImportAll() {
    errorMessage.value = '';
    successMessage.value = '';
    try {
      if (!lastImportDocIds.value.length) return;
      const ok = window.confirm(
        `마지막 CSV 업로드로 반영된 ${lastImportDocIds.value.length}건을 모두 삭제할까요?\n(basis + extend + stroke + word)`,
      );
      if (!ok) return;
      await deleteByHanjaIds([...lastImportDocIds.value]);
      lastImportDocIds.value = [];
      lastImportSummary.value = null;
      importStatus.value = null;
      await refresh();
      successMessage.value = '업로드 내역 전체삭제 완료';
    } catch (e: any) {
      errorMessage.value = e?.message || String(e);
    }
  }

  return {
    csvFileName,
    csvPreview,
    csvImporting,
    importStatus,
    lastImportDocIds,
    lastImportSummary,
    onCsvSelected,
    importCsvUpsert,
    deleteLastImportAll,
  };
}

