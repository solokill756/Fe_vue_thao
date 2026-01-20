<template>
  <div class="h-full flex flex-col space-y-4">
    <div v-if="pending" class="flex items-center justify-center py-12">
      <CommonLoadingSpinner
        :full-screen="false"
        :text="$t('loading.assignmentDetail')"
      />
    </div>
    <div
      v-else-if="error"
      class="bg-red-50 border border-red-200 rounded-lg p-4 text-center"
    >
      <p class="text-red-600 text-sm">
        {{ $t('teacher.grading.errorLoading') }}
      </p>
      <button
        @click="navigateTo('/teacher/grading')"
        class="mt-2 px-4 py-2 bg-red-600 text-white text-sm rounded-lg hover:bg-red-700"
      >
        {{ $t('teacher.grading.backToList') }}
      </button>
    </div>
    <TeacherGradingDetail
      v-else-if="assignment"
      :assignment="assignment"
      :submissions="submissions"
      :pending="loadingSubmissions"
      @refresh="refresh"
    />
  </div>
</template>

<script setup lang="ts">
import TeacherGradingDetail from '../../../components/teacher/grading/TeacherGradingDetail.vue';
import {
  useTeacherGradingApi,
  type TeacherAssignment,
  type TeacherSubmission,
} from '../../../composables/useTeacherGradingApi';

definePageMeta({
  layout: 'teacher',
  middleware: 'auth',
});

const route = useRoute();
const { fetchAssignmentDetail, fetchSubmissionsByAssignment } =
  useTeacherGradingApi();

const assignmentId = computed(() => {
  const id = route.params.id;
  if (Array.isArray(id)) {
    const numId = Number(id[0]);
    return isNaN(numId) ? null : numId;
  }
  const numId = Number(id);
  return isNaN(numId) ? null : numId;
});

const loadingSubmissions = ref(false);
const submissions = ref<TeacherSubmission[]>([]);

const {
  data: assignmentData,
  pending,
  error,
  refresh,
} = useAsyncData(
  () => `teacher-grading-assignment-${assignmentId.value}`,
  async () => {
    try {
      const id = assignmentId.value;
      if (!id || isNaN(id)) {
        throw new Error('Invalid assignment ID');
      }

      // Fetch assignment detail using dedicated API
      const response = await fetchAssignmentDetail(id);
      const assignment = response.data;

      if (!assignment) {
        throw new Error('Assignment not found');
      }

      // Map API response to TeacherAssignment type
      const mappedAssignment: TeacherAssignment = {
        id: assignment.id,
        title: assignment.title,
        description: assignment.content || assignment.description,
        due_date: assignment.due_date,
        class_id: assignment.school_class?.id || 0,
        class_name: assignment.school_class?.name || '',
        class_code: assignment.school_class?.code,
        status: (assignment.due_date &&
        new Date(assignment.due_date) < new Date()
          ? 'closed'
          : 'open') as 'open' | 'closed',
        submissions_count: assignment.submissions_count || 0,
        graded_submissions_count: assignment.graded_submissions_count || 0,
        total_students: assignment.school_class?.students_count || 0,
        created_at: assignment.created_at,
      };

      return mappedAssignment;
    } catch (err) {
      console.error('Error loading assignment detail:', err);
      throw err;
    }
  },
  {
    server: false, 
    watch: [assignmentId],
  }
);

const assignment = computed(() => assignmentData.value || null);

watch(
  assignment,
  async (newAssignment, oldAssignment) => {
    // Clear submissions when assignment changes or becomes null
    if (!newAssignment || (oldAssignment && newAssignment.id !== oldAssignment.id)) {
      submissions.value = [];
    }
    
    if (newAssignment) {
      loadingSubmissions.value = true;
      try {
        const response = await fetchSubmissionsByAssignment(newAssignment.id);
        submissions.value = response.data.submissions || [];
      } catch (err) {
        console.error('Error loading submissions:', err);
        submissions.value = [];
        // Optionally show error toast here if needed
      } finally {
        loadingSubmissions.value = false;
      }
    } else {
      loadingSubmissions.value = false;
    }
  },
  { immediate: true }
);
</script>
