<template>
  <div
    class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
  >
    <table class="w-full text-sm text-left">
      <thead
        class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200"
      >
        <tr>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.assignments.name') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.assignments.dueDate') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.assignments.status') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.assignments.score') }}
          </th>
          <th class="px-6 py-4 text-right">
            {{ $t('student.classes.detail.assignments.actions') }}
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <tr
          v-for="(assignment, idx) in assignments"
          :key="idx"
          class="hover:bg-slate-50"
        >
          <td
            class="px-6 py-4 font-medium text-slate-800 cursor-pointer hover:text-blue-600 transition-colors"
            @click="$emit('view-assignment', assignment.id!)"
          >
            {{ assignment?.title }}
          </td>
          <td
            class="px-6 py-4"
            :class="
              assignment.isUrgent
                ? 'text-red-500 font-bold'
                : 'text-slate-500'
            "
          >
            {{ assignment.dueDate }}
          </td>
          <td class="px-6 py-4">
            <span
              :class="[
                'px-2 py-1 rounded-full text-xs font-bold',
                getAssignmentStatusClass(assignment.submission_status),
              ]"
            >
              {{ getAssignmentStatusLabel(assignment.submission_status) }}
            </span>
          </td>
          <td class="px-6 py-4 text-slate-400">
            {{ assignment.score || '--' }}
          </td>
          <td class="px-6 py-4 text-right">
            <button
              v-if="assignment.submission_status === 'no_submission'"
              class="text-blue-600 hover:underline font-bold"
              @click="$emit('view-assignment', assignment.id!)"
            >
              {{ $t('student.classes.detail.assignments.submit') }}
            </button>
            <button
              v-else
              class="text-slate-500 hover:text-blue-600"
              @click="$emit('view-assignment', assignment.id!)"
            >
              {{ $t('student.classes.detail.assignments.view') }}
            </button>
          </td>
        </tr>
        <tr v-if="assignments.length === 0">
          <td colspan="5" class="px-6 py-12 text-center text-slate-400">
            <i class="fa-solid fa-inbox text-3xl mb-2"></i>
            <p>
              {{ $t('student.classes.detail.assignments.noAssignments') }}
            </p>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { Assignment } from '@/types/assignment';

interface Props {
  assignments: Assignment[];
}

defineProps<Props>();

const { t } = useI18n();

const getAssignmentStatusClass = (status: string): string => {
  const statusMap: Record<string, string> = {
    no_submission: 'bg-yellow-100 text-yellow-700',
    submitted: 'bg-blue-100 text-blue-700',
    graded: 'bg-green-100 text-green-700',
    late: 'bg-red-100 text-red-700',
    resubmit_requested: 'bg-orange-100 text-orange-700',
    // Legacy support
    'Chưa nộp': 'bg-yellow-100 text-yellow-700',
    'Đã nộp': 'bg-blue-100 text-blue-700',
    'Đã chấm': 'bg-green-100 text-green-700',
  };
  return statusMap[status] || 'bg-slate-100 text-slate-700';
};

const getAssignmentStatusLabel = (status: string): string => {
  const statusMap: Record<string, string> = {
    no_submission: t('student.assignments.noSubmission'),
    submitted: t('student.assignments.submitted'),
    graded: t('student.assignments.graded'),
    late: t('student.assignments.submitted'), // Late submissions are still submitted
    resubmit_requested: t('student.assignments.submitted'),
    // Legacy support
    'Chưa nộp': t('student.assignments.noSubmission'),
    'Đã nộp': t('student.assignments.submitted'),
    'Đã chấm': t('student.assignments.graded'),
  };
  return statusMap[status] || status;
};

defineEmits<{
  'view-assignment': [assignmentId: number];
}>();
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
