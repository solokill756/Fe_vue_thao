import type { AssignmentListResponse } from '@/types/assignment';
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
  }) => {
    return $fetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/list-by-student`,
      {
        method: 'GET',
        headers: getAuthHeader(),
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
    $fetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/${id}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
      }
    );

  const fetchAssignmentsByClass = (
    classId: number,
    params?: {
      page?: number;
      page_size?: number;
      title?: string;
    }
  ) =>
    $fetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/list-by-class/${classId}`,
      {
        method: 'GET',
        headers: getAuthHeader(),
        params,
      }
    );
  const createAssignment = (payload: {
    title: string;
    description?: string;
    due_date?: string;
    subject?: string;
  }) =>
    $fetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: { assignment: payload },
      }
    );
  const updateAssignment = (
    id: number,
    payload: {
      title?: string;
      description?: string;
      due_date?: string;
      subject?: string;
    }
  ) =>
    $fetch<ApiResponseSuccess<AssignmentListResponse>>(
      `${apiBase}/assignments/${id}`,
      {
        method: 'PATCH',
        headers: getAuthHeader(),
        body: { assignment: payload },
      }
    );
  const deleteAssignment = (id: number) =>
    $fetch(`${apiBase}/assignments/${id}`, {
      method: 'DELETE',
      headers: getAuthHeader(),
    });

  return {
    mapSubmissionStatusToStatusKey,
    formatDate,
    isUrgent,
    fetchAssignments,
    fetchAssignmentDetail,
    fetchAssignmentsByClass,
    createAssignment,
    updateAssignment,
    deleteAssignment,
  };
};
