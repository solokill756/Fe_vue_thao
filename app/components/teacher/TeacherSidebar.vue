<template>
  <aside
    class="w-20 lg:w-64 bg-slate-900 text-slate-300 flex-shrink-0 flex flex-col transition-all duration-300 shadow-xl z-20"
  >
    <div
      class="h-16 flex items-center justify-center lg:justify-start lg:px-6 border-b border-slate-800 bg-slate-900"
    >
      <div
        class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-lg"
      >
        T
      </div>
      <span
        class="ml-3 font-bold text-lg text-white hidden lg:block tracking-tight"
      >
        TMS Teacher
      </span>
    </div>

    <nav class="flex-1 py-6 px-3 space-y-1">
      <NuxtLink
        to="/teacher"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-chart-pie w-5 text-center"></i>
        <span class="hidden lg:block">Tổng quan</span>
      </NuxtLink>

      <NuxtLink
        to="/teacher/classes"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher/classes')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-chalkboard-user w-5 text-center"></i>
        <span class="hidden lg:block">Quản lý Lớp</span>
      </NuxtLink>

      <NuxtLink
        to="/teacher/attendance"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher/attendance')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-check-double w-5 text-center"></i>
        <span class="hidden lg:block">Điểm danh</span>
      </NuxtLink>

      <NuxtLink
        to="/teacher/grading"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher/grading')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <div class="relative">
          <i class="fa-solid fa-pen-to-square w-5 text-center"></i>
          <span
            class="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full border border-slate-900"
          ></span>
        </div>
        <span class="hidden lg:block">Chấm bài</span>
      </NuxtLink>

      <NuxtLink
        to="/teacher/finance"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher/finance')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-money-bill-wave w-5 text-center"></i>
        <span class="hidden lg:block">Học phí lớp</span>
      </NuxtLink>

      <NuxtLink
        to="/teacher/profile"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors',
          isActive('/teacher/profile')
            ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
            : 'hover:bg-slate-800 hover:text-white',
        ]"
      >
        <i class="fa-solid fa-user w-5 text-center"></i>
        <span class="hidden lg:block">Trang cá nhân</span>
      </NuxtLink>

      <div class="pt-4 mt-4 border-t border-slate-800">
        <NuxtLink
          to="/teacher/ai"
          :class="[
            'flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-colors bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg',
          ]"
        >
          <i class="fa-solid fa-robot w-5 text-center"></i>
          <span class="hidden lg:block">Trợ lý AI (VIP)</span>
        </NuxtLink>
      </div>
    </nav>

    <ClientOnly>
      <div class="p-4 border-t border-slate-800 space-y-3">
        <NuxtLink
          to="/teacher/profile"
          class="flex items-center gap-3 hover:bg-slate-800 rounded-lg p-2 transition-colors cursor-pointer"
        >
          <img
            :src="
              authStore.user?.photo_url ||
              `https://ui-avatars.com/api/?name=${encodeURIComponent(
                authStore.user?.full_name || 'Teacher'
              )}&background=random`
            "
            class="w-9 h-9 rounded-full border border-slate-600"
          />
          <div class="hidden lg:block overflow-hidden flex-1">
            <div class="text-sm font-medium text-white truncate">
              {{ authStore.user?.full_name || 'Giáo viên' }}
            </div>
            <div class="text-xs text-slate-500">Giáo viên</div>
          </div>
        </NuxtLink>
        <button
          @click="handleLogout"
          class="w-full flex items-center gap-3 px-3 py-2 rounded-lg font-medium transition-colors text-slate-300 hover:bg-slate-800 hover:text-white justify-center lg:justify-start"
        >
          <i class="fa-solid fa-arrow-right-from-bracket w-5 text-center"></i>
          <span class="hidden lg:block">Đăng xuất</span>
        </button>
      </div>
      <template #fallback>
        <div class="p-4 border-t border-slate-800">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-full border border-slate-600 bg-slate-700"></div>
            <div class="hidden lg:block overflow-hidden">
              <div class="text-sm font-medium text-white truncate">
                Giáo viên
              </div>
              <div class="text-xs text-slate-500">Giáo viên</div>
            </div>
          </div>
        </div>
      </template>
    </ClientOnly>
  </aside>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import { getErrorMessage } from '../../utils/errorHandler';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const authStore = useAuthStore();
const toast = useToast();
const route = useRoute();

const isActive = (path: string) => {
  if (path === '/teacher') {
    return route.path === '/teacher';
  }
  return route.path.startsWith(path);
};

const handleLogout = () => {
  try {
    authStore.logout();
    toast.success(t('common.logoutSuccess'));
    navigateTo('/auth');
  } catch (error) {
    console.error('Logout failed:', error);
    toast.error(
      getErrorMessage(error, 'common.', t) || t('common.logoutError')
    );
  }
};
</script>
