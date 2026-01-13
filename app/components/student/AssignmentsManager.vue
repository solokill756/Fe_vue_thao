<template>
  <div class="h-full flex flex-col gap-6 animate-fade-in">
    <!-- LIST VIEW -->
    <div v-if="viewMode === 'list'" class="h-full flex flex-col">
      <!-- Header & Filters -->
      <div
        class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6"
      >
        <div
          class="flex flex-col md:flex-row justify-between md:items-center gap-4 mb-4"
        >
          <div>
            <h2 class="text-2xl font-bold text-slate-800">{{ t('student.assignments.myAssignments') }}</h2>
            <p class="text-sm text-slate-500">{{ t('student.assignments.manageDeadlinesAndScores') }}</p>
          </div>
          <div class="flex gap-2">
            <!-- Class Filter -->
            <select
              v-model="filterSubject"
              @change="updateFilters"
              class="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 font-bold text-slate-600"
            >
              <option value="all">{{ t('student.assignments.allSubjects') }}</option>
              <option
                v-for="subject in uniqueSubjects"
                :key="subject"
                :value="subject"
              >
                {{ subject }}
              </option>
            </select>

            <!-- Search -->
            <div class="relative">
              <input
                v-model="searchTerm"
                @input="onSearchChange"
                type="text"
                :placeholder="t('student.assignments.searchPlaceholder')"
                class="pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 text-sm w-48"
              />
              <i
                class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
              ></i>
            </div>
          </div>
        </div>

        <!-- Status Tabs -->
        <div class="flex gap-2 overflow-x-auto pb-2 md:pb-0">
          <button
            @click="
              filterStatus = 'all';
              updateFilters();
            "
            :class="[
              'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
              filterStatus === 'all'
                ? 'bg-blue-600 text-white shadow-md'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200',
            ]"
          >
            {{ t('student.assignments.allStatus') }}
          </button>
          <button
            @click="
              filterStatus = 'no_submission';
              updateFilters();
            "
            :class="[
              'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
              filterStatus === 'no_submission'
                ? 'bg-yellow-500 text-white shadow-md'
                : 'bg-white border border-slate-200 text-slate-600 hover:bg-yellow-50 hover:text-yellow-600',
            ]"
          >
            {{ t('student.assignments.noSubmission') }}
          </button>
          <button
            @click="
              filterStatus = 'submitted';
              updateFilters();
            "
            :class="[
              'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
              filterStatus === 'submitted'
                ? 'bg-blue-500 text-white shadow-md'
                : 'bg-white border border-slate-200 text-slate-600 hover:bg-blue-50 hover:text-blue-600',
            ]"
          >
            {{ t('student.assignments.submitted') }}
          </button>
          <button
            @click="
              filterStatus = 'graded';
              updateFilters();
            "
            :class="[
              'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
              filterStatus === 'graded'
                ? 'bg-green-600 text-white shadow-md'
                : 'bg-white border border-slate-200 text-slate-600 hover:bg-green-50 hover:text-green-600',
            ]"
          >
            {{ t('student.assignments.graded') }}
          </button>
        </div>
      </div>

      <!-- Grid -->
      <div class="flex-1 overflow-y-auto custom-scroll pr-1">
        <div
          v-if="assignments.length > 0"
          class="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          <div
            v-for="(task, idx) in assignments"
            :key="idx"
            @click="openDetail(task)"
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
                  <span class="text-slate-500">{{ t('student.assignments.dueDate') }}</span>
                  <span
                    :class="[
                      'font-bold',
                      isUrgent(task.due_date)
                        ? 'text-red-600'
                        : 'text-slate-700',
                    ]"
                  >
                    {{ formatDate(task.due_date) }}
                  </span>
                </div>
                <div class="flex justify-between items-center text-sm">
                  <span class="text-slate-500">{{ t('student.assignments.status') }}</span>
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
                  <span class="text-slate-500">{{ t('student.assignments.score') }}</span>
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
          <p class="font-medium">{{ t('student.assignments.noAssignmentsFound') }}</p>
        </div>
      </div>
    </div>

    <!-- DETAIL VIEW -->
    <div
      v-else
      class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
    >
      <!-- Header -->
      <div
        class="p-6 border-b border-slate-200 bg-slate-50 flex justify-between items-start"
      >
        <div class="flex gap-4">
          <button
            @click="goBack"
            class="mt-1 w-8 h-8 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-blue-600 hover:border-blue-300 transition-all"
          >
            <i class="fa-solid fa-arrow-left"></i>
          </button>
          <div>
            <div class="flex items-center gap-3 mb-1">
              <span
                class="text-xs font-bold text-slate-500 uppercase tracking-wide bg-white px-2 py-0.5 rounded border border-slate-200"
              >
                {{ selectedAssignment?.school_class.name }} -
                {{ selectedAssignment?.school_class.subject }}
              </span>
              <span
                :class="[
                  'text-xs font-bold px-2 py-0.5 rounded border',
                  getStatusClass(
                    selectedAssignment?.submission_status || 'No Submission'
                  ),
                ]"
              >
                {{
                  mapSubmissionStatusToStatusKey(
                    selectedAssignment?.submission_status!
                  )
                }}
              </span>
            </div>
            <h2 class="text-2xl font-bold text-slate-800">
              {{ selectedAssignment?.title }}
            </h2>
            <p class="text-sm text-slate-500 mt-1">
              <i class="fa-solid fa-user-tie mr-1"></i> {{ t('student.assignments.teacher') }}
              {{ selectedAssignment?.teacher_name }} &bull; {{ t('student.assignments.dueDate') }}
              {{ formatDate(selectedAssignment?.due_date!) }}
            </p>
          </div>
        </div>
        <div
          v-if="selectedAssignment?.score"
          class="text-center bg-white p-3 rounded-xl border border-green-200 shadow-sm"
        >
          <div class="text-3xl font-bold text-green-600">
            {{ selectedAssignment?.score }}
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
              {{
                selectedAssignment?.content ||
                t('student.assignments.defaultContent')
              }}
            </div>
          </div>

          <div>
            <h3 class="font-bold text-slate-800 mb-3">{{ t('student.assignments.attachedDocuments') }}</h3>
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
                  {{
                    selectedAssignment?.assignment_attachments?.[0]?.file_name
                  }}
                </div>
                <!-- <div class="text-xs text-slate-500">2.4 MB</div> -->
              </div>
              <a
                :href="
                  selectedAssignment?.assignment_attachments?.[0]?.file_url
                "
                target="_blank"
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
          <div v-if="historySubmissions && historySubmissions.length > 0">
            <h3 class="font-bold text-slate-800 mb-3 pt-4 border-t">
              {{ t('student.assignments.activityHistory') }}
            </h3>
            <div class="space-y-4 border-l-2 border-slate-200 ml-2 pl-4 py-2">
              <LoadingSpinner
                v-if="pendingHistory"
                :text="t('student.assignments.loadingHistory')"
              />
              <div
                v-else-if="errorHistory"
                class="text-red-600 text-sm font-bold"
              >
                {{ t('student.assignments.errorFetchingHistory') }}
              </div>
              <div
                v-else
                v-for="(log, i) in historySubmissions!"
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
                      ? t('student.assignments.gradeReceived', { score: log.score })
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
        </div>

        <!-- Right: Submission / Feedback -->
        <div class="space-y-6">
          <!-- Feedback Section (Visible if Graded) -->
          <div
            v-if="selectedAssignment?.submission_status === 'graded'"
            class="bg-green-50 border border-green-200 rounded-xl p-6"
          >
            <h3 class="font-bold text-green-800 mb-3 flex items-center gap-2">
              <i class="fa-solid fa-comment-dots"></i> {{ t('student.assignments.teacherFeedback') }}
            </h3>
            <p
              class="text-sm text-green-900 bg-white p-4 rounded-lg border border-green-100 italic"
            >
              "{{
                selectedAssignment?.feedback ||
                'Bài làm tốt, trình bày rõ ràng. Tuy nhiên cần chú ý câu 3b.'
              }}"
            </p>
          </div>

          <!-- Submission Form (Visible if Pending or Resubmit allowed) -->
          <div
            v-if="selectedAssignment?.submission_status !== 'graded'"
            class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden"
          >
            <div
              class="bg-slate-50 p-4 border-b border-slate-200 flex justify-between items-center"
            >
              <h3 class="font-bold text-slate-800">{{ t('student.assignments.submissionArea') }}</h3>
              <span
                v-if="selectedAssignment?.submission_status === 'submitted'"
                class="text-xs font-bold text-blue-600 bg-blue-100 px-2 py-1 rounded"
              >
                {{ t('student.assignments.alreadySubmitted') }}
              </span>
            </div>

            <div class="p-6">
              <!-- Tabs -->
              <div class="flex gap-4 mb-4 border-b border-slate-100 pb-1">
                <button
                  @click="submissionTab = 'file'"
                  :class="[
                    'text-sm font-bold pb-2 border-b-2 transition-colors',
                    submissionTab === 'file'
                      ? 'border-blue-600 text-blue-600'
                      : 'border-transparent text-slate-500',
                  ]"
                >
                  <i class="fa-solid fa-upload mr-1"></i> {{ t('student.assignments.fileUploadTab') }}
                </button>
                <button
                  @click="submissionTab = 'text'"
                  :class="[
                    'text-sm font-bold pb-2 border-b-2 transition-colors',
                    submissionTab === 'text'
                      ? 'border-blue-600 text-blue-600'
                      : 'border-transparent text-slate-500',
                  ]"
                >
                  <i class="fa-solid fa-pen mr-1"></i> {{ t('student.assignments.textInputTab') }}
                </button>
              </div>

              <!-- File Upload -->
              <div v-if="submissionTab === 'file'" class="space-y-4">
                <div
                  @dragover="handleDragOver"
                  @drop="handleDrop"
                  @click="fileInput?.click()"
                  class="border-2 border-dashed border-slate-300 rounded-xl p-8 text-center bg-slate-50 hover:bg-blue-50 hover:border-blue-300 transition-colors cursor-pointer group"
                >
                  <i
                    class="fa-solid fa-cloud-arrow-up text-4xl text-slate-400 group-hover:text-blue-500 mb-3 transition-colors"
                  ></i>
                  <p class="text-sm font-bold text-slate-600">
                    {{ t('student.assignments.dragDropFile') }}
                    <span class="text-blue-600 underline">{{ t('student.assignments.selectFile') }}</span>
                  </p>
                  <p class="text-xs text-slate-400 mt-2">
                    {{ t('student.assignments.supportedFormats') }}
                  </p>
                  <input
                    ref="fileInput"
                    type="file"
                    hidden
                    @change="handleFileSelect"
                    accept=".pdf,.docx,.jpg,.jpeg,.png,.txt"
                  />
                </div>

                <!-- Selected File Display -->
                <div
                  v-if="selectedFile"
                  class="flex items-center gap-3 p-3 bg-blue-50 border border-blue-200 rounded-lg"
                >
                  <i class="fa-solid fa-file text-blue-600 text-lg"></i>
                  <div class="flex-1">
                    <div class="text-sm font-bold text-blue-900">
                      {{ selectedFile.name }}
                    </div>
                    <div class="text-xs text-blue-700">
                      {{ formatFileSize(selectedFile.size) }}
                    </div>
                  </div>
                  <button
                    @click="selectedFile = undefined"
                    class="text-blue-600 hover:text-blue-800 transition"
                    :title="t('common.delete')"
                  >
                    <i class="fa-solid fa-trash"></i>
                  </button>
                </div>
              </div>

              <!-- Text Entry -->
              <div v-else>
                <textarea
                  v-model="submissionText"
                  rows="6"
                  class="w-full p-3 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 resize-none"
                  :placeholder="t('student.assignments.textSubmissionPlaceholder')"
                ></textarea>
              </div>

              <!-- Action Button -->
              <button
                @click="submitAssignment"
                :disabled="uploading"
                class="w-full mt-4 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-bold rounded-lg shadow-md transition-all flex items-center justify-center gap-2"
              >
                <i v-if="uploading" class="fa-solid fa-spinner fa-spin"></i>
                <span v-else>
                  {{
                    selectedAssignment?.submission_status === 'submitted'
                      ? t('student.assignments.submitButtonResubmit')
                      : t('student.assignments.submitButtonDefault')
                  }}
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Assignment, SubmissionHistory } from '@/types/assignment';
import { ref, computed } from 'vue';
import { useToast } from 'vue-toastification';
import LoadingSpinner from '../common/LoadingSpinner.vue';
interface assignmentFilter {
  page: number;
  pageSize: number;
  title: string;
  subject: string | null;
  submission_status: string | null;
}
const props = defineProps<{
  assignments: Assignment[];
  filters?: assignmentFilter;
  historySubmissions: SubmissionHistory[];
  pendingHistory: boolean;
  errorHistory: any;
}>();

