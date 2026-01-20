<template>
  <div
    class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
  >
    <!-- Header -->
    <div
      class="p-6 border-b border-slate-200 bg-slate-50 flex justify-between items-start"
    >
      <div class="flex gap-4">
        <button
          @click="$emit('back')"
          class="mt-1 w-8 h-8 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-blue-600 hover:border-blue-300 transition-all"
        >
          <i class="fa-solid fa-arrow-left"></i>
        </button>
        <div>
          <div class="flex items-center gap-3 mb-1">
            <span
              class="text-xs font-bold text-slate-500 uppercase tracking-wide bg-white px-2 py-0.5 rounded border border-slate-200"
            >
              {{ assignment?.school_class.name }} -
              {{ assignment?.school_class.subject }}
            </span>
            <span
              :class="[
                'text-xs font-bold px-2 py-0.5 rounded border',
                getStatusClass(
                  assignment?.submission_status || 'No Submission'
                ),
              ]"
            >
              {{
                mapSubmissionStatusToStatusKey(assignment?.submission_status!)
              }}
            </span>
          </div>
          <h2 class="text-2xl font-bold text-slate-800">
            {{ assignment?.title }}
          </h2>
          <p class="text-sm text-slate-500 mt-1">
            <i class="fa-solid fa-user-tie mr-1"></i>
            {{ t('student.assignments.teacher') }}
            {{ assignment?.teacher_name }} &bull;
            {{ t('student.assignments.dueDate') }}
            {{ formatDate(assignment?.due_date!) }}
          </p>
        </div>
      </div>
      <div
        v-if="assignment?.score"
        class="text-center bg-white p-3 rounded-xl border border-green-200 shadow-sm"
      >
        <div class="text-3xl font-bold text-green-600">
          {{ assignment?.score }}
        </div>
        <div class="text-xs text-slate-500 font-bold uppercase">Điểm số</div>
      </div>
    </div>

    <!-- Content Grid -->
    <div
      class="flex-1 overflow-y-auto custom-scroll p-6 grid lg:grid-cols-2 gap-8"
    >
      <!-- Left: Task Info -->
      <div class="space-y-6">
        <div>
          <h3 class="font-bold text-slate-800 mb-3 border-b pb-2">
            {{ t('student.assignments.taskContent') }}
          </h3>
          <div
            class="text-slate-600 text-sm leading-relaxed bg-slate-50 p-4 rounded-lg border border-slate-100"
          >
            {{ assignment?.content || t('student.assignments.defaultContent') }}
          </div>
        </div>

        <div>
          <h3 class="font-bold text-slate-800 mb-3">
            {{ t('student.assignments.attachedDocuments') }}
          </h3>
          <div
            class="flex items-center gap-3 p-3 border border-slate-200 rounded-lg hover:bg-blue-50 transition-colors cursor-pointer group"
          >
            <div
              class="w-10 h-10 bg-red-100 text-red-500 rounded flex items-center justify-center text-lg"
            >
              <i class="fa-regular fa-file-pdf"></i>
            </div>
            <div class="flex-1">
              <div class="font-bold text-sm group-hover:text-blue-600">
                {{ assignment?.assignment_attachments?.[0]?.file_name }}
              </div>
            </div>
            <a
              :href="getAttachmentDownloadUrl(assignment?.assignment_attachments?.[0])"
              :download="assignment?.assignment_attachments?.[0]?.file_name || 'attachment'"
              class="ml-auto"
            >
              <i
                class="fa-solid fa-download text-slate-400 group-hover:text-blue-600"
                :title="t('student.assignments.downloadFile')"
              ></i>
            </a>
          </div>
        </div>

        <!-- Submission History -->
        <AssignmentHistory
          :history-submissions="historySubmissions"
          :pending-history="pendingHistory"
          :error-history="errorHistory"
        />
      </div>

      <!-- Right: Submission / Feedback -->
      <div class="space-y-6">
        <!-- Feedback Section (Visible if Graded) -->
        <div
          v-if="assignment?.submission_status === 'graded'"
          class="bg-green-50 border border-green-200 rounded-xl p-6"
        >
          <h3 class="font-bold text-green-800 mb-3 flex items-center gap-2">
            <i class="fa-solid fa-comment-dots"></i>
            {{ t('student.assignments.teacherFeedback') }}
          </h3>
          <p
            class="text-sm text-green-900 bg-white p-4 rounded-lg border border-green-100 italic"
          >
            "{{
              historySubmissions?.[0]?.teacher_feedback || t('student.assignments.defaultFeedback')
            }}"
          </p>
        </div>

        <!-- Submission Form -->
        <AssignmentSubmission
          ref="submissionRef"
          :assignment="assignment"
          :uploading="uploading"
          v-model:submission-text="submissionText"
          v-model:selected-file="selectedFile"
          @submit="handleSubmit"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Assignment, SubmissionHistory } from '@/types/assignment';
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AssignmentHistory from './AssignmentHistory.vue';
import AssignmentSubmission from './AssignmentSubmission.vue';

interface SubmissionRef {
  submissionText: string;
  selectedFile: File | undefined;
  submissionTab: 'file' | 'text';
}

interface Props {
  assignment: Assignment | null;
  historySubmissions: SubmissionHistory[];
  pendingHistory: boolean;
  errorHistory: any;
  uploading?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  uploading: false,
});

const emit = defineEmits<{
  back: [];
  submit: [];
}>();

const { t } = useI18n();
const { formatDate, mapSubmissionStatusToStatusKey } = useAssignmentApi();
const config = useRuntimeConfig();
const apiBase = config.public.apiBase;

const submissionText = ref('');
const selectedFile = ref<File | undefined>(undefined);
const submissionRef = ref<SubmissionRef | null>(null);

const getAttachmentDownloadUrl = (attachment: any): string => {
  if (!attachment?.file_url) return '#';
  // If URL is already absolute or starts with /, use it directly
  if (attachment.file_url.startsWith('http') || attachment.file_url.startsWith('/')) {
    return attachment.file_url.startsWith('/') ? `${apiBase}${attachment.file_url}` : attachment.file_url;
  }
  // Otherwise, construct full URL
  return `${apiBase}${attachment.file_url}`;
};

const handleSubmit = () => {
  // Get submission data from child component via ref
  if (submissionRef.value) {
    const data = submissionRef.value as any;
    if (data.submissionText !== undefined) {
      submissionText.value = data.submissionText;
    }
    if (data.selectedFile !== undefined) {
      selectedFile.value = data.selectedFile;
    }
  }
  emit('submit');
};

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

// Expose values for parent component
defineExpose({
  submissionText,
  selectedFile,
  getSubmissionData: () => ({
    submissionText: submissionText.value,
    selectedFile: selectedFile.value,
    submissionTab: submissionRef.value?.submissionTab || 'file',
  }),
});
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

.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}
</style>
