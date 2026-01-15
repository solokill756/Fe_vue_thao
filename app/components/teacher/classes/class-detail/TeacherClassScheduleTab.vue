<template>
  <div class="space-y-6">
    <div
      class="bg-blue-50 border border-blue-100 rounded-lg p-4 flex items-center gap-3"
    >
      <div
        class="w-10 h-10 bg-white rounded-full flex items-center justify-center text-blue-600 shadow-sm"
      >
        <i class="fa-regular fa-clock"></i>
      </div>
      <div class="flex-1">
        <h4 class="font-bold text-blue-900">{{ $t('teacher.classes.scheduleTab.fixedSchedule') }}</h4>
        <p
          v-if="
            scheduleData?.fixed_schedule &&
            Object.keys(scheduleData.fixed_schedule).length > 0
          "
          class="text-sm text-blue-700"
        >
          {{ formatSchedule(scheduleData.fixed_schedule) }}
        </p>
        <p v-else class="text-sm text-blue-700 italic">
          {{ $t('teacher.classes.scheduleTab.noFixedSchedule') }}
        </p>
      </div>
      <button
        @click="showEditScheduleModal = true"
        class="ml-auto text-sm font-bold text-blue-600 hover:underline"
      >
        {{ $t('teacher.classes.scheduleTab.change') }}
      </button>
    </div>

    <!-- Edit Schedule Modal -->
    <div
      v-if="showEditScheduleModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="showEditScheduleModal = false"
    >
      <div
        class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-slate-800">
            {{ $t('teacher.classes.scheduleTab.modal.editFixedSchedule') }}
          </h3>
          <button
            @click="showEditScheduleModal = false"
            class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 transition-colors"
          >
            <i class="fa-solid fa-times"></i>
          </button>
        </div>

        <div class="space-y-3">
          <p class="text-sm text-slate-600 mb-4">
            {{ $t('teacher.classes.scheduleTab.modal.description') }}
          </p>
          <div>
            <label class="block text-sm font-bold text-slate-700 mb-2">
              {{ $t('teacher.classes.scheduleTab.modal.scheduleJson') }}
            </label>
            <textarea
              v-model="scheduleJsonInput"
              rows="4"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 font-mono text-sm"
              :placeholder="$t('teacher.classes.scheduleTab.modal.schedulePlaceholder')"
            ></textarea>
            <p class="text-xs text-slate-500 mt-1">
              Ví dụ JSON: <code class="bg-slate-100 px-1 rounded">{"0": "17:30-19:00", "2": "17:30-19:00"}</code>
            </p>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button
            @click="showEditScheduleModal = false"
            class="flex-1 px-4 py-2 border border-slate-200 text-slate-700 font-bold rounded-lg hover:bg-slate-50 transition-colors"
          >
            {{ $t('teacher.classes.scheduleTab.modal.cancel') }}
          </button>
          <button
            @click="handleSaveSchedule"
            class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors"
          >
            {{ $t('teacher.classes.scheduleTab.modal.save') }}
          </button>
        </div>
      </div>
    </div>

    <div>
      <div class="flex justify-between items-center mb-4">
        <h4 class="font-bold text-slate-800">{{ $t('teacher.classes.scheduleTab.upcomingSessions') }}</h4>
        <button
          @click="openAddSessionModal"
          class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold rounded-lg transition-colors flex items-center gap-2"
        >
          <i class="fa-solid fa-plus"></i>
          {{ $t('teacher.classes.scheduleTab.addSession') }}
        </button>
      </div>

      <div v-if="loadingSchedule" class="text-center py-8">
        <div
          class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"
        ></div>
        <p class="text-sm text-slate-500 mt-2">{{ $t('teacher.classes.scheduleTab.loading') }}</p>
      </div>

      <div
        v-else-if="
          !scheduleData?.upcoming_sessions ||
          scheduleData.upcoming_sessions.length === 0
        "
        class="text-center py-8 text-slate-500"
      >
        <i class="fa-regular fa-calendar text-4xl mb-2"></i>
        <p>{{ $t('teacher.classes.scheduleTab.noUpcomingSessions') }}</p>
      </div>

      <div v-else class="space-y-3">
        <div
          v-for="session in scheduleData?.upcoming_sessions || []"
          :key="session.id"
          class="flex items-center justify-between p-4 border border-slate-200 rounded-lg hover:border-blue-300 transition-colors bg-slate-50"
        >
          <div class="flex items-center gap-4 flex-1">
            <div
              class="text-center w-16 bg-white rounded border border-slate-200 py-2"
            >
              <div class="text-xs text-slate-500 font-bold">
                {{ getDayOfWeekShort(session.day_of_week) }}
              </div>
              <div class="text-lg font-bold text-slate-800">
                {{ session.date_display.split('/')[0] }}
              </div>
              <div class="text-xs text-slate-500">
                {{ session.date_display.split('/')[1] }}/{{
                  session.date_display.split('/')[2]
                }}
              </div>
            </div>
            <div class="flex-1">
              <div class="font-bold text-slate-800">
                {{ session.time_display }}
              </div>
              <div
                v-if="session.teacher_note"
                class="text-sm text-slate-600 mt-1"
              >
                {{ session.teacher_note }}
              </div>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span
              class="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded font-bold"
              >{{ $t('teacher.classes.scheduleTab.upcoming') }}</span
            >
            <button
              @click="openEditSessionModal(session)"
              class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 transition-colors"
              :title="$t('teacher.classes.scheduleTab.edit')"
            >
              <i class="fa-solid fa-pencil text-xs"></i>
            </button>
            <button
              @click="handleDeleteSession(session.id)"
              class="w-8 h-8 rounded-full bg-red-50 hover:bg-red-100 flex items-center justify-center text-red-600 transition-colors"
              :title="$t('teacher.classes.scheduleTab.delete')"
            >
              <i class="fa-solid fa-trash text-xs"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Session Modal -->
    <div
      v-if="showSessionModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="showSessionModal = false"
    >
      <div
        class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-slate-800">
            {{ editingSession ? $t('teacher.classes.scheduleTab.modal.editSession') : $t('teacher.classes.scheduleTab.modal.addSession') }}
          </h3>
          <button
            @click="showSessionModal = false"
            class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 transition-colors"
          >
            <i class="fa-solid fa-times"></i>
          </button>
        </div>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-bold text-slate-700 mb-2">
              {{ $t('teacher.classes.scheduleTab.modal.sessionDate') }}
            </label>
            <input
              v-model="sessionDate"
              type="date"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-bold text-slate-700 mb-2">
              {{ $t('teacher.classes.scheduleTab.modal.sessionTime') }}
            </label>
            <input
              v-model="sessionTime"
              type="time"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-bold text-slate-700 mb-2">
              {{ $t('teacher.classes.scheduleTab.modal.sessionNote') }}
            </label>
            <textarea
              v-model="sessionNote"
              rows="3"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500"
              :placeholder="$t('teacher.classes.scheduleTab.modal.notePlaceholder')"
            ></textarea>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button
            @click="showSessionModal = false"
            class="flex-1 px-4 py-2 border border-slate-200 text-slate-700 font-bold rounded-lg hover:bg-slate-50 transition-colors"
          >
            {{ $t('teacher.classes.scheduleTab.modal.cancel') }}
          </button>
          <button
            @click="handleSaveSession"
            class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors"
          >
            {{ editingSession ? $t('teacher.classes.scheduleTab.modal.update') : $t('teacher.classes.scheduleTab.modal.add') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TeacherClassDetail } from '../../../../composables/useTeacherClassApi';
import { useTeacherClassApi } from '../../../../composables/useTeacherClassApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

const props = defineProps<{
  classDetail: TeacherClassDetail;
  scheduleData: {
    fixed_schedule: any;
    upcoming_sessions: Array<{
      id: number;
      date: string;
      date_display: string;
      time_display: string;
      day_of_week: string;
      teacher_note: string;
      status: string;
    }>;
  } | null;
  loadingSchedule: boolean;
}>();

const emit = defineEmits<{
  refreshSchedule: [];
}>();

const toast = useToast();
const {
  createAttendanceSession,
  updateAttendanceSession,
  deleteAttendanceSession,
  updateSchedule,
} = useTeacherClassApi();

const showEditScheduleModal = ref(false);
const showSessionModal = ref(false);
const editingSession = ref<{
  id?: number;
  date: string;
  teacher_note: string;
} | null>(null);
const sessionDate = ref('');
const sessionTime = ref('');
const sessionNote = ref('');
const scheduleJsonInput = ref('');

const formatSchedule = (schedule: any) => {
  if (!schedule || typeof schedule !== 'object') return t('teacher.classes.scheduleTab.messages.noSchedule');
  const days = [
    t('teacher.classes.scheduleTab.days.monday'),
    t('teacher.classes.scheduleTab.days.tuesday'),
    t('teacher.classes.scheduleTab.days.wednesday'),
    t('teacher.classes.scheduleTab.days.thursday'),
    t('teacher.classes.scheduleTab.days.friday'),
    t('teacher.classes.scheduleTab.days.saturday'),
    t('teacher.classes.scheduleTab.days.sunday'),
  ];
  const parts: string[] = [];

  Object.keys(schedule).forEach((key) => {
    const dayIndex = parseInt(key);
    if (!isNaN(dayIndex) && dayIndex >= 0 && dayIndex <= 6) {
      const time = schedule[key];
      parts.push(`${days[dayIndex]}: ${time}`);
    }
  });

  return parts.length > 0 ? parts.join(', ') : t('teacher.classes.scheduleTab.messages.noSchedule');
};

const getDayOfWeekShort = (dayOfWeek: string) => {
  const dayMap: Record<string, string> = {
    Monday: t('teacher.classes.scheduleTab.dayShort.monday'),
    Tuesday: t('teacher.classes.scheduleTab.dayShort.tuesday'),
    Wednesday: t('teacher.classes.scheduleTab.dayShort.wednesday'),
    Thursday: t('teacher.classes.scheduleTab.dayShort.thursday'),
    Friday: t('teacher.classes.scheduleTab.dayShort.friday'),
    Saturday: t('teacher.classes.scheduleTab.dayShort.saturday'),
    Sunday: t('teacher.classes.scheduleTab.dayShort.sunday'),
  };
  return dayMap[dayOfWeek] || dayOfWeek;
};

const openAddSessionModal = () => {
  editingSession.value = null;
  sessionDate.value = '';
  sessionTime.value = '';
  sessionNote.value = '';
  showSessionModal.value = true;
};

const openEditSessionModal = (session: any) => {
  editingSession.value = {
    id: session.id,
    date: session.date,
    teacher_note: session.teacher_note || '',
  };
  const dateObj = new Date(session.date);
  const dateStr = dateObj.toISOString().split('T')[0];
  const timeStr = dateObj.toTimeString().slice(0, 5);
  sessionDate.value = dateStr || '';
  sessionTime.value = timeStr || '';
  sessionNote.value = session.teacher_note || '';
  showSessionModal.value = true;
};

const handleSaveSession = async () => {
  if (!sessionDate.value || !sessionTime.value) {
    toast.error(t('teacher.classes.scheduleTab.messages.invalidDateTime'));
    return;
  }

  try {
    const dateTime = new Date(`${sessionDate.value}T${sessionTime.value}:00`);
    const dateTimeString = dateTime.toISOString();

    if (editingSession.value?.id) {
      await updateAttendanceSession(
        props.classDetail.id,
        editingSession.value.id,
        dateTimeString,
        sessionNote.value
      );
      toast.success(t('teacher.classes.scheduleTab.messages.updateSessionSuccess'));
    } else {
      await createAttendanceSession(
        props.classDetail.id,
        dateTimeString,
        sessionNote.value
      );
      toast.success(t('teacher.classes.scheduleTab.messages.addSessionSuccess'));
    }

    showSessionModal.value = false;
    emit('refreshSchedule');
  } catch (error: any) {
    toast.error(error?.data?.message || t('teacher.classes.scheduleTab.messages.saveError'));
  }
};

const handleDeleteSession = async (sessionId: number) => {
  if (!confirm(t('teacher.classes.scheduleTab.messages.confirmDelete'))) return;

  try {
    await deleteAttendanceSession(props.classDetail.id, sessionId);
    toast.success(t('teacher.classes.scheduleTab.messages.deleteSessionSuccess'));
    emit('refreshSchedule');
  } catch (error: any) {
    toast.error(error?.data?.message || t('teacher.classes.scheduleTab.messages.deleteError'));
  }
};

const handleSaveSchedule = async () => {
  try {
    let scheduleObj;
    if (scheduleJsonInput.value.trim()) {
      scheduleObj = JSON.parse(scheduleJsonInput.value);
    } else {
      scheduleObj = {};
    }

    await updateSchedule(props.classDetail.id, scheduleObj);
    toast.success(t('teacher.classes.scheduleTab.messages.updateScheduleSuccess'));
    showEditScheduleModal.value = false;
    emit('refreshSchedule');
  } catch (error: any) {
    if (error instanceof SyntaxError) {
      toast.error(t('teacher.classes.scheduleTab.messages.invalidJson'));
    } else {
      toast.error(error?.data?.message || t('teacher.classes.scheduleTab.messages.updateScheduleError'));
    }
  }
};

watch(showEditScheduleModal, (isOpen) => {
  if (isOpen) {
    scheduleJsonInput.value = JSON.stringify(
      props.scheduleData?.fixed_schedule || {},
      null,
      2
    );
  }
});
</script>
