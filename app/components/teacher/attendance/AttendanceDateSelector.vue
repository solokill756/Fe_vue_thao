<template>
  <div class="flex flex-col flex-1">
    <label class="text-xs font-bold text-slate-500 mb-1 uppercase">
      {{ $t('teacher.attendance.dateLabel') }}
    </label>
    <div class="flex gap-2">
      <select
        :value="selectedDateOption"
        @change="handleSelectChange"
        class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-800 outline-none focus:border-blue-500 flex-1"
      >
        <option value="custom">
          {{ $t('teacher.attendance.selectCustomDate') }}
        </option>
        <option
          v-for="dateOption in upcomingClassDates"
          :key="dateOption.value"
          :value="dateOption.value"
        >
          {{ dateOption.label }}
        </option>
      </select>
      <input
        v-if="selectedDateOption === 'custom'"
        :value="selectedDate"
        @input="handleDateInput"
        @change="handleDateChange"
        @blur="handleDateBlur"
        type="date"
        class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-800 outline-none focus:border-blue-500 w-48"
      />
      <div
        v-else
        class="px-4 py-2 bg-blue-50 border border-blue-200 rounded-lg text-sm font-bold text-blue-800 flex items-center gap-2"
      >
        <i class="fa-solid fa-calendar-check"></i>
        <span>{{ formatSelectedDate }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  selectedDate: string;
  selectedDateOption: string;
  upcomingClassDates: Array<{ value: string; label: string }>;
}>();

const emit = defineEmits<{
  'update:selectedDate': [value: string];
  'update:selectedDateOption': [value: string];
  dateOptionChange: [];
  dateChange: [];
}>();

const handleSelectChange = (event: Event) => {
  const target = event.target as HTMLSelectElement;
  const value = target.value;
  emit('update:selectedDateOption', value);
  emit('dateOptionChange');
};

const handleDateInput = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const value = target.value;
  emit('update:selectedDate', value);
  // Emit dateChange immediately on input
  emit('dateChange');
};

const handleDateChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const value = target.value;
  emit('update:selectedDate', value);
  // Also emit dateChange when date input changes
  emit('dateChange');
};

const handleDateBlur = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const value = target.value;
  if (value && value !== props.selectedDate) {
    emit('update:selectedDate', value);
    emit('dateChange');
  }
};

const formatSelectedDate = computed(() => {
  if (!props.selectedDate) return '';
  try {
    const date = new Date(props.selectedDate);

    if (isNaN(date.getTime())) return '';

    return date.toLocaleDateString('vi-VN', {
      weekday: 'long',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  } catch {
    return '';
  }
});
</script>
