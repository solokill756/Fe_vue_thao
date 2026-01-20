<template>
  <div
    @click="$emit('click', assignment)"
    class="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-lg hover:border-blue-300 transition-all cursor-pointer group flex flex-col"
  >
    <div class="p-5 border-b border-slate-100">
      <div class="flex justify-between items-start mb-2">
        <span
          class="text-xs font-bold text-slate-400 uppercase tracking-wide"
        >
          {{ assignment.class_name }}
        </span>
        <span
          :class="[
            'text-[10px] font-bold px-2 py-1 rounded-full uppercase',
            assignment.status === 'open'
              ? 'bg-green-100 text-green-700'
              : 'bg-slate-100 text-slate-500',
          ]"
        >
          {{
            assignment.status === 'open'
              ? $t('teacher.grading.statusOpen')
              : $t('teacher.grading.statusClosed')
          }}
        </span>
      </div>
      <h3
        class="font-bold text-lg text-slate-800 group-hover:text-blue-600 transition-colors line-clamp-2"
      >
        {{ assignment.title }}
      </h3>
      <p class="text-sm text-slate-500 mt-1">
        <i class="fa-regular fa-clock mr-1"></i>
        {{ $t('teacher.grading.dueDate') }}:
        {{ formatDate(assignment.due_date) }}
      </p>
    </div>
    <div class="p-5 flex-1 flex flex-col justify-end">
      <div class="flex justify-between text-sm mb-1.5">
        <span class="text-slate-500">
          {{ $t('teacher.grading.gradingProgress') }}
        </span>
        <span class="font-bold text-blue-600">
          {{ assignment.graded_submissions_count || 0 }}/{{
            assignment.submissions_count || 0
          }}
          {{ $t('teacher.grading.submissions') }}
        </span>
      </div>
      <div class="w-full bg-slate-100 rounded-full h-2 mb-4">
        <div
          class="bg-blue-500 h-2 rounded-full transition-all duration-500"
          :style="{
            width:
              assignment.submissions_count && assignment.submissions_count > 0
                ? ((assignment.graded_submissions_count || 0) /
                    assignment.submissions_count) *
                    100 +
                  '%'
                : '0%',
          }"
        ></div>
      </div>
      <div
        class="flex items-center justify-between text-xs text-slate-400"
      >
        <span>
          {{ $t('teacher.grading.total') }}:
          {{ assignment.total_students || 0 }}
          {{ $t('teacher.grading.students') }}
        </span>
        <span
          v-if="
            assignment.total_students &&
            (assignment.submissions_count || 0) < assignment.total_students
          "
          class="text-orange-500 font-bold"
        >
          {{ assignment.total_students - (assignment.submissions_count || 0) }}
          {{ $t('teacher.grading.notSubmitted') }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { TeacherAssignment } from '../../../composables/useTeacherGradingApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';

const { t } = useI18n();
const { formatDate } = useTeacherGradingApi();

defineProps<{
  assignment: TeacherAssignment;
}>();

defineEmits<{
  click: [assignment: TeacherAssignment];
}>();
</script>
