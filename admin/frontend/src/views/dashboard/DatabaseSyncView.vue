<script setup lang="ts">
import { computed } from "vue";
import { RouterLink } from "vue-router";
import { isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { useNotificationsStore } from "@/stores/notifications";
import { useDbSync, type SyncPhase, type SyncTableKey } from "@/composables/useDbSync";

const auth = useAuthStore();
const notifications = useNotificationsStore();
const sync = useDbSync();
const syncTableKeys: SyncTableKey[] = ["hanja_basis", "hanja_stroke", "hanja_word"];

const canRunSync = computed(
  () =>
    isFirebaseConfigured() &&
    auth.isAuthReady &&
    auth.isAuthenticated &&
    auth.isAdmin &&
    !sync.isBusy.value,
);

const firebaseConfigured = computed(() => isFirebaseConfigured());

function describeDbSyncPhaseInKorean(phase: SyncPhase): string {
  switch (phase) {
    case "idle":
      return "대기";
    case "running":
      return "진행 중";
    case "done":
      return "완료";
    case "error":
      return "오류";
    default:
      return phase;
  }
}

async function handleSyncLocalToServerClick() {
  if (!canRunSync.value) return;
  try {
    await auth.syncIdTokenForFirestore();
    await sync.runLocalToServer();
    notifications.success("로컬 → 서버 동기화가 완료되었습니다.");
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "동기화에 실패했습니다.");
  }
}

async function handleSyncServerToLocalClick() {
  if (!canRunSync.value) return;
  try {
    await auth.syncIdTokenForFirestore();
    await sync.runServerToLocal();
    notifications.success("서버 → 로컬 동기화가 완료되었습니다.");
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "동기화에 실패했습니다.");
  }
}
</script>

