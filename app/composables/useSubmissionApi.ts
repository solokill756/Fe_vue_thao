import type {
  SubmissionHistory,
  SubmissionListResponse,
} from '@/types/assignment';
import type { ApiResponseSuccess, PaginationParams } from '@/types/common';


export const useSubmissionApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const fetchSubmissions = (params: {
    per_page?: number;
    page?: number;
    assignment_id?: number;
    class_id?: number;
  }) =>
    apiFetch<ApiResponseSuccess<SubmissionListResponse>>(
      `${apiBase}/submissions/list-by-student`,
      {
        method: 'GET',
        params,
      }
    );

  const createSubmission = (
    payload:
      | FormData
      | {
          assignment_id: number;
          content?: string;
          file_url?: string;
          submitted_at?: string;
        }
  ) => {
    if (payload instanceof FormData) {
      return apiFetch(`${apiBase}/submissions`, {
        method: 'POST',
        body: payload,
      });
    }

    return apiFetch(`${apiBase}/submissions`, {
      method: 'POST',
      body: { submission: payload },
    });
  };

  const updateSubmission = (
    id: number,
    payload: {
      content?: string;
      file_url?: string;
      status?: string;
    }
  ) =>
    apiFetch(`${apiBase}/submissions/${id}`, {
      method: 'PATCH',
      body: { submission: payload },
    });

  const deleteSubmission = (id: number) =>
    apiFetch(`${apiBase}/submissions/${id}`, {
      method: 'DELETE',
    });

  return {
    fetchSubmissions,
    createSubmission,
    updateSubmission,
    deleteSubmission,
  };
};
