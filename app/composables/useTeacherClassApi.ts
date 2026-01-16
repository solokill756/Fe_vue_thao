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
    fee_per_session?: number;
    schedule_days?: string[];
    start_time?: string;
    end_time?: string;
  }) =>
    $fetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: data,
      }
    );

  const fetchTeacherClasses = (params?: {
    page?: number;
    per_page?: number;
    status?: string;
    search?: string;
  }) =>
    $fetch<ApiResponseSuccess<TeacherClassesResponse>>(
      `${apiBase}/teacher/classes`,
      {
        method: 'GET',
        params,
        headers: getAuthHeader(),
      }
    );

  const fetchTeacherClassDetail = (classId: number) =>
    $fetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
      }
    );

  const fetchPendingRequests = (classId: number) =>
    $fetch<
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
      headers: getAuthHeader(),
    });

  const approveEnrollment = (classId: number, enrollmentId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/approve`,
      {
        method: 'POST',
        headers: getAuthHeader(),
      }
    );

  const rejectEnrollment = (classId: number, enrollmentId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/enrollments/${enrollmentId}/reject`,
      {
        method: 'POST',
        headers: getAuthHeader(),
      }
    );

  const approveLeaveRequest = (
    classId: number,
    leaveRequestId: number,
    teacherNote?: string
  ) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/leave_requests/${leaveRequestId}/approve`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: { teacher_note: teacherNote },
      }
    );

  const rejectLeaveRequest = (
    classId: number,
    leaveRequestId: number,
    teacherNote?: string
  ) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/leave_requests/${leaveRequestId}/reject`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: { teacher_note: teacherNote },
      }
    );

  const addStudent = (classId: number, studentId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/students`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: { student_id: studentId },
      }
    );

  const removeStudent = (classId: number, studentId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/students/${studentId}`,
      {
        method: 'DELETE',
        headers: getAuthHeader(),
      }
    );

  const searchStudents = (classId: number, query: string) =>
    $fetch<
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
      headers: getAuthHeader(),
    });

  const fetchClassSchedule = (classId: number) =>
    $fetch<
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
      headers: getAuthHeader(),
    });

  const createAttendanceSession = (
    classId: number,
    date: string,
    teacherNote?: string
  ) =>
    $fetch<
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
      headers: getAuthHeader(),
      body: { date, teacher_note: teacherNote },
    });

  const updateAttendanceSession = (
    classId: number,
    sessionId: number,
    date: string,
    teacherNote?: string
  ) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/attendance_sessions/${sessionId}`,
      {
        method: 'PATCH',
        headers: getAuthHeader(),
        body: { date, teacher_note: teacherNote },
      }
    );

  const deleteAttendanceSession = (classId: number, sessionId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}/attendance_sessions/${sessionId}`,
      {
        method: 'DELETE',
        headers: getAuthHeader(),
      }
    );

  const updateSchedule = (classId: number, schedule: any) =>
    $fetch<ApiResponseSuccess<{ message: string; schedule: any }>>(
      `${apiBase}/teacher/classes/${classId}/schedule`,
      {
        method: 'PATCH',
        headers: getAuthHeader(),
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
          fee_per_session?: number;
          status?: string;
          cover_image?: string;
        }
  ) => {
    const headers = getAuthHeader();

    if (data instanceof FormData) {
      const { 'Content-Type': _, ...restHeaders } = headers;
      return $fetch<ApiResponseSuccess<TeacherClassDetail>>(
        `${apiBase}/teacher/classes/${classId}`,
        {
          method: 'PATCH',
          headers: restHeaders,
          body: data,
        }
      );
    }

    return $fetch<ApiResponseSuccess<TeacherClassDetail>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'PATCH',
        headers: getAuthHeader(),
        body: data,
      }
    );
  };

  const deleteClass = (classId: number) =>
    $fetch<ApiResponseSuccess<{ message: string }>>(
      `${apiBase}/teacher/classes/${classId}`,
      {
        method: 'DELETE',
        headers: getAuthHeader(),
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
