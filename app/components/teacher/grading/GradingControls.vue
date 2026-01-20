<template>
  <div
    class="bg-white border-t border-slate-200 p-6 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] z-10"
  >
    <div class="grid grid-cols-4 gap-6">
      <div class="col-span-1">
        <label
          class="block text-xs font-bold text-slate-500 uppercase mb-1"
        >
          {{ $t('teacher.grading.score') }} (0-10)
        </label>
        <input
          :model-value="submission.score"
          @update:model-value="$emit('update:score', $event)"
          type="number"
          min="0"
          max="10"
          step="0.5"
          :disabled="submission.status === 'missing'"
          class="w-full px-4 py-2 border-2 border-slate-200 rounded-xl text-center font-bold text-xl text-blue-600 focus:border-blue-500 focus:outline-none transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        />
      </div>
      <div class="col-span-3">
        <div class="flex justify-between mb-1">
          <label
            class="block text-xs font-bold text-slate-500 uppercase"
          >
            {{ $t('teacher.grading.feedback') }}
          </label>
          <button
            @click="$emit('generate-ai-feedback')"
            class="text-xs font-bold text-purple-600 hover:text-purple-800 flex items-center gap-1 transition-colors"
            :title="$t('teacher.grading.aiFeedbackHint')"
          >
            <i class="fa-solid fa-wand-magic-sparkles"></i>
            {{ $t('teacher.grading.aiSuggestion') }}
          </button>
        </div>
        <textarea
          :model-value="submission.teacher_feedback"
          @update:model-value="$emit('update:feedback', $event)"
          rows="2"
          :disabled="submission.status === 'missing'"
          class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none resize-none transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          :placeholder="$t('teacher.grading.feedbackPlaceholder')"
        ></textarea>
      </div>
    </div>
    <div class="flex justify-between mt-4 items-center">
      <button
        @click="$emit('previous')"
        class="text-slate-400 hover:text-slate-600 text-sm font-bold"
      >
        <i class="fa-solid fa-chevron-left"></i>
        {{ $t('teacher.grading.previousStudent') }}
      </button>
      <button
        @click="$emit('save')"
        :disabled="saving"
        class="px-8 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg shadow-md transition-transform active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <i
          v-if="saving"
          class="fa-solid fa-spinner fa-spin mr-2"
        ></i>
        {{ $t('teacher.grading.saveAndContinue') }}
      </button>
      <button
        @click="$emit('next')"
        class="text-slate-600 hover:text-blue-600 text-sm font-bold"
      >
        {{ $t('teacher.grading.nextStudent') }}
        <i class="fa-solid fa-chevron-right"></i>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { TeacherSubmission } from '../../../composables/useTeacherGradingApi';

const { t } = useI18n();

defineProps<{
  submission: TeacherSubmission;
  saving: boolean;
}>();

defineEmits<{
  'update:score': [score: number | null | undefined];
  'update:feedback': [feedback: string];
  'generate-ai-feedback': [];
  save: [];
  previous: [];
  next: [];
}>();
</script>