<template>
  <div class="space-y-6">
    <section
      class="relative overflow-hidden rounded-xl border border-outline-variant/80 bg-gradient-to-br from-primary/[0.07] via-surface-lowest to-surface-low px-3 py-2.5 shadow-float ring-1 ring-black/[0.03] sm:px-4 sm:py-3"
    >
      <div
        class="pointer-events-none absolute -right-8 -top-10 h-28 w-28 rounded-full bg-primary/[0.09] blur-2xl"
        aria-hidden="true"
      />
      <div
        class="relative flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="flex min-w-0 items-center gap-2.5 sm:gap-3">
          <div
            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary font-display text-sm font-bold text-white shadow-md shadow-primary/20"
            aria-hidden="true"
          >
            擴
          </div>
          <div class="min-w-0 flex-1">
            <h1 class="page-title">
              <span class="page-title-kicker">Firestore · 로컬 SQLite</span>DB 동기화
            </h1>
          </div>
        </div>
        <div class="flex flex-wrap gap-2 sm:shrink-0 sm:justify-end">
          <RouterLink
            :to="{ name: 'sqlite-manage' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            로컬 DB
          </RouterLink>
          <RouterLink
            :to="{ name: 'firestore-manage' }"
            class="btn-secondary px-3 py-1.5 text-xs sm:text-sm"
          >
            서버DB 관리
          </RouterLink>
        </div>
      </div>
    </section>

    <p class="truncate text-xs text-onSurface-variant">
      <code class="rounded bg-surface-low px-1 font-mono text-[11px] text-primary">chusa.db</code>
      ↔ Firestore
      <span class="font-mono text-[11px]">hanja_basis</span>·<span class="font-mono text-[11px]">hanja_stroke</span>·<span class="font-mono text-[11px]">hanja_word</span>
      동기화. 목록·편집은
      <RouterLink
        :to="{ name: 'firestore-manage' }"
        class="font-medium text-primary underline decoration-primary/30 underline-offset-2 hover:decoration-primary"
      >서버DB 관리</RouterLink>.
    </p>

    <div
      v-if="!firebaseConfigured"
      class="rounded-xl border border-amber-200/90 bg-amber-50/90 px-4 py-3 text-sm text-amber-950"
    >
      Firebase 환경 변수가 없어 동기화를 실행할 수 없습니다. 배포 설정의 Firebase 항목을 확인하세요.
    </div>

    <section
      v-else
      class="rounded-xl border border-outline-variant/70 bg-surface-lowest px-3 py-4 shadow-float sm:px-4 sm:py-5"
    >
      <div class="mb-3 flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between sm:gap-4">
        <div class="min-w-0">
          <h2 class="text-sm font-semibold text-onSurface">양방향 동기화</h2>
          <p class="mt-1 text-[11px] leading-relaxed text-onSurface-variant">
            서버 → 로컬 실행 전
            <RouterLink
              :to="{ name: 'sqlite-manage' }"
              class="font-medium text-primary underline decoration-primary/30 underline-offset-2 hover:decoration-primary"
            >로컬 DB 관리</RouterLink>
            에서 편집한 뒤, 상단 <strong class="text-onSurface">변경관리</strong>에서
            <strong class="text-onSurface">채번</strong>을 확인하세요. Firebase·
            <strong class="text-onSurface">admin</strong> 클레임이 필요합니다.
          </p>
        </div>
        <div class="flex shrink-0 flex-wrap gap-2">
          <button
            type="button"
            class="btn-primary px-3 py-2 text-xs shadow-sm shadow-primary/15 sm:text-sm"
            :disabled="!canRunSync"
            title="로컬 한자·획·단어를 Firestore에 반영합니다."
            @click="() => void handleSyncLocalToServerClick()"
          >
            로컬 → 서버
          </button>
          <button
            type="button"
            class="btn-secondary px-3 py-2 text-xs sm:text-sm"
            :disabled="!canRunSync"
            title="Firestore 한자·획·단어를 로컬 DB에 반영합니다."
            @click="() => void handleSyncServerToLocalClick()"
          >
            서버 → 로컬
          </button>
        </div>
      </div>
      <div
        v-if="auth.isAuthReady && !auth.isAdmin"
        class="mb-3 rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-xs text-amber-950"
      >
        <strong class="font-medium">admin</strong> 클레임이 있어야 동기화를 실행할 수 있습니다.
      </div>
      <div class="overflow-x-auto rounded-lg border border-outline-variant/60">
        <table class="w-full min-w-[28rem] border-collapse text-left text-xs">
          <thead>
            <tr
              class="border-b border-outline-variant/70 bg-surface-low/90 text-[10px] font-semibold uppercase tracking-wide text-onSurface-variant"
            >
              <th class="px-3 py-2">테이블</th>
              <th class="px-3 py-2">상태</th>
              <th class="px-3 py-2">반영 건수</th>
              <th class="px-3 py-2">비고</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-outline-variant/50">
            <tr
              v-for="key in syncTableKeys"
              :key="key"
              class="bg-surface-lowest/90"
            >
              <td class="px-3 py-2 font-mono text-[11px] text-onSurface">
                {{ sync.tables[key].label }}
              </td>
              <td class="px-3 py-2">
                <span
                  class="inline-flex rounded-full px-2 py-0.5 font-semibold"
                  :class="{
                    'bg-onSurface-variant/15 text-onSurface-variant':
                      sync.tables[key].phase === 'idle',
                    'bg-primary/15 text-primary': sync.tables[key].phase === 'running',
                    'bg-emerald-100 text-emerald-900': sync.tables[key].phase === 'done',
                    'bg-red-100 text-red-900': sync.tables[key].phase === 'error',
                  }"
                >{{ describeDbSyncPhaseInKorean(sync.tables[key].phase) }}</span>
              </td>
              <td class="px-3 py-2 tabular-nums text-onSurface">
                {{ sync.tables[key].processed.toLocaleString("ko-KR") }}
                <span class="text-onSurface-variant">/</span>
                {{ sync.tables[key].total.toLocaleString("ko-KR") }}
              </td>
              <td class="max-w-[14rem] truncate px-3 py-2 text-onSurface-variant">
                {{ sync.tables[key].errorMessage || "—" }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
