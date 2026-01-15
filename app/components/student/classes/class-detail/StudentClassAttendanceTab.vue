<template>
  <div class="space-y-6 animate-fade-in">
    <div class="grid grid-cols-3 gap-4">
      <div
        class="bg-green-50 border border-green-100 p-4 rounded-xl text-center"
      >
        <div class="text-2xl font-bold text-green-600">
          {{ attendanceStats.present }}
        </div>
        <div class="text-xs text-green-800">
          {{ $t('student.classes.detail.attendance.present') }}
        </div>
      </div>
      <div
        class="bg-yellow-50 border border-yellow-100 p-4 rounded-xl text-center"
      >
        <div class="text-2xl font-bold text-yellow-600">
          {{ attendanceStats.excused }}
        </div>
        <div class="text-xs text-yellow-800">
          {{ $t('student.classes.detail.attendance.excused') }}
        </div>
      </div>
      <div class="bg-red-50 border border-red-100 p-4 rounded-xl text-center">
        <div class="text-2xl font-bold text-red-600">
          {{ attendanceStats.unexcused }}
        </div>
        <div class="text-xs text-red-800">
          {{ $t('student.classes.detail.attendance.unexcused') }}
        </div>
      </div>
    </div>

    <div class="flex justify-end">
      <button
        class="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white font-bold text-sm rounded-lg shadow-sm flex items-center gap-2 transition-colors"
        @click="showLeaveModal = true"
      >
        <i class="fa-regular fa-envelope"></i>
        {{ $t('student.classes.detail.attendance.requestLeave') }}
      </button>
    </div>

    <!-- Leave Request Modal -->
    <StudentLeaveRequestModal
      v-model="showLeaveModal"
      :selected-class="selectedClass"
      @submit="handleSubmitLeave"
    />

    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"
    >
      <div class="p-4 border-b border-slate-100 font-bold text-slate-800">
        {{ $t('student.classes.detail.attendance.history') }}
      </div>
      <div class="divide-y divide-slate-100">
        <div
          v-for="(record, idx) in attendanceRecords"
          :key="idx"
          class="p-4 flex items-center justify-between hover:bg-slate-50"
        >
          <div class="flex items-center gap-4">
            <div
              class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 font-bold text-xs"
            >
              {{ record.date.split('/')[0] }}
            </div>
            <div>
              <div class="font-bold text-slate-800">{{ record.date }}</div>
              <div class="text-xs text-slate-500">{{ record.time }}</div>
            </div>
          </div>
          <div>
            <span
              v-if="record.type === 'present'"
              class="flex items-center gap-2 text-green-600 text-sm font-bold bg-green-50 px-3 py-1 rounded-full border border-green-100"
            >
              <i class="fa-solid fa-check"></i>
              {{ $t('student.classes.detail.attendance.present') }}
            </span>
            <span
              v-else-if="record.type === 'excused'"
              class="flex items-center gap-2 text-yellow-600 text-sm font-bold bg-yellow-50 px-3 py-1 rounded-full border border-yellow-100"
            >
              <i class="fa-solid fa-envelope-open-text"></i>
              {{ $t('student.classes.detail.attendance.excused') }}
            </span>
          </div>
        </div>
        <div
          v-if="attendanceRecords.length === 0"
          class="p-12 text-center text-slate-400"
        >
          <i class="fa-solid fa-inbox text-3xl mb-2"></i>
          <p>{{ $t('student.classes.detail.attendance.noRecords') }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import type { StudentClass } from 'app/types/class';
import StudentLeaveRequestModal from '../StudentLeaveRequestModal.vue';

interface AttendanceRecord {
  date: string;
  time: string;
  type: 'present' | 'excused' | 'unexcused';
}

interface Props {
  attendanceStats: {
    present: number;
    excused: number;
    unexcused: number;
  };
  attendanceRecords: AttendanceRecord[];
  selectedClass: StudentClass | null;
}

const props = defineProps<Props>();

const { t } = useI18n();
const toast = useToast();
const showLeaveModal = ref(false);

const handleSubmitLeave = async (payload: {
  date: string;
  reason: string;
  leaveType: string;
}) => {
  if (!props.selectedClass) return;

  try {
    await useEnrollClassApi().leaveRequestClass(
      props.selectedClass.class_id,
      payload.reason,
      payload.leaveType,
      payload.date
    );
    toast.success(t('student.classes.leave.successMessage'));
    showLeaveModal.value = false;
  } catch (error) {
    toast.error(
      getErrorMessage(error, 'student.classes.', t) ||
        t('student.classes.leave.errorSubmitting')
    );
  }
};
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
