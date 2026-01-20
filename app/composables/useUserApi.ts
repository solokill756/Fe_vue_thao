import type { ApiResponseSuccess } from '@/types/common';


export const useUserApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const updateUser = (payload: { full_name?: string; phone_number?: string }) =>
    apiFetch(`${apiBase}/users/profile`, {
      method: 'PATCH',
      body: { user: payload },
    });
  const uploadAvatar = (file: File) => {
    const formData = new FormData();
    formData.append('avatar', file);
    return apiFetch<ApiResponseSuccess<{ avatar: string }>>(
      `${apiBase}/users/upload_avatar`,
      {
        method: 'POST',
        body: formData,
      }
    );
  };

  const uploadQrCode = (file: File) => {
    const formData = new FormData();
    formData.append('qr_code', file);
    return apiFetch<ApiResponseSuccess<{ qr_code: string }>>(
      `${apiBase}/teachers/upload_qr_code`,
      {
        method: 'POST',
        body: formData,
      }
    );
  };

  return {
    updateUser,
    uploadAvatar,
    uploadQrCode,
  };
};
