<template>
  <div class="space-y-6">
    <CommonLoadingSpinner
      v-if="pending"
      :fullScreen="true"
      :text="t('loading.studentProfile')"
    />
    <CommonBaseError v-else-if="error" :error="t('error.studentProfile')" />
    <StudentProfile v-else :student="studentInfo!" />
  </div>
</template>

<script setup lang="ts">
import type { StudentProfile } from '@/types/student';
import { useI18n } from 'vue-i18n';

definePageMeta({
  layout: 'student',
  middleware: 'auth',
});

const { t } = useI18n();

const {
  data: studentInfo,
  pending,
  error,
} = await useAsyncData<StudentProfile>('studentProfile', async () => {
  const response = await useStudentApi().getProfile();
  return response.data;
});
</script>
