<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4"
    @click.self="close"
  >
    <div
      class="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden flex flex-col"
    >
      <div
        class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
      >
        <h3 class="font-bold text-lg text-slate-800">
          {{ $t('teacher.classes.createModal.title') }}
        </h3>
        <button @click="close" class="text-slate-400 hover:text-slate-600">
          <i class="fa-solid fa-xmark text-xl"></i>
        </button>
      </div>
      <div class="p-6 space-y-4">
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.classes.createModal.className') }}
            <span class="text-red-500">{{
              $t('teacher.classes.settingsTab.required')
            }}</span>
          </label>
          <input
            v-model="formData.name"
            type="text"
            :placeholder="
              $t('teacher.classes.createModal.classNamePlaceholder')
            "
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            :class="{ 'border-red-300': errors.name }"
          />
          <p v-if="errors.name" class="text-xs text-red-600 mt-1">
            {{ errors.name }}
          </p>
        </div>
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.classes.createModal.subject') }}
            <span class="text-red-500">{{
              $t('teacher.classes.settingsTab.required')
            }}</span>
          </label>
          <input
            v-model="formData.subject"
            type="text"
            :placeholder="$t('teacher.classes.createModal.subjectPlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            :class="{ 'border-red-300': errors.subject }"
          />
          <p v-if="errors.subject" class="text-xs text-red-600 mt-1">
            {{ errors.subject }}
          </p>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-bold text-slate-700 mb-1">
              {{ $t('teacher.classes.createModal.gradeLevel') }}
            </label>
            <input
              v-model="formData.grade_level"
              type="text"
              :placeholder="
                $t('teacher.classes.createModal.gradeLevelPlaceholder')
              "
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            />
          </div>
          <div>
            <label class="block text-sm font-bold text-slate-700 mb-1">
              {{ $t('teacher.classes.createModal.monthlyTuitionFee') }}
            </label>
            <input
              v-model.number="formData.monthly_tuition_fee"
              type="number"
              min="0"
              :placeholder="$t('teacher.classes.settingsTab.feePlaceholder')"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            />
          </div>
        </div>
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.classes.createModal.schedule') }}
          </label>
          <div class="flex gap-2 mb-3 flex-wrap">
            <button
              v-for="day in scheduleDays"
              :key="day"
              @click="toggleDay(day)"
              :class="[
                'px-3 py-1 border rounded text-xs font-bold transition-colors',
                isDaySelected(day)
                  ? 'bg-blue-600 text-white border-blue-600'
                  : 'bg-white hover:bg-blue-50 hover:border-blue-200 hover:text-blue-600 border-slate-200',
              ]"
            >
              {{ day }}
            </button>
          </div>
          <div v-if="selectedDays.length > 0" class="space-y-3">
            <div
              v-for="day in selectedDays"
              :key="day"
              class="p-3 bg-slate-50 rounded-lg border border-slate-200"
            >
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm font-bold text-slate-700">{{ day }}</span>
                <button
                  @click="removeDay(day)"
                  class="text-red-500 hover:text-red-700 text-xs"
                >
                  <i class="fa-solid fa-times"></i>
                </button>
              </div>
              <div class="flex items-center gap-2">
                <input
                  :value="formData.schedule[day]?.startTime || ''"
                  @input="(e) => updateScheduleTime(day, 'startTime', (e.target as HTMLInputElement).value)"
                  type="time"
                  class="flex-1 border border-slate-200 rounded-lg px-3 py-2 text-sm focus:border-blue-500 outline-none"
                />
                <span class="text-sm text-slate-600">{{
                  $t('teacher.classes.createModal.to')
                }}</span>
                <input
                  :value="formData.schedule[day]?.endTime || ''"
                  @input="(e) => updateScheduleTime(day, 'endTime', (e.target as HTMLInputElement).value)"
                  type="time"
                  class="flex-1 border border-slate-200 rounded-lg px-3 py-2 text-sm focus:border-blue-500 outline-none"
                />
              </div>
            </div>
          </div>
          <p v-else class="text-sm text-slate-500 italic">
            {{ $t('teacher.classes.createModal.selectDaysHint') }}
          </p>
        </div>
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.classes.createModal.description') }}
          </label>
          <textarea
            v-model="formData.description"
            rows="3"
            :placeholder="
              $t('teacher.classes.createModal.descriptionPlaceholder')
            "
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none resize-none"
          ></textarea>
        </div>
      </div>
      <div
        class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3"
      >
        <button
          @click="close"
          :disabled="creating"
          class="px-4 py-2 text-slate-500 font-bold text-sm hover:bg-slate-200 rounded-lg transition-colors disabled:opacity-50"
        >
          {{ $t('teacher.classes.createModal.cancel') }}
        </button>
        <button
          @click="handleCreateClass"
          :disabled="creating"
          class="px-4 py-2 bg-blue-600 text-white font-bold text-sm rounded-lg hover:bg-blue-700 shadow-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <i v-if="creating" class="fa-solid fa-spinner fa-spin"></i>
          <span>{{
            creating
              ? $t('teacher.classes.createModal.creating')
              : $t('teacher.classes.createModal.create')
          }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTeacherClassApi } from '../../composables/useTeacherClassApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const toast = useToast();
