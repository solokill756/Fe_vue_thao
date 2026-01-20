<template>
  <div class="h-full flex flex-col space-y-4">
    <!-- Assignment List View -->
    <div v-if="!selectedAssignment" class="h-full flex flex-col gap-4">
      <GradingToolbar
        :classes="classes"
        v-model:search-query="searchQuery"
        v-model:selected-class-id="selectedClassId"
        @create-assignment="showCreateAssignmentModal = true"
      />

      <!-- Assignments Grid -->
      <div v-if="pending" class="flex items-center justify-center h-full">
        <CommonLoadingSpinner
          :full-screen="false"
          :text="$t('loading.assignments')"
        />
      </div>
      <div
        v-else-if="error"
        class="flex flex-col items-center justify-center h-full text-slate-400"
      >
        <i class="fa-solid fa-exclamation-triangle text-4xl mb-2"></i>
        <p>{{ $t('teacher.grading.errorLoading') }}</p>
        <button
          @click="handleRefreshAssignments"
          class="mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg"
        >
          {{ $t('teacher.grading.retry') }}
        </button>
      </div>
      <div
        v-else-if="filteredAssignments.length === 0"
        class="flex flex-col items-center justify-center h-full text-slate-400"
      >
        <i class="fa-solid fa-clipboard-list text-4xl mb-2"></i>
        <p>{{ $t('teacher.grading.noAssignments') }}</p>
      </div>
      <div v-else class="flex flex-col gap-4">
        <div
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 overflow-y-auto custom-scroll pr-1 pb-2"
        >
          <GradingAssignmentCard
            v-for="assign in filteredAssignments"
            :key="assign.id"
            :assignment="assign"
            @click="openAssignmentDetail"
          />
        </div>

        <!-- Pagination -->
        <CommonPagination
          v-if="pagination.totalPages > 1 && pagination.totalItems > 0"
          :current-page="pagination.currentPage"
          :total-pages="pagination.totalPages"
          :items-per-page="pagination.itemsPerPage"
          :total-items="pagination.totalItems"
          @update:currentPage="handlePageChange"
          @update:itemsPerPage="handleItemsPerPageChange"
        />
      </div>
    </div>

    <!-- Assignment Detail View -->
    <div
      v-if="selectedAssignment"
      class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
    >
      <GradingDetailHeader
        :assignment="currentAssignment"
        v-model:grading-filter="gradingFilter"
        :total-submissions="submissions.length"
        :needs-grading-count="needsGradingCount"
        @back="closeAssignmentDetail"
      />

      <div v-if="pendingSubmissions" class="flex-1 flex items-center justify-center">
        <CommonLoadingSpinner
          :full-screen="false"
          :text="$t('loading.submissions')"
        />
      </div>
      <div
        v-else-if="submissionsError"
        class="flex-1 flex flex-col items-center justify-center text-slate-400 p-8"
      >
        <i class="fa-solid fa-exclamation-triangle text-4xl mb-2 text-red-500"></i>
        <p>{{ $t('teacher.grading.errorLoading') }}</p>
        <button
          @click="() => refreshSubmissions()"
          class="mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700"
        >
          {{ $t('teacher.grading.retry') }}
        </button>
      </div>
      <div v-else class="flex-1 flex overflow-hidden">
        <!-- Left: Student List -->
        <div
          class="w-1/3 border-r border-slate-200 overflow-y-auto custom-scroll bg-white"
        >
          <GradingStudentListItem
            v-for="sub in filteredSubmissions"
            :key="sub.student_id"
            :submission="sub"
            :selected-submission-id="selectedSubmission?.student_id ?? undefined"
            @select="selectStudentForGrading"
          />
        </div>

        <!-- Right: Grading Area -->
        <div class="w-2/3 bg-slate-50/50 flex flex-col overflow-hidden">
          <div v-if="selectedSubmission" class="flex-1 flex flex-col h-full">
            <GradingSubmissionPreview :submission="selectedSubmission" />

            <GradingControls
              :submission="selectedSubmission"
              :saving="savingGrade"
              @update:score="handleScoreUpdate"
              @update:feedback="selectedSubmission.teacher_feedback = $event"
              @generate-ai-feedback="generateAIFeedback"
              @save="saveGrade"
              @previous="navigateToPrevious"
              @next="navigateToNext"
            />
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import {
  useTeacherGradingApi,
  type TeacherAssignment,
  type TeacherSubmission,
} from '../../composables/useTeacherGradingApi';
import { useTeacherClassApi } from '../../composables/useTeacherClassApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import { getErrorMessage } from '../../utils/errorHandler';
import GradingToolbar from './grading/GradingToolbar.vue';
import GradingAssignmentCard from './grading/GradingAssignmentCard.vue';
import GradingDetailHeader from './grading/GradingDetailHeader.vue';
import GradingStudentListItem from './grading/GradingStudentListItem.vue';
import GradingSubmissionPreview from './grading/GradingSubmissionPreview.vue';
import GradingControls from './grading/GradingControls.vue';

