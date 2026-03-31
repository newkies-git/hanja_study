<script setup lang="ts">
import { onMounted, ref } from "vue";
import { collection, getCountFromServer } from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

const auth = useAuthStore();

const countCards = ref<
  { key: string; label: string; value: number | null }[]
>([
  { key: "hanja", label: "한자 (hanja)", value: null },
  { key: "words", label: "단어/성어 (words)", value: null },
  { key: "hanja_basis", label: "기준 CSV (hanja_basis)", value: null },
  { key: "hanja_extend", label: "ETL 확장 (hanja_extend)", value: null },
]);
const loadError = ref<string | null>(null);

async function loadCounts() {
  if (!isFirebaseConfigured() || !auth.isAuthenticated) return;
  loadError.value = null;
  const db = getFirestoreDb();
  for (const card of countCards.value) {
    try {
      const snap = await getCountFromServer(collection(db, card.key));
      card.value = snap.data().count;
    } catch {
      card.value = null;
    }
  }
}

onMounted(loadCounts);
</script>

<template>
  <div class="space-y-8">
    <div class="max-w-3xl">
      <h1 class="font-display text-3xl font-semibold tracking-tight text-onSurface">
        대시보드
      </h1>
      <p class="mt-2 text-onSurface-variant">
        HUD Vue 레이아웃(사이드바·헤더·콘텐츠)을 참고하고,
        <span class="text-onSurface">uiux/DESIGN-admin.md</span> 톤에 맞춘 표면 계층으로 구성했습니다.
      </p>
    </div>

    <div v-if="!auth.isAdmin" class="max-w-3xl rounded-xl bg-surface-low p-4 text-sm text-onSurface-variant">
      현재 계정에 <strong class="text-onSurface">admin</strong> 클레임이 없으면 Firestore 쓰기가 거절됩니다.
      CSV 업로드 등은 클레임 부여 후 토큰을 새로고침하세요.
    </div>

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <div
        v-for="card in countCards"
        :key="card.key"
        class="rounded-xl bg-surface-low p-5 transition hover:bg-surface-lowest"
      >
        <p class="text-xs font-medium uppercase tracking-wide text-onSurface-variant">
          {{ card.label }}
        </p>
        <p class="mt-2 font-display text-3xl font-semibold text-onSurface">
          {{ card.value === null ? "—" : card.value }}
        </p>
      </div>
    </div>

    <p v-if="loadError" class="text-sm text-red-600">{{ loadError }}</p>
  </div>
</template>
