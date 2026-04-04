<script setup lang="ts">
import { ref } from 'vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

interface CalendarEvent {
  name: string;
  start: Date;
  end: Date;
  color: string;
  timed: boolean;
}

/* possible shapes v-calendar may pass to event-color:
   - the raw event (CalendarEvent)
   - a wrapper object containing `event` or `color`
   - other unexpected payloads (use unknown for safety)
*/
type VCalendarEventPayload = CalendarEvent | { event?: CalendarEvent; color?: string } | Record<string, unknown>;

interface CalendarApi {
  prev(): void;
  next(): void;
}

const type = ref<'month' | 'week' | 'day' | '4day'>('month');
const types = ['month', 'week', 'day', '4day'] as const;
const weekday = ref<number[]>([0, 1, 2, 3, 4, 5, 6]);
const weekdays: Array<{ title: string; value: number[] }> = [
  { title: 'Sun - Sat', value: [0, 1, 2, 3, 4, 5, 6] },
  { title: 'Mon - Sun', value: [1, 2, 3, 4, 5, 6, 0] },
  { title: 'Mon - Fri', value: [1, 2, 3, 4, 5] },
  { title: 'Mon, Wed, Fri', value: [1, 3, 5] }
];
const value = ref<string>('');
const events = ref<CalendarEvent[]>([]);

const colors = ['primary', 'secondary', 'success', 'warning', 'info', 'error', 'lightprimary'];
const names = ['Meeting', 'Holiday', 'PTO', 'Travel', 'Event', 'Birthday', 'Conference', 'Party'];

/* template ref for the calendar component with a minimal API type */
const calendar = ref<CalendarApi | null>(null);

function rnd(a: number, b: number): number {
  return Math.floor((b - a + 1) * Math.random()) + a;
}

function getEvents({ start, end }: { start: { date: string }; end: { date: string } }): void {
  const evts: CalendarEvent[] = [];

  const min = new Date(`${start.date}T00:00:00`);
  const max = new Date(`${end.date}T23:59:59`);
  const days = (max.getTime() - min.getTime()) / 86400000;
  const eventCount = rnd(days, days + 20);

  for (let i = 0; i < eventCount; i++) {
    const allDay = rnd(0, 3) === 0;
    const firstTimestamp = rnd(min.getTime(), max.getTime());
    const first = new Date(firstTimestamp - (firstTimestamp % 900000));
    const secondTimestamp = rnd(2, allDay ? 288 : 8) * 900000;
    const second = new Date(first.getTime() + secondTimestamp);

    evts.push({
      name: names[rnd(0, names.length - 1)]!,
      start: first,
      end: second,
      color: colors[rnd(0, colors.length - 1)]!,
      timed: !allDay
    });
  }

  events.value = evts;
}

/* typed event-color function — narrow safely without using `any` */
function getEventColor(payload: VCalendarEventPayload): string {
  if (!payload) return 'primary';

  // payload is CalendarEvent
  if ('color' in payload && typeof payload.color === 'string') {
    return payload.color;
  }

  // payload is wrapper { event?: CalendarEvent }
  if ('event' in payload && payload.event && typeof payload.event === 'object') {
    const ev = payload.event as CalendarEvent;
    if (typeof ev.color === 'string') return ev.color;
  }

  return 'primary';
}

/* wrappers that call the declared template ref (avoid $refs) */
function prev(): void {
  calendar.value?.prev();
}
function next(): void {
  calendar.value?.next();
}
</script>
<template>
  <UiParentCard title="Default">
    <div>
      <v-sheet class="d-flex justify-content-between ga-lg-5 ga-4 mb-6 align-center flex-wrap" tile>
        <v-btn variant="text" icon aria-label="left arrow icon" @click="prev">
          <v-icon icon="$chevronLeft" />
        </v-btn>

        <v-select v-model="type" :items="types" density="comfortable" label="Type" variant="outlined" hide-details />

        <v-select v-model="weekday" :items="weekdays" density="comfortable" label="Weekdays" variant="outlined" hide-details />

        <v-btn variant="text" icon aria-label="right arrow icon" @click="next">
          <v-icon icon="$chevronRight" />
        </v-btn>
      </v-sheet>

      <v-sheet height="600">
        <v-calendar
          ref="calendar"
          v-model="value"
          :event-color="getEventColor"
          :event-overlap-threshold="30"
          :events="events"
          :type="type"
          :weekdays="weekday"
          @change="getEvents"
        />
      </v-sheet>
    </div>
  </UiParentCard>
</template>
