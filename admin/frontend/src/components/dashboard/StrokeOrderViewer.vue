<script setup lang="ts">
import { computed, ref, watch } from "vue";

export type StrokePoint = [number, number];
export type StrokeShape = { order: number; points: StrokePoint[] };

const props = defineProps<{
  strokes: StrokeShape[];
  /** 있으면 원본 SVG path `d`로 전역 좌표계에 렌더(네이버 획순 SVG와 동일 계열) */
  svgPaths?: string[];
  title: string;
  subtitle: string;
  footnote?: string;
}>();

const strokeInfo = ref("");
/** null이면 모든 획을 동일 강조, 아니면 해당 인덱스만 강조 */
const focusedStrokeIndex = ref<number | null>(null);

/** Naver `d` 문자열에서 숫자 토큰을 모아 bbox 근사 */
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

const usePathMode = computed(() => activeSvgPaths.value.length > 0);

/** path 모드 viewBox 패딩(좌표 스케일 ~1000대 가정) */
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

/** 획별 0~1 정규화 좌표용 (svg_paths 없을 때만 사용; 여러 획 동시 표시는 좌표계가 맞지 않음) */
const polylineLayout = computed(() => {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const s of props.strokes) {
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
  if (focusedStrokeIndex.value === null) return 1;
  return focusedStrokeIndex.value === i ? 1 : 0.22;
}

function polylineStrokeWidth(i: number): number {
  if (focusedStrokeIndex.value === null) return 0.009;
  return focusedStrokeIndex.value === i ? 0.014 : 0.005;
}

function onEnterStroke(index: number) {
  strokeInfo.value = `획순: ${index + 1}번째`;
}

function onLeaveStroke() {
  strokeInfo.value = "";
}

function playAnimation() {
  focusedStrokeIndex.value = null;
}

function resetStrokes() {
  focusedStrokeIndex.value = null;
}

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
  usePathMode.value ? activeSvgPaths.value.length : props.strokes.length,
);

const polylineOverlapWarning = computed(
  () =>
    !usePathMode.value &&
    props.strokes.length > 1,
);

watch(
  () => [props.strokes, props.svgPaths] as const,
  () => {
    focusedStrokeIndex.value = null;
    strokeInfo.value = "";
  },
  { deep: true },
);
</script>

<template>
  <div
    class="rounded-xl border border-outline-variant bg-surface-lowest p-4 shadow-float"
  >
    <div class="text-center">
      <h2 class="font-display text-3xl font-semibold text-onSurface">
        {{ title || "—" }}
      </h2>
      <p class="mt-1 text-sm text-onSurface-variant">
        {{ subtitle }}
      </p>
    </div>

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
      <!-- 원본 path d + Y 반전 + fill 실루엣 -->
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

      <p
        v-else
        class="py-12 text-center text-sm text-onSurface-variant"
      >
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
      <button type="button" class="btn-primary text-sm" @click="playAnimation">
        전체 보기
      </button>
      <button type="button" class="btn-secondary text-sm" @click="prevStroke">
        이전
      </button>
      <button type="button" class="btn-secondary text-sm" @click="nextStroke">
        다음
      </button>
      <button type="button" class="btn-secondary text-sm" @click="resetStrokes">
        초기화
      </button>
    </div>

    <p
      v-if="footnote"
      class="mt-4 text-center font-mono text-xs text-onSurface-variant"
    >
      {{ footnote }}
    </p>
  </div>
</template>
