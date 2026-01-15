<template>
  <div class="min-h-screen bg-primary-light p-6">
    <!-- Loading State -->
    <CommonLoadingSpinner v-if="pending" :text="t('loading.assignments')" />

    <!-- Error State -->
    <CommonBaseError
      v-else-if="error"
      :error="t('error.fetchAssignments')"
      @retry="refetch"
    />

    <!-- Content -->
    <AssignmentDetail
      v-else-if="assignment"
      ref="detailRef"
      :assignment="assignment"
      :history-submissions="historySubmissions?.submissions || []"
      :pending-history="pendingHistory"
      :error-history="errorHistory"
      :uploading="uploading"
      @back="handleBack"
      @submit="submitAssignment"
    />
    <div v-else class="text-center py-12">
      <p class="text-slate-500">{{ t('error.assignmentNotFound') }}</p>
      <button
        @click="handleBack"
        class="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        {{ t('common.back') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';

import AssignmentDetail from '../../../components/student/assignments/AssignmentDetail.vue';

definePageMeta({
  layout: 'student',
  middleware: 'auth',
});

const { fetchAssignmentDetail } = useAssignmentApi();
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const toast = useToast();

interface AssignmentDetailRef {
  getSubmissionData: () => {
    submissionText: string;
    selectedFile: File | undefined;
    submissionTab: 'file' | 'text';
  };
}

const detailRef = ref<AssignmentDetailRef | null>(null);
const uploading = ref(false);

const {
  data: assignmentData,
  pending,
  error,
  refresh: refetch,
} = await useAsyncData(`assignment-${route.params.id}`, async () => {
  try {
    const result = await fetchAssignmentDetail(Number(route.params.id));
    return result.data || null;
  } catch (error: any) {
    console.error('Error fetching assignment:', error);
    // If 404, return null to show not found message
    if (error?.status === 404 || error?.statusCode === 404) {
      return null;
    }
    // For other errors, throw to trigger error state
    throw error;
  }
});

const assignment = computed(() => {
  return assignmentData.value ?? null;
});

const { fetchSubmissions, createSubmission } = useSubmissionApi();
const {
  data: historySubmissions,
  pending: pendingHistory,
  error: errorHistory,
  refresh: refetchHistory,
} = await useAsyncData(`assignment-history-${route.params.id}`, async () => {
  if (!route.params.id) return { submissions: [], pagination: null };
  const result = await fetchSubmissions({
    per_page: 5,
    page: 1,
    assignment_id: Number(route.params.id),
  });
  return result.data;
});

const handleBack = () => {
  router.push('/student/assignments');
};

const submitAssignment = async () => {
  if (!assignment.value) return;

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
      String(assignment.value?.id || 0)
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
    await refetchHistory();
    toast.success(t('student.assignments.submissionSuccess'));

    // Refresh assignment data to update submission status
    await refetch();
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