const emit = defineEmits<{
  'update:filters': [filters: Partial<assignmentFilter>];
  'update:viewMode': [selectAssignmentId: number | null];
  'refetch-history': [];
}>();

const { createSubmission } = useSubmissionApi();
const viewMode = ref<'list' | 'detail'>('list');
const filterStatus = ref(props.filters?.submission_status || 'all');
const filterSubject = ref(props.filters?.subject || 'all');
const searchTerm = ref(props.filters?.title || '');
const selectedAssignment = ref<Assignment | null>(null);
const submissionTab = ref<'file' | 'text'>('file');
const uploading = ref(false);
const submissionText = ref('');
const fileInput = ref<HTMLInputElement>();
const selectedFile = ref<File | undefined>(undefined);
const toast = useToast();
const { t } = useI18n();
const config = useRuntimeConfig();
const apiBase = config.public.apiBase;

const { formatDate, isUrgent, mapSubmissionStatusToStatusKey } =
  useAssignmentApi();

const uniqueSubjects = computed(() => {
  return [...new Set(props.assignments.map((a) => a.school_class.subject))];
});

const openDetail = (task: Assignment) => {
  selectedAssignment.value = task;
  viewMode.value = 'detail';
  submissionText.value = '';
  emit('update:viewMode', selectedAssignment.value?.id || null);
};

