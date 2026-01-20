<template>
  <div class="space-y-6">
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="text-center">
        <i class="fa-solid fa-spinner fa-spin text-3xl text-slate-400 mb-2"></i>
        <p class="text-slate-500">Đang tải dữ liệu...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-xl p-4">
      <div class="flex items-center gap-2 text-red-600">
        <i class="fa-solid fa-circle-exclamation"></i>
        <span>{{ error }}</span>
      </div>
    </div>

    <!-- Dashboard Content -->
    <template v-else>
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div class="text-slate-500 text-xs font-bold uppercase mb-1">
            Tổng học sinh
          </div>
          <div class="text-2xl font-bold text-slate-800">{{ totalStudents }}</div>
          <div class="text-xs text-slate-400 mt-1">
            Tất cả các lớp
          </div>
        </div>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div class="text-slate-500 text-xs font-bold uppercase mb-1">
            Lớp đang dạy
          </div>
          <div class="text-2xl font-bold text-slate-800">{{ activeClassesCount }}</div>
          <div class="text-xs text-slate-400 mt-1">
            {{ activeClassesNames.length > 0 ? activeClassesNames.join(', ') : 'Chưa có lớp' }}
          </div>
        </div>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div class="text-slate-500 text-xs font-bold uppercase mb-1">
            Học phí tồn đọng
          </div>
          <div class="text-2xl font-bold text-red-600">{{ formatCurrency(pendingTuition) }}</div>
          <div class="text-xs text-red-500 mt-1 font-bold" v-if="pendingTuitionCount > 0">
            {{ pendingTuitionCount }} học sinh chưa đóng
          </div>
          <div class="text-xs text-green-500 mt-1 font-bold" v-else>
            Đã thu đủ
          </div>
        </div>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div class="text-slate-500 text-xs font-bold uppercase mb-1">
            Bài cần chấm
          </div>
          <div class="text-2xl font-bold text-blue-600">{{ pendingGradingCount }}</div>
          <div class="text-xs text-blue-500 mt-1 font-bold" v-if="pendingGradingDeadline > 0">
            {{ pendingGradingDeadline }} deadline hôm nay
          </div>
          <div class="text-xs text-slate-400 mt-1" v-else>
            Tất cả đã chấm
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
            v-if="todayClasses.length === 0"
            class="p-8 text-center text-slate-400"
          >
            <i class="fa-solid fa-calendar-xmark text-3xl mb-2"></i>
            <p>Không có lịch dạy hôm nay</p>
          </div>
          <div
            v-for="cls in todayClasses"
            :key="cls.id"
            class="p-5 flex items-center justify-between hover:bg-slate-50"
          >
            <div class="flex items-center gap-4">
              <div
                class="flex flex-col items-center justify-center w-14 h-14 bg-blue-50 text-blue-600 rounded-lg font-bold"
              >
                <span class="text-sm">{{ cls.time.split('-')[0]?.trim() || '' }}</span>
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
              :to="`/teacher/classes/${cls.id}/attendance`"
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
    </template>
  </div>
</template>

<script setup lang="ts">

const { fetchTeacherClasses, fetchTeacherClassDetail } = useTeacherClassApi();
const { getAllFinanceStats } = useTeacherFinanceApi();
const { fetchAllAssignments } = useTeacherGradingApi();

// Stats
const totalStudents = ref(0);
const activeClassesCount = ref(0);
const activeClassesNames = ref<string[]>([]);
const pendingTuition = ref(0);
const pendingTuitionCount = ref(0);
const pendingGradingCount = ref(0);
const pendingGradingDeadline = ref(0);

// Today's classes
const todayClasses = ref<Array<{
  id: number;
  name: string;
  time: string;
  room: string;
  count: number;
}>>([]);

const loading = ref(true);
const error = ref<string | null>(null);

const formatDate = (date: Date) => {
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date);
};

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
};

// Parse schedule to get today's classes
const parseTodaySchedule = async (classes: Array<{ id: number; name: string; room: string; students: number }>) => {
  const today = new Date();
  const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, etc.
  const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  const todayName = dayNames[dayOfWeek];
  
  if (!todayName) return [];
  
  const todayClassesList: typeof todayClasses.value = [];
  
  // Fetch details for classes to get raw_schedule
  const detailPromises = classes.map(cls => 
    fetchTeacherClassDetail(cls.id).catch(() => null)
  );
  const detailResponses = await Promise.all(detailPromises);
  
  detailResponses.forEach((response, index) => {
    if (!response?.data) return;
    
    const cls = classes[index];
    if (!cls) return;
    
    const classDetail = response.data;
    if (!classDetail.raw_schedule) return;
    
    // Check if class has schedule for today
    const schedule = classDetail.raw_schedule;
    const scheduleEntry = schedule[todayName];
    
    if (scheduleEntry) {
      // Parse time from schedule (format: "17:30 - 19:00" or similar)
      const timeMatch = scheduleEntry.match(/(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})/);
      const time = timeMatch ? `${timeMatch[1]} - ${timeMatch[2]}` : scheduleEntry;
      
      todayClassesList.push({
        id: cls.id,
        name: cls.name,
        time: time,
        room: cls.room || 'Chưa có',
        count: cls.students || 0,
      });
    }
  });
  
  // Sort by time
  todayClassesList.sort((a, b) => {
    const timeA = a.time.split('-')[0]?.trim() || '';
    const timeB = b.time.split('-')[0]?.trim() || '';
    return timeA.localeCompare(timeB);
  });
  
  return todayClassesList;
};

// Load dashboard data
const loadDashboardData = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    // Fetch all data in parallel
    const [classesResponse, financeStatsResponse, assignmentsResponse] = await Promise.all([
      fetchTeacherClasses({ status: 'active' }),
      getAllFinanceStats(),
      fetchAllAssignments(),
    ]);
    
    // Process classes data
    const classes = classesResponse.data.classes;
    activeClassesCount.value = classes.length;
    activeClassesNames.value = classes.slice(0, 3).map(c => c.name);
    
    // Calculate total students
    totalStudents.value = classes.reduce((sum, cls) => sum + (cls.students || 0), 0);
    
    // Get today's classes
    todayClasses.value = await parseTodaySchedule(classes);
    
    // Process finance stats
    if (financeStatsResponse.data) {
      pendingTuition.value = financeStatsResponse.data.outstandingDebt || 0;
      pendingTuitionCount.value = financeStatsResponse.data.debtCount || 0;
    }
    
    // Process assignments - count pending submissions
    if (assignmentsResponse.data) {
      const assignments = assignmentsResponse.data.assignments;
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      let pendingCount = 0;
      let deadlineToday = 0;
      
      for (const assignment of assignments) {
        const dueDate = new Date(assignment.due_date);
        dueDate.setHours(0, 0, 0, 0);
        
        // Count ungraded submissions
        const ungraded = assignment.total_students - assignment.graded_submissions_count;
        if (ungraded > 0) {
          pendingCount += ungraded;
          
          // Check if deadline is today
          if (dueDate.getTime() === today.getTime()) {
            deadlineToday += ungraded;
          }
        }
      }
      
      pendingGradingCount.value = pendingCount;
      pendingGradingDeadline.value = deadlineToday;
    }
    
  } catch (err: any) {
    console.error('Error loading dashboard data:', err);
    error.value = err.message || 'Không thể tải dữ liệu dashboard';
  } finally {
    loading.value = false;
  }
};

// Load data on mount
onMounted(() => {
  loadDashboardData();
});
</script>
