import type { ApiResponseSuccess } from '@/types/common';
import type { AttendanceSessionsResponse } from '@/types/attendance';


export interface AttendanceRecord {
  id: number;
  student_id: number;
  status: 'present' | 'absent_w_reason' | 'absent_no_reason' | 'late';
  note?: string | null;
  score_in_class?: number | null;
  student?: {
    id: number;
    name: string;
    student_code?: string;
    avatar?: string;
  };
}

export interface AttendanceSessionData {
  id: number;
  class_id: number;
  date: string;
  teacher_note?: string | null;
  attendance_records?: AttendanceRecord[];
}

export const useAttendanceApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getAttendanceSessionsByClass = (
    classId: number,
    params?: { page?: number; per_page?: number }
  ) =>
    apiFetch<ApiResponseSuccess<AttendanceSessionsResponse>>(
      `${apiBase}/classes/${classId}/attendance_sessions`,
      {
        method: 'GET',
        params,
      }
    );

  const getAttendanceRecords = (classId: number, sessionId: number) =>
    apiFetch<ApiResponseSuccess<AttendanceRecord[]>>(
      `${apiBase}/classes/${classId}/attendance_sessions/${sessionId}/attendance_records`,
      {
        method: 'GET',
      }
    );

  const createAttendanceRecord = (
    classId: number,
    sessionId: number,
    data: {
      student_id: number;
      status: 'present' | 'absent_w_reason' | 'absent_no_reason' | 'late';
      note?: string;
      score_in_class?: number;
    }
  ) =>
    apiFetch<ApiResponseSuccess<AttendanceRecord>>(
      `${apiBase}/classes/${classId}/attendance_sessions/${sessionId}/attendance_records`,
      {
        method: 'POST',
        body: { attendance_record: data },
      }
    );

  const updateAttendanceRecord = (
    classId: number,
    sessionId: number,
    recordId: number,
    data: {
      status?: 'present' | 'absent_w_reason' | 'absent_no_reason' | 'late';
      note?: string;
      score_in_class?: number;
    }
  ) =>
    apiFetch<ApiResponseSuccess<AttendanceRecord>>(
      `${apiBase}/classes/${classId}/attendance_sessions/${sessionId}/attendance_records/${recordId}`,
      {
        method: 'PATCH',
        body: { attendance_record: data },
      }
    );

  return {
    getAttendanceSessionsByClass,
    getAttendanceRecords,
    createAttendanceRecord,
    updateAttendanceRecord,
  };
};
