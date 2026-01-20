export const handleAuthError = (e: unknown, title: string) => {
  if ((e as any)?.data?.error) {
    const errorCode = (e as any).data.error.code;

    switch (errorCode) {
      case 'UNAUTHORIZED':
        return `${title}.messages.unauthorizedError`;
      case 'VALIDATION_ERROR':
        return `${title}.messages.validationError`;
      case 'NOT_FOUND':
        return `${title}.messages.notFoundError`;
      default:
        return `${title}.messages.loginFailedError`;
    }
  } else {
    return 'common.errors.networkError';
  }
};

export const getAuthHeader = (): Record<string, string> => {
  const token = useCookie('auth_token').value;
  if (!token) return {};

  return {
    Authorization: `Bearer ${token}`,
  };
};

// Module-level variables for token refresh queue
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value?: any) => void;
  reject: (reason?: any) => void;
}> = [];

const processQueue = (error: any, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

/**
 * Wrapper for $fetch that automatically handles token refresh on 401 errors
 * Use this for authenticated API calls instead of direct $fetch
 */
export const apiFetch = async <T = any>(
  url: string,
  options: any = {}
): Promise<T> => {
  const authStore = useAuthStore();

  // Add auth header if not present
  if (!options.headers) {
    options.headers = {};
  }

  if (!options.headers.Authorization) {
    const authHeader = getAuthHeader();
    if (authHeader.Authorization) {
      options.headers.Authorization = authHeader.Authorization;
    }
  }

  try {
    return await $fetch<T>(url, options);
  } catch (error: any) {
    // Check if error is 401 (Unauthorized) - token expired
    if (error?.status === 401 || error?.statusCode === 401) {
      const originalRequest = { url, options };

      // If already refreshing, queue this request
      if (isRefreshing) {
        return new Promise<T>((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            originalRequest.options.headers.Authorization = `Bearer ${token}`;
            return $fetch<T>(originalRequest.url, originalRequest.options);
          })
          .catch((err) => Promise.reject(err));
      }

      isRefreshing = true;

      try {
        // Try to refresh token
        const newToken = await authStore.refreshAccessToken();

        // Process queued requests
        processQueue(null, newToken);

        // Retry original request with new token
        originalRequest.options.headers.Authorization = `Bearer ${newToken}`;
        return await $fetch<T>(originalRequest.url, originalRequest.options);
      } catch (refreshError) {
        // Refresh failed, process queue with error
        processQueue(refreshError, null);

        // Redirect to login if refresh fails
        if (process.client) {
          authStore.logout();
          navigateTo('/auth');
        }

        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    // For other errors, just throw
    throw error;
  }
};
