<template>
  <div v-if="historySubmissions && historySubmissions.length > 0">
    <h3 class="font-bold text-slate-800 mb-3 pt-4 border-t">
      {{ t('student.assignments.activityHistory') }}
    </h3>
    <div class="space-y-4 border-l-2 border-slate-200 ml-2 pl-4 py-2">
      <LoadingSpinner
        v-if="pendingHistory"
        :text="t('student.assignments.loadingHistory')"
      />
      <div v-else-if="errorHistory" class="text-red-600 text-sm font-bold">
        {{ t('student.assignments.errorFetchingHistory') }}
      </div>
      <div
        v-else
        v-for="(log, i) in historySubmissions"
        :key="i"
        class="relative"
      >
        <div
          class="absolute -left-[21px] top-1 w-3 h-3 bg-blue-500 rounded-full border-2 border-white"
        ></div>
        <div class="text-xs text-slate-500 mb-0.5">
          {{ new Date(log.submitted_at!).toLocaleString('vi-VN') }}
        </div>
        <div class="text-sm font-bold text-slate-800">
          {{
            log.score != null
              ? t('student.assignments.gradeReceived', {
                  score: log.score,
                })
              : t('student.assignments.submissionReceived')
          }}
        </div>
        <div
          class="text-xs text-slate-600 bg-slate-50 p-2 rounded mt-1 border border-slate-100"
        >
          <a
            v-if="log.content == null"
            :href="`${apiBase}/submissions/${log.id}/file-url`"
            class="text-blue-600 underline font-bold"
          >
            {{ t('student.assignments.downloadSubmittedFile') }}
          </a>
          <span v-else>
            {{ log.content || t('student.assignments.noContentAvailable') }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SubmissionHistory } from '@/types/assignment';
import { useI18n } from 'vue-i18n';

interface Props {
  historySubmissions: SubmissionHistory[];
  pendingHistory: boolean;
  errorHistory: any;
}

defineProps<Props>();

const { t } = useI18n();
const config = useRuntimeConfig();
const apiBase = config.public.apiBase;
</script>
