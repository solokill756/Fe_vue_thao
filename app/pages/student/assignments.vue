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
    <div v-else class="space-y-6">
      <student-assignments-manager
        :assignments="assignments?.assignments!"
        :refetch="refetch"
        :filters="{
          page,
          pageSize,
          title,
          subject,
          submission_status,
        }"
        @update:filters="updateFilters"
        @update:viewMode="selectedAssignmentId = $event"
        :history-submissions="historySubmissions?.submissions || []"
        :pending-history="pendingHistory"
        :error-history="errorHistory"
        @refetch-history="refetchHistory"
      />

      <!-- Pagination (Only show in list view) -->
      <CommonPagination
        v-if="!selectedAssignmentId"
        :current-page="assignments?.pagination.current_page || 1"
        :total-pages="assignments?.pagination.total_pages || 1"
        :items-per-page="pageSize"
        :total-items="assignments?.pagination.total_count || 0"
        @update:currentPage="page = $event"
        @update:itemsPerPage="pageSize = $event"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
definePageMeta({
  layout: 'student',
  middleware: 'auth',
});
const { fetchAssignments } = useAssignmentApi();
const { t } = useI18n();
const page = ref(1);
const pageSize = ref(10);
const title = ref('');
const subject = ref<string | null>(null);
const submission_status = ref<string | null>(null);
const selectedAssignmentId = ref<number | null>(null);
let searchTimeout: ReturnType<typeof setTimeout> | null = null;
const { fetchSubmissions } = useSubmissionApi();
const {
  data: assignments,
  pending,
  error,
  refresh: refetch,
} = useAsyncData(
  'student-assignments',
  async () => {
    const result = await fetchAssignments({
      page: page.value,
      page_size: pageSize.value,
      title: title.value,
      subject: subject.value,
      submission_status: submission_status.value || undefined,
    });
    return result.data;
  },
  {
    watch: [page, pageSize, subject, submission_status],
  }
);

const {
  data: historySubmissions,
  pending: pendingHistory,
  error: errorHistory,
  refresh: refetchHistory,
} = useAsyncData(
  'student-history-submissions',
  async () => {
    console.log(
      'Fetching history submissions for assignment',
      selectedAssignmentId.value
    );
    const result = await fetchSubmissions({
      per_page: 5,
      page: 1,
      assignment_id: selectedAssignmentId.value || undefined,
    });
    return result.data;
  },
  {
    watch: [selectedAssignmentId],
  }
);

// Debounce search to avoid excessive API calls
watch(title, (newTitle) => {
  if (searchTimeout) clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    page.value = 1;
    refetch();
  }, 500);
});

const updateFilters = (newFilters: {
  title?: string;
  subject?: string | null;
  submission_status?: string | null;
}) => {
  if (newFilters.title !== undefined) title.value = newFilters.title;
  if (newFilters.subject !== undefined) subject.value = newFilters.subject;
  if (newFilters.submission_status !== undefined)
    submission_status.value = newFilters.submission_status;
  page.value = 1;
};
</script>
