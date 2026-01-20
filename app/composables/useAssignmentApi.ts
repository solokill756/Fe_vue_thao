import type { Assignment, AssignmentListResponse } from '@/types/assignment';
import type { ApiResponseSuccess } from '@/types/common';
import { ref, computed } from 'vue';


export const useAssignmentApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;
  const fetchAssignments = (params?: {
    page?: number;
    page_size?: number;
    subject?: string | null;
    title?: string;
    submission_status?: string;
    class_id?: number;
  }) => {
    return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/list-by-student`,
      {
        method: 'GET',
        params,
      }
    );
  };

  const fetchAssignmentsByClass = (
    classId: number,
    params?: {
      page?: number;
      page_size?: number;
      subject?: string | null;
      title?: string;
      submission_status?: string;
    }
  ) => {
    return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/list-by-class?class_id=${classId}`,
      {
        method: 'GET',
        params,
      }
    );
  };
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

  const isUrgent = (dueDate: string): boolean => {
    try {
      const due = new Date(dueDate);
      const now = new Date();
      const diff = due.getTime() - now.getTime();
      const daysUntilDue = Math.ceil(diff / (1000 * 60 * 60 * 24));
      return daysUntilDue <= 3 && daysUntilDue > 0;
    } catch {
      return false;
    }
  };

  const mapSubmissionStatusToStatusKey = (
    status: string
  ): 'Pending' | 'Submitted' | 'Graded' | 'Late' | 'No Submission' => {
    const statusMap: Record<
      string,
      'Pending' | 'Submitted' | 'Graded' | 'Late' | 'No Submission'
    > = {
      no_submission: 'No Submission',
      submitted: 'Submitted',
      late: 'Late',
      graded: 'Graded',
      resubmit_requested: 'Pending',
    };
    return statusMap[status] || 'Pending';
  };

  const fetchAssignmentDetail = (id: number) =>
    apiFetch<ApiResponseSuccess<Assignment>>(`${apiBase}/assignments/${id}`, {
      method: 'GET',
    });

  const createAssignment = (
    payload:
      | FormData
      | {
          title: string;
          content?: string;
          due_date?: string;
          class_id: number;
        }
  ) => {
    if (payload instanceof FormData) {
      return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
        `${apiBase}/assignments`,
        {
          method: 'POST',
          body: payload,
        }
      );
    }
    
    return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments`,
      {
        method: 'POST',
        body: { assignment: payload },
      }
    );
  };
  const updateAssignment = (
    id: number,
    payload:
      | FormData
      | {
          title?: string;
          content?: string;
          due_date?: string;
          subject?: string;
        }
  ) => {
    if (payload instanceof FormData) {
      return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
        `${apiBase}/assignments/${id}`,
        {
          method: 'PATCH',
          body: payload,
        }
      );
    }
    
    return apiFetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/${id}`,
      {
        method: 'PATCH',
        body: { assignment: payload },
      }
    );
  };
  const deleteAssignment = (id: number) =>
    apiFetch(`${apiBase}/assignments/${id}`, {
      method: 'DELETE',
    });

  return {
    mapSubmissionStatusToStatusKey,
    formatDate,
    isUrgent,
    fetchAssignments,
    fetchAssignmentsByClass,
    fetchAssignmentDetail,
    createAssignment,
    updateAssignment,
    deleteAssignment,
  };
};
