import type { ApiResponseSuccess } from '@/types/common';


export interface AdminUser {
  id: number;
  email: string;
  full_name: string;
  role: 'teacher' | 'student' | 'admin';
  is_active: boolean;
  otp_verified: boolean;
  phone_number: string | null;
  photo_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface AdminUserListResponse {
  users: AdminUser[];
  pagination: {
    current_page: number;
    per_page: number;
    total_count: number;
    total_pages: number;
  };
}

export interface CreateUserParams {
  email: string;
  full_name: string;
  password: string;
  role: 'teacher' | 'student';
  is_active?: boolean;
  phone_number?: string;
}

export interface UpdateUserParams {
  email?: string;
  full_name?: string;
  password?: string;
  role?: 'teacher' | 'student';
  is_active?: boolean;
  phone_number?: string;
}

export const useAdminApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const getUsers = (params?: {
    page?: number;
    per_page?: number;
    role?: 'teacher' | 'student';
    status?: 'active' | 'inactive';
    search?: string;
  }) => {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.per_page) queryParams.append('per_page', params.per_page.toString());
    if (params?.role) queryParams.append('role', params.role);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.search) queryParams.append('search', params.search);

    const queryString = queryParams.toString();
    return apiFetch<ApiResponseSuccess<AdminUserListResponse>>(
      `${apiBase}/admin/users${queryString ? `?${queryString}` : ''}`,
      {
        method: 'GET',
      }
    );
  };

  const getUser = (id: number) =>
    apiFetch<ApiResponseSuccess<AdminUser>>(`${apiBase}/admin/users/${id}`, {
      method: 'GET',
    });

  const createUser = (params: CreateUserParams) =>
    apiFetch<ApiResponseSuccess<AdminUser>>(`${apiBase}/admin/users`, {
      method: 'POST',
      body: { user: params },
    });

  const updateUser = (id: number, params: UpdateUserParams) =>
    apiFetch<ApiResponseSuccess<AdminUser>>(`${apiBase}/admin/users/${id}`, {
      method: 'PATCH',
      body: { user: params },
    });

  const deleteUser = (id: number) =>
    apiFetch<ApiResponseSuccess<{ message: string }>>(`${apiBase}/admin/users/${id}`, {
      method: 'DELETE',
    });

  const toggleUserStatus = (id: number) =>
    apiFetch<ApiResponseSuccess<AdminUser>>(`${apiBase}/admin/users/${id}/toggle-status`, {
      method: 'PATCH',
    });

  return {
    getUsers,
    getUser,
    createUser,
    updateUser,
    deleteUser,
    toggleUserStatus,
  };
};
