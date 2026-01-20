import type { ApiResponseSuccess, PaginationInfo } from '@/types/common';

export interface TeacherClass {
  id: number;
  code: string;
  name: string;
  grade: string;
  schedule: string;
  room: string;
  students: number;
  maxStudents: number;
  status: string;
  subject: string;
  cover_image?: string;
  raw_schedule?: Record<string, string> | null;
}

export interface TeacherClassDetail extends TeacherClass {
  description?: string;
  raw_schedule?: Record<string, string> | null;
  students_list: Array<{
    id: number;
    name: string;
    dob: string;
    phone: string;
    parent: string;
    student_code?: string;
    sessions_attended?: number;
    total_sessions?: number;
    avatar?: string;
  }>;
}

export interface TeacherClassesResponse {
  classes: TeacherClass[];
  pagination: PaginationInfo;
}

export const useTeacherClassApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const createClass = (data: {
    name: string;
    subject: string;
    grade_level?: string;
    description?: string;
    monthly_tuition_fee?: number;
    schedule_days?: string[];
    start_time?: string;
    end_time?: string;
  }) =>
    apiFetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes`,
      {
        method: 'POST',
        body: data,
      }
    );

  const fetchTeacherClasses = (params?: {
    page?: number;
    per_page?: number;
    status?: string;
    search?: string;
  }) =>
    apiFetch<ApiResponseSuccess<TeacherClassesResponse>>(
      `${apiBase}/teacher/classes`,
      {
        method: 'GET',
        params,
      }
    );

  const fetchTeacherClassDetail = (classId: number) =>
    apiFetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'GET',
      }
    );

  const fetchPendingRequests = (classId: number) =>
    apiFetch<
      ApiResponseSuccess<{
        enrollments: Array<{
          id: number;
          student_id: number;
          student_name: string;
          student_phone: string;
          created_at: string;
        }>;
        leave_requests: Array<{
          id: number;
          student_id: number;
          student_name: string;
          student_phone: string;
          leave_type: string;
          date: string | null;
          reason: string;
          created_at: string;
        }>;
      }>
    >(`${apiBase}/teacher/classes/${classId}/pending_requests`, {
      method: 'GET',
    });

  const approveEnrollment = (classId: number, enrollmentId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/approve`,
      {
        method: 'POST',
      }
    );

  const rejectEnrollment = (classId: number, enrollmentId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/reject`,
      {
        method: 'POST',
      }
    );

  const approveLeaveRequest = (
    classId: number,
    leaveRequestId: number,
    teacherNote?: string
  ) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/leave_requests/${leaveRequestId}/approve`,
      {
        method: 'POST',
        body: { teacher_note: teacherNote },
      }
    );

  const rejectLeaveRequest = (
    classId: number,
    leaveRequestId: number,
    teacherNote?: string
  ) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/leave_requests/${leaveRequestId}/reject`,
      {
        method: 'POST',
        body: { teacher_note: teacherNote },
      }
    );

  const addStudent = (classId: number, studentId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/students`,
      {
        method: 'POST',
        body: { student_id: studentId },
      }
    );

  const removeStudent = (classId: number, studentId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/students/${studentId}`,
      {
        method: 'DELETE',
      }
    );

  const searchStudents = (classId: number, query: string) =>
    apiFetch<
      ApiResponseSuccess<{
        students: Array<{
          id: number;
          name: string;
          email: string;
          student_code: string;
          phone: string;
        }>;
      }>
    >(`${apiBase}/teacher/classes/${classId}/search_students`, {
      method: 'GET',
      params: { query },
    });

  const fetchClassSchedule = (classId: number) =>
    apiFetch<
      ApiResponseSuccess<{
        fixed_schedule: any;
        upcoming_sessions: Array<{
          id: number;
          date: string;
          date_display: string;
          time_display: string;
          day_of_week: string;
          teacher_note: string;
          status: string;
        }>;
      }>
    >(`${apiBase}/teacher/classes/${classId}/schedule`, {
      method: 'GET',
    });

  const createAttendanceSession = (
    classId: number,
    date: string,
    time?: string,
    teacherNote?: string
  ) =>
    apiFetch<
      ApiResponseSuccess<{
        session: {
          id: number;
          date: string;
          date_display: string;
          time_display: string;
        };
      }>
    >(`${apiBase}/teacher/classes/${classId}/attendance_sessions`, {
      method: 'POST',
      body: { date, time, teacher_note: teacherNote },
    });

  const updateAttendanceSession = (
    classId: number,
    sessionId: number,
    date: string,
    time?: string,
    teacherNote?: string
  ) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/attendance_sessions/${sessionId}`,
      {
        method: 'PATCH',
        body: { date, time, teacher_note: teacherNote },
      }
    );

  const deleteAttendanceSession = (classId: number, sessionId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/attendance_sessions/${sessionId}`,
      {
        method: 'DELETE',
      }
    );

  const updateSchedule = (classId: number, schedule: any) =>
    apiFetch<ApiResponseSuccess<{ message: string; schedule: any }>>(
      `${apiBase}/teacher/classes/${classId}/schedule`,
      {
        method: 'PATCH',
        body: { schedule },
      }
    );

  const updateClass = (
    classId: number,
    data:
      | FormData
      | {
          name?: string;
          subject?: string;
          grade_level?: string;
          description?: string;
          monthly_tuition_fee?: number;
          status?: string;
          cover_image?: string;
        }
  ) => {
    if (data instanceof FormData) {
      return apiFetch<ApiResponseSuccess<TeacherClassDetail>>(
        `${apiBase}/teacher/classes/${classId}`,
        {
          method: 'PATCH',
          body: data,
        }
      );
    }

    return apiFetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'PATCH',
        body: data,
      }
    );
  };

  const deleteClass = (classId: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'DELETE',
      }
    );

  return {
    createClass,
    fetchTeacherClasses,
    fetchTeacherClassDetail,
    fetchPendingRequests,
    approveEnrollment,
    rejectEnrollment,
    approveLeaveRequest,
    rejectLeaveRequest,
    addStudent,
    removeStudent,
    searchStudents,
    fetchClassSchedule,
    createAttendanceSession,
    updateAttendanceSession,
    deleteAttendanceSession,
    updateSchedule,
    updateClass,
    deleteClass,
  };
};
