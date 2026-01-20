<template>
  <div
    v-if="modelValue && selectedClass"
    class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
    @click.self="$emit('update:modelValue', false)"
  >
    <div class="bg-white rounded-xl shadow-lg max-w-md w-full p-6 space-y-4">
      <h3 class="text-lg font-bold text-slate-800">
        {{ $t('student.classes.leave.title') }}
      </h3>
      <p class="text-sm text-slate-600">
        {{ $t('student.classes.leave.description') }}:
        <strong>{{ selectedClass.name }}</strong>
      </p>

      <div class="space-y-2">
        <label class="block text-sm font-medium text-slate-700">
          {{ $t('student.classes.leave.leaveType') }}
        </label>
        <div class="flex gap-3">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              v-model="leaveTypeLocal"
              type="radio"
              value="temporary"
              class="w-4 h-4"
            />
            <span class="text-sm text-slate-700">{{
              $t('student.classes.leave.temporary')
            }}</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              v-model="leaveTypeLocal"
              type="radio"
              value="permanent"
              class="w-4 h-4"
            />
            <span class="text-sm text-slate-700">{{
              $t('student.classes.leave.permanent')
            }}</span>
          </label>
        </div>
      </div>

      <div v-if="leaveTypeLocal !== 'permanent'" class="space-y-2">
        <label class="block text-sm font-medium text-slate-700">
          {{ $t('student.classes.leave.date') }}
        </label>
        <select
          v-model="leaveDateLocal"
          class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-600 focus:border-transparent outline-none"
          :disabled="loadingDates || availableDates.length === 0"
        >
          <option value="">{{ $t('student.classes.leave.selectDate') }}</option>
          <option
            v-for="date in availableDates"
            :key="date.value"
            :value="date.value"
          >
            {{ date.label }}
          </option>
        </select>
        <p v-if="loadingDates" class="text-xs text-slate-500">
          {{ $t('student.classes.leave.loadingDates') }}
        </p>
        <p v-else-if="availableDates.length === 0" class="text-xs text-slate-500">
          {{ $t('student.classes.leave.noDatesAvailable') }}
        </p>
      </div>

      <div class="space-y-2">
        <label class="block text-sm font-medium text-slate-700">
          {{ $t('student.classes.leave.reason') }}
        </label>
        <textarea
          v-model="leaveReasonLocal"
          class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-600 focus:border-transparent outline-none resize-none"
          rows="4"
          :placeholder="$t('student.classes.leave.reasonPlaceholder')"
        ></textarea>
      </div>

      <div class="flex gap-3">
        <button
          @click="$emit('update:modelValue', false)"
          class="flex-1 px-4 py-2 border border-slate-300 rounded-lg text-slate-700 font-medium hover:bg-slate-50 transition-colors"
        >
          {{ $t('student.classes.leave.cancel') }}
        </button>
        <button
          @click="submit"
          :disabled="!leaveDateLocal && leaveTypeLocal === 'temporary' || !leaveReasonLocal.trim()"
          class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ $t('student.classes.leave.submit') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { StudentClass } from 'app/types/class';
import { ref, computed, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const props = defineProps<{
  modelValue: boolean;
  selectedClass: StudentClass | null;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: boolean];
  submit: [payload: { date: string; reason: string; leaveType: string }];
}>();

const leaveDateLocal = ref('');
const leaveReasonLocal = ref('');
const leaveTypeLocal = ref('temporary');
const loadingDates = ref(false);
const attendanceSessions = ref<Array<{ date: string }>>([]);

const { getAttendanceSessionsByClass } = useAttendanceApi();

// Calculate available dates from fixed schedule and attendance sessions
const availableDates = computed(() => {
  if (!props.selectedClass) return [];

  const dates: Array<{ value: string; label: string }> = [];
  const today = new Date();
  const twoWeeksLater = new Date(today);
  twoWeeksLater.setDate(today.getDate() + 14);

  // Get fixed schedule
  const schedule = props.selectedClass.rawSchedule || {};
  const scheduleDays = Object.keys(schedule).map(Number); // [0, 1, 2, ...] for Monday, Tuesday, etc.

  // Generate dates from fixed schedule (from today to 2 weeks later)
  const currentDate = new Date(today);
  while (currentDate <= twoWeeksLater) {
    const dayOfWeek = currentDate.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    // Convert to schedule format: 0 = Monday, 1 = Tuesday, ..., 6 = Sunday
    const scheduleDay = dayOfWeek === 0 ? 6 : dayOfWeek - 1;

    if (scheduleDays.includes(scheduleDay)) {
      const dateStr = currentDate.toISOString().split('T')[0] || '';
      if (dateStr) {
        const formattedDate = formatDateForDisplay(currentDate);
        dates.push({ value: dateStr, label: formattedDate });
      }
    }

    currentDate.setDate(currentDate.getDate() + 1);
  }

  // Add attendance sessions (make-up classes) that are within the range
  attendanceSessions.value.forEach((session) => {
    if (!session.date) return;
    const sessionDate = new Date(session.date);
    if (sessionDate >= today && sessionDate <= twoWeeksLater) {
      const dateStr = sessionDate.toISOString().split('T')[0] || '';
      // Only add if not already in the list
      if (dateStr && !dates.find((d) => d.value === dateStr)) {
        const formattedDate = formatDateForDisplay(sessionDate);
        dates.push({ value: dateStr, label: formattedDate });
      }
    }
  });

  // Sort by date
  dates.sort((a, b) => a.value.localeCompare(b.value));

  return dates;
});

const formatDateForDisplay = (date: Date): string => {
  const days = [
    t('common.days.sunday'),
    t('common.days.monday'),
    t('common.days.tuesday'),
    t('common.days.wednesday'),
    t('common.days.thursday'),
    t('common.days.friday'),
    t('common.days.saturday'),
  ];
  const dayName = days[date.getDay()];
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();
  return `${dayName}, ${day}/${month}/${year}`;
};

// Load attendance sessions when modal opens and class is selected
watch(
  () => [props.modelValue, props.selectedClass?.class_id],
  async ([isOpen, classId]) => {
    if (isOpen && classId && typeof classId === 'number') {
      await loadAttendanceSessions(classId);
    }
  },
  { immediate: true }
);

const loadAttendanceSessions = async (classId: number) => {
  try {
    loadingDates.value = true;
    const response = await getAttendanceSessionsByClass(classId);
    if (response.data?.sessions) {
      attendanceSessions.value = response.data.sessions.map((s: any) => ({
        date: s.date,
      }));
    }
  } catch (error) {
    console.error('Error loading attendance sessions:', error);
    attendanceSessions.value = [];
  } finally {
    loadingDates.value = false;
  }
};

const submit = () => {
  if (
    (leaveDateLocal.value &&
      leaveTypeLocal.value === 'temporary' &&
      leaveReasonLocal.value.trim()) ||
    (leaveTypeLocal.value === 'permanent' && leaveReasonLocal.value.trim())
  ) {
    emit('submit', {
      date: leaveDateLocal.value || new Date().toISOString(),
      reason: leaveReasonLocal.value,
      leaveType:
        leaveTypeLocal.value === 'temporary' ? 'temporary' : 'permanent',
    });
  }
  leaveDateLocal.value = '';
  leaveReasonLocal.value = '';
  leaveTypeLocal.value = 'temporary';
};
</script>
