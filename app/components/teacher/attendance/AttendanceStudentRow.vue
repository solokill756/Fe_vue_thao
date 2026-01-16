<template>
  <tr
    :class="[
      'transition-colors group border-l-4',
      getStatusBorder(student.status),
    ]"
  >
    <td class="px-4 py-4 text-center text-slate-400 font-mono text-xs">
      {{ index + 1 }}
    </td>

    <!-- Student Info with Session Alert -->
    <td class="px-4 py-4">
      <div class="flex items-center gap-3">
        <div class="relative">
          <img
            :src="getStudentAvatar(student)"
            :alt="student.name"
            class="w-10 h-10 rounded-full border border-slate-200 bg-white object-cover"
            @error="handleImageError($event)"
          />
          <div
            v-if="student.status === 'present'"
            class="absolute -bottom-1 -right-1 bg-green-500 w-3.5 h-3.5 rounded-full border-2 border-white"
          ></div>
        </div>
        <div>
          <div class="font-bold text-slate-800 text-base">
            {{ student.name }}
          </div>
          <div class="flex items-center gap-2 mt-0.5">
            <span
              v-if="student.student_code"
              class="text-xs text-slate-500 font-mono"
            >
              {{ student.student_code }}
            </span>

            <!-- Session Counter with Alert Logic -->
            <div class="flex items-center gap-1">
              <span
                :class="[
                  'text-[10px] px-1.5 py-0.5 rounded font-bold border',
                  getSessionStatusColor(
                    student.sessions_attended || 0,
                    student.total_sessions || 0
                  ),
                ]"
                :title="
                  $t('teacher.attendance.sessionsTooltip', {
                    attended: student.sessions_attended || 0,
                    total: student.total_sessions || 0,
                  })
                "
              >
                {{ student.sessions_attended || 0 }}/{{
                  student.total_sessions || 0
                }}
                {{ $t('teacher.attendance.sessions') }}
              </span>
              <!-- Warning Icon if running low -->
              <i
                v-if="
                  isRunningLow(
                    student.sessions_attended || 0,
                    student.total_sessions || 0
                  )
                "
                class="fa-solid fa-circle-exclamation text-red-500 text-xs animate-pulse"
                :title="$t('teacher.attendance.sessionWarning')"
              ></i>
            </div>
          </div>
        </div>
      </div>
    </td>

    <!-- Status Buttons -->
    <td class="px-4 py-4">
      <AttendanceStatusButtons
        :model-value="student.status"
        @status-change="(status) => $emit('statusChange', status)"
      />
    </td>

    <!-- Notes & Quick Actions -->
    <td class="px-4 py-4">
      <AttendanceNotes
        :note="student.note"
        :status="student.status"
        @update:note="(note) => $emit('noteChange', note)"
        @add-tag="(tag) => $emit('addTag', tag)"
        @alert-parent="$emit('alertParent')"
      />
    </td>
  </tr>
</template>

<script setup lang="ts">
import AttendanceStatusButtons from './AttendanceStatusButtons.vue';
import AttendanceNotes from './AttendanceNotes.vue';

interface AttendanceStudent {
  id: number;
  name: string;
  student_code?: string;
  status:
    | 'present'
    | 'late'
    | 'absent'
    | 'absent_w_reason'
    | 'absent_no_reason';
  note: string;
  sessions_attended?: number;
  total_sessions?: number;
  avatar?: string;
  attendance_record_id?: number;
}

defineProps<{
  student: AttendanceStudent;
  index: number;
}>();

defineEmits<{
  statusChange: [
    status:
      | 'present'
      | 'late'
      | 'absent'
      | 'absent_w_reason'
      | 'absent_no_reason'
  ];
  noteChange: [note: string];
  addTag: [tag: string];
  alertParent: [];
}>();

const getStatusBorder = (status: string) => {
  switch (status) {
    case 'present':
      return 'border-l-green-500 bg-white';
    case 'late':
      return 'border-l-yellow-500 bg-yellow-50/10';
    case 'absent_w_reason':
      return 'border-l-blue-500 bg-blue-50/10';
    case 'absent_no_reason':
      return 'border-l-red-500 bg-red-50/10';
    default:
      return 'border-l-transparent';
  }
};

const isRunningLow = (attended: number, total: number) => {
  if (total === 0) return false;
  return attended / total >= 0.85;
};

const getSessionStatusColor = (attended: number, total: number) => {
  if (total === 0) return 'bg-slate-50 text-slate-600 border-slate-100';
  const ratio = attended / total;
  if (ratio >= 0.9) return 'bg-red-50 text-red-600 border-red-100'; // Critical
  if (ratio >= 0.8) return 'bg-yellow-50 text-yellow-600 border-yellow-100'; // Warning
  return 'bg-blue-50 text-blue-600 border-blue-100'; // Normal
};

const getStudentAvatar = (student: AttendanceStudent) => {
  if (student.avatar) return student.avatar;
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(
    student.name
  )}&background=random`;
};

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement;
  img.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(
    img.alt
  )}&background=random`;
};
</script>
