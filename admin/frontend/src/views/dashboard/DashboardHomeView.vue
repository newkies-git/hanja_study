<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { RouterLink } from "vue-router";
import { collection, getCountFromServer } from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

const auth = useAuthStore();
const firebaseConfigured = computed(() => isFirebaseConfigured());

type CountCard = {
  key: string;
  label: string;
  hint: string;
  icon: string;
};

const countCards = ref<(CountCard & { value: number | null })[]>([
  { key: "hanja", label: "레거시 한자", hint: "hanja", icon: "字", value: null },
  { key: "words", label: "단어·성어", hint: "words", icon: "詞", value: null },
  { key: "hanja_basis", label: "기준 CSV", hint: "hanja_basis", icon: "基", value: null },
  { key: "hanja_extend", label: "ETL 확장", hint: "hanja_extend", icon: "擴", value: null },
]);

const loadError = ref<string | null>(null);
const countsLoading = ref(false);

async function loadCounts() {
  if (!firebaseConfigured.value || !auth.isAuthenticated) return;
  loadError.value = null;
  countsLoading.value = true;
  const db = getFirestoreDb();
  try {
    await Promise.all(
      countCards.value.map(async (card) => {
        try {
          const snap = await getCountFromServer(collection(db, card.key));
          card.value = snap.data().count;
        } catch {
          card.value = null;
        }
      }),
    );
  } finally {
    countsLoading.value = false;
  }
}

onMounted(loadCounts);
</script>

<template>
  <div class="space-y-6">
    <!-- 히어로 -->
    <section
      class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute -right-10 -top-12 h-32 w-32 rounded-full bg-primary/[0.08] blur-2xl"
        aria-hidden="true"
      />
      <div
        class="relative flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="flex min-w-0 items-center gap-3">
          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-lg font-bold text-white shadow-md shadow-primary/25"
            aria-hidden="true"
          >
            板
          </div>
          <div class="min-w-0 leading-tight">
            <p
              class="text-[9px] font-semibold uppercase tracking-[0.14em] text-primary/90"
            >
              Firestore · 요약
            </p>
            <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
              대시보드
            </h1>
            <p class="mt-0.5 text-xs text-onSurface-variant sm:text-sm">
              컬렉션별 문서 수를 확인하고 주요 작업으로 바로 이동합니다.
            </p>
          </div>
        </div>
        <div class="flex flex-wrap gap-2 sm:shrink-0 sm:justify-end">
          <RouterLink
            :to="{ name: 'basis' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            기준 데이터
          </RouterLink>
          <RouterLink
            :to="{ name: 'basis-upload' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            마스터 등록
          </RouterLink>
          <RouterLink
            :to="{ name: 'etl' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            ETL · 확장
          </RouterLink>
          <RouterLink
            :to="{ name: 'settings-auth' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            인증
          </RouterLink>
        </div>
      </div>
    </section>

    <div
      v-if="!auth.isAdmin"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950 shadow-sm"
    >
      <strong class="font-medium">admin</strong> 클레임이 없으면 Firestore 쓰기가 거절됩니다.
      CSV 업로드 등은 클레임 부여 후 설정 → 인증에서 토큰을 갱신하세요.
    </div>

    <div
      v-if="!firebaseConfigured"
      class="rounded-xl border border-outline-variant/70 bg-surface-low px-4 py-3 text-sm text-onSurface-variant"
    >
      Firebase가 설정되지 않았습니다. <code class="rounded bg-surface-lowest px-1.5 py-0.5 font-mono text-xs">.env</code>를 확인하세요.
    </div>

    <!-- 통계 카드 -->
    <div
      class="grid gap-3 sm:grid-cols-2 sm:gap-4 xl:grid-cols-4"
    >
      <div
        v-for="card in countCards"
        :key="card.key"
        class="group relative overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-[0_12px_40px_rgba(25,28,30,0.05)] ring-1 ring-black/[0.02] transition hover:border-primary/20 hover:shadow-[0_16px_48px_rgba(0,74,198,0.08)] sm:p-5"
      >
        <div
          class="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-primary/[0.06] blur-2xl transition group-hover:bg-primary/[0.1]"
          aria-hidden="true"
        />
        <div class="relative flex items-start justify-between gap-2">
          <div class="min-w-0">
            <p
              class="text-[10px] font-semibold uppercase tracking-[0.12em] text-onSurface-variant"
            >
              {{ card.label }}
            </p>
            <code
              class="mt-1 inline-block rounded-md border border-outline-variant/50 bg-surface-low px-1.5 py-0.5 font-mono text-[10px] text-primary"
            >{{ card.hint }}</code>
          </div>
          <div
            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-primary/15 bg-primary/[0.08] font-display text-lg text-primary shadow-sm"
            aria-hidden="true"
          >
            {{ card.icon }}
          </div>
        </div>
        <div class="relative mt-4">
          <div
            v-if="countsLoading"
            class="flex items-center gap-2 text-sm text-onSurface-variant"
            role="status"
            aria-live="polite"
          >
            <span class="flex gap-1" aria-hidden="true">
              <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-primary [animation-delay:-0.15s]" />
              <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-primary [animation-delay:-0.08s]" />
              <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-primary" />
            </span>
            불러오는 중…
          </div>
          <p
            v-else
            class="font-display text-3xl font-semibold tabular-nums tracking-tight text-onSurface sm:text-[2rem]"
          >
            {{
              card.value === null
                ? "—"
                : card.value.toLocaleString("ko-KR")
            }}
          </p>
          <p class="mt-1 text-[11px] text-onSurface-variant">
            문서 수
          </p>
        </div>
      </div>
    </div>

    <p
      v-if="loadError"
      class="rounded-xl border border-red-200/90 bg-red-50/90 px-4 py-3 text-sm text-red-900"
    >
      {{ loadError }}
    </p>
  </div>
</template>
