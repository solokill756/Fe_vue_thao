<template>
  <div class="fixed inset-0 w-full h-full min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <h1 class="text-4xl font-bold mb-4">Đang tải...</h1>
      <p class="text-gray-600">Đang kiểm tra trạng thái đăng nhập</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

onMounted(() => {
  const authToken = useCookie('auth_token').value;
  const authStore = useAuthStore();
  authStore.initializeFromStorage();

  if (authToken && authStore.user) {
    const role = authStore.user.role;
    if (role === 'student') {
      navigateTo('/student');
    } else if (role === 'admin') {
      navigateTo('/admin');
    } else {
      navigateTo('/teacher');
    }
  } else {
    navigateTo('/auth');
  }
});
</script>
