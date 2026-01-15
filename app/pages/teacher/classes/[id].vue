<template>
  <div class="h-full flex flex-col space-y-4">
    <div v-if="pending" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-2"
        ></div>
        <p class="text-sm text-slate-500">Đang tải chi tiết lớp học...</p>
      </div>
    </div>
    <div
      v-else-if="error"
      class="bg-red-50 border border-red-200 rounded-lg p-4 text-center"
    >
      <p class="text-red-600 text-sm">
        Không thể tải chi tiết lớp học. Vui lòng thử lại.
      </p>
      <button
        @click="navigateTo('/teacher/classes')"
        class="mt-2 px-4 py-2 bg-red-600 text-white text-sm rounded-lg hover:bg-red-700"
      >
        Quay lại
      </button>
    </div>
    <TeacherClassDetail
      v-else-if="classDetail"
      :class-detail="classDetail"
      :initial-tab="initialTab"
      @refresh="refresh()"
    />
  </div>
</template>

<script setup lang="ts">
import TeacherClassDetail from '../../../components/teacher/classes/TeacherClassDetail.vue';

definePageMeta({
  layout: 'teacher',
  middleware: 'auth',
});

const route = useRoute();
const { fetchTeacherClassDetail } = useTeacherClassApi();

const classId = computed(() => route.params.id as string);
const initialTab = computed(() => {
  const tab = route.query.tab as string;
  if (tab === 'students' || tab === 'schedule' || tab === 'settings') {
    return tab;
  }
  return 'students';
});

const {
  data: classDetail,
  pending,
  error,
  refresh,
} = await useAsyncData(`teacher-class-detail-${classId.value}`, async () => {
  try {
    const response = await fetchTeacherClassDetail(Number(classId.value));
    return response.data || null;
  } catch (err) {
    console.error('Error loading class detail:', err);
    throw err;
  }
});
</script>
