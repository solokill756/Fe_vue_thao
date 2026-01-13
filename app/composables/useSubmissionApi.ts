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
  }) =>
    $fetch<ApiResponseSuccess<SubmissionListResponse>>(
      `${apiBase}/submissions/list-by-student`,
      {
        method: 'GET',
        headers: getAuthHeader(),
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
    const headers = getAuthHeader();

    if (payload instanceof FormData) {
      return $fetch(`${apiBase}/submissions`, {
        method: 'POST',
        headers,
        body: payload,
      });
    }

    return $fetch(`${apiBase}/submissions`, {
      method: 'POST',
      headers,
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
    $fetch(`${apiBase}/submissions/${id}`, {
      method: 'PATCH',
      headers: getAuthHeader(),
      body: { submission: payload },
    });

  const deleteSubmission = (id: number) =>
    $fetch(`${apiBase}/submissions/${id}`, {
      method: 'DELETE',
      headers: getAuthHeader(),
    });

  return {
    fetchSubmissions,
    createSubmission,
    updateSubmission,
    deleteSubmission,
  };
};
