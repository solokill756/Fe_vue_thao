<template>
  <div class="flex-1 overflow-y-auto custom-scroll pr-1">
    <div
      v-if="assignments.length > 0"
      class="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
    >
      <div
        v-for="(task, idx) in assignments"
        :key="idx"
        @click="$emit('select-assignment', task)"
        class="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-lg hover:border-blue-300 transition-all flex flex-col group cursor-pointer"
      >
        <div
          class="p-5 border-b border-slate-100 flex items-start justify-between"
        >
          <div class="flex gap-4">
            <div
              class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-xl shadow-sm"
            >
              <i :class="['fa-solid', 'fa-book']"></i>
            </div>
            <div>
              <span
                class="text-xs font-bold text-slate-400 uppercase tracking-wide"
                >{{ task.school_class.name }}</span
              >
              <h3
                class="font-bold text-slate-800 text-lg leading-tight group-hover:text-blue-600 transition-colors line-clamp-2"
              >
                {{ task.title }}
              </h3>
            </div>
          </div>
        </div>
        <div class="p-5 flex-1 space-y-4">
          <div
            class="bg-slate-50 rounded-lg p-3 border border-slate-100 space-y-2"
          >
            <div class="flex justify-between items-center text-sm">
              <span class="text-slate-500">{{
                t('student.assignments.dueDate')
              }}</span>
              <span
                :class="[
                  'font-bold',
                  isUrgent(task.due_date) ? 'text-red-600' : 'text-slate-700',
                ]"
              >
                {{ formatDate(task.due_date) }}
              </span>
            </div>
            <div class="flex justify-between items-center text-sm">
              <span class="text-slate-500">{{
                t('student.assignments.status')
              }}</span>
              <span
                :class="[
                  'text-xs font-bold px-2 py-0.5 rounded border',
                  getStatusClass(task.submission_status),
                ]"
              >
                {{ mapSubmissionStatusToStatusKey(task.submission_status) }}
              </span>
            </div>
            <div
              v-if="task.score"
              class="flex justify-between items-center text-sm pt-1 border-t border-slate-200 mt-1"
            >
              <span class="text-slate-500">{{
                t('student.assignments.score')
              }}</span>
              <span class="font-bold text-green-600 text-lg"
                >{{ task.score }}/10</span
              >
            </div>
          </div>
        </div>
      </div>
    </div>
    <div
      v-else
      class="flex flex-col items-center justify-center h-64 text-slate-400 bg-white rounded-xl border border-slate-200 border-dashed"
    >
      <i class="fa-solid fa-folder-open text-3xl opacity-50 mb-2"></i>
      <p class="font-medium">
        {{ t('student.assignments.noAssignmentsFound') }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Assignment } from '@/types/assignment';
import { useI18n } from 'vue-i18n';

interface Props {
  assignments: Assignment[];
}

defineProps<Props>();

defineEmits<{
  'select-assignment': [assignment: Assignment];
}>();

const { t } = useI18n();
const { formatDate, isUrgent, mapSubmissionStatusToStatusKey } =
  useAssignmentApi();

const getStatusClass = (statusKey?: string) => {
  switch (statusKey) {
    case 'no_submission':
      return 'bg-yellow-100 text-yellow-700 border-yellow-200';
    case 'submitted':
      return 'bg-blue-100 text-blue-700 border-blue-200';
    case 'graded':
      return 'bg-green-100 text-green-700 border-green-200';
    case 'late':
      return 'bg-red-100 text-red-700 border-red-200';
    default:
      return 'bg-slate-100 text-slate-700';
  }
};
</script>

<style scoped>
.custom-scroll::-webkit-scrollbar {
  width: 6px;
}
.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}
.custom-scroll::-webkit-scrollbar-thumb {
  background: #93c5fd;
  border-radius: 3px;
}
.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #3b82f6;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
