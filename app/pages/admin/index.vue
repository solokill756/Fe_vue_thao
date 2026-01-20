<template>
  <div class="h-full flex flex-col gap-6">
    <h1 class="text-2xl font-bold text-slate-800">Tổng quan Admin</h1>
    
    <div class="grid md:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
        <h3 class="text-lg font-bold text-slate-800 mb-4">Thống kê người dùng</h3>
        <p class="text-slate-500 text-sm">Quản lý giáo viên và học sinh</p>
        <NuxtLink
          to="/admin/users"
          class="mt-4 inline-block px-4 py-2 bg-purple-600 text-white text-sm font-bold rounded-lg hover:bg-purple-700 transition-colors"
        >
          Xem chi tiết →
        </NuxtLink>
      </div>
      
      <!-- Add more dashboard cards as needed -->
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin',
  middleware: 'auth',
});
</script>
