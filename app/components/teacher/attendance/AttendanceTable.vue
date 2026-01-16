<template>
  <div class="overflow-y-auto custom-scroll flex-1">
    <table class="w-full text-sm text-left border-collapse">
      <thead
        class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0 z-10 shadow-sm"
      >
        <tr>
          <th class="px-4 py-3 w-12 text-center">#</th>
          <th class="px-4 py-3 min-w-[200px]">
            {{ $t('teacher.attendance.table.student') }}
          </th>
          <th class="px-4 py-3 text-center min-w-[280px]">
            {{ $t('teacher.attendance.table.status') }}
          </th>
          <th class="px-4 py-3">
            {{ $t('teacher.attendance.table.notes') }}
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <AttendanceStudentRow
          v-for="(student, idx) in students"
          :key="student.id"
          :student="student"
          :index="idx"
          @status-change="(status) => $emit('studentStatusChange', student.id, status)"
          @note-change="(note) => $emit('studentNoteChange', student.id, note)"
          @add-tag="(tag) => $emit('studentAddTag', student.id, tag)"
          @alert-parent="$emit('studentAlertParent', student)"
        />
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import AttendanceStudentRow from './AttendanceStudentRow.vue';

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
  students: AttendanceStudent[];
}>();

defineEmits<{
  studentStatusChange: [
    studentId: number,
    status:
      | 'present'
      | 'late'
      | 'absent'
      | 'absent_w_reason'
      | 'absent_no_reason'
  ];
  studentNoteChange: [studentId: number, note: string];
  studentAddTag: [studentId: number, tag: string];
  studentAlertParent: [student: AttendanceStudent];
}>();
</script>

<style scoped>
.custom-scroll {
  scrollbar-width: thin;
  scrollbar-color: #cbd5e1 #f1f1f1;
}

.custom-scroll::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
