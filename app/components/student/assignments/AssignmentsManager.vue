<template>
  <div class="h-full flex flex-col gap-6 animate-fade-in">
    <!-- LIST VIEW -->
    <div v-if="viewMode === 'list'" class="h-full flex flex-col">
      <AssignmentFilters
        :unique-subjects="uniqueSubjects"
        :initial-status="filterStatus"
        :initial-subject="filterSubject"
        :initial-search="searchTerm"
        @update:status="handleStatusChange"
        @update:subject="handleSubjectChange"
        @update:search="handleSearchChange"
      />

      <AssignmentList
        :assignments="assignments"
        @select-assignment="openDetail"
      />
    </div>

    <!-- DETAIL VIEW -->
    <AssignmentDetail
      v-else-if="selectedAssignment"
      ref="detailRef"
      :assignment="selectedAssignment"
      :history-submissions="historySubmissions"
      :pending-history="pendingHistory"
      :error-history="errorHistory"
      :uploading="uploading"
      @back="goBack"
      @submit="submitAssignment"
    />
  </div>
</template>

<script setup lang="ts">
import type { Assignment, SubmissionHistory } from '@/types/assignment';
import { ref, computed } from 'vue';
import { useToast } from 'vue-toastification';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import AssignmentFilters from './AssignmentFilters.vue';
import AssignmentList from './AssignmentList.vue';
import AssignmentDetail from './AssignmentDetail.vue';

interface AssignmentDetailRef {
  getSubmissionData: () => {
    submissionText: string;
    selectedFile: File | undefined;
    submissionTab: 'file' | 'text';
  };
}

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
  selectedAssignmentId?: number | null;
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
const uploading = ref(false);
const submissionText = ref('');
const selectedFile = ref<File | undefined>(undefined);
const detailRef = ref<AssignmentDetailRef | null>(null);
const toast = useToast();
const { t } = useI18n();
const router = useRouter();

const uniqueSubjects = computed(() => {
  return [...new Set(props.assignments.map((a) => a.school_class.subject))];
});

const openDetail = (task: Assignment) => {
  selectedAssignment.value = task;
  viewMode.value = 'detail';
  submissionText.value = '';
  selectedFile.value = undefined;
  emit('update:viewMode', selectedAssignment.value?.id || null);
};

const goBack = () => {
  if (router.currentRoute.value.path.startsWith('/student/assignments/')) {
    router.push('/student/assignments');
  }
  viewMode.value = 'list';
  selectedAssignment.value = null;
  submissionText.value = '';
  selectedFile.value = undefined;
  emit('update:viewMode', null);
};

const handleSearchChange = (search: string) => {
  searchTerm.value = search;
  emit('update:filters', { title: search });
};

const handleStatusChange = (status: string) => {
  filterStatus.value = status;
  const filters: Partial<assignmentFilter> = {};
  if (status !== 'all') {
    filters.submission_status = status;
  } else {
    filters.submission_status = null;
  }
  emit('update:filters', filters);
};

const handleSubjectChange = (subject: string) => {
  filterSubject.value = subject;
  const filters: Partial<assignmentFilter> = {};
  if (subject !== 'all') {
    filters.subject = subject;
  } else {
    filters.subject = null;
  }
  emit('update:filters', filters);
};

const submitAssignment = async () => {
  if (!selectedAssignment.value) return;

  // Get submission data from AssignmentDetail component
  const submissionData = detailRef.value?.getSubmissionData();
  if (!submissionData) {
    toast.error(t('student.assignments.selectFileError'));
    return;
  }

  // Validate
  if (submissionData.submissionTab === 'file' && !submissionData.selectedFile) {
    toast.error(t('student.assignments.selectFileError'));
    return;
  }

  if (
    submissionData.submissionTab === 'text' &&
    !submissionData.submissionText.trim()
  ) {
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

    if (
      submissionData.submissionTab === 'file' &&
      submissionData.selectedFile
    ) {
      formData.append('submission[file]', submissionData.selectedFile);
    } else if (
      submissionData.submissionTab === 'text' &&
      submissionData.submissionText.trim()
    ) {
      formData.append('submission[content]', submissionData.submissionText);
    }

    await createSubmission(formData);
    emit('refetch-history');
    toast.success(t('student.assignments.submissionSuccess'));

    if (selectedAssignment.value) {
      selectedAssignment.value.submission_status = 'submitted';
    }
  } catch (err) {
    toast.error(
      getErrorMessage(err, 'student.assignments.', t) ||
        t('student.assignments.submissionError')
    );
  } finally {
    uploading.value = false;
  }
};
</script>

<style scoped>
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
