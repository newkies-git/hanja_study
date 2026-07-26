<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import type { StrokePoint, StrokeShape } from "@/types/strokeOrder";

const props = defineProps<{
  svgPaths: string[];
  strokeShapes?: StrokeShape[];
  isStrokeLoading?: boolean;
}>();

const strokeInfo = ref("");
const focusedStrokeIndex = ref<number | null>(null);
const isPlaying = ref(false);
const revealedCount = ref(0); // 재생 중 누적 표시된 획 수
let playTimer: ReturnType<typeof setInterval> | null = null;

function pathBBoxFromD(d: string): {
  minX: number;
  minY: number;
  maxX: number;
  maxY: number;
} {
  const matches = d.match(/-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/g);
  if (!matches || matches.length < 2) {
    return { minX: 0, minY: 0, maxX: 1, maxY: 1 };
  }
  const nums = matches.map(Number).filter((n) => Number.isFinite(n));
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (let i = 0; i + 1 < nums.length; i += 2) {
    const x = nums[i]!;
    const y = nums[i + 1]!;
    minX = Math.min(minX, x);
    minY = Math.min(minY, y);
    maxX = Math.max(maxX, x);
    maxY = Math.max(maxY, y);
  }
  if (!Number.isFinite(minX)) {
    return { minX: 0, minY: 0, maxX: 1, maxY: 1 };
  }
  return { minX, minY, maxX, maxY };
}

const activeSvgPaths = computed(() => {
  const raw = props.svgPaths;
  if (!raw?.length) return [];
  return raw.map((s) => String(s).trim()).filter((s) => s.length > 0);
});

const strokes = computed(() => props.strokeShapes ?? []);

const usePathMode = computed(() => activeSvgPaths.value.length > 0);

const pathLayout = computed(() => {
  const paths = activeSvgPaths.value;
  if (paths.length === 0) {
    return { viewBox: "0 0 1 1" };
  }
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const d of paths) {
    const b = pathBBoxFromD(d);
    minX = Math.min(minX, b.minX);
    minY = Math.min(minY, b.minY);
    maxX = Math.max(maxX, b.maxX);
    maxY = Math.max(maxY, b.maxY);
  }
  if (!Number.isFinite(minX)) {
    return { viewBox: "0 0 1 1" };
  }
  const pad = 60;
  const w = maxX - minX + pad * 2;
  const h = maxY - minY + pad * 2;
  const vb = `${minX - pad} ${-(maxY + pad)} ${w} ${h}`;
  return { viewBox: vb };
});

function bboxForPoints(points: StrokePoint[]) {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const [x, y] of points) {
    minX = Math.min(minX, x);
    minY = Math.min(minY, y);
    maxX = Math.max(maxX, x);
    maxY = Math.max(maxY, y);
  }
  if (!Number.isFinite(minX)) {
    return { minX: 0, minY: 0, maxX: 1, maxY: 1 };
  }
  return { minX, minY, maxX, maxY };
}

const polylineLayout = computed(() => {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const s of strokes.value) {
    const b = bboxForPoints(s.points);
    minX = Math.min(minX, b.minX);
    minY = Math.min(minY, b.minY);
    maxX = Math.max(maxX, b.maxX);
    maxY = Math.max(maxY, b.maxY);
  }
  if (!Number.isFinite(minX)) {
    return { viewBox: "0 0 1 1", pad: 0 };
  }
  const span = Math.max(maxX - minX, maxY - minY, 1e-6);
  const pad = span * 0.06 + 0.02;
  const w = maxX - minX + pad * 2;
  const h = maxY - minY + pad * 2;
  const vb = `${minX - pad} ${-(maxY + pad)} ${w} ${h}`;
  return { viewBox: vb, pad };
});

function pointsAttr(pts: StrokePoint[]): string {
  return pts.map(([x, y]) => `${x},${y}`).join(" ");
}

function strokeOpacity(i: number): number {
  if (isPlaying.value) return i < revealedCount.value ? 1 : 0.1;
  if (focusedStrokeIndex.value === null) return 1;
  return focusedStrokeIndex.value === i ? 1 : 0.22;
}

function polylineStrokeWidth(i: number): number {
  if (isPlaying.value) return i < revealedCount.value ? 0.009 : 0.003;
  if (focusedStrokeIndex.value === null) return 0.009;
  return focusedStrokeIndex.value === i ? 0.014 : 0.005;
}

function onEnterStroke(index: number) {
  strokeInfo.value = `획순: ${index + 1}번째`;
}

function onLeaveStroke() {
  strokeInfo.value = "";
}

function stopPlay() {
  if (playTimer !== null) {
    clearInterval(playTimer);
    playTimer = null;
  }
  isPlaying.value = false;
  revealedCount.value = 0;
}

function startPlay() {
  stopPlay();
  const n = displayStrokeCount.value;
  if (n === 0) return;
  focusedStrokeIndex.value = null;
  revealedCount.value = 1;
  isPlaying.value = true;
  playTimer = setInterval(() => {
    if (revealedCount.value >= n) {
      // 모두 표시 완료 → 재생 종료, 전체 유지
      if (playTimer !== null) clearInterval(playTimer);
      playTimer = null;
      isPlaying.value = false;
      revealedCount.value = 0;
    } else {
      revealedCount.value += 1;
    }
  }, 1000);
}

function playAnimation() {
  stopPlay();
  focusedStrokeIndex.value = null;
}

onUnmounted(stopPlay);

