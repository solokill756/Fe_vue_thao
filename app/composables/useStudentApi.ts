import type { StudentProfile } from '@/types/student';
import type { ApiResponseSuccess } from 'app/types/common';


export const useStudentApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getProfile = () =>
    apiFetch<ApiResponseSuccess<StudentProfile>>(`${apiBase}/students/profile`, {
      method: 'GET',
    });

  const updateProfile = (payload: Partial<StudentProfile>) =>
    apiFetch<ApiResponseSuccess<StudentProfile>>(`${apiBase}/students/profile`, {
      method: 'PATCH',
      body: { student: payload },
    });

  return {
    getProfile,
    updateProfile,
  };
};
