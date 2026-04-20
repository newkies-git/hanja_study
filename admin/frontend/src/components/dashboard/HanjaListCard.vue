<script setup lang="ts">
import { sliceGraphemes, oneGraphemeOrDash } from "@/utils/hanjaBasis";
import type { HanjaListRow } from "@/utils/hanjaBasis";

defineProps<{
  rows: HanjaListRow[];
  activeId: string | null;
  isLoading: boolean;
  /** 1-based 표시 페이지 */
  currentPage: number;
  totalPages: number;
  totalCount: number;
  pageSize: number;
  pageSizeOptions: readonly number[];
}>();

const emit = defineEmits<{
  select: [id: string];
  prev: [];
  next: [];
  "update:pageSize": [n: number];
}>();
</script>

<template>
  <div
    class="flex min-h-0 flex-1 flex-col overflow-hidden rounded-xl border border-outline-variant/70 bg-surface-lowest shadow-float"
  >
    <div
      v-if="isLoading"
      class="flex flex-1 flex-col items-center justify-center gap-2 py-12 text-onSurface-variant"
    >
      <div class="flex gap-1.5" aria-hidden="true">
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.2s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary [animation-delay:-0.1s]" />
        <span class="h-2 w-2 animate-bounce rounded-full bg-primary" />
      </div>
      <p class="text-xs font-medium">불러오는 중…</p>
    </div>
    <div
      v-else-if="totalCount === 0"
      class="flex flex-1 flex-col items-center justify-center px-4 py-12 text-center text-sm text-onSurface-variant"
    >
      <slot name="empty">
        <p>검색 결과가 없습니다.</p>
      </slot>
    </div>
    <template v-else>
      <div class="min-h-0 flex-1 overflow-auto">
        <table
          class="w-full min-w-0 table-fixed border-collapse text-left font-sans text-xs leading-normal text-onSurface"
        >
          <colgroup>
            <col style="width: 6ch" />
            <col style="width: 1.5rem" />
            <col style="width: 1.5rem" />
            <col style="width: 10ch" />
            <col style="width: 2.75rem" />
          </colgroup>
          <thead
            class="sticky top-0 z-[1] border-b border-outline-variant/80 bg-surface-low/95 text-xs font-semibold uppercase tracking-wide text-onSurface-variant backdrop-blur-sm"
          >
            <tr>
              <th class="px-2 py-2 text-start align-middle">ID</th>
              <th class="px-1 py-2 text-center align-middle">한자</th>
              <th class="px-1 py-2 text-center align-middle">음</th>
              <th class="px-1 py-2 text-start align-middle">훈</th>
              <th class="px-1 py-2 text-center align-middle">등급</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-outline-variant/50">
            <tr
              v-for="row in rows"
              :key="row.id"
              class="cursor-pointer transition-colors hover:bg-primary/[0.06]"
              :class="activeId === row.id ? 'bg-primary/[0.1] ring-1 ring-inset ring-primary/25' : ''"
              role="button"
              tabindex="0"
              :aria-current="activeId === row.id ? 'true' : undefined"
              @click="emit('select', row.id)"
              @keydown.enter.prevent="emit('select', row.id)"
            >
              <td
                class="truncate px-2 py-2 text-start align-middle font-medium tabular-nums text-primary"
                :title="row.displayId"
              >
                {{ sliceGraphemes(row.displayId, 6) }}
              </td>
              <td
                class="truncate px-1 py-2 text-center align-middle font-hanja"
                :title="row.char"
              >
                {{ oneGraphemeOrDash(row.char) }}
              </td>
              <td
                class="truncate px-1 py-2 text-center align-middle"
                :title="row.reading"
              >
                {{ oneGraphemeOrDash(row.reading) }}
              </td>
              <td
                class="truncate px-1 py-2 text-start align-middle"
                :title="row.meaning"
              >
                {{ sliceGraphemes(row.meaning, 10) || "—" }}
              </td>
              <td
                class="truncate px-1 py-2 text-center align-middle font-semibold text-onSurface-variant"
                :title="row.tag"
              >
                {{ row.tag }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div
        class="flex shrink-0 flex-col gap-2 border-t border-outline-variant/60 bg-surface-low/80 px-3 py-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div
          class="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-onSurface-variant"
        >
          <label class="flex items-center whitespace-nowrap">
            <select
              :value="pageSize"
              class="input-minimal max-w-[5.5rem] cursor-pointer py-1 text-xs"
              aria-label="한 페이지 행 수"
              @change="emit('update:pageSize', Number(($event.target as HTMLSelectElement).value))"
            >
              <option v-for="n in pageSizeOptions" :key="n" :value="n">{{ n }}건</option>
            </select>
          </label>
          <p class="min-w-0">
            페이지
            <span class="font-medium text-onSurface tabular-nums">{{ currentPage }}</span>
            /
            <span class="tabular-nums">{{ totalPages }}</span>
            · 총
            <span class="tabular-nums">{{ totalCount.toLocaleString("ko-KR") }}</span>건
          </p>
        </div>
        <div class="flex gap-1">
          <button
            type="button"
            class="btn-secondary px-2 py-1 text-xs"
            :disabled="isLoading || currentPage <= 1"
            @click="emit('prev')"
          >
            이전
          </button>
          <button
            type="button"
            class="btn-secondary px-2 py-1 text-xs"
            :disabled="isLoading || currentPage >= totalPages"
            @click="emit('next')"
          >
            다음
          </button>
        </div>
      </div>
    </template>
  </div>
</template>