function prevStroke() {
  const n = displayStrokeCount.value;
  if (n === 0) return;
  if (focusedStrokeIndex.value === null) {
    focusedStrokeIndex.value = n - 1;
    return;
  }
  focusedStrokeIndex.value = (focusedStrokeIndex.value - 1 + n) % n;
}

function nextStroke() {
  const n = displayStrokeCount.value;
  if (n === 0) return;
  if (focusedStrokeIndex.value === null) {
    focusedStrokeIndex.value = 0;
    return;
  }
  focusedStrokeIndex.value = (focusedStrokeIndex.value + 1) % n;
}

const displayStrokeCount = computed(() =>
  usePathMode.value ? activeSvgPaths.value.length : strokes.value.length,
);

const polylineOverlapWarning = computed(
  () => !usePathMode.value && strokes.value.length > 1,
);

const hasRenderableStrokes = computed(
  () => usePathMode.value || strokes.value.length > 0,
);

watch(
  () => [props.strokeShapes, props.svgPaths] as const,
  () => {
    stopPlay();
    focusedStrokeIndex.value = null;
    strokeInfo.value = "";
  },
  { deep: true },
);
</script>

<template>
  <div class="flex flex-col gap-6">
    <div v-if="isStrokeLoading" class="flex items-center justify-center py-10">
      <div class="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
    </div>

    <template v-else-if="hasRenderableStrokes">
      <div
        class="min-h-[300px] rounded-xl border border-outline-variant/60 bg-surface-lowest p-4 shadow-float"
      >
        <p
          v-if="polylineOverlapWarning"
          class="mt-3 rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-center text-xs leading-snug text-amber-950"
        >
          이 데이터는 획마다 좌표가 각각 0~1로만 맞춰져 있어, 한 캔버스에 겹치면 깨져 보입니다.
          <span class="font-medium">hanja_stroke</span> 문서에
          <code class="rounded bg-white/80 px-1">svg_paths</code>가 있으면 올바른 글자 형태로
          표시됩니다.
        </p>

        <div
          class="mx-auto mt-4 w-full max-w-md rounded-lg border border-outline-variant bg-white p-4 shadow-inner"
        >
          <svg
            v-if="usePathMode"
            class="mx-auto block h-[min(24rem,85vw)] w-[min(24rem,85vw)] max-w-full text-onSurface"
            :viewBox="pathLayout.viewBox"
            preserveAspectRatio="xMidYMid meet"
            shape-rendering="geometricPrecision"
          >
            <g transform="scale(1, -1)">
              <path
                v-for="(d, i) in activeSvgPaths"
                :key="'svg-path-' + i"
                :d="d"
                fill="currentColor"
                stroke="none"
                class="cursor-pointer transition-opacity duration-300"
                :style="{ opacity: strokeOpacity(i) }"
                @mouseenter="onEnterStroke(i)"
                @mouseleave="onLeaveStroke"
              />
            </g>
          </svg>

          <svg
            v-else-if="strokes.length"
            class="mx-auto block h-[min(24rem,85vw)] w-[min(24rem,85vw)] max-w-full text-onSurface"
            :viewBox="polylineLayout.viewBox"
            preserveAspectRatio="xMidYMid meet"
            shape-rendering="geometricPrecision"
          >
            <g transform="scale(1, -1)">
              <g v-for="(s, i) in strokes" :key="'poly-' + i + '-' + s.order">
                <polyline
                  :points="pointsAttr(s.points)"
                  fill="none"
                  stroke="currentColor"
                  :stroke-width="polylineStrokeWidth(i)"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="cursor-pointer transition-[opacity,stroke-width] duration-300"
                  :style="{ opacity: strokeOpacity(i) }"
                  @mouseenter="onEnterStroke(i)"
                  @mouseleave="onLeaveStroke"
                />
              </g>
            </g>
          </svg>

          <p v-else class="py-12 text-center text-sm text-onSurface-variant">
            표시할 획 경로가 없습니다.
          </p>
        </div>

        <p class="mt-3 min-h-[1.25rem] text-center text-sm text-primary">
          {{ strokeInfo }}
        </p>

        <div
          v-if="displayStrokeCount > 0"
          class="mt-4 flex flex-wrap justify-center gap-2"
        >
          <!-- 재생 / 정지 -->
          <button
            type="button"
            class="btn-primary flex items-center gap-1.5 text-sm"
            @click="isPlaying ? stopPlay() : startPlay()"
          >
            <!-- 재생 아이콘 -->
            <svg v-if="!isPlaying" class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M8 5v14l11-7z" />
            </svg>
            <!-- 정지 아이콘 -->
            <svg v-else class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z" />
            </svg>
            {{ isPlaying ? "정지" : "재생" }}
          </button>
          <button type="button" class="btn-secondary text-sm" @click="playAnimation">
            전체 보기
          </button>
          <button type="button" class="btn-secondary text-sm" @click="prevStroke">
            이전
          </button>
          <button type="button" class="btn-secondary text-sm" @click="nextStroke">
            다음
          </button>
        </div>
      </div>
    </template>

    <div
      v-else
      class="flex flex-col items-center justify-center rounded-xl border border-dashed border-outline-variant bg-surface-low px-4 py-12"
    >
      <svg
        class="mb-3 size-10 text-onSurface-variant/50"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="1.5"
          d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
        />
      </svg>
      <p class="text-sm font-medium text-onSurface-variant">연결된 획순 데이터가 없습니다</p>
    </div>
  </div>
</template>
