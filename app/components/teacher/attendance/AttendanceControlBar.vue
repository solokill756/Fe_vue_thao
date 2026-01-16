<template>
  <div
    class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col xl:flex-row gap-4 justify-between items-start xl:items-center"
  >
    <div class="flex flex-col sm:flex-row gap-4 w-full xl:w-auto">
      <!-- Class Selector -->
      <div class="flex flex-col flex-1">
        <label class="text-xs font-bold text-slate-500 mb-1 uppercase">
          {{ $t('teacher.attendance.classLabel') }}
        </label>
        <select
          :value="selectedClassId || ''"
          @change="handleClassIdChange"
          class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-800 outline-none focus:border-blue-500 min-w-[200px]"
        >
          <option value="">{{ $t('teacher.attendance.selectClass') }}</option>
          <option v-for="cls in classes" :key="cls.id" :value="cls.id">
            {{ cls.name }}
          </option>
        </select>
      </div>

      <!-- Date Selector -->
      <AttendanceDateSelector
        :selected-date="selectedDate"
        :selected-date-option="selectedDateOption"
        :upcoming-class-dates="upcomingClassDates"
        @update:selected-date="$emit('update:selectedDate', $event)"
        @update:selected-date-option="
          $emit('update:selectedDateOption', $event)
        "
        @date-option-change="$emit('dateOptionChange')"
        @date-change="handleDateChange"
      />
    </div>

    <!-- Stats -->
    <AttendanceStats :stats="attendanceStats" :total-students="totalStudents" />

    <!-- Actions -->
    <div class="flex items-center gap-2 w-full xl:w-auto">
      <button
        @click="$emit('markAllPresent')"
        class="flex-1 xl:flex-none px-4 py-2.5 bg-white border border-slate-200 text-slate-600 text-sm font-bold rounded-lg hover:bg-slate-50 hover:text-blue-600 transition-colors flex items-center justify-center gap-2 whitespace-nowrap"
      >
        <i class="fa-solid fa-check-double text-blue-500"></i>
        {{ $t('teacher.attendance.markAllPresent') }}
      </button>
      <button
        @click="$emit('saveAttendance')"
        :disabled="saving || !selectedClassId || !selectedDate"
        class="flex-1 xl:flex-none px-6 py-2.5 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 shadow-lg shadow-blue-200 flex items-center justify-center gap-2 transition-transform active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <i v-if="saving" class="fa-solid fa-spinner fa-spin"></i>
        <i v-else class="fa-solid fa-floppy-disk"></i>
        {{
          saving
            ? $t('teacher.attendance.saving')
            : $t('teacher.attendance.save')
        }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import AttendanceDateSelector from './AttendanceDateSelector.vue';
import AttendanceStats from './AttendanceStats.vue';

defineProps<{
  selectedClassId: string;
  selectedDate: string;
  selectedDateOption: string;
  classes: Array<{ id: number; name: string }>;
  upcomingClassDates: Array<{ value: string; label: string }>;
  attendanceStats: {
    present: number;
    late: number;
    absent: number;
  };
  totalStudents: number;
  saving: boolean;
}>();

const emit = defineEmits<{
  'update:selectedClassId': [value: string];
  'update:selectedDate': [value: string];
  'update:selectedDateOption': [value: string];
  classChange: [];
  dateOptionChange: [];
  dateChange: [];
  markAllPresent: [];
  saveAttendance: [];
}>();

const handleClassIdChange = (event: Event) => {
  const target = event.target as HTMLSelectElement;
  const value = target.value;
  emit('update:selectedClassId', value || '');
  // Also emit classChange to trigger handler
  emit('classChange');
};

const handleDateChange = () => {
  emit('dateChange');
};
</script>
