import type { RawHanjaDraft, RawHanjaRow } from './dashboardTypes';

export function emptyDraft(): RawHanjaDraft {
  return { hanja: '', 음: '', 훈: '', 전체: '', 훈음: '', 구분: '' };
}

export function requiredDraftErrors(d: RawHanjaDraft): string[] {
  const errs: string[] = [];
  if (!d.hanja.trim()) errs.push('한자는 필수입니다.');
  if (!d.음.trim()) errs.push('음은 필수입니다.');
  if (!d.훈.trim()) errs.push('훈은 필수입니다.');
  if (!d.구분.trim()) errs.push('구분은 필수입니다.');
  return errs;
}

export function unicodeDocIdFromHanja(hanja: string): string {
  const s = hanja.trim();
  if (!s) return '';
  const cp = s.codePointAt(0);
  if (cp == null) return '';
  return `U+${cp.toString(16).toUpperCase()}`;
}

export function draftToFirestore(d: RawHanjaDraft): Record<string, unknown> {
  return {
    한자: d.hanja.trim(),
    음: d.음.trim(),
    훈: d.훈.trim(),
    전체: d.전체.trim(),
    훈음: d.훈음.trim(),
    구분: d.구분.trim(),
  };
}

export function mapHanja(docId: string, data: Record<string, unknown>): RawHanjaRow {
  const hanja = (data['한자'] as string | undefined) ?? '';
  const 음 = (data['음'] as string | undefined) ?? '';
  const 훈 = (data['훈'] as string | undefined) ?? '';
  const 전체 = (data['전체'] as string | undefined) ?? '';
  const 훈음 = (data['훈음'] as string | undefined) ?? '';
  const 구분 = (data['구분'] as string | undefined) ?? '';
  return { id: docId, hanja: String(hanja), 음: String(음), 훈: String(훈), 전체: String(전체), 훈음: String(훈음), 구분: String(구분) };
}

