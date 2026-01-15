export default defineNuxtRouteMiddleware((to, from) => {
  const token = useCookie('auth_token').value;
  const auth = useAuthStore();
  auth.initializeFromStorage();

  if (!token && from.path !== '/auth') {
    return navigateTo('/auth');
  }

  if (auth.user?.role === 'student' && !to.path.startsWith('/student')) {
    return navigateTo('/student');
  }
  if (auth.user?.role === 'teacher' && !to.path.startsWith('/teacher')) {
    return navigateTo('/teacher');
  }
  if (auth.user?.role === 'admin' && !to.path.startsWith('/admin')) {
    return navigateTo('/admin');
  }
});
