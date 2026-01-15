export default defineNuxtRouteMiddleware((to, from) => {
  const token = useCookie('auth_token').value;
  const auth = useAuthStore();
  auth.initializeFromStorage();
  if (auth.user?.role === 'student') {
    return navigateTo('/student');
  }
  if (auth.user?.role === 'teacher') {
    return navigateTo('/teacher');
  }
  if (auth.user?.role === 'admin') {
    return navigateTo('/admin');
  }
  if (!token && from.path !== '/auth') {
    return navigateTo('/auth');
  }
});
