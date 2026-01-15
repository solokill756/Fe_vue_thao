<template>
  <div class="space-y-6">
    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
        <div class="text-slate-500 text-xs font-bold uppercase mb-1">
          Tổng học sinh
        </div>
        <div class="text-2xl font-bold text-slate-800">124</div>
        <div class="text-xs text-green-500 mt-1 font-bold">
          <i class="fa-solid fa-arrow-up"></i> +12 tháng này
        </div>
      </div>
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
        <div class="text-slate-500 text-xs font-bold uppercase mb-1">
          Lớp đang dạy
        </div>
        <div class="text-2xl font-bold text-slate-800">5</div>
        <div class="text-xs text-slate-400 mt-1">
          Toán 10, Toán 11, Luyện thi
        </div>
      </div>
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
        <div class="text-slate-500 text-xs font-bold uppercase mb-1">
          Học phí tồn đọng
        </div>
        <div class="text-2xl font-bold text-red-600">4.500.000đ</div>
        <div class="text-xs text-red-500 mt-1 font-bold">
          5 học sinh chưa đóng
        </div>
      </div>
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
        <div class="text-slate-500 text-xs font-bold uppercase mb-1">
          Bài cần chấm
        </div>
        <div class="text-2xl font-bold text-blue-600">28</div>
        <div class="text-xs text-blue-500 mt-1 font-bold">
          Deadline hôm nay
        </div>
      </div>
    </div>

    <div class="grid lg:grid-cols-3 gap-6">
      <!-- Upcoming Schedule -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200 shadow-sm">
        <div
          class="p-5 border-b border-slate-100 flex justify-between items-center"
        >
          <h3 class="font-bold text-slate-800">Lịch dạy hôm nay</h3>
          <span
            class="text-xs bg-slate-100 px-2 py-1 rounded text-slate-500 font-medium"
          >
            {{ formatDate(new Date()) }}
          </span>
        </div>
        <div class="divide-y divide-slate-100">
          <div
            v-for="cls in todayClasses"
            :key="cls.id"
            class="p-5 flex items-center justify-between hover:bg-slate-50"
          >
            <div class="flex items-center gap-4">
              <div
                class="flex flex-col items-center justify-center w-14 h-14 bg-blue-50 text-blue-600 rounded-lg font-bold"
              >
                <span class="text-sm">{{ cls.time.split('-')[0] }}</span>
              </div>
              <div>
                <div class="font-bold text-slate-800">{{ cls.name }}</div>
                <div class="text-sm text-slate-500">
                  <i class="fa-solid fa-location-dot mr-1"></i> {{ cls.room }} •
                  {{ cls.count }} HS
                </div>
              </div>
            </div>
            <NuxtLink
              to="/teacher/attendance"
              class="px-4 py-2 border border-slate-200 text-slate-600 text-sm font-bold rounded-lg hover:bg-slate-800 hover:text-white transition-colors"
            >
              Điểm danh
            </NuxtLink>
          </div>
        </div>
      </div>

      <!-- AI Suggestion -->
      <div
        class="bg-gradient-to-br from-indigo-900 to-slate-900 rounded-xl shadow-lg p-6 text-white relative overflow-hidden"
      >
        <div class="relative z-10">
          <div class="flex items-center gap-2 mb-4">
            <div
              class="w-8 h-8 rounded bg-white/20 flex items-center justify-center"
            >
              <i class="fa-solid fa-robot"></i>
            </div>
            <h3 class="font-bold">Trợ lý AI</h3>
          </div>
          <p class="text-sm text-slate-300 mb-4">
            Thầy ơi, lớp Toán 12A có 3 bạn điểm thấp liên tiếp. Thầy có muốn
            tôi soạn tin nhắn nhắc nhở phụ huynh không?
          </p>
          <NuxtLink
            to="/teacher/ai"
            class="w-full py-2 bg-white text-slate-900 font-bold text-sm rounded-lg hover:bg-slate-100 transition-colors block text-center"
          >
            Xử lý ngay
          </NuxtLink>
        </div>
        <div
          class="absolute -bottom-10 -right-10 w-40 h-40 bg-indigo-500 rounded-full blur-3xl opacity-50"
        ></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const todayClasses = ref([
  {
    id: 1,
    name: 'Toán Luyện Thi 12A',
    time: '17:30 - 19:00',
    room: 'P.302',
    count: 32,
  },
  {
    id: 2,
    name: 'Toán Cơ Bản 10',
    time: '19:15 - 20:45',
    room: 'P.201',
    count: 28,
  },
]);

const formatDate = (date: Date) => {
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date);
};
</script>