const goBack = () => {
  viewMode.value = 'list';
  selectedAssignment.value = null;
  submissionText.value = '';
  selectedFile.value = undefined;
  emit('update:viewMode', null);
};

const onSearchChange = () => {
  emit('update:filters', { title: searchTerm.value });
};

const updateFilters = () => {
  const filters: Partial<assignmentFilter> = {};
  if (filterStatus.value !== 'all') {
    filters.submission_status = filterStatus.value;
  } else {
    filters.submission_status = null;
  }
  if (filterSubject.value !== 'all') {
    filters.subject = filterSubject.value;
  } else {
    filters.subject = null;
  }
  emit('update:filters', filters);
};
const submitAssignment = async () => {
  // Validate
  if (submissionTab.value === 'file' && !selectedFile.value) {
    toast.error(t('student.assignments.selectFileError'));
    return;
  }

  if (submissionTab.value === 'text' && !submissionText.value.trim()) {
    toast.error(t('student.assignments.enterContentError'));
    return;
  }

  uploading.value = true;
  try {
    const formData = new FormData();
    formData.append(
      'submission[assignment_id]',
      String(selectedAssignment.value?.id || 0)
    );
    formData.append('submission[submitted_at]', new Date().toISOString());

    if (submissionTab.value === 'file' && selectedFile.value) {
      formData.append('submission[file]', selectedFile.value);
    } else if (submissionTab.value === 'text') {
      formData.append('submission[content]', submissionText.value);
    }

    await createSubmission(formData);
    emit('refetch-history');
    selectedFile.value = undefined;
    toast.success(t('student.assignments.submissionSuccess'));

    if (selectedAssignment.value) {
      selectedAssignment.value.submission_status = 'submitted';
      selectedAssignment.value.status = 'Đã nộp';
    }

    // goBack();
  } catch (err) {
    toast.error(
      getErrorMessage(err, 'student.assignments.', t) ||
        t('student.assignments.submissionError')
    );
  } finally {
    uploading.value = false;
  }
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

// File upload handlers
const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files?.length) {
    selectedFile.value = target.files[0];
  }
};

const handleDragOver = (e: DragEvent) => {
  e.preventDefault();
  e.stopPropagation();
};

const handleDrop = (e: DragEvent) => {
  e.preventDefault();
  e.stopPropagation();
  if (e.dataTransfer?.files?.length) {
    selectedFile.value = e.dataTransfer.files[0];
  }
};

const formatFileSize = (bytes: number) => {
  const kb = bytes / 1024;
  return kb > 1024 ? `${(kb / 1024).toFixed(2)} MB` : `${kb.toFixed(2)} KB`;
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

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
