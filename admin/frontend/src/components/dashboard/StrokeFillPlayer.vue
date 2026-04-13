<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";
import type { StrokeShape } from "./StrokeOrderViewer.vue";

const props = defineProps<{
  svgPaths: string[];
  strokes: StrokeShape[];
}>();

// ── SVG path → 절대 좌표 세그먼트 변환 ───────────────────────────────────────
// 상대 명령(m, l, c…)을 절대 좌표로 정규화해 임의 인덱스에서 path를 잘라도
// 좌표 계산이 깨지지 않게 한다.

interface AbsSeg {
  endpoint: [number, number];
  absCmd: string; // 절대 좌표로 재구성한 SVG 명령 문자열
}

function parseSvgToAbsSegs(d: string): AbsSeg[] {
  const re = /([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)/g;
  const result: AbsSeg[] = [];
  let cx = 0, cy = 0, sx = 0, sy = 0;
  let prevC = "", prevCtrlX = 0, prevCtrlY = 0;
  let m: RegExpExecArray | null;

  while ((m = re.exec(d)) !== null) {
    const cmd = m[1]!;
    const C = cmd.toUpperCase();
    const rel = cmd !== C && C !== "Z";
    const a = m[2]!.trim().length === 0
      ? []
      : m[2]!.trim().split(/[\s,]+/).filter(Boolean).map(Number);

    let ex = cx, ey = cy, absCmd = "";

    if (C === "M") {
      ex = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx);
      ey = rel ? cy + (a[1] ?? 0) : (a[1] ?? cy);
      sx = ex; sy = ey;
      absCmd = `M ${ex} ${ey}`;
    } else if (C === "L" || C === "T") {
      ex = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx);
      ey = rel ? cy + (a[1] ?? 0) : (a[1] ?? cy);
      absCmd = `L ${ex} ${ey}`;
    } else if (C === "H") {
      ex = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx); ey = cy;
      absCmd = `L ${ex} ${ey}`;
    } else if (C === "V") {
      ex = cx; ey = rel ? cy + (a[0] ?? 0) : (a[0] ?? cy);
      absCmd = `L ${ex} ${ey}`;
    } else if (C === "C") {
      const x1 = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx);
      const y1 = rel ? cy + (a[1] ?? 0) : (a[1] ?? cy);
      const x2 = rel ? cx + (a[2] ?? 0) : (a[2] ?? cx);
      const y2 = rel ? cy + (a[3] ?? 0) : (a[3] ?? cy);
      ex = rel ? cx + (a[4] ?? 0) : (a[4] ?? cx);
      ey = rel ? cy + (a[5] ?? 0) : (a[5] ?? cy);
      prevCtrlX = x2; prevCtrlY = y2;
      absCmd = `C ${x1} ${y1} ${x2} ${y2} ${ex} ${ey}`;
    } else if (C === "S") {
      // 이전 제어점의 반사 점
      const x1 = (prevC === "C" || prevC === "S") ? 2 * cx - prevCtrlX : cx;
      const y1 = (prevC === "C" || prevC === "S") ? 2 * cy - prevCtrlY : cy;
      const x2 = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx);
      const y2 = rel ? cy + (a[1] ?? 0) : (a[1] ?? cy);
      ex = rel ? cx + (a[2] ?? 0) : (a[2] ?? cx);
      ey = rel ? cy + (a[3] ?? 0) : (a[3] ?? cy);
      prevCtrlX = x2; prevCtrlY = y2;
      absCmd = `C ${x1} ${y1} ${x2} ${y2} ${ex} ${ey}`;
    } else if (C === "Q") {
      const x1 = rel ? cx + (a[0] ?? 0) : (a[0] ?? cx);
      const y1 = rel ? cy + (a[1] ?? 0) : (a[1] ?? cy);
      ex = rel ? cx + (a[2] ?? 0) : (a[2] ?? cx);
      ey = rel ? cy + (a[3] ?? 0) : (a[3] ?? cy);
      prevCtrlX = x1; prevCtrlY = y1;
      absCmd = `Q ${x1} ${y1} ${ex} ${ey}`;
    } else if (C === "A") {
      ex = rel ? cx + (a[5] ?? 0) : (a[5] ?? cx);
      ey = rel ? cy + (a[6] ?? 0) : (a[6] ?? cy);
      absCmd = `A ${Math.abs(a[0] ?? 0)} ${Math.abs(a[1] ?? 0)} ${a[2] ?? 0} ${a[3] ?? 0} ${a[4] ?? 0} ${ex} ${ey}`;
    } else if (C === "Z") {
      ex = sx; ey = sy;
      absCmd = "Z";
    }

    if (C !== "Z") prevC = C;
    result.push({ endpoint: [ex, ey], absCmd });
    cx = ex; cy = ey;
  }
  return result;
}

