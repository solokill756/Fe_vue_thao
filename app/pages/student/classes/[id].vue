<template>
  <div class="space-y-6 min-h-screen bg-primary-light p-6">
    <CommonLoadingSpinner v-if="pending" :text="t('loading.classes')" />
    <CommonBaseError
      v-else-if="error"
      :error="error"
      :title="$t('student.classes.errorTitle')"
      @retry="refetch"
    />
    <StudentClassDetailView
      v-else-if="classData"
      :selected-class="classData"
      @back="handleBack"
      @request-leave="handleRequestLeave(classData!)"
      @submit-assignment="handleSubmitAssignment"
      @view-assignment="handleViewAssignment"
      @download-document="handleDownloadDocument"
    />
    <div v-else class="text-center py-12">
      <p class="text-slate-500 mb-2">{{ t('error.classNotFound') }}</p>
      <p class="text-xs text-slate-400 mb-4">Class ID: {{ route.params.id }}</p>
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
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';
import type { StudentClass } from 'app/types/class';
import { formatScheduleObject } from '../../../utils/scheduleFormatter';
import { getErrorMessage } from '../../../utils/errorHandler';
import StudentClassDetailView from '../../../components/student/classes/StudentClassDetailView.vue';

definePageMeta({
  layout: 'student',
  middleware: 'auth',
});

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const toast = useToast();
const classApi = useClassApi();
const { startLoading, stopLoading } = useLoading();

// Fetch class data from student classes
const {
  data: studentClassesData,
  pending,
  error,
  refresh: refetch,
} = await useAsyncData(`student-class-${route.params.id}`, async () => {
  try {
    const classId = Number(route.params.id);
    const response = await classApi.fetchStudentClassDetail(classId);
    const foundClass = response.data;

    // Transform to StudentClass format
    const transformedClass = {
      id: foundClass.class_id.toString(),
      code: foundClass.class_id.toString(),
      name: foundClass.class_name,
      teacher: foundClass.teacher_name,
      schedule: formatScheduleObject(foundClass.schedule), // Formatted string for display
      rawSchedule: foundClass.schedule, // Raw schedule object for calendar parsing
      room: 'N/A',
      attended: foundClass.sessions_attended || 0,
      totalSessions: foundClass.total_sessions || Object.keys(foundClass.schedule || {}).length * 4, // Use backend calculated value, fallback to old calculation
      status: foundClass.status,
      class_id: foundClass.class_id,
    } as StudentClass;

    console.log('[Class Detail] Transformed class:', foundClass.schedule);
    return transformedClass;
  } catch (error) {
    console.error('[Class Detail] Error fetching class:', error);
    return null;
  }
});

const classData = computed(() => {
  const data = studentClassesData.value;

  return data;
});


const handleBack = () => {
  router.push('/student/classes');
};

const handleRequestLeave = async (cls: StudentClass) => {
  if (cls.status === 'pending') {
    if (
      confirm(t('student.classes.confirmCancelEnroll', { className: cls.name }))
    ) {
      try {
        startLoading(t('student.classes.leaving'));
        await useEnrollClassApi().quitClass(cls.class_id);
        toast.success(t('student.classes.leave.cancelSuccess'));
        router.push('/student/classes');
      } catch (error) {
        toast.error(
          getErrorMessage(error, 'student.classes.', t) ||
            t('student.classes.leave.cancelError')
        );
      } finally {
        stopLoading();
      }
    }
  } else {
   
    toast.info(t('student.classes.leave.requestInfo'));
  }
};

const handleSubmitAssignment = (assignment: any) => {
  router.push(`/student/assignments/${assignment.id}`);
};

const handleViewAssignment = (assignment: any) => {
  router.push(`/student/assignments/${assignment.id}`);
};

const handleDownloadDocument = (document: any) => {
  if (document.url) {
    window.open(document.url, '_blank');
  } else {
    toast.info(t('student.classes.detail.documents.downloadMessage'));
  }
};
</script>
