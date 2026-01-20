import type { ApiResponseSuccess } from '@/types/common';
import { useTeacherClassApi } from './useTeacherClassApi';


export interface TeacherAssignment {
  id: number;
  title: string;
  description?: string;
  due_date: string;
  class_id: number;
  class_name: string;
  class_code?: string;
  status: 'open' | 'closed';
  submissions_count: number;
  graded_submissions_count: number;
  total_students: number;
  created_at: string;
}

export interface TeacherSubmission {
  id: number;
  student_id: number;
  student_name: string;
  student_code?: string;
  avatar?: string;
  assignment_id: number;
  content?: string;
  file_url?: string;
  file_name?: string;
  submitted_at?: string;
  status: 'submitted' | 'late' | 'graded' | 'missing';
  score?: number;
  teacher_feedback?: string;
}

export interface AssignmentSubmissionsResponse {
  assignment: TeacherAssignment;
  submissions: TeacherSubmission[];
  total_students: number;
}

export interface TeacherAssignmentsResponse {
  assignments: TeacherAssignment[];
  pagination: {
    current_page: number;
    per_page: number;
    total_count: number;
    total_pages: number;
  };
}

export const useTeacherGradingApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  // Fetch assignments for a teacher's class
  const fetchAssignmentsByClass = (
    classId: number,
    params?: {
      page?: number;
      page_size?: number;
      title?: string;
      status?: string;
    }
  ) =>
    apiFetch<ApiResponseSuccess<TeacherAssignmentsResponse>>(
      `${apiBase}/assignments/list-by-class`,
      {
        method: 'GET',
        params: {
          class_id: classId,
          ...params,
        },
      }
    );

  // Fetch all assignments for teacher (across all classes)
  const fetchAllAssignments = async (params?: {
    page?: number;
    page_size?: number;
    title?: string;
    class_id?: number;
  }) => {
    // If class_id is provided, fetch assignments for that specific class
    if (params?.class_id) {
      return fetchAssignmentsByClass(params.class_id, params);
    }

    // Otherwise, fetch all classes for teacher and then fetch assignments for each
    try {
      const { fetchTeacherClasses } = useTeacherClassApi();
      const classesResponse = await fetchTeacherClasses();

      const allAssignments: TeacherAssignment[] = [];

      // Fetch assignments for each class
      for (const cls of classesResponse.data.classes) {
        try {
          const response = await fetchAssignmentsByClass(cls.id, {
            title: params?.title,
          });
          allAssignments.push(...response.data.assignments);
        } catch (err) {
          // Skip classes that fail
          console.error(
            `Failed to fetch assignments for class ${cls.id}:`,
            err
          );
        }
      }

      // Filter by title if provided
      let filtered = allAssignments;
      if (params?.title) {
        const query = params.title.toLowerCase();
        filtered = allAssignments.filter((a) =>
          a.title.toLowerCase().includes(query)
        );
      }

      const page = params?.page || 1;
      const pageSize = params?.page_size || 10;
      const total = filtered.length;
      const totalPages = Math.ceil(total / pageSize);
      const startIndex = (page - 1) * pageSize;
      const endIndex = startIndex + pageSize;
      const paginatedAssignments = filtered.slice(startIndex, endIndex);

      return {
        success: true,
        data: {
          assignments: paginatedAssignments,
          pagination: {
            current_page: page,
            per_page: pageSize,
            total_count: total,
            total_pages: totalPages,
          },
        },
      } as ApiResponseSuccess<TeacherAssignmentsResponse>;
    } catch (err) {
      throw new Error('Unable to fetch assignments');
    }
  };

  // Fetch assignment detail by ID
  const fetchAssignmentDetail = (assignmentId: number) =>
    apiFetch<ApiResponseSuccess<any>>(
      `${apiBase}/assignments/${assignmentId}`,
      {
        method: 'GET',
      }
    );

  // Fetch submissions for a specific assignment
  const fetchSubmissionsByAssignment = (
    assignmentId: number,
    params?: {
      page?: number;
      per_page?: number;
      status?: string;
    }
  ) =>
    apiFetch<ApiResponseSuccess<AssignmentSubmissionsResponse>>(
      `${apiBase}/assignments/${assignmentId}/submissions`,
      {
        method: 'GET',
        params,
      }
    );

  // Fallback: Fetch assignment detail and construct submissions
  const fetchAssignmentWithSubmissions = async (
    assignmentId: number,
    params?: {
      page?: number;
      per_page?: number;
    }
  ) => {
    const assignmentResponse = await apiFetch<ApiResponseSuccess<any>>(
      `${apiBase}/assignments/${assignmentId}`,
      {
        method: 'GET',
      }
    );

    const assignment = assignmentResponse.data;

    // Get class detail to get all students
    const classResponse = await apiFetch<ApiResponseSuccess<any>>(
      `${apiBase}/teacher/classes/${assignment.school_class.id}`,
      {
        method: 'GET',
      }
    );

    const classDetail = classResponse.data;
    const allStudents = classDetail.students_list || [];

    // Map students to submissions
    const submissions: TeacherSubmission[] = allStudents.map((student: any) => {
      // Find submission for this student
      const submission = assignment.submissions?.find(
        (s: any) => s.student_id === student.id
      );

      return {
        id: submission?.id || 0,
        student_id: student.id,
        student_name: student.name,
        student_code: student.student_code,
        avatar:
          student.avatar ||
          `https://ui-avatars.com/api/?name=${encodeURIComponent(
            student.name
          )}&background=random`,
        assignment_id: assignmentId,
        content: submission?.content,
        file_url: submission?.file_url,
        file_name: submission?.file_name,
        submitted_at: submission?.submitted_at,
        status: submission
          ? submission.status === 'graded'
            ? 'graded'
            : submission.status === 'late'
            ? 'late'
            : 'submitted'
          : 'missing',
        score: submission?.score,
        teacher_feedback: submission?.teacher_feedback,
      };
    });

    return {
      success: true,
      data: {
        assignment: {
          id: assignment.id,
          title: assignment.title,
          description: assignment.content,
          due_date: assignment.due_date,
          class_id: assignment.school_class.id,
          class_name: assignment.school_class.name,
          class_code: assignment.school_class.code,
          status:
            new Date(assignment.due_date) > new Date() ? 'open' : 'closed',
          submissions_count: assignment.submissions_count,
          graded_submissions_count: assignment.graded_submissions_count,
          total_students: allStudents.length,
          created_at: assignment.created_at,
        },
        submissions,
        total_students: allStudents.length,
      },
    } as ApiResponseSuccess<AssignmentSubmissionsResponse>;
  };

  // Update submission grade and feedback
  const updateSubmissionGrade = (
    submissionId: number,
    data: {
      score: number;
      teacher_feedback?: string;
    }
  ) =>
    apiFetch<ApiResponseSuccess<TeacherSubmission>>(
      `${apiBase}/submissions/${submissionId}`,
      {
        method: 'PATCH',
        body: {
          submission: {
            score: data.score,
            teacher_feedback: data.teacher_feedback,
            status: 'graded',
          },
        },
      }
    );

  // Format date for display
  const formatDate = (dateString: string): string => {
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      });
    } catch {
      return dateString;
    }
  };

  // Format datetime for display
  const formatDateTime = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Chưa nộp';
    try {
      const date = new Date(dateString);
      return date.toLocaleString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return dateString;
    }
  };

  return {
    fetchAssignmentsByClass,
    fetchAllAssignments,
    fetchAssignmentDetail,
    fetchSubmissionsByAssignment,
    updateSubmissionGrade,
    formatDate,
    formatDateTime,
  };
};