// ── bbox & 좌표 변환 ──────────────────────────────────────────────────────────

interface BBox { minX: number; minY: number; maxX: number; maxY: number; }

function bboxOf(pts: [number, number][]): BBox {
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (const [x, y] of pts) {
    if (x < minX) minX = x; if (x > maxX) maxX = x;
    if (y < minY) minY = y; if (y > maxY) maxY = y;
  }
  return { minX, minY, maxX, maxY };
}

function mapPt(p: [number, number], from: BBox, to: BBox, flipY: boolean): [number, number] {
  const nx = (from.maxX - from.minX) > 1e-9 ? (p[0] - from.minX) / (from.maxX - from.minX) : 0.5;
  const ny = (from.maxY - from.minY) > 1e-9 ? (p[1] - from.minY) / (from.maxY - from.minY) : 0.5;
  return [
    to.minX + nx * (to.maxX - to.minX),
    flipY ? to.maxY - ny * (to.maxY - to.minY) : to.minY + ny * (to.maxY - to.minY),
  ];
}

function nearestIdx(coords: [number, number][], target: [number, number]): number {
  let best = 0, minD2 = Infinity;
  for (let i = 0; i < coords.length; i++) {
    const dx = coords[i]![0] - target[0], dy = coords[i]![1] - target[1];
    const d2 = dx * dx + dy * dy;
    if (d2 < minD2) { minD2 = d2; best = i; }
  }
  return best;
}

// ── 획 메타데이터 (시작/전환 인덱스 계산) ────────────────────────────────────
//
// strokes[i].points[0]   → svg_path에서 획 시작점 인덱스 (startIdx)
// strokes[i].points[n]   → svg_path에서 획 끝점 = 전환점 인덱스 (splitIdx)
//
// 전진 경로: segs[startIdx] → segs[startIdx+1] → … → segs[splitIdx]
// 귀환 경로: segs[splitIdx] → … → segs[startIdx]  (닫힌 path의 나머지)

interface StrokeMeta {
  segs: AbsSeg[];       // Z 제외 절대 세그먼트
  startIdx: number;
  splitIdx: number;
  forwardCount: number; // startIdx → splitIdx 사이 세그먼트 수
}

function computeMeta(svgD: string, strokePts: [number, number][]): StrokeMeta {
  const all = parseSvgToAbsSegs(svgD);
  const segs = all.filter(s => s.absCmd !== "Z");
  const n = segs.length;

  if (strokePts.length < 2 || n < 2) {
    const half = Math.floor(n / 2);
    return { segs, startIdx: 0, splitIdx: half, forwardCount: half };
  }

  const svgCoords = segs.map(s => s.endpoint);
  const svgBbox = bboxOf(svgCoords);
  const ptsBbox = bboxOf(strokePts);
  const pStart = strokePts[0]!;
  const pEnd = strokePts[strokePts.length - 1]!;

  // Y축 반전 여부: 두 방향을 모두 시험해 오차가 더 작은 쪽을 채택
  const ms_no = mapPt(pStart, ptsBbox, svgBbox, false);
  const ms_flip = mapPt(pStart, ptsBbox, svgBbox, true);
  const d_no   = (c => Math.hypot(c[0] - ms_no[0],   c[1] - ms_no[1]))(svgCoords[nearestIdx(svgCoords, ms_no)]!);
  const d_flip = (c => Math.hypot(c[0] - ms_flip[0], c[1] - ms_flip[1]))(svgCoords[nearestIdx(svgCoords, ms_flip)]!);
  const flipY = d_flip < d_no;

  const mappedStart = mapPt(pStart, ptsBbox, svgBbox, flipY);
  const mappedEnd   = mapPt(pEnd,   ptsBbox, svgBbox, flipY);

  const startIdx = nearestIdx(svgCoords, mappedStart);
  const splitIdx = nearestIdx(svgCoords, mappedEnd);

  const forwardCount = splitIdx >= startIdx
    ? splitIdx - startIdx
    : n - startIdx + splitIdx;

  return { segs, startIdx, splitIdx, forwardCount };
}

// ── 부분 경로 빌더 ────────────────────────────────────────────────────────────
// startIdx 에서 시작해 count 개 세그먼트를 이어붙인 열린 path.
// SVG fill이 자동으로 startIdx 점까지 직선으로 닫아주어 채움 영역이 생긴다.

function buildPartial(meta: StrokeMeta, count: number): string {
  const { segs, startIdx } = meta;
  const n = segs.length;
  if (n === 0) return "";
  const [sx, sy] = segs[startIdx]!.endpoint;
  const parts: string[] = [`M ${sx} ${sy}`];

  for (let i = 1; i <= count; i++) {
    const seg = segs[(startIdx + i) % n]!;
    // wrap-around 후 M 명령이 오면 L 로 변환 (커서 점프 방지)
    parts.push(seg.absCmd.startsWith("M")
      ? `L ${seg.endpoint[0]} ${seg.endpoint[1]}`
      : seg.absCmd);
  }
  return parts.join(" ");
}

