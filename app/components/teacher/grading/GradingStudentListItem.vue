<template>
  <div
    @click="$emit('select', submission)"
    :class="[
      'p-4 border-b border-slate-100 cursor-pointer transition-colors hover:bg-slate-50 flex items-center justify-between',
      isSelected
        ? 'bg-blue-50 border-l-4 border-l-blue-500'
        : 'border-l-4 border-l-transparent',
    ]"
  >
    <div class="flex items-center gap-3">
      <div class="relative">
        <img
          :src="avatar"
          :alt="submission.student_name"
          class="w-8 h-8 rounded-full bg-slate-200 object-cover"
        />
        <div
          v-if="submission.status === 'late'"
          class="absolute -top-1 -right-1 w-2.5 h-2.5 bg-orange-500 rounded-full border-2 border-white"
          :title="$t('teacher.grading.lateSubmission')"
        ></div>
      </div>
      <div>
        <div class="text-sm font-bold text-slate-800">
          {{ submission.student_name }}
        </div>
        <div class="text-xs text-slate-500">
          {{
            submission.submitted_at
              ? formatDateTime(submission.submitted_at)
              : $t('teacher.grading.notSubmitted')
          }}
        </div>
      </div>
    </div>
    <div
      v-if="submission.score !== null && submission.score !== undefined"
      class="w-8 h-8 rounded-lg bg-green-100 text-green-700 font-bold flex items-center justify-center text-sm border border-green-200"
    >
      {{ submission.score }}
    </div>
    <div
      v-else-if="submission.status === 'missing'"
      class="text-xs text-red-500 font-bold uppercase"
    >
      {{ $t('teacher.grading.notSubmitted') }}
    </div>
    <div v-else class="w-2 h-2 rounded-full bg-blue-500"></div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import type { TeacherSubmission } from '../../../composables/useTeacherGradingApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';

const { t } = useI18n();
const { formatDateTime } = useTeacherGradingApi();

const props = defineProps<{
  submission: TeacherSubmission;
  selectedSubmissionId: number | null | undefined;
}>();

const isSelected = computed(
  () => props.submission.student_id === props.selectedSubmissionId
);

const avatar = computed(() => {
  if (props.submission.avatar) return props.submission.avatar;
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(
    props.submission.student_name
  )}&background=random`;
});

defineEmits<{
  select: [submission: TeacherSubmission];
}>();
</script>
