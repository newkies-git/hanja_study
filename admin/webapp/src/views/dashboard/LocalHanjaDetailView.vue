<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import HanjaDetailViewForm from "@/components/dashboard/HanjaDetailViewForm.vue";
import { useNotificationsStore } from "@/stores/notifications";
import { useWorkbenchStore } from "@/stores/workbench";
import ConfirmModal from "@/components/app/ConfirmModal.vue";
import { createEmptyLocalHanjaFormRecord } from "@/types/hanjaAdminForms";
import { routeParamAsString } from "@/utils/hanjaBasis";
import { isLocalApiEnabled, localApiFetch } from "@/config/localApi";
import { useHanjaDetailState } from "@/composables/useHanjaDetailState";

const route = useRoute();
const router = useRouter();
const notifications = useNotificationsStore();
const workbench = useWorkbenchStore();

const id = computed(() => routeParamAsString(route.params.id));
const isNew = computed(() => id.value === "new");

const { isLoading, isSaving, error, form, svgPaths, charDisplay, mergeApiResponse } =
  useHanjaDetailState(createEmptyLocalHanjaFormRecord, () => id.value);

const wordContainingSource = computed(() => (isLocalApiEnabled ? ("local" as const) : undefined));

async function loadSqliteHanjaDetail() {
  isLoading.value = true;
  error.value = null;

  try {
    if (isNew.value) {
      form.value = createEmptyLocalHanjaFormRecord();
      svgPaths.value = [];
      return;
    }

    const res = await localApiFetch(`/api/hanja/${id.value}`);
    if (!res.ok) throw new Error("문서를 찾을 수 없습니다.");

    const data = (await res.json()) as Record<string, unknown>;

    form.value = mergeApiResponse(data);
    svgPaths.value = Array.isArray(data.font_outline) ? data.font_outline : [];
  } catch (e) {
    error.value = e instanceof Error ? e.message : "데이터 로드 실패";
  } finally {
    isLoading.value = false;
  }
}

async function persistSqliteHanjaDetail() {
  await workbench.fetchLocalSession();
  if (!workbench.localSession) {
    notifications.error("활성 채번이 없습니다. 상단 변경관리에서 발급하세요.");
    return;
  }
  isSaving.value = true;
  try {
    const isCreate = isNew.value;
    const url = isCreate ? `/api/hanja` : `/api/hanja/${id.value}`;
    const method = isCreate ? "POST" : "PUT";

    if (isCreate && !form.value.id) {
      const char = String(form.value.char_str ?? form.value.한자 ?? "");
      if (char) {
        const cp = char.codePointAt(0);
        if (cp !== undefined) {
          form.value.id = `H${cp.toString(16).toUpperCase()}`;
        }
      } else {
        throw new Error("한자 또는 ID가 필요합니다.");
      }
    }

    const extendPayload: Record<string, unknown> = {
      ...(form.value.extend as Record<string, unknown>),
      grade: String(form.value.grade ?? "").trim(),
    };
    delete extendPayload["구분"];

    const res = await localApiFetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ...form.value,
        extend: extendPayload,
        change_number: workbench.localSession.id,
      }),
    });

    if (!res.ok) {
      const errBody = await res.json();
      throw new Error(errBody.error || "저장 실패");
    }

    notifications.success("저장 완료");
    if (isCreate && typeof form.value.id === "string") {
      void router.replace({ name: "sqlite-detail", params: { id: form.value.id } });
    }
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "저장 실패");
  } finally {
    isSaving.value = false;
  }
}

const confirmOpen = ref(false);

function openDeletionConfirmModal() {
  if (!workbench.localSession || isNew.value) return;
  confirmOpen.value = true;
}

async function executeConfirmedDeletion() {
  confirmOpen.value = false;
  if (!workbench.localSession) return;
  isSaving.value = true;
  try {
    const res = await localApiFetch(`/api/hanja/${id.value}`, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ change_number: workbench.localSession.id }),
    });
    if (!res.ok) throw new Error("삭제 실패");
    notifications.success("삭제 처리 완료");
    void router.push({ name: "sqlite-manage" });
  } catch (e) {
    notifications.error(e instanceof Error ? e.message : "삭제 실패");
  } finally {
    isSaving.value = false;
  }
}