// ── viewBox (전체 획 포함) ────────────────────────────────────────────────────

function buildViewBox(paths: string[]): string {
  const all: number[] = [];
  for (const d of paths) {
    const found = d.match(/-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/g);
    if (found) all.push(...found.map(Number).filter(Number.isFinite));
  }
  if (all.length < 2) return "0 0 1 1";
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (let i = 0; i + 1 < all.length; i += 2) {
    minX = Math.min(minX, all[i]!); minY = Math.min(minY, all[i + 1]!);
    maxX = Math.max(maxX, all[i]!); maxY = Math.max(maxY, all[i + 1]!);
  }
  const pad = 60;
  return `${minX - pad} ${-(maxY + pad)} ${maxX - minX + pad * 2} ${maxY - minY + pad * 2}`;
}

// ── 데이터 준비 ───────────────────────────────────────────────────────────────

const canCompare = computed(() =>
  props.svgPaths.length > 0 &&
  props.strokes.length === props.svgPaths.length,
);

const metas = computed<StrokeMeta[]>(() => {
  if (!canCompare.value) return [];
  return props.svgPaths.map((d, i) =>
    computeMeta(d, props.strokes[i]?.points ?? []),
  );
});

// 전역 단계: (획 인덱스, 전진 세그먼트 수 t)
interface GlobalStep { strokeIndex: number; t: number; }

const allSteps = computed<GlobalStep[]>(() => {
  if (!canCompare.value) return [];
  const steps: GlobalStep[] = [];
  for (let si = 0; si < metas.value.length; si++) {
    const fc = metas.value[si]!.forwardCount;
    for (let t = 0; t <= fc; t++) steps.push({ strokeIndex: si, t });
  }
  return steps;
});

const viewBox = computed(() => buildViewBox(props.svgPaths));

// ── 상태 ─────────────────────────────────────────────────────────────────────

const currentIndex = ref(0);
const isPlaying = ref(false);
const delayMs = ref(60);

const totalSteps = computed(() => allSteps.value.length);
const currentStep = computed(() => allSteps.value[currentIndex.value] ?? null);

// ── 렌더 경로 목록 ────────────────────────────────────────────────────────────
// isRed === true  → 전진 중 (빨강, 부분 경로)
// isRed === false → 완료·ghost (검정/어두운, 전체 경로)

interface RenderPath { d: string; opacity: number; isRed: boolean; }

const renderPaths = computed<RenderPath[]>(() => {
  const step = currentStep.value;
  if (!step || !canCompare.value) {
    return props.svgPaths.map(d => ({ d, opacity: 1, isRed: false }));
  }
  return props.svgPaths.map((d, i) => {
    if (i < step.strokeIndex) {
      // 이미 완료된 획 → 전체 경로, 검정
      return { d, opacity: 0.85, isRed: false };
    } else if (i === step.strokeIndex) {
      const meta = metas.value[i]!;
      const done = step.t >= meta.forwardCount;
      return {
        // 전진 완료되면 전체 닫힌 path(검정), 진행 중이면 부분 경로(빨강)
        d: done ? d : buildPartial(meta, step.t),
        opacity: 1,
        isRed: !done,
      };
    } else {
      // 미래 획 ghost
      return { d, opacity: 0.05, isRed: false };
    }
  });
});

const infoText = computed(() => {
  const step = currentStep.value;
  if (!step) return "—";
  const meta = metas.value[step.strokeIndex];
  return `획 ${step.strokeIndex + 1} / ${props.svgPaths.length}  ·  세그먼트 ${step.t} / ${meta?.forwardCount ?? "?"}`;
});

// ── 재생 ─────────────────────────────────────────────────────────────────────

let timer: ReturnType<typeof setInterval> | null = null;
function clearTimer() { if (timer) { clearInterval(timer); timer = null; } }

function startPlay() {
  clearTimer();
  if (currentIndex.value >= totalSteps.value - 1) currentIndex.value = 0;
  isPlaying.value = true;
  timer = setInterval(() => {
    if (currentIndex.value >= totalSteps.value - 1) { isPlaying.value = false; clearTimer(); return; }
    currentIndex.value++;
  }, delayMs.value);
}

function pausePlay() { isPlaying.value = false; clearTimer(); }
function togglePlay() { isPlaying.value ? pausePlay() : startPlay(); }
function stepPrev() { pausePlay(); currentIndex.value = Math.max(0, currentIndex.value - 1); }
function stepNext() { pausePlay(); currentIndex.value = Math.min(totalSteps.value - 1, currentIndex.value + 1); }
function goReset() { pausePlay(); currentIndex.value = 0; }
function goEnd() { pausePlay(); currentIndex.value = totalSteps.value - 1; }

