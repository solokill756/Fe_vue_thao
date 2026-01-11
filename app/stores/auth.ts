import { defineStore } from 'pinia';
import type { UserModel } from 'app/types/user';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as UserModel | null,
    token: null as string | null,
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
      this.user = res.data.user;

      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }

      useCookie('auth_token', {
        maxAge: 60 * 60 * 24 * 7,
      }).value = this.token;
    },

    async googleLogin(provider: string) {
      const { googleLogin } = useAuthApi();
      const res = await googleLogin(provider);

      this.token = res.data.token;
      this.user = res.data.user;

      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }

      useCookie('auth_token').value = this.token;
    },

    logout() {
      useCookie('auth_token').value = null;

      if (process.client) {
        localStorage.removeItem('auth_user');
      }

      this.$reset();
    },

    initializeFromStorage() {
      if (!process.client) return;

      const userStr = localStorage.getItem('auth_user');

      if (userStr) {
        try {
          this.user = JSON.parse(userStr);
        } catch (error) {
          console.error('Error parsing stored user:', error);
          localStorage.removeItem('auth_user');
        }
      }
    },
    refreshUser(user: UserModel) {
      this.user = user;
      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(this.user));
      }
    },
  },
});
