<template>
  <div class="space-y-6">
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
        :assignments="assignments?.assignments || []"
        :filters="{
          page,
          pageSize,
          title,
          subject,
          submission_status,
        }"
        :history-submissions="[]"
        :pending-history="false"
        :error-history="null"
        @update:filters="updateFilters"
        @update:viewMode="handleViewModeChange"
      />

      <!-- Pagination -->
      <CommonPagination
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
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';

definePageMeta({
  layout: 'student',
  middleware: 'auth',
});

const { fetchAssignments } = useAssignmentApi();
const { t } = useI18n();
const router = useRouter();

const page = ref(1);
const pageSize = ref(10);
const title = ref('');
const subject = ref<string | null>(null);
const submission_status = ref<string | null>(null);
let searchTimeout: ReturnType<typeof setTimeout> | null = null;

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

const handleViewModeChange = (assignmentId: number | null) => {
  if (assignmentId) {
    router.push(`/student/assignments/${assignmentId}`);
  }
};
</script>
