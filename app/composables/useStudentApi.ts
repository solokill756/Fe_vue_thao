import type { StudentProfile } from '@/types/student';
import type { ApiResponseSuccess } from 'app/types/common';
export const useStudentApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getProfile = () =>
    $fetch<ApiResponseSuccess<StudentProfile>>(`${apiBase}/students/profile`, {
      method: 'GET',
      headers: getAuthHeader(),
    });

  const updateProfile = (payload: Partial<StudentProfile>) =>
    $fetch<ApiResponseSuccess<StudentProfile>>(`${apiBase}/students/profile`, {
      method: 'PATCH',
      headers: getAuthHeader(),
      body: { student: payload },
    });

  return {
    getProfile,
    updateProfile,
  };
};
