<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from "vue";

const props = defineProps<{
  svgPaths: string[];
}>();

// ── 파싱 ──────────────────────────────────────────────────────────────────────

interface Segment {
  cmd: string;
  args: number[];
  /** 이 세그먼트까지 누적한 path d 문자열 */
  partialD: string;
}

function parsePath(d: string): Segment[] {
  const re = /([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)/g;
  const segments: Segment[] = [];
  let cumD = "";
  let m: RegExpExecArray | null;

  while ((m = re.exec(d)) !== null) {
    const cmd = m[1]!;
    const rawArgs = m[2]!.trim();
    const args = rawArgs.length === 0
      ? []
      : rawArgs.split(/[\s,]+/).filter(Boolean).map(Number).filter(Number.isFinite);
    const part = args.length ? `${cmd} ${args.join(" ")}` : cmd;
    cumD += (cumD ? " " : "") + part;
    segments.push({ cmd, args, partialD: cumD });
  }
  return segments;
}

/** 현재 커서 위치에서 해당 명령의 종점 계산 */
function computeEndpoint(
  cmd: string,
  args: number[],
  curX: number,
  curY: number,
): [number, number] | null {
  const C = cmd.toUpperCase();
  const rel = cmd !== C && C !== "Z";

  switch (C) {
    case "M":
    case "L":
    case "T":
      if (args.length < 2) return null;
      return [
        rel ? curX + args[0]! : args[0]!,
        rel ? curY + args[1]! : args[1]!,
      ];
    case "H":
      if (args.length < 1) return null;
      return [rel ? curX + args[0]! : args[0]!, curY];
    case "V":
      if (args.length < 1) return null;
      return [curX, rel ? curY + args[0]! : args[0]!];
    case "C":
      if (args.length < 6) return null;
      return [
        rel ? curX + args[4]! : args[4]!,
        rel ? curY + args[5]! : args[5]!,
      ];
    case "S":
    case "Q":
      if (args.length < 4) return null;
      return [
        rel ? curX + args[2]! : args[2]!,
        rel ? curY + args[3]! : args[3]!,
      ];
    case "A":
      if (args.length < 7) return null;
      return [
        rel ? curX + args[5]! : args[5]!,
        rel ? curY + args[6]! : args[6]!,
      ];
    default:
      return null;
  }
}

// ── 전역 단계 목록 ──────────────────────────────────────────────────────────────

interface Step {
  pathIndex: number;
  segIndex: number;
  totalSegsInPath: number;
  cmd: string;
  args: number[];
  endpoint: [number, number] | null;
  partialD: string;
}

const parsedPaths = computed<Segment[][]>(() =>
  props.svgPaths.map((d) => parsePath(d.trim())),
);

const allSteps = computed<Step[]>(() => {
  const steps: Step[] = [];
  for (let pi = 0; pi < parsedPaths.value.length; pi++) {
    const segs = parsedPaths.value[pi]!;
    let curX = 0;
    let curY = 0;
    for (let si = 0; si < segs.length; si++) {
      const { cmd, args, partialD } = segs[si]!;
      const endpoint = computeEndpoint(cmd, args, curX, curY);
      if (endpoint) { curX = endpoint[0]; curY = endpoint[1]; }
      steps.push({ pathIndex: pi, segIndex: si, totalSegsInPath: segs.length, cmd, args, endpoint, partialD });
    }
  }
  return steps;
});

// ── 상태 ──────────────────────────────────────────────────────────────────────

const currentIndex = ref(0);
const isPlaying = ref(false);
/** 재생 간격 ms (클수록 느림) */
const delayMs = ref(500);

const totalSteps = computed(() => allSteps.value.length);
const currentStep = computed(() => allSteps.value[currentIndex.value] ?? null);

// ── ViewBox ───────────────────────────────────────────────────────────────────

function pathBBoxNums(d: string) {
  const matches = d.match(/-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/g);
  if (!matches || matches.length < 2) return { minX: 0, minY: 0, maxX: 1, maxY: 1 };
  const nums = matches.map(Number).filter(Number.isFinite);
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (let i = 0; i + 1 < nums.length; i += 2) {
    minX = Math.min(minX, nums[i]!);
    minY = Math.min(minY, nums[i + 1]!);
    maxX = Math.max(maxX, nums[i]!);
    maxY = Math.max(maxY, nums[i + 1]!);
  }
  return Number.isFinite(minX) ? { minX, minY, maxX, maxY } : { minX: 0, minY: 0, maxX: 1, maxY: 1 };
}

const layout = computed(() => {
  const paths = props.svgPaths;
  if (paths.length === 0) return { viewBox: "0 0 1 1", dotR: 1 };
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (const d of paths) {
    const b = pathBBoxNums(d);
    minX = Math.min(minX, b.minX);
    minY = Math.min(minY, b.minY);
    maxX = Math.max(maxX, b.maxX);
    maxY = Math.max(maxY, b.maxY);
  }
  if (!Number.isFinite(minX)) return { viewBox: "0 0 1 1", dotR: 1 };
  const span = Math.max(maxX - minX, maxY - minY, 1);
  const pad = 60;
  const w = maxX - minX + pad * 2;
  const h = maxY - minY + pad * 2;
  const vb = `${minX - pad} ${-(maxY + pad)} ${w} ${h}`;
  return { viewBox: vb, dotR: span * 0.022 };
});

// ── 표시 경로 계산 ────────────────────────────────────────────────────────────

interface DisplayPath {
  d: string;
  isActive: boolean;
  opacity: number;
}

const displayPaths = computed<DisplayPath[]>(() => {
  const step = currentStep.value;
  const result: DisplayPath[] = [];

  if (step === null) {
    // 전체 보기
    for (const d of props.svgPaths) {
      result.push({ d, isActive: false, opacity: 1 });
    }
    return result;
  }

  for (let pi = 0; pi < props.svgPaths.length; pi++) {
    if (pi < step.pathIndex) {
      result.push({ d: props.svgPaths[pi]!, isActive: false, opacity: 0.25 });
    } else if (pi === step.pathIndex) {
      result.push({ d: step.partialD, isActive: true, opacity: 1 });
    }
    // 미래 경로는 표시하지 않음
  }
  return result;
});

// ── 명령 설명 ─────────────────────────────────────────────────────────────────

const CMD_LABEL: Record<string, string> = {
  M: "이동", m: "이동(상대)",
  L: "직선", l: "직선(상대)",
  H: "수평선", h: "수평선(상대)",
  V: "수직선", v: "수직선(상대)",
  C: "3차 베지어", c: "3차 베지어(상대)",
  S: "연속 3차", s: "연속 3차(상대)",
  Q: "2차 베지어", q: "2차 베지어(상대)",
  T: "연속 2차", t: "연속 2차(상대)",
  A: "호", a: "호(상대)",
  Z: "닫기", z: "닫기",
};

const cmdLabel = computed(() => {
  const step = currentStep.value;
  if (!step) return "—";
  return CMD_LABEL[step.cmd] ?? step.cmd;
});

const endpointText = computed(() => {
  const ep = currentStep.value?.endpoint;
  if (!ep) return "—";
  return `(${ep[0].toFixed(1)}, ${ep[1].toFixed(1)})`;
});

const argsText = computed(() => {
  const step = currentStep.value;
  if (!step) return "—";
  if (step.args.length === 0) return "(없음)";
  const pairs: string[] = [];
  for (let i = 0; i + 1 < step.args.length; i += 2) {
    pairs.push(`${step.args[i]!.toFixed(1)}, ${step.args[i + 1]!.toFixed(1)}`);
  }
  if (step.args.length % 2 !== 0) pairs.push(step.args[step.args.length - 1]!.toFixed(1));
  return pairs.join("  /  ");
});

// ── 재생 제어 ─────────────────────────────────────────────────────────────────

let timer: ReturnType<typeof setInterval> | null = null;

function clearTimer() {
  if (timer !== null) { clearInterval(timer); timer = null; }
}

function startPlay() {
  clearTimer();
  if (currentIndex.value >= totalSteps.value - 1) currentIndex.value = 0;
  isPlaying.value = true;
  timer = setInterval(() => {
    if (currentIndex.value >= totalSteps.value - 1) {
      isPlaying.value = false;
      clearTimer();
      return;
    }
    currentIndex.value++;
  }, delayMs.value);
}

function pausePlay() {
  isPlaying.value = false;
  clearTimer();
}

function togglePlay() {
  isPlaying.value ? pausePlay() : startPlay();
}

function stepPrev() {
  pausePlay();
  currentIndex.value = Math.max(0, currentIndex.value - 1);
}

function stepNext() {
  pausePlay();
  currentIndex.value = Math.min(totalSteps.value - 1, currentIndex.value + 1);
}

function goReset() {
  pausePlay();
  currentIndex.value = 0;
}

function goEnd() {
  pausePlay();
  currentIndex.value = totalSteps.value - 1;
}

function onSliderInput(e: Event) {
  pausePlay();
  currentIndex.value = Number((e.target as HTMLInputElement).value);
}

function onSpeedInput(e: Event) {
  // 슬라이더는 왼쪽=빠름(100ms), 오른쪽=느림(2000ms) — value를 그대로 delay로 사용
  delayMs.value = Number((e.target as HTMLInputElement).value);
  if (isPlaying.value) startPlay();
}

watch(
  () => props.svgPaths,
  () => { pausePlay(); currentIndex.value = 0; },
);

onUnmounted(() => clearTimer());
</script>

<template>
  <div class="flex flex-col gap-4">
    <!-- SVG 캔버스 -->
    <div
      class="mx-auto w-full max-w-md rounded-lg border border-outline-variant bg-white p-4 shadow-inner"
    >
      <svg
        v-if="svgPaths.length > 0"
        class="mx-auto block h-[min(22rem,80vw)] w-[min(22rem,80vw)] max-w-full"
        :viewBox="layout.viewBox"
        preserveAspectRatio="xMidYMid meet"
        shape-rendering="geometricPrecision"
      >
        <g transform="scale(1, -1)">
          <!-- 전체 글자 윤곽 (매우 연하게) -->
          <path
            v-for="(d, i) in svgPaths"
            :key="'ghost-' + i"
            :d="d"
            fill="currentColor"
            class="text-onSurface"
            style="opacity: 0.06"
          />

          <!-- 현재까지 진행된 경로 -->
          <path
            v-for="(dp, i) in displayPaths"
            :key="'dp-' + i"
            :d="dp.d"
            fill="currentColor"
            :class="dp.isActive ? 'text-primary' : 'text-onSurface'"
            :style="{ opacity: dp.opacity }"
          />

          <!-- 현재 좌표 마커 -->
          <circle
            v-if="currentStep?.endpoint"
            :cx="currentStep.endpoint[0]"
            :cy="currentStep.endpoint[1]"
            :r="layout.dotR"
            class="fill-current text-red-500"
          />
        </g>
      </svg>

      <p v-else class="py-12 text-center text-sm text-onSurface-variant">
        표시할 경로가 없습니다.
      </p>
    </div>

    <!-- 좌표 정보 카드 -->
    <div
      v-if="currentStep"
      class="rounded-lg border border-outline-variant/70 bg-surface-low px-4 py-3"
    >
      <div class="flex items-start justify-between gap-4">
        <div class="min-w-0 flex-1">
          <p class="text-[10px] font-semibold uppercase tracking-widest text-onSurface-variant">
            경로 {{ currentStep.pathIndex + 1 }}/{{ svgPaths.length }}
            &nbsp;·&nbsp;
            명령 {{ currentStep.segIndex + 1 }}/{{ currentStep.totalSegsInPath }}
          </p>
          <p class="mt-1 font-mono text-base font-semibold text-onSurface">
            <span class="rounded bg-primary/10 px-1.5 py-0.5 text-primary">{{ currentStep.cmd }}</span>
            &ensp;{{ cmdLabel }}
          </p>
          <p
            v-if="currentStep.args.length > 0"
            class="mt-1.5 break-all font-mono text-xs text-onSurface-variant"
          >
            인수&ensp;{{ argsText }}
          </p>
          <p
            v-if="currentStep.endpoint"
            class="mt-1 font-mono text-sm font-medium text-primary"
          >
            종점&ensp;{{ endpointText }}
          </p>
        </div>
        <div class="shrink-0 text-right">
          <p class="font-mono text-lg font-bold tabular-nums text-onSurface">
            {{ currentIndex + 1 }}<span class="text-sm font-normal text-onSurface-variant">/{{ totalSteps }}</span>
          </p>
          <p class="text-xs text-onSurface-variant">단계</p>
        </div>
      </div>
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
        <span>처음</span>
        <span>끝</span>
      </div>
    </div>

    <!-- 재생 컨트롤 -->
    <div class="flex flex-wrap justify-center gap-2">
      <button
        type="button"
        class="btn-secondary text-sm"
        :disabled="currentIndex === 0"
        @click="goReset"
      >
        처음
      </button>
      <button
        type="button"
        class="btn-secondary text-sm"
        :disabled="currentIndex === 0"
        @click="stepPrev"
      >
        이전
      </button>
      <button
        type="button"
        class="btn-primary min-w-[5rem] text-sm"
        :disabled="totalSteps === 0"
        @click="togglePlay"
      >
        {{ isPlaying ? "일시정지" : "재생" }}
      </button>
      <button
        type="button"
        class="btn-secondary text-sm"
        :disabled="currentIndex >= totalSteps - 1"
        @click="stepNext"
      >
        다음
      </button>
      <button
        type="button"
        class="btn-secondary text-sm"
        :disabled="currentIndex >= totalSteps - 1"
        @click="goEnd"
      >
        끝
      </button>
    </div>

    <!-- 속도 조절: 슬라이더 왼쪽=빠름(100ms), 오른쪽=느림(2000ms) -->
    <div class="flex items-center justify-center gap-3">
      <span class="text-xs text-onSurface-variant">빠름</span>
      <input
        type="range"
        min="100"
        max="2000"
        step="100"
        :value="delayMs"
        class="w-28 accent-primary"
        @input="onSpeedInput"
      />
      <span class="text-xs text-onSurface-variant">느림</span>
      <span class="ml-1 font-mono text-xs text-onSurface-variant tabular-nums">{{ delayMs }}ms</span>
    </div>

    <!-- 경로 없음 안내 -->
    <p
      v-if="svgPaths.length === 0"
      class="rounded-lg border border-amber-200/90 bg-amber-50/90 px-3 py-2 text-center text-xs text-amber-900"
    >
      <code>svg_paths</code> 데이터가 없어 좌표를 표시할 수 없습니다.
    </p>
  </div>
</template>
