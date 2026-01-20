<template>
  <aside
    class="w-20 lg:w-64 bg-slate-900 text-slate-300 flex-shrink-0 flex flex-col transition-all duration-300 shadow-xl z-20"
  >
    <div
      class="h-16 flex items-center justify-center lg:justify-start lg:px-6 border-b border-slate-800 bg-slate-900"
    >
      <div
        class="w-8 h-8 bg-purple-600 rounded-lg flex items-center justify-center text-white font-bold text-lg"
      >
        A
      </div>
      <span
        class="ml-3 font-bold text-lg text-white hidden lg:block tracking-tight"
      >
        Admin Panel
      </span>
    </div>

    <nav class="flex-1 py-6 px-3 space-y-1">
      <NuxtLink
        to="/admin"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          $route.path === '/admin'
            ? 'bg-purple-600 text-white shadow-lg shadow-purple-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-chart-pie w-5 text-center"></i>
        <span class="hidden lg:block">Tổng quan</span>
      </NuxtLink>

      <NuxtLink
        to="/admin/users"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/admin/users')
            ? 'bg-purple-600 text-white shadow-lg shadow-purple-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-users w-5 text-center"></i>
        <span class="hidden lg:block">Quản lý Người dùng</span>
      </NuxtLink>
    </nav>

    <ClientOnly>
      <div class="p-4 border-t border-slate-800 space-y-3">
        <div class="flex items-center gap-3 hover:bg-slate-800 rounded-lg p-2 transition-colors cursor-pointer">
          <img
            :src="
              authStore.user?.photo_url ||
              `https://ui-avatars.com/api/?name=${encodeURIComponent(
                authStore.user?.full_name || 'Admin'
              )}&background=random`
            "
            class="w-9 h-9 rounded-full border border-slate-600"
          />
          <div class="hidden lg:block overflow-hidden flex-1">
            <div class="text-sm font-medium text-white truncate">
              {{ authStore.user?.full_name || 'Quản trị viên' }}
            </div>
            <div class="text-xs text-slate-500">Admin</div>
          </div>
        </div>
        <button
          @click="handleLogout"
          class="w-full flex items-center gap-3 px-3 py-2 rounded-lg font-medium transition-colors text-slate-300 hover:bg-slate-800 hover:text-white justify-center lg:justify-start"
        >
          <i class="fa-solid fa-right-from-bracket w-5 text-center"></i>
          <span class="hidden lg:block">Đăng xuất</span>
        </button>
      </div>
    </ClientOnly>
  </aside>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';

const router = useRouter();
const toast = useToast();
const authStore = useAuthStore();

const isActive = (path: string) => {
  return useRoute().path.startsWith(path);
};

const handleLogout = () => {
  authStore.logout();
  toast.success('Đăng xuất thành công');
  router.push('/auth');
};
</script>
