import { defineStore } from 'pinia';
import type { UserModel } from 'app/types/user';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as UserModel | null,
    token: null as string | null,
    refreshToken: null as string | null,
  }),

  getters: {
    isAuthenticated: (s) => !!s.token,
    role: (s) => s.user?.role,
  },

  actions: {
    async login(email: string, password: string) {
      const { login } = useAuthApi();
      const res = await login(email, password);

      this.token = res.data.token;
      this.refreshToken = res.data.refresh_token;
      this.user = res.data.user;

      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }

      // Access token expires in 15 minutes
      useCookie('auth_token', {
        maxAge: 60 * 15, // 15 minutes
      }).value = this.token;

      // Refresh token expires in 7 days
      useCookie('auth_refresh_token', {
        maxAge: 60 * 60 * 24 * 7, // 7 days
      }).value = this.refreshToken;
    },

    async googleLogin(idToken: string) {
      const { googleLogin } = useAuthApi();
      const res = await googleLogin(idToken);

      this.token = res.data.token;
      this.refreshToken = res.data.refresh_token;
      this.user = res.data.user;

      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }

      useCookie('auth_token', {
        maxAge: 60 * 15, // 15 minutes
      }).value = this.token;

      useCookie('auth_refresh_token', {
        maxAge: 60 * 60 * 24 * 7, // 7 days
      }).value = this.refreshToken;
    },

    async refreshAccessToken() {
      const refreshTokenCookie = useCookie('auth_refresh_token').value;
      
      if (!refreshTokenCookie) {
        throw new Error('No refresh token available');
      }

      try {
        const { refreshToken } = useAuthApi();
        const res = await refreshToken(refreshTokenCookie);

        this.token = res.data.token;
        this.refreshToken = res.data.refresh_token;

        useCookie('auth_token', {
          maxAge: 60 * 15, // 15 minutes
        }).value = this.token;

        useCookie('auth_refresh_token', {
          maxAge: 60 * 60 * 24 * 7, // 7 days
        }).value = this.refreshToken;

        return this.token;
      } catch (error) {
        // If refresh fails, logout user
        this.logout();
        throw error;
      }
    },

    logout() {
      useCookie('auth_token').value = null;
      useCookie('auth_refresh_token').value = null;

      if (process.client) {
        localStorage.removeItem('auth_user');
      }

      this.$reset();
    },

    initializeFromStorage() {
      if (!process.client) return;

      const userStr = localStorage.getItem('auth_user');
      const token = useCookie('auth_token').value;
      const refreshToken = useCookie('auth_refresh_token').value;

      if (userStr) {
        try {
          this.user = JSON.parse(userStr);
        } catch (error) {
          console.error('Error parsing stored user:', error);
          localStorage.removeItem('auth_user');
        }
      }

      if (token) {
        this.token = token;
      }

      if (refreshToken) {
        this.refreshToken = refreshToken;
      }
    },
    refreshUser(user: UserModel) {
      this.user = user;
      if (process.env.CLIENT) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }
    },
  },
});
