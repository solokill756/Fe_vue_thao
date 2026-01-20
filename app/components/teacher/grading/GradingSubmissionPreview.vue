<template>
  <div class="flex-1 p-6 overflow-y-auto custom-scroll">
    <div
      v-if="submission.status !== 'missing'"
      class="bg-white border border-slate-200 rounded-xl shadow-sm h-full flex flex-col items-center justify-center p-8 text-center"
    >
      <div
        class="w-16 h-16 bg-red-50 text-red-500 rounded-xl flex items-center justify-center text-3xl mb-4"
      >
        <i
          :class="
            submission.file_name?.endsWith('.pdf')
              ? 'fa-regular fa-file-pdf'
              : submission.file_name?.endsWith('.jpg') ||
                submission.file_name?.endsWith('.png')
              ? 'fa-regular fa-file-image'
              : 'fa-regular fa-file'
          "
        ></i>
      </div>
      <h3 class="font-bold text-slate-800 text-lg">
        {{
          submission.file_name || $t('teacher.grading.textSubmission')
        }}
      </h3>
      <p class="text-slate-500 text-sm mb-6">
        {{
          submission.submitted_at
            ? $t('teacher.grading.submittedAt', {
                time: formatDateTime(submission.submitted_at),
              })
            : ''
        }}
      </p>
      <div
        v-if="submission.content"
        class="w-full max-w-2xl bg-slate-50 rounded-lg p-4 text-left mb-4"
      >
        <p class="text-sm text-slate-700 whitespace-pre-wrap">
          {{ submission.content }}
        </p>
      </div>
      <a
        v-if="submission.file_url"
        :href="fileUrl"
        target="_blank"
        class="px-6 py-2 border border-slate-300 rounded-lg text-sm font-bold text-slate-600 hover:bg-slate-50 hover:text-blue-600 transition-colors inline-flex items-center gap-2"
      >
        <i class="fa-solid fa-eye"></i>
        {{ $t('teacher.grading.viewSubmission') }}
      </a>
    </div>
    <div
      v-else
      class="h-full flex flex-col items-center justify-center text-slate-400"
    >
      <i class="fa-solid fa-user-slash text-4xl mb-3"></i>
      <p>{{ $t('teacher.grading.studentNotSubmitted') }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import type { TeacherSubmission } from '../../../composables/useTeacherGradingApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';

const { t } = useI18n();
const { formatDateTime } = useTeacherGradingApi();
const config = useRuntimeConfig();

const props = defineProps<{
  submission: TeacherSubmission;
}>();

const fileUrl = computed(() => {
  if (!props.submission.file_url) return '';
  if (props.submission.file_url.startsWith('http')) {
    return props.submission.file_url;
  }
  return `${config.public.apiBase}${props.submission.file_url}`;
});
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