onMounted(() => {
  void loadSqliteHanjaDetail();
});
watch(
  () => routeParamAsString(route.params.id),
  (next, prev) => {
    if (!next || next === prev) return;
    void loadSqliteHanjaDetail();
  },
);
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col overflow-hidden bg-surface-lowest">
    <header
      class="z-10 flex shrink-0 flex-col gap-3 border-b border-outline-variant/60 bg-surface-low px-3 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-4"
    >
      <div class="flex min-w-0 items-center gap-3">
        <button
          type="button"
          class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-onSurface-variant transition hover:bg-surface-bright hover:text-primary"
          title="목록으로"
          @click="router.push({ name: 'sqlite-manage' })"
        >
          <svg
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="2"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
        </button>
        <div
          class="flex h-12 w-12 shrink-0 select-none items-center justify-center overflow-hidden rounded-xl border border-primary/20 bg-surface-lowest font-hanja text-3xl font-medium text-onSurface shadow-sm"
        >
          <span>{{ isLoading ? "…" : charDisplay || "—" }}</span>
        </div>
        <h1 class="sr-only">
          <span class="page-title-kicker">SQLite</span>
          <template v-if="!isLoading">{{ id }}</template>
          <template v-else>로딩 중</template>
        </h1>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <div
          class="flex min-w-0 flex-col rounded-lg border border-outline-variant/60 bg-surface-lowest px-2.5 py-1 text-[11px]"
        >
          <span class="text-onSurface-variant">
            채번
            <strong
              :class="workbench.localSession ? 'text-primary' : 'text-red-600'"
              >{{
                workbench.localSession ? `#${workbench.localSession.id}` : "없음"
              }}</strong
            >
          </span>
          <span
            v-if="workbench.localSession?.description"
            class="truncate text-onSurface-variant/90"
            :title="workbench.localSession.description"
            >{{ workbench.localSession.description }}</span
          >
        </div>
        <button
          v-if="!isNew && !isLoading && !error"
          type="button"
          class="rounded-md border border-red-200/90 bg-surface-lowest px-3 py-1.5 text-xs font-medium text-red-700 transition hover:bg-red-50/80"
          :disabled="isSaving || !workbench.localSession"
          @click="openDeletionConfirmModal"
        >
          삭제
        </button>
        <button
          type="button"
          class="btn-secondary px-3 py-1.5 text-xs"
          :disabled="isLoading"
          @click="() => void loadSqliteHanjaDetail()"
        >
          새로고침
        </button>
        <button
          type="button"
          class="btn-primary px-4 py-1.5 text-xs shadow-sm shadow-primary/15"
          :disabled="isSaving || isLoading || !workbench.localSession"
          @click="persistSqliteHanjaDetail"
        >
          {{ isSaving ? "저장 중…" : "저장" }}
        </button>
      </div>
    </header>

    <div class="min-h-0 flex-1 overflow-y-auto overscroll-contain p-3 sm:p-4">
      <div
        v-if="error"
        class="mx-auto flex max-w-4xl items-center gap-3 rounded-lg border border-red-100 bg-red-50 p-4"
      >
        <svg class="h-5 w-5 shrink-0 text-red-500" fill="currentColor" viewBox="0 0 20 20">
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z"
            clip-rule="evenodd"
          />
        </svg>
        <p class="text-sm font-medium text-red-800">{{ error }}</p>
      </div>

      <div v-else-if="isLoading" class="mx-auto max-w-4xl">
        <div class="animate-pulse space-y-6">
          <!-- loader shapes -->
        </div>
      </div>

      <HanjaDetailViewForm
        v-else
        v-model:form="form"
        :is-new="isNew"
        :svg-paths="svgPaths"
        :word-containing-glyph="charDisplay"
        :word-containing-source="wordContainingSource"
      />
    </div>

    <ConfirmModal
      :open="confirmOpen"
      title="한자 삭제"
      message="정말 이 한자를 삭제(가림) 처리하시겠습니까?"
      confirm-label="삭제"
      :danger="true"
      @confirm="executeConfirmedDeletion"
      @cancel="confirmOpen = false"
    />
  </div>
</template>