const { t } = useI18n();
const toast = useToast();
const {
  fetchAllAssignments,
  fetchSubmissionsByAssignment,
  updateSubmissionGrade,
} = useTeacherGradingApi();
const { fetchTeacherClasses } = useTeacherClassApi();

// State
const selectedAssignment = ref<TeacherAssignment | null>(null);
const selectedSubmission = ref<TeacherSubmission | null>(null);
const gradingFilter = ref<'all' | 'needs_grading'>('all');
const searchQuery = ref('');
const selectedClassId = ref<number | string>('');
const savingGrade = ref(false);
const showCreateAssignmentModal = ref(false);
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalPages = ref(1);
const totalItems = ref(0);

const pagination = computed(() => ({
  currentPage: currentPage.value,
  totalPages: totalPages.value,
  itemsPerPage: itemsPerPage.value,
  totalItems: totalItems.value,
}));

// Fetch assignments using useAsyncData
const {
  data: assignmentsData,
  pending,
  error,
  refresh: refreshAssignments,
} = useAsyncData(
  'teacher-grading-assignments',
  async () => {
    try {
      const classIdValue =
        selectedClassId.value === ''
          ? undefined
          : Number(selectedClassId.value);
      const response = await fetchAllAssignments({
        class_id: classIdValue,
        page: currentPage.value,
        page_size: itemsPerPage.value,
        title: searchQuery.value || undefined,
      });

      const assignments = response.data.assignments.map((assign: any) => ({
        id: assign.id,
        title: assign.title,
        description: assign.content,
        due_date: assign.due_date,
        class_id: assign.school_class?.id || 0,
        class_name: assign.school_class?.name || '',
        class_code: assign.school_class?.code,
        status: (assign.due_date && new Date(assign.due_date) < new Date()
          ? 'closed'
          : 'open') as 'open' | 'closed',
        submissions_count: assign.submissions_count || assign.submitted_submissions_count || 0,
        graded_submissions_count: assign.graded_submissions_count || 0,
        total_students:
          assign.school_class?.students_count ||
          assign.school_class?.students_list?.length ||
          0,
        created_at: assign.created_at,
      }));

      // Update pagination info
      if (response.data.pagination) {
        currentPage.value = response.data.pagination.current_page || 1;
        totalPages.value = response.data.pagination.total_pages || 1;
        itemsPerPage.value = response.data.pagination.per_page || 10;
        totalItems.value = response.data.pagination.total_count || 0;
      } else {
        // Fallback: calculate pagination from assignments length
        const total = assignments.length;
        currentPage.value = 1;
        totalPages.value = Math.ceil(total / itemsPerPage.value) || 1;
        totalItems.value = total;
      }

      return assignments;
    } catch (err) {
      const errorMsg = getErrorMessage(err, 'teacher.grading', t);
      toast.error(t('teacher.grading.errorLoading'));
      throw err;
    }
  },
  {
    lazy: true,
    watch: [selectedClassId, searchQuery, currentPage, itemsPerPage],
  }
);

const assignments = computed(() => assignmentsData.value || []);
const filteredAssignments = computed(() => {
  return assignments.value;
});

