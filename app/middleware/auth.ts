export default defineNuxtRouteMiddleware((to, from) => {
  const token = useCookie('auth_token').value;
  const auth = useAuthStore();
  auth.initializeFromStorage();
  if (!token && from.path !== '/auth') {
    return navigateTo('/auth');
  }
});
