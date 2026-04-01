<script setup lang="ts">
import { computed } from "vue";
import { RouterLink } from "vue-router";
import { isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";

const auth = useAuthStore();
const firebaseConfigured = computed(() => isFirebaseConfigured());

type DashCard = {
  key: string;
  label: string;
  hint: string;
  icon: string;
  /** 집계 API 대신 앱 내 목록으로 연결 */
  routeName?: "basis" | "etl";
  blurb: string;
};

const dashCards: DashCard[] = [
  {
    key: "hanja",
    label: "레거시 한자",
    hint: "hanja",
    icon: "字",
    blurb: "전용 화면 없음. 문서 수·목록은 Firebase Console → Firestore에서 확인하세요.",
  },
  {
    key: "words",
    label: "단어·성어",
    hint: "words",
    icon: "詞",
    blurb: "전용 화면 없음. 문서 수·목록은 Firebase Console → Firestore에서 확인하세요.",
  },
  {
    key: "hanja_basis",
    label: "기준 CSV",
    hint: "hanja_basis",
    icon: "基",
    routeName: "basis",
    blurb: "기준 데이터에서 목록·검색·편집",
  },
  {
    key: "hanja_extend",
    label: "ETL 확장",
    hint: "hanja_extend",
    icon: "擴",
    routeName: "etl",
    blurb: "ETL·확장에서 basis 연동 목록",
  },
];

const cardBaseClass =
  "group relative block overflow-hidden rounded-2xl border border-outline-variant/70 bg-surface-lowest p-4 shadow-[0_12px_40px_rgba(25,28,30,0.05)] ring-1 ring-black/[0.02] transition sm:p-5";

const cardInteractiveClass =
  "hover:border-primary/25 hover:shadow-[0_16px_48px_rgba(0,74,198,0.08)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/30";

const cardStaticClass = "cursor-default opacity-[0.98]";
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
              Firestore · 작업 허브
            </p>
            <h1 class="font-display text-lg font-semibold tracking-tight text-onSurface sm:text-xl">
              대시보드
            </h1>
            <p class="mt-0.5 text-xs text-onSurface-variant sm:text-sm">
              주요 컬렉션 안내와 관리 화면으로 바로 이동합니다.
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
      v-if="firebaseConfigured"
      class="rounded-xl border border-outline-variant/70 bg-surface-low/90 px-4 py-3 text-xs leading-relaxed text-onSurface-variant shadow-sm sm:text-sm"
    >
      <strong class="font-medium text-onSurface">문서 건수 표시 없음</strong>
      — Firestore
      <code class="mx-0.5 rounded bg-surface-lowest px-1 py-px font-mono text-[11px] text-primary">RunAggregationQuery</code>
      는 프로젝트 할당량에서
      <code class="mx-0.5 rounded bg-surface-lowest px-1 py-px font-mono text-[11px]">resource-exhausted</code>
      가 자주 발생합니다. 건수는
      <strong class="text-onSurface">Google Cloud Console → Firestore</strong>
      에서 확인하고, 목록은 아래 카드에서 연결된 화면을 이용하세요.
    </div>

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

    <!-- 컬렉션 카드 (집계 API 미사용) -->
    <div class="grid gap-3 sm:grid-cols-2 sm:gap-4 xl:grid-cols-4">
      <template v-for="card in dashCards" :key="card.key">
        <RouterLink
          v-if="card.routeName"
          :to="{ name: card.routeName }"
          :class="[cardBaseClass, cardInteractiveClass, 'text-inherit no-underline']"
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
          <p class="relative mt-4 font-display text-base font-semibold text-primary">
            목록 열기 →
          </p>
          <p class="relative mt-1 text-[11px] leading-snug text-onSurface-variant">
            {{ card.blurb }}
          </p>
        </RouterLink>
        <div
          v-else
          :class="[cardBaseClass, cardStaticClass]"
        >
          <div
            class="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-primary/[0.05] blur-2xl"
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
              class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-outline-variant/40 bg-surface-low/80 font-display text-lg text-onSurface-variant shadow-sm"
              aria-hidden="true"
            >
              {{ card.icon }}
            </div>
          </div>
          <p class="relative mt-4 font-display text-sm font-semibold tabular-nums text-onSurface-variant">
            콘솔에서 확인
          </p>
          <p class="relative mt-1 text-[11px] leading-snug text-onSurface-variant">
            {{ card.blurb }}
          </p>
        </div>
      </template>
    </div>
  </div>
</template>
