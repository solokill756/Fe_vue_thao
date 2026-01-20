<template>
  <div class="h-full flex flex-col space-y-4">
    <TeacherGradingList
      :assignments="assignments"
      :pending="pending"
      :error="error"
      :pagination="pagination"
      :classes="classes"
      v-model:search-query="searchQuery"
      v-model:selected-class-id="selectedClassId"
      @refresh="refreshAssignments"
      @page-change="handlePageChange"
      @items-per-page-change="handleItemsPerPageChange"
      @assignmentClick="handleAssignmentClick"
      @create-assignment="showCreateAssignmentModal = true"
      @edit-assignment="handleEditAssignment"
      @delete-assignment="handleDeleteAssignment"
    />
    <CreateAssignmentModal
      :is-open="showCreateAssignmentModal"
      :classes="classes"
      @close="showCreateAssignmentModal = false"
      @created="handleAssignmentCreated"
    />
    <EditAssignmentModal
      :is-open="showEditAssignmentModal"
      :assignment="selectedAssignment"
      :classes="classes"
      @close="showEditAssignmentModal = false"
      @updated="handleAssignmentUpdated"
    />
  </div>
</template>

<script setup lang="ts">
import TeacherGradingList from '../../../components/teacher/grading/TeacherGradingList.vue';
import CreateAssignmentModal from '../../../components/teacher/grading/CreateAssignmentModal.vue';
import EditAssignmentModal from '../../../components/teacher/grading/EditAssignmentModal.vue';
import { useTeacherClassApi } from '../../../composables/useTeacherClassApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';
import { useAssignmentApi } from '../../../composables/useAssignmentApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import { getErrorMessage } from '../../../utils/errorHandler';
import type { TeacherAssignment } from '../../../composables/useTeacherGradingApi';

definePageMeta({
  layout: 'teacher',
  middleware: 'auth',
});

const { t } = useI18n();
const toast = useToast();
const { fetchAllAssignments } = useTeacherGradingApi();
const { fetchTeacherClasses } = useTeacherClassApi();
const { deleteAssignment } = useAssignmentApi();

// State - persist selectedClassId in cookie to maintain selection when navigating
const selectedClassIdCookie = useCookie<number | string>(
  'teacher-grading-selected-class-id',
  {
    default: () => '',
  }
);
const selectedClassId = ref<number | string>(selectedClassIdCookie.value || '');
const searchQuery = ref('');
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalPages = ref(1);
const totalItems = ref(0);
const showCreateAssignmentModal = ref(false);
const showEditAssignmentModal = ref(false);
const selectedAssignment = ref<TeacherAssignment | null>(null);

// Fetch assignments using useAsyncData - exactly like classes/index.vue
const {
  data: assignmentsData,
  pending,
  error,
  refresh: refreshAssignments,
} = await useAsyncData(
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
        class_code: assign.school_class?.code || undefined,
        status: (assign.due_date && new Date(assign.due_date) < new Date()
          ? 'closed'
          : 'open') as 'open' | 'closed',
        submissions_count: assign.submissions_count || 0,
        submitted_submissions_count: assign.submitted_submissions_count || 0,
        graded_submissions_count: assign.graded_submissions_count || 0,
        total_students: assign.school_class?.students_count || 0,
        created_at: assign.created_at,
      }));

      if (response.data.pagination) {
        totalPages.value = response.data.pagination.total_pages || 1;
        totalItems.value = response.data.pagination.total_count || response.data.pagination.total_count || 0;
      } else {
        const total = assignments.length;
        totalPages.value = Math.ceil(total / itemsPerPage.value) || 1;
        totalItems.value = total;
      }

      return assignments;
    } catch (err) {
      console.error('Error loading assignments:', err);
      const errorMsg = getErrorMessage(err, 'teacher.grading', t);
      toast.error(t('teacher.grading.errorLoading'));
      return [];
    }
  },
  {
    server: false, // Only fetch on client to avoid SSR issues with useCookie in getAuthHeader
    watch: [selectedClassId, searchQuery, currentPage, itemsPerPage],
  }
);

const assignments = computed(() => assignmentsData.value || []);
const pagination = computed(() => ({
  currentPage: currentPage.value,
  totalPages: totalPages.value,
  itemsPerPage: itemsPerPage.value,
  totalItems: totalItems.value,
}));

// Fetch classes using useAsyncData
const {
  data: classesData,
  refresh: refreshClasses,
} = await useAsyncData(
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
    server: false, // Only fetch on client to avoid SSR issues with useCookie in getAuthHeader
  }
);

const classes = computed(() => classesData.value || []);


const handlePageChange = (page: number) => {
  currentPage.value = page;
};

const handleItemsPerPageChange = (perPage: number) => {
  itemsPerPage.value = perPage;
  currentPage.value = 1;
};

const handleAssignmentClick = (assignmentId: number) => {
  if (assignmentId && !isNaN(assignmentId)) {
    navigateTo(`/teacher/grading/${assignmentId}`);
  }
};

const handleAssignmentCreated = () => {
  // Refresh assignments list after creating new assignment
  refreshAssignments();
};

const handleEditAssignment = (assignment: TeacherAssignment) => {
  selectedAssignment.value = assignment;
  showEditAssignmentModal.value = true;
};

const handleAssignmentUpdated = () => {
  // Refresh assignments list after updating assignment
  refreshAssignments();
  showEditAssignmentModal.value = false;
  selectedAssignment.value = null;
};

const handleDeleteAssignment = async (assignment: TeacherAssignment) => {
  if (!confirm(t('teacher.grading.deleteConfirm') || `Bạn có chắc chắn muốn xóa bài tập "${assignment.title}"?`)) {
    return;
  }

  try {
    await deleteAssignment(assignment.id);
    toast.success(t('teacher.grading.deleteSuccess') || 'Xóa bài tập thành công!');
    refreshAssignments();
  } catch (error) {
    console.error('Error deleting assignment:', error);
    const errorMsg = getErrorMessage(error, 'teacher.grading', t);
    toast.error(errorMsg || t('teacher.grading.deleteError'));
  }
};

watch(selectedClassId, (newValue) => {
  selectedClassIdCookie.value = newValue;
  currentPage.value = 1;
});

watch(searchQuery, () => {
  currentPage.value = 1;
});
</script>
