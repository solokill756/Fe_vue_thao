<template>
  <div
    class="p-4 border-b border-slate-200 bg-slate-50 flex justify-between items-center"
  >
    <div class="flex items-center gap-4">
      <button
        @click="$emit('back')"
        class="w-8 h-8 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-blue-600 hover:border-blue-300 transition-all"
      >
        <i class="fa-solid fa-arrow-left"></i>
      </button>
      <template v-if="assignment">
        <h2 class="font-bold text-slate-800 text-lg">
          {{ assignment.title }}
        </h2>
        <p class="text-xs text-slate-500 font-mono">
          {{ assignment.class_name }}
        </p>
      </template>
    </div>
    <div class="flex gap-2">
      <div
        class="hidden sm:flex bg-white border border-slate-200 rounded-lg p-1"
      >
        <button
          @click="$emit('update:gradingFilter', 'all')"
          :class="[
            'px-3 py-1 rounded text-xs font-bold transition-all',
            gradingFilter === 'all'
              ? 'bg-slate-100 text-slate-800'
              : 'text-slate-500 hover:bg-slate-50',
          ]"
        >
          {{ $t('teacher.grading.all') }} ({{ totalSubmissions }})
        </button>
        <button
          @click="$emit('update:gradingFilter', 'needs_grading')"
          :class="[
            'px-3 py-1 rounded text-xs font-bold transition-all',
            gradingFilter === 'needs_grading'
              ? 'bg-blue-100 text-blue-700'
              : 'text-slate-500 hover:bg-slate-50',
          ]"
        >
          {{ $t('teacher.grading.needsGrading') }} ({{ needsGradingCount }})
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { TeacherAssignment } from '../../../composables/useTeacherGradingApi';

const { t } = useI18n();

defineProps<{
  assignment: TeacherAssignment | null;
  gradingFilter: 'all' | 'needs_grading';
  totalSubmissions: number;
  needsGradingCount: number;
}>();

defineEmits<{
  back: [];
  'update:gradingFilter': [filter: 'all' | 'needs_grading'];
}>();
</script>
