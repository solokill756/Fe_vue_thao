import type { ApiResponseSuccess } from 'app/types/common';
import type { UserModel } from 'app/types/user';

interface LoginResponse {
  token: string;
  refresh_token: string;
  user: UserModel;
}

export const useAuthApi = () => {
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBase;

  const login = (email: string, password: string) =>
    $fetch<ApiResponseSuccess<LoginResponse>>(`${apiBase}/auth/login`, {
      method: 'POST',
      body: { user: { email, password } },
    });

  const register = (payload: {
    email: string;
    password: string;
    full_name: string;
    role: string;
  }) =>
    $fetch<ApiResponseSuccess<UserModel>>(`${apiBase}/auth/sign_up`, {
      method: 'POST',
      body: { user: payload },
    });

  const googleLogin = (idToken: string) =>
    $fetch<ApiResponseSuccess<LoginResponse>>(`${apiBase}/auth/google-login`, {
      method: 'POST',
      body: { user: { id_token: idToken } },
    });

  const refreshToken = (refreshToken: string) =>
    $fetch<ApiResponseSuccess<{ token: string; refresh_token: string }>>(
      `${apiBase}/auth/refresh-token`,
      {
        method: 'POST',
        body: { refresh_token: refreshToken },
      }
    );

  return {
    login,
    register,
    googleLogin,
    refreshToken,
  };
};
