import type { ApiResponseSuccess } from 'app/types/common';

export const useEnrollClassApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const registerClass = (classId: number) =>
    apiFetch<ApiResponseSuccess<string>>(`${apiBase}/classes/${classId}/enroll`, {
      method: 'POST',
    });
  const quitClass = (classId: number) =>
    apiFetch<ApiResponseSuccess<string>>(`${apiBase}/classes/${classId}/quit`, {
      method: 'DELETE',
    });

  const leaveRequestClass = (
    classId: number,
    reason: string,
    leaveType: string,
    date?: string
  ) =>
    apiFetch<ApiResponseSuccess<string>>(
      `${apiBase}/classes/${classId}/leave_requests`,
      {
        method: 'POST',
        body: {
          leave_request: {
            date: date || null,
            reason,
            leave_type: leaveType,
          },
        },
      }
    );

  return {
    registerClass,
    quitClass,
    leaveRequestClass,
  };
};