function jumpToStroke(si: number) {
  pausePlay();
  const idx = allSteps.value.findIndex(s => s.strokeIndex === si);
  if (idx >= 0) currentIndex.value = idx;
}

function onSliderInput(e: Event) {
  pausePlay();
  currentIndex.value = Number((e.target as HTMLInputElement).value);
}

function onSpeedInput(e: Event) {
  delayMs.value = Number((e.target as HTMLInputElement).value);
  if (isPlaying.value) startPlay();
}

watch(
  () => [props.svgPaths, props.strokes] as const,
  () => { pausePlay(); currentIndex.value = 0; },
);
onUnmounted(() => clearTimer());
</script>

<template>
  <div class="flex flex-col gap-4">
    <!-- 데이터 불일치 경고 -->
    <p
      v-if="!canCompare"
      class="rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-center text-xs text-amber-900"
    >
      <code>svg_paths</code>와 <code>strokes</code>의 획 수가 다릅니다.
      두 데이터가 모두 있어야 시작/전환점 매칭이 가능합니다.
    </p>

    <!-- SVG 캔버스 -->
    <div
      class="mx-auto w-full max-w-md rounded-lg border border-outline-variant bg-white p-4 shadow-inner"
    >
      <svg
        v-if="svgPaths.length > 0"
        class="mx-auto block h-[min(22rem,80vw)] w-[min(22rem,80vw)] max-w-full"
        :viewBox="viewBox"
        preserveAspectRatio="xMidYMid meet"
        shape-rendering="geometricPrecision"
      >
        <g transform="scale(1, -1)">
          <path
            v-for="(rp, i) in renderPaths"
            :key="i"
            :d="rp.d"
            class="text-onSurface transition-[fill,opacity] duration-300"
            :fill="rp.isRed ? '#ef4444' : 'currentColor'"
            :style="{ opacity: rp.opacity }"
          />
        </g>
      </svg>

      <p v-else class="py-12 text-center text-sm text-onSurface-variant">
        svg_paths 데이터가 없습니다.
      </p>
    </div>

    <!-- 정보 -->
    <p class="text-center font-mono text-xs text-onSurface-variant">{{ infoText }}</p>

    <!-- 획 선택 버튼 -->
    <div v-if="svgPaths.length > 1" class="flex flex-wrap justify-center gap-1.5">
      <button
        v-for="(_, si) in svgPaths"
        :key="si"
        type="button"
        class="min-w-[2rem] rounded px-2 py-1 text-xs font-medium transition-colors"
        :class="currentStep?.strokeIndex === si
          ? 'bg-primary text-white'
          : 'bg-surface-low text-onSurface-variant hover:bg-surface-variant hover:text-onSurface'"
        @click="jumpToStroke(si)"
      >
        {{ si + 1 }}획
      </button>
    </div>

    <!-- 슬라이더 -->
    <div class="px-1">
      <input
        type="range"
        :min="0"
        :max="Math.max(totalSteps - 1, 0)"
        :value="currentIndex"
        class="w-full accent-primary"
        @input="onSliderInput"
      />
      <div class="mt-0.5 flex justify-between text-[10px] text-onSurface-variant">
        <span>시작</span>
        <span class="tabular-nums">{{ currentIndex + 1 }} / {{ totalSteps }}</span>
        <span>끝</span>
      </div>
    </div>

    <!-- 재생 컨트롤 -->
    <div class="flex flex-wrap justify-center gap-2">
      <button type="button" class="btn-secondary text-sm" :disabled="currentIndex === 0" @click="goReset">처음</button>
      <button type="button" class="btn-secondary text-sm" :disabled="currentIndex === 0" @click="stepPrev">이전</button>
      <button type="button" class="btn-primary min-w-[5rem] text-sm" :disabled="totalSteps === 0" @click="togglePlay">
        {{ isPlaying ? "일시정지" : "재생" }}
      </button>
      <button type="button" class="btn-secondary text-sm" :disabled="currentIndex >= totalSteps - 1" @click="stepNext">다음</button>
      <button type="button" class="btn-secondary text-sm" :disabled="currentIndex >= totalSteps - 1" @click="goEnd">끝</button>
    </div>

    <!-- 속도 -->
    <div class="flex items-center justify-center gap-3">
      <span class="text-xs text-onSurface-variant">빠름</span>
      <input type="range" min="20" max="400" step="10" :value="delayMs" class="w-28 accent-primary" @input="onSpeedInput" />
      <span class="text-xs text-onSurface-variant">느림</span>
      <span class="ml-1 font-mono text-xs tabular-nums text-onSurface-variant">{{ delayMs }}ms</span>
    </div>
  </div>
</template>
