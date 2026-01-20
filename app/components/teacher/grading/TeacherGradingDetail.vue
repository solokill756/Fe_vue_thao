<template>
  <div
    class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
  >
    <!-- Detail Header -->
    <div
      class="p-4 border-b border-slate-200 bg-slate-50 flex justify-between items-center"
    >
      <div class="flex items-center gap-4">
        <button
          @click="navigateTo('/teacher/grading')"
          class="w-8 h-8 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-blue-600 hover:border-blue-300 transition-all"
        >
          <i class="fa-solid fa-arrow-left"></i>
        </button>
        <div>
          <h2 class="font-bold text-slate-800 text-lg">
            {{ assignment.title }}
          </h2>
          <p class="text-xs text-slate-500 font-mono">
            {{ assignment.class_name }}
          </p>
        </div>
      </div>
      <div class="flex gap-2">
        <div
          class="hidden sm:flex bg-white border border-slate-200 rounded-lg p-1"
        >
          <button
            @click="gradingFilter = 'all'"
            :class="[
              'px-3 py-1 rounded text-xs font-bold transition-all',
              gradingFilter === 'all'
                ? 'bg-slate-100 text-slate-800'
                : 'text-slate-500 hover:bg-slate-50',
            ]"
          >
            {{ $t('teacher.grading.all') }} ({{ submissions.length }})
          </button>
          <button
            @click="gradingFilter = 'needs_grading'"
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

    <div v-if="pending" class="flex items-center justify-center py-12">
      <CommonLoadingSpinner
        :full-screen="false"
        :text="$t('loading.submissions')"
      />
    </div>
    <div v-else class="flex-1 flex overflow-hidden">
      <!-- Left: Student List -->
      <div
        class="w-1/3 border-r border-slate-200 overflow-y-auto custom-scroll bg-white"
      >
        <div
          v-for="sub in filteredSubmissions"
          :key="sub.student_id"
          @click="selectStudentForGrading(sub)"
          :class="[
            'p-4 border-b border-slate-100 cursor-pointer transition-colors hover:bg-slate-50 flex items-center justify-between',
            selectedSubmission?.student_id === sub.student_id
              ? 'bg-blue-50 border-l-4 border-l-blue-500'
              : 'border-l-4 border-l-transparent',
          ]"
        >
          <div class="flex items-center gap-3">
            <div class="relative">
              <img
                :src="getStudentAvatar(sub)"
                :alt="sub.student_name"
                class="w-8 h-8 rounded-full bg-slate-200 object-cover"
              />
              <div
                v-if="sub.status === 'late'"
                class="absolute -top-1 -right-1 w-2.5 h-2.5 bg-orange-500 rounded-full border-2 border-white"
                :title="$t('teacher.grading.lateSubmission')"
              ></div>
            </div>
            <div>
              <div class="text-sm font-bold text-slate-800">
                {{ sub.student_name }}
              </div>
              <div class="text-xs text-slate-500">
                {{
                  sub.submitted_at
                    ? formatDateTime(sub.submitted_at)
                    : $t('teacher.grading.notSubmitted')
                }}
              </div>
            </div>
          </div>
          <div
            v-if="sub.score !== null && sub.score !== undefined"
            class="w-8 h-8 rounded-lg bg-green-100 text-green-700 font-bold flex items-center justify-center text-sm border border-green-200"
          >
            {{ sub.score }}
          </div>
          <div
            v-else-if="sub.status === 'missing'"
            class="text-xs text-red-500 font-bold uppercase"
          >
            {{ $t('teacher.grading.notSubmitted') }}
          </div>
          <div v-else class="w-2 h-2 rounded-full bg-blue-500"></div>
        </div>
      </div>

      <!-- Right: Grading Area -->
      <div class="w-2/3 bg-slate-50/50 flex flex-col overflow-hidden">
        <div v-if="selectedSubmission" class="flex-1 flex flex-col h-full">
          <!-- File Preview -->
          <div class="flex-1 p-6 overflow-y-auto custom-scroll">
            <div
              v-if="selectedSubmission.status !== 'missing'"
              class="bg-white border border-slate-200 rounded-xl shadow-sm h-full flex flex-col items-center justify-center p-8 text-center"
            >
              <div
                class="w-16 h-16 bg-red-50 text-red-500 rounded-xl flex items-center justify-center text-3xl mb-4"
              >
                <i
                  :class="
                    selectedSubmission.file_name?.endsWith('.pdf')
                      ? 'fa-regular fa-file-pdf'
                      : selectedSubmission.file_name?.endsWith('.jpg') ||
                        selectedSubmission.file_name?.endsWith('.png')
                      ? 'fa-regular fa-file-image'
                      : 'fa-regular fa-file'
                  "
                ></i>
              </div>
              <h3 class="font-bold text-slate-800 text-lg">
                {{
                  selectedSubmission.file_name ||
                  $t('teacher.grading.textSubmission')
                }}
              </h3>
              <p class="text-slate-500 text-sm mb-6">
                {{
                  selectedSubmission.submitted_at
                    ? $t('teacher.grading.submittedAt', {
                        time: formatDateTime(selectedSubmission.submitted_at),
                      })
                    : ''
                }}
              </p>
              <div
                v-if="selectedSubmission.content"
                class="w-full max-w-2xl bg-slate-50 rounded-lg p-4 text-left mb-4"
              >
                <p class="text-sm text-slate-700 whitespace-pre-wrap">
                  {{ selectedSubmission.content }}
                </p>
              </div>
              <a
                v-if="selectedSubmission.content == null"
                :href="`${apiBase}/submissions/${selectedSubmission.id}/file-url`"
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

          <!-- Grading Controls -->
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
                  v-model.number="selectedSubmission.score"
                  type="number"
                  min="0"
                  max="10"
                  step="0.5"
                  :disabled="selectedSubmission.status === 'missing'"
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
                    @click="generateAIFeedback"
                    class="text-xs font-bold text-purple-600 hover:text-purple-800 flex items-center gap-1 transition-colors"
                    :title="$t('teacher.grading.aiFeedbackHint')"
                  >
                    <i class="fa-solid fa-wand-magic-sparkles"></i>
                    {{ $t('teacher.grading.aiSuggestion') }}
                  </button>
                </div>
                <textarea
                  v-model="selectedSubmission.teacher_feedback"
                  rows="2"
                  :disabled="selectedSubmission.status === 'missing'"
                  class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none resize-none transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  :placeholder="$t('teacher.grading.feedbackPlaceholder')"
                ></textarea>
              </div>
            </div>
            <div class="flex justify-between mt-4 items-center">
              <button
                @click="navigateToPrevious"
                class="text-slate-400 hover:text-slate-600 text-sm font-bold"
              >
                <i class="fa-solid fa-chevron-left"></i>
                {{ $t('teacher.grading.previousStudent') }}
              </button>
              <button
                @click="saveGrade"
                :disabled="savingGrade"
                class="px-8 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg shadow-md transition-transform active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <i
                  v-if="savingGrade"
                  class="fa-solid fa-spinner fa-spin mr-2"
                ></i>
                {{ $t('teacher.grading.saveAndContinue') }}
              </button>
              <button
                @click="navigateToNext"
                class="text-slate-600 hover:text-blue-600 text-sm font-bold"
              >
                {{ $t('teacher.grading.nextStudent') }}
                <i class="fa-solid fa-chevron-right"></i>
              </button>
            </div>
          </div>
        </div>
        <div
          v-else
          class="flex-1 flex items-center justify-center text-slate-400"
        >
          <div class="text-center">
            <i class="fa-solid fa-arrow-left text-2xl mb-2"></i>
            <p>{{ $t('teacher.grading.selectStudent') }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import type {
  TeacherAssignment,
  TeacherSubmission,
} from '../../../composables/useTeacherGradingApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';

const { updateSubmissionGrade, formatDateTime } = useTeacherGradingApi();
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import { getErrorMessage } from '../../../utils/errorHandler';

const props = defineProps<{
  assignment: TeacherAssignment;
  submissions: TeacherSubmission[];
  pending: boolean;
}>();

const emit = defineEmits<{
  refresh: [];
}>();

const { t } = useI18n();
const toast = useToast();

const selectedSubmission = ref<TeacherSubmission | null>(null);
const gradingFilter = ref<'all' | 'needs_grading'>('all');
const savingGrade = ref(false);

const config = useRuntimeConfig();
const apiBase = config.public.apiBase;

const filteredSubmissions = computed(() => {
  if (gradingFilter.value === 'needs_grading') {
    return props.submissions.filter(
      (s) =>
        s.status !== 'missing' && (s.score === null || s.score === undefined)
    );
  }
  return props.submissions;
});

const needsGradingCount = computed(() => {
  return props.submissions.filter(
    (s) => s.status !== 'missing' && (s.score === null || s.score === undefined)
  ).length;
});

const selectStudentForGrading = (sub: TeacherSubmission) => {
  selectedSubmission.value = { ...sub };
};

const saveGrade = async () => {
  if (
    !selectedSubmission.value ||
    selectedSubmission.value.status === 'missing'
  ) {
    return;
  }

  if (
    selectedSubmission.value.score === null ||
    selectedSubmission.value.score === undefined
  ) {
    toast.warning(t('teacher.grading.enterScore'));
    return;
  }

  if (!selectedSubmission.value.id || selectedSubmission.value.id === 0) {
    toast.error(t('teacher.grading.cannotGradeMissing'));
    return;
  }

  savingGrade.value = true;
  try {
    await updateSubmissionGrade(selectedSubmission.value.id, {
      score: selectedSubmission.value.score,
      teacher_feedback: selectedSubmission.value.teacher_feedback || '',
    });

    toast.success(t('teacher.grading.saveSuccess'));
    emit('refresh');
    navigateToNext();
  } catch (err) {
    toast.error(getErrorMessage(err, 'teacher.grading', t));
  } finally {
    savingGrade.value = false;
  }
};

const navigateToNext = () => {
  if (!selectedSubmission.value) return;
  const currentIndex = filteredSubmissions.value.findIndex(
    (s) => s.student_id === selectedSubmission.value!.student_id
  );
  if (currentIndex < filteredSubmissions.value.length - 1) {
    const nextSubmission = filteredSubmissions.value[currentIndex + 1];
    if (nextSubmission) {
      selectStudentForGrading(nextSubmission);
    }
  }
};

const navigateToPrevious = () => {
  if (!selectedSubmission.value) return;
  const currentIndex = filteredSubmissions.value.findIndex(
    (s) => s.student_id === selectedSubmission.value!.student_id
  );
  if (currentIndex > 0) {
    const prevSubmission = filteredSubmissions.value[currentIndex - 1];
    if (prevSubmission) {
      selectStudentForGrading(prevSubmission);
    }
  }
};

const generateAIFeedback = () => {
  if (
    !selectedSubmission.value ||
    selectedSubmission.value.score === null ||
    selectedSubmission.value.score === undefined
  ) {
    toast.warning(t('teacher.grading.enterScoreFirst'));
    return;
  }

  const score = selectedSubmission.value.score;
  let feedback = '';

  if (score >= 9) {
    feedback = t('teacher.grading.aiFeedback.excellent');
  } else if (score >= 7) {
    feedback = t('teacher.grading.aiFeedback.good');
  } else if (score >= 5) {
    feedback = t('teacher.grading.aiFeedback.average');
  } else {
    feedback = t('teacher.grading.aiFeedback.poor');
  }

  if (selectedSubmission.value) {
    selectedSubmission.value.teacher_feedback = feedback;
  }
};

const getStudentAvatar = (sub: TeacherSubmission): string => {
  if (sub.avatar) return sub.avatar;
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(
    sub.student_name
  )}&background=random`;
};


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
