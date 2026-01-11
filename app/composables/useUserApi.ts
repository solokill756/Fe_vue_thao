import type { ApiResponseSuccess } from '@/types/common';

export const useUserApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const updateUser = (payload: { full_name?: string; phone_number?: string }) =>
    $fetch(`${apiBase}/users/profile`, {
      method: 'PATCH',
      headers: getAuthHeader(),
      body: { user: payload },
    });
  const uploadAvatar = (file: File) => {
    const formData = new FormData();
    formData.append('avatar', file);
    return $fetch<ApiResponseSuccess<{ avatar: string }>>(
      `${apiBase}/users/upload_avatar`,
      {
        method: 'POST',
        headers: getAuthHeader(),
        body: formData,
      }
    );
  };
  return {
    updateUser,
    uploadAvatar,
  };
};
