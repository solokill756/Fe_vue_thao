<template>
  <div class="space-y-6">
    <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm mb-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="font-bold text-lg text-slate-800">
          Tình hình thu học phí - {{ currentMonth }}
        </h3>
        <select
          v-model="selectedClass"
          class="px-3 py-1 bg-slate-50 border border-slate-200 rounded text-sm font-bold"
        >
          <option value="">Tất cả lớp</option>
          <option
            v-for="cls in classes"
            :key="cls.id"
            :value="cls.id"
          >
            {{ cls.name }}
          </option>
        </select>
      </div>
      <div class="w-full bg-slate-100 rounded-full h-4 mb-2">
        <div
          class="bg-green-500 h-4 rounded-full"
          :style="{ width: paymentProgress + '%' }"
        ></div>
      </div>
      <div class="flex justify-between text-sm">
        <span class="text-green-600 font-bold"
          >Đã thu: {{ formatCurrency(paidAmount) }} ({{ paidCount }} HS)</span
        >
        <span class="text-red-500 font-bold"
          >Chưa thu: {{ formatCurrency(unpaidAmount) }} ({{ unpaidCount }} HS)</span
        >
      </div>
    </div>

    <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
      <div
        class="p-4 border-b border-slate-100 flex justify-between items-center"
      >
        <h4 class="font-bold text-slate-700">Danh sách nợ học phí</h4>
        <button
          @click="sendAllReminders"
          class="px-3 py-1.5 bg-red-100 text-red-600 text-xs font-bold rounded hover:bg-red-200 transition-colors"
        >
          <i class="fa-regular fa-bell mr-1"></i> Nhắc tất cả
        </button>
      </div>
      <div class="divide-y divide-slate-100">
        <div
          v-for="debt in debtList"
          :key="debt.id"
          class="p-4 flex items-center justify-between hover:bg-slate-50"
        >
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center font-bold text-slate-500"
            >
              {{ debt.name.charAt(0) }}
            </div>
            <div>
              <div class="font-bold text-slate-800">{{ debt.name }}</div>
              <div class="text-xs text-red-500 font-bold">
                Nợ: {{ formatCurrency(debt.amount) }}
              </div>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <div class="text-xs text-slate-400 mr-2">Hạn: {{ debt.due }}</div>
            <button
              class="w-8 h-8 rounded bg-slate-100 text-slate-500 hover:text-blue-600 hover:bg-blue-50 flex items-center justify-center"
            >
              <i class="fa-regular fa-comment-dots"></i>
            </button>
            <button
              @click="markAsPaid(debt.id)"
              class="w-8 h-8 rounded bg-slate-100 text-slate-500 hover:text-green-600 hover:bg-green-50 flex items-center justify-center"
            >
              <i class="fa-solid fa-check"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const selectedClass = ref('');

const classes = ref([
  { id: 1, name: 'Toán Luyện Thi 12A' },
  { id: 2, name: 'Toán Cơ Bản 10' },
]);

const debtList = ref([
  { id: 1, name: 'Lê Hoàng Cường', amount: 500000, due: '05/01' },
  { id: 2, name: 'Vũ Văn Hùng', amount: 1000000, due: '01/01' },
  { id: 3, name: 'Đỗ Quang Em', amount: 500000, due: '10/01' },
]);

const paidAmount = computed(() => 14000000);
const unpaidAmount = computed(() => 2000000);
const paidCount = computed(() => 28);
const unpaidCount = computed(() => 4);
const paymentProgress = computed(() => {
  const total = paidAmount.value + unpaidAmount.value;
  return total > 0 ? (paidAmount.value / total) * 100 : 0;
});

const currentMonth = computed(() => {
  return new Intl.DateTimeFormat('vi-VN', {
    month: 'long',
    year: 'numeric',
  }).format(new Date());
});

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount);
};

const sendAllReminders = () => {
  // TODO: Implement send reminders API call
  console.log('Sending reminders to all');
};

const markAsPaid = (id: number) => {
  // TODO: Implement mark as paid API call
  console.log('Marking as paid:', id);
};
</script>
