<script setup>
import { ref } from 'vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

const value = ref('');
const events = ref([]);
const colors = ['#1e88e5', '#5e35b1', '#03c9d7', '#00c853', '#ffc107', '#f44336', '#FFAB91'];
const names = ['Meeting', 'Holiday', 'PTO', 'Travel', 'Event', 'Birthday', 'Conference', 'Party'];
const dragEvent = ref(null);
const dragTime = ref(null);
const createEvent = ref(null);
const createStart = ref(null);
const extendOriginal = ref(null);

function startDrag(nativeEvent, { event, timed }) {
  if (event && timed) {
    dragEvent.value = event;
    dragTime.value = null;
    extendOriginal.value = null;
  }
}

function startTime(nativeEvent, tms) {
  const mouse = toTime(tms);

  if (dragEvent.value && dragTime.value === null) {
    const start = dragEvent.value.start;
    dragTime.value = mouse - start;
  } else {
    createStart.value = roundTime(mouse);
    createEvent.value = {
      name: `Event #${events.value.length}`,
      color: rndElement(colors),
      start: createStart.value,
      end: createStart.value,
      timed: true
    };
    events.value.push(createEvent.value);
  }
}

function extendBottom(event) {
  createEvent.value = event;
  createStart.value = event.start;
  extendOriginal.value = event.end;
}

function mouseMove(nativeEvent, tms) {
  const mouse = toTime(tms);

  if (dragEvent.value && dragTime.value !== null) {
    const start = dragEvent.value.start;
    const end = dragEvent.value.end;
    const duration = end - start;
    const newStartTime = mouse - dragTime.value;
    const newStart = roundTime(newStartTime);
    const newEnd = newStart + duration;

    dragEvent.value.start = newStart;
    dragEvent.value.end = newEnd;
  } else if (createEvent.value && createStart.value !== null) {
    const mouseRounded = roundTime(mouse, false);
    const min = Math.min(mouseRounded, createStart.value);
    const max = Math.max(mouseRounded, createStart.value);

    createEvent.value.start = min;
    createEvent.value.end = max;
  }
}

function endDrag() {
  dragTime.value = null;
  dragEvent.value = null;
  createEvent.value = null;
  createStart.value = null;
  extendOriginal.value = null;
}

function cancelDrag() {
  if (createEvent.value) {
    if (extendOriginal.value) {
      createEvent.value.end = extendOriginal.value;
    } else {
      const i = events.value.indexOf(createEvent.value);
      if (i !== -1) {
        events.value.splice(i, 1);
      }
    }
  }

  createEvent.value = null;
  createStart.value = null;
  dragTime.value = null;
  dragEvent.value = null;
}

function roundTime(time, down = true) {
  const roundTo = 15; // minutes
  const roundDownTime = roundTo * 60 * 1000;

  return down ? time - (time % roundDownTime) : time + (roundDownTime - (time % roundDownTime));
}

function toTime(tms) {
  return new Date(tms.year, tms.month - 1, tms.day, tms.hour, tms.minute).getTime();
}

function getEventColor(event) {
  const rgb = parseInt(event.color.substring(1), 16);
  const r = (rgb >> 16) & 0xff;
  const g = (rgb >> 8) & 0xff;
  const b = (rgb >> 0) & 0xff;

  return event === dragEvent.value
    ? `rgba(${r}, ${g}, ${b}, 0.7)`
    : event === createEvent.value
      ? `rgba(${r}, ${g}, ${b}, 0.7)`
      : event.color;
}

function getEvents({ start, end }) {
  const newEvents = [];

  const min = new Date(`${start.date}T00:00:00`).getTime();
  const max = new Date(`${end.date}T23:59:59`).getTime();
  const days = (max - min) / 86400000;
  const eventCount = rnd(days, days + 20);

  for (let i = 0; i < eventCount; i++) {
    const timed = rnd(0, 3) !== 0;
    const firstTimestamp = rnd(min, max);
    const secondTimestamp = rnd(2, timed ? 8 : 288) * 900000;
    const startTime = firstTimestamp - (firstTimestamp % 900000);
    const endTime = startTime + secondTimestamp;

    newEvents.push({
      name: rndElement(names),
      color: rndElement(colors),
      start: startTime,
      end: endTime,
      timed
    });
  }

  events.value = newEvents;
}

function rnd(a, b) {
  return Math.floor((b - a + 1) * Math.random()) + a;
}

function rndElement(arr) {
  return arr[rnd(0, arr.length - 1)];
}
</script>

<template>
  <UiParentCard title="Drag and Drop">
    <v-row class="fill-height">
      <v-col>
        <v-sheet height="600">
          <v-calendar
            ref="calendar"
            v-model="value"
            :event-color="getEventColor"
            :event-ripple="false"
            :events="events"
            color="primary"
            type="4day"
            @change="getEvents"
            @mousedown:event="startDrag"
            @mousedown:time="startTime"
            @mouseleave="cancelDrag"
            @mousemove:time="mouseMove"
            @mouseup:time="endDrag"
          >
            <template v-slot:event="{ event, timed, eventSummary }">
              <div class="v-event-draggable">
                <component :is="eventSummary"></component>
              </div>
              <div v-if="timed" class="v-event-drag-bottom" @mousedown.stop="extendBottom(event)"></div>
            </template>
          </v-calendar>
        </v-sheet>
      </v-col>
    </v-row>
  </UiParentCard>
</template>

<style scoped lang="scss">
.v-event-draggable {
  padding-left: 6px;
}

.v-event-timed {
  user-select: none;
  -webkit-user-select: none;
}

.v-event-drag-bottom {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 4px;
  height: 4px;
  cursor: ns-resize;

  &::after {
    display: none;
    position: absolute;
    left: 50%;
    height: 4px;
    border-top: 1px solid white;
    border-bottom: 1px solid white;
    width: 16px;
    margin-left: -8px;
    opacity: 0.8;
    content: '';
  }

  &:hover::after {
    display: block;
  }
}
</style>