const { createClass: createClassApi } = useTeacherClassApi();

const props = defineProps<{
  isOpen: boolean;
}>();

const emit = defineEmits<{
  close: [];
  created: [];
}>();

const formData = ref({
  name: '',
  subject: '',
  grade_level: '',
  description: '',
  monthly_tuition_fee: 0,
  schedule: {} as Record<string, { startTime: string; endTime: string }>,
});

const errors = ref<Record<string, string>>({});
const creating = ref(false);

const scheduleDays = [
  t('teacher.classes.scheduleTab.days.monday'),
  t('teacher.classes.scheduleTab.days.tuesday'),
  t('teacher.classes.scheduleTab.days.wednesday'),
  t('teacher.classes.scheduleTab.days.thursday'),
  t('teacher.classes.scheduleTab.days.friday'),
  t('teacher.classes.scheduleTab.days.saturday'),
  t('teacher.classes.scheduleTab.days.sunday'),
];

const isDaySelected = (day: string) => {
  return day in formData.value.schedule;
};

const selectedDays = computed(() => {
  return Object.keys(formData.value.schedule);
});

const toggleDay = (day: string) => {
  if (isDaySelected(day)) {
    removeDay(day);
  } else {
    formData.value.schedule[day] = {
      startTime: '',
      endTime: '',
    };
  }
};

const removeDay = (day: string) => {
  delete formData.value.schedule[day];
};

const updateScheduleTime = (
  day: string,
  field: 'startTime' | 'endTime',
  value: string
) => {
  if (!formData.value.schedule[day]) {
    formData.value.schedule[day] = { startTime: '', endTime: '' };
  }
  formData.value.schedule[day][field] = value;
};

const validateForm = () => {
  errors.value = {};

  if (!formData.value.name?.trim()) {
    errors.value.name = t('teacher.classes.createModal.errors.nameRequired');
  }

  if (!formData.value.subject?.trim()) {
    errors.value.subject = t(
      'teacher.classes.createModal.errors.subjectRequired'
    );
  }

  return Object.keys(errors.value).length === 0;
};

const close = () => {
  emit('close');
  // Reset form
  formData.value = {
    name: '',
    subject: '',
    grade_level: '',
    description: '',
    monthly_tuition_fee: 0,
    schedule: {},
  };
  errors.value = {};
};

const handleCreateClass = async () => {
  if (!validateForm()) {
    return;
  }

  try {
    creating.value = true;
    errors.value = {};

    const payload: any = {
      name: formData.value.name.trim(),
      subject: formData.value.subject.trim(),
    };

    if (formData.value.grade_level?.trim()) {
      payload.grade_level = formData.value.grade_level.trim();
    }

    if (formData.value.description?.trim()) {
      payload.description = formData.value.description.trim();
    }

    if (formData.value.monthly_tuition_fee) {
      payload.monthly_tuition_fee = formData.value.monthly_tuition_fee;
    }

    // Build schedule data - each day can have different times
    const scheduleEntries = Object.entries(formData.value.schedule).filter(
      ([_, times]) => times.startTime && times.endTime
    );

    if (scheduleEntries.length > 0) {
      payload.schedule_data = scheduleEntries.map(([day, times]) => ({
        day,
        start_time: times.startTime,
        end_time: times.endTime,
      }));
    }

    const response = await createClassApi(payload);

    if (response.data) {
      toast.success(t('teacher.classes.createModal.messages.success'));
      emit('created');
      close();
    }
  } catch (error: any) {
    const errorMessage =
      error?.data?.message || t('teacher.classes.createModal.messages.error');
    toast.error(errorMessage);

    // Set field-specific errors if available
    if (error?.data?.errors) {
      errors.value = error.data.errors;
    }
  } finally {
    creating.value = false;
  }
};
</script>
