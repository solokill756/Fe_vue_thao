<template>
  <div class="space-y-6 min-h-screen bg-primary-light p-6">
    <CommonLoadingSpinner v-if="pending" :text="t('loading.classes')" />
    <CommonBaseError
      v-else-if="error"
      :error="t('error.fetchClass')"
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
const { fetchAssignmentDetail } = useAssignmentApi();

// Fetch class data from student classes
const {
  data: studentClassesData,
  pending,
  error,
  refresh: refetch,
} = await useAsyncData(`student-class-${route.params.id}`, async () => {
  try {
    const result = await fetchAssignmentDetail(Number(route.params.id));
    // Transform to StudentClass format
    const transformedClass = {
      id: result.data.school_class.id.toString(),
      code: result.data.school_class.id.toString(),
      name: result.data.school_class.name,
      teacher: result.data.teacher_name,
      schedule: formatScheduleObject(result.data.school_class.schedule),
      room: 'N/A',
      attended: 0,
      totalSessions:
        Object.keys(result.data.school_class.schedule || {}).length * 4,
      status: result.data.school_class.status,
      class_id: result.data.school_class.id,
    } as StudentClass;

    console.log('[Class Detail] Transformed class:', transformedClass);
    return transformedClass;
  } catch (error) {
    console.error('[Class Detail] Error fetching class:', error);
    return null;
  }
});

const classData = computed(() => {
  const data = studentClassesData.value;
  console.log('[Class Detail] classData computed:', data);
  return data;
});

// Debug: Log component state
console.log('[Class Detail] Component mounted');
console.log('[Class Detail] pending:', pending);
console.log('[Class Detail] error:', error);
console.log('[Class Detail] classData:', classData);

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
        toast.error(t('student.classes.leave.cancelError'));
      } finally {
        stopLoading();
      }
    }
  } else {
    // Show leave request modal - we'll need to handle this differently
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