const filteredSubmissions = computed(() => {
  if (gradingFilter.value === 'needs_grading') {
    return submissions.value.filter(
      (s) =>
        s.status !== 'missing' && (s.score === null || s.score === undefined)
    );
  }
  return submissions.value;
});

const needsGradingCount = computed(() => {
  return submissions.value.filter(
    (s) => s.status !== 'missing' && (s.score === null || s.score === undefined)
  ).length;
});

// Computed for selected assignment to help TypeScript
const currentAssignment = computed(() => selectedAssignment.value);

// Fetch classes using useAsyncData
const {
  data: classesData,
  refresh: refreshClasses,
} = useAsyncData(
  'teacher-grading-classes',
  async () => {
    try {
      const response = await fetchTeacherClasses();
      return response.data.classes.map((cls: any) => ({
        id: cls.id,
        name: cls.name,
      }));
    } catch (err) {
      console.error('Error loading classes:', err);
      return [];
    }
  },
  {
    lazy: true,
  }
);

const classes = computed(() => classesData.value || []);

// Fetch submissions using useAsyncData
const {
  data: submissionsData,
  pending: pendingSubmissions,
  error: submissionsError,
  refresh: refreshSubmissions,
} = useAsyncData(
  () => `teacher-grading-submissions-${selectedAssignment.value?.id || 'none'}`,
  async () => {
    if (!selectedAssignment.value) {
      return [];
    }
    try {
      const response = await fetchSubmissionsByAssignment(selectedAssignment.value.id);
      return response.data.submissions;
    } catch (err) {
      toast.error(getErrorMessage(err, 'teacher.grading', t));
      throw err;
    }
  },
  {
    lazy: true,
    watch: [selectedAssignment],
    default: () => [],
  }
);

const submissions = computed(() => submissionsData.value || []);

// Methods
const handleRefreshAssignments = () => {
  refreshAssignments();
};

const openAssignmentDetail = (assign: TeacherAssignment) => {
  selectedAssignment.value = assign;
  selectedSubmission.value = null;
  // useAsyncData will automatically fetch submissions when selectedAssignment changes
};

const closeAssignmentDetail = () => {
  selectedAssignment.value = null;
  selectedSubmission.value = null;
  // submissions will automatically be empty when selectedAssignment is null
};

const selectStudentForGrading = (sub: TeacherSubmission) => {
  selectedSubmission.value = { ...sub };
};

const handleScoreUpdate = (score: number | null | undefined) => {
  if (selectedSubmission.value) {
    selectedSubmission.value.score = score ?? undefined;
  }
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

    // Refresh submissions to get updated data from server
    await refreshSubmissions();

    // Update selected submission from refreshed data
    const updatedSubmission = submissions.value.find(
      (s) => s.student_id === selectedSubmission.value!.student_id
    );
    if (updatedSubmission) {
      selectedSubmission.value = { ...updatedSubmission };
    }

    // Update assignment stats
    if (selectedAssignment.value) {
      const gradedCount = submissions.value.filter(
        (s) => s.score !== null && s.score !== undefined
      ).length;
      selectedAssignment.value.graded_submissions_count = gradedCount;
    }

    toast.success(t('teacher.grading.saveSuccess'));

    // Auto navigate to next
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

// Pagination handlers
const handlePageChange = (page: number) => {
  currentPage.value = page;
  // useAsyncData will automatically refresh when currentPage changes
};

const handleItemsPerPageChange = (perPage: number) => {
  itemsPerPage.value = perPage;
  currentPage.value = 1; // Reset to first page
  // useAsyncData will automatically refresh when itemsPerPage changes
};

// Watchers - reset pagination when filters change
watch(selectedClassId, () => {
  currentPage.value = 1;
  // useAsyncData will automatically refresh when selectedClassId changes
});

watch(searchQuery, () => {
  currentPage.value = 1; // Reset to first page when search changes
  // useAsyncData will automatically refresh when searchQuery changes
});

// Lifecycle
onMounted(() => {
  // Trigger initial load of classes and assignments
  refreshClasses();
  refreshAssignments();
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
