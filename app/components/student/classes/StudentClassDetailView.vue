<template>
  <div
    class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in"
  >
    <!-- Header -->
    <StudentClassDetailHeader
      :selected-class="selectedClass"
      @back="handleBack"
    />

    <!-- Tabs Navigation -->
    <StudentClassDetailTabs
      :current-tab="detailTab"
      :assignment-count="assignmentCount"
      @update:tab="detailTab = $event"
    />

    <!-- Tab Content -->
    <div class="flex-1 overflow-y-auto p-6 bg-slate-50 custom-scroll">
      <!-- Overview Tab -->
      <StudentClassOverviewTab
        v-if="detailTab === 'overview'"
        :average-grade="averageGrade"
        :grade-change="gradeChange"
        :class-average="classAverage"
      />

      <!-- Assignments Tab -->
      <StudentClassAssignmentsTab
        v-else-if="detailTab === 'assignments'"
        :assignments="assignments?.assignments || []"
        @view-assignment="navigateToAssignment"
      />

      <!-- Attendance Tab -->
      <StudentClassAttendanceTab
        v-else-if="detailTab === 'attendance'"
        :attendance-stats="attendanceStats"
        :attendance-records="attendanceRecords"
        :selected-class="selectedClass"
      />

      <!-- Grades Tab -->
      <StudentClassGradesTab
        v-else-if="detailTab === 'grades'"
        :grades="grades"
      />

      <!-- Documents Tab -->
      <StudentClassDocumentsTab
        v-else-if="detailTab === 'documents'"
        :documents="documents"
        @download-document="$emit('download-document', $event)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import type { StudentClass } from 'app/types/class';
import type { Assignment } from '@/types/assignment';
import type { StudentAttendanceSession } from '@/types/attendance';
import StudentClassDetailHeader from './class-detail/StudentClassDetailHeader.vue';
import StudentClassDetailTabs from './class-detail/StudentClassDetailTabs.vue';
import StudentClassOverviewTab from './class-detail/StudentClassOverviewTab.vue';
import StudentClassAssignmentsTab from './class-detail/StudentClassAssignmentsTab.vue';
import StudentClassAttendanceTab from './class-detail/StudentClassAttendanceTab.vue';
import StudentClassGradesTab from './class-detail/StudentClassGradesTab.vue';
import StudentClassDocumentsTab from './class-detail/StudentClassDocumentsTab.vue';

const { t } = useI18n();
const router = useRouter();

const handleBack = () => {
  // If we're on a detail route, navigate back to list
  if (router.currentRoute.value.path.startsWith('/student/classes/')) {
    router.push('/student/classes');
  }
};

interface Props {
  selectedClass: StudentClass;
  assignmentCount?: number;
}

const props = withDefaults(defineProps<Props>(), {
  assignmentCount: 0,
});

defineEmits<{
  back: [];
  'request-leave': [];
  'submit-assignment': [assignment: any];
  'view-assignment': [assignment: any];
  'download-document': [document: any];
}>();

const detailTab = ref<
  'overview' | 'assignments' | 'attendance' | 'grades' | 'documents'
>('overview');

const { fetchAssignments } = useAssignmentApi();
const { getAttendanceSessionsByClass } = useAttendanceApi();

const {
  data: assignments,
  pending: assignmentsPending,
  error: assignmentsError,
  refresh: refetchAssignments,
} = useAsyncData(
  `student-assignments-${props.selectedClass.class_id}`,
  async () => {
    try {
      const result = await fetchAssignments({
        page_size: 10,
        page: 1,
        class_id: Number(props.selectedClass.class_id),
      });
      return result.data;
    } catch (error) {
      console.error('Error fetching assignments:', error);
      return { assignments: [], pagination: null };
    }
  },
  {
    watch: [() => props.selectedClass.class_id],
  }
);

const averageGrade = computed(() => {
  if (!assignments.value?.assignments) return 0;
  const graded = assignments.value.assignments.filter(
    (a) => a.submission?.score != null
  );
  if (graded.length === 0) return 0;
  return (
    graded.reduce((acc, assignment) => {
      return acc + (assignment.submission?.score || 0);
    }, 0) / graded.length
  );
});

const gradeChange = computed(() => {
  // Simplified: return 0 for now, can be enhanced later
  return 0;
});

const classAverage = computed(() => {
  // Simplified: same as averageGrade for now
  return averageGrade.value;
});

const {
  data: attendanceData,
  pending: attendancePending,
  error: attendanceError,
  refresh: refetchAttendance,
} = useAsyncData(
  `student-attendance-${props.selectedClass.class_id}`,
  async () => {
    try {
      const result = await getAttendanceSessionsByClass(
        Number(props.selectedClass.class_id),
        { per_page: 50, page: 1 }
      );
      return result.data;
    } catch (error) {
      console.error('Error fetching attendance:', error);
      return { sessions: [], pagination: null };
    }
  },
  { watch: [() => props.selectedClass.class_id] }
);

const attendanceSessions = computed<StudentAttendanceSession[]>(() => {
  return attendanceData.value?.sessions || [];
});

const attendanceStats = computed(() => {
  const stats = { present: 0, excused: 0, unexcused: 0 };
  for (const s of attendanceSessions.value) {
    const status = s.student_record?.status;
    if (!status) continue;
    if (status === 'present' || status === 'late') stats.present += 1;
    else if (status === 'absent_w_reason') stats.excused += 1;
    else if (status === 'absent_no_reason') stats.unexcused += 1;
  }
  return stats;
});

interface AttendanceRecord {
  date: string;
  time: string;
  type: 'present' | 'excused' | 'unexcused';
}

const attendanceRecords = computed<AttendanceRecord[]>(() => {
  return attendanceSessions.value
    .filter((s) => !!s.student_record?.status)
    .map((s) => {
      const status = s.student_record!.status;
      const type: 'present' | 'excused' | 'unexcused' =
        status === 'absent_w_reason'
          ? 'excused'
          : status === 'absent_no_reason'
          ? 'unexcused'
          : 'present';
      return {
        date: formatDate(s.date),
        time: props.selectedClass.schedule || '',
        type,
      };
    });
});

const documents = computed(() => {
  if (!assignments.value?.assignments) return [];
  return assignments.value.assignments
    .filter(
      (assignment: Assignment) =>
        assignment.assignment_attachments &&
        assignment.assignment_attachments.length > 0
    )
    .flatMap((assignment: Assignment) => {
      return (assignment.assignment_attachments || []).map((attachment) => {
        return {
          name: attachment.file_name || assignment.title || '',
          size: 'N/A', // File size not available in API response
          date: formatDate(assignment.due_date),
          url: attachment.file_url || '',
        };
      });
    });
});

const grades = computed(() => {
  if (!assignments.value?.assignments) return [];

  return assignments.value.assignments
    .filter((assignment: Assignment) => {
      // Only show graded assignments
      return assignment.submission_status === 'graded' && assignment.submission;
    })
    .map((assignment: Assignment) => {
      return {
        title: assignment.title || '',
        score: assignment.submission?.score || 0,
        date: formatDate(assignment.due_date),
        comment: assignment.submission?.teacher_feedback || '',
      };
    });
});

const formatDate = (dateString: string | null | undefined): string => {
  if (!dateString) return '';
  try {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    }).format(date);
  } catch (error) {
    return dateString;
  }
};

const navigateToAssignment = (assignmentId: number) => {
  router.push(`/student/assignments/${assignmentId}`);
};
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
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
</style>
