import type { ApiResponseSuccess } from '@/types/common';
import type { AttendanceSessionsResponse } from '@/types/attendance';

export const useAttendanceApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getAttendanceSessionsByClass = (
    classId: number,
    params?: { page?: number; per_page?: number }
  ) =>
    $fetch<ApiResponseSuccess<AttendanceSessionsResponse>>(
      `${apiBase}/classes/${classId}/attendance_sessions`,
      {
        method: 'GET',
        headers: getAuthHeader(),
        params,
      }
    );

  return { getAttendanceSessionsByClass };
};
