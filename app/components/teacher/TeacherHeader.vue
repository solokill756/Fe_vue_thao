<template>
  <header
    class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 shadow-sm z-10"
  >
    <h2 class="font-bold text-slate-800 text-lg">{{ pageTitle }}</h2>
    <div class="flex items-center gap-4">
      <!-- Language Switcher -->
      <CommonLanguageSwitcher />

      <button
        class="w-9 h-9 rounded-full bg-slate-50 hover:bg-slate-100 flex items-center justify-center text-slate-500 relative"
      >
        <i class="fa-regular fa-bell"></i>
        <span
          class="absolute top-2 right-2.5 w-1.5 h-1.5 bg-red-500 rounded-full"
        ></span>
      </button>
      <button
        v-if="showCreateButton"
        @click="$emit('create-class')"
        class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg shadow-sm flex items-center gap-2"
      >
        <i class="fa-solid fa-plus"></i>
        <span class="hidden sm:inline">Tạo lớp mới</span>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
const route = useRoute();

defineProps<{
  showCreateButton?: boolean;
}>();

defineEmits<{
  'create-class': [];
}>();

const pageTitle = computed(() => {
  const path = route.path;
  if (path === '/teacher') return 'Tổng quan';
  if (path.startsWith('/teacher/classes')) return 'Quản lý Lớp học';
  if (path.startsWith('/teacher/attendance')) return 'Điểm danh';
  if (path.startsWith('/teacher/grading')) return 'Chấm bài & Bài tập';
  if (path.startsWith('/teacher/finance')) return 'Quản lý Học phí';
  if (path.startsWith('/teacher/ai')) return 'Trợ lý Ảo';
  if (path.startsWith('/teacher/profile')) return 'Trang cá nhân';
  return 'Teacher Portal';
});
</script>
