<template>
  <header
    class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 shadow-sm z-10"
  >
    <h2 class="font-bold text-slate-800 text-lg">{{ pageTitle }}</h2>
    <div class="flex items-center gap-4">
      <button
        class="w-9 h-9 rounded-full bg-slate-50 hover:bg-slate-100 flex items-center justify-center text-slate-500 relative"
      >
        <i class="fa-regular fa-bell"></i>
        <span
          class="absolute top-2 right-2.5 w-1.5 h-1.5 bg-red-500 rounded-full"
        ></span>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
const route = useRoute();

const pageTitle = computed(() => {
  const path = route.path;
  if (path === '/admin') return 'Tổng quan';
  if (path.startsWith('/admin/users')) return 'Quản lý Người dùng';
  return 'Admin Panel';
});
</script>
