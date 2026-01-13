<template>
  <div class="component-box h-full flex flex-col gap-6 animate-fade-in relative">
    <span class="component-label">TuitionManager.vue</span>

    <!-- Stats Cards -->
    <div class="grid md:grid-cols-3 gap-6">
      <div
        class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
      >
        <div>
          <p class="text-sm text-slate-500 font-bold mb-1">Tổng nợ hiện tại</p>
          <h3 class="text-2xl font-bold text-red-600">
            {{ formatCurrency(tuitionData.total_debt) }}
          </h3>
        </div>
        <div class="w-10 h-10 rounded-lg bg-red-50 text-red-500 flex items-center justify-center text-xl">
          <i class="fa-solid fa-money-bill-wave"></i>
        </div>
      </div>
      <div
        class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
      >
        <div>
          <p class="text-sm text-slate-500 font-bold mb-1">Hạn thanh toán</p>
          <h3 class="text-2xl font-bold text-slate-800">
            {{ tuitionData.next_due_date }}
          </h3>
        </div>
        <div class="w-10 h-10 rounded-lg bg-blue-50 text-blue-500 flex items-center justify-center text-xl">
          <i class="fa-regular fa-calendar-check"></i>
        </div>
      </div>
      <div
        class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
      >
        <div>
          <p class="text-sm text-slate-500 font-bold mb-1">Ví học phí</p>
          <h3 class="text-2xl font-bold text-green-600">
            {{ formatCurrency(tuitionData.wallet_balance) }}
          </h3>
        </div>
        <div class="w-10 h-10 rounded-lg bg-green-50 text-green-500 flex items-center justify-center text-xl">
          <i class="fa-solid fa-wallet"></i>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="flex-1 bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden flex flex-col">
      <!-- Tabs -->
      <div class="flex border-b border-slate-200">
        <button
          @click="activeTab = 'pending'"
          :class="[
            'flex-1 py-4 text-sm font-bold text-center border-b-2 transition-colors',
            activeTab === 'pending'
              ? 'border-blue-600 text-blue-600 bg-blue-50/50'
              : 'border-transparent text-slate-500 hover:bg-slate-50'
          ]"
        >
          Chờ thanh toán
          <span
            v-if="tuitionData.pending_invoices.length > 0"
            class="ml-2 bg-red-500 text-white text-[10px] px-1.5 py-0.5 rounded-full"
          >
            {{ tuitionData.pending_invoices.length }}
          </span>
        </button>
        <button
          @click="activeTab = 'history'"
          :class="[
            'flex-1 py-4 text-sm font-bold text-center border-b-2 transition-colors',
            activeTab === 'history'
              ? 'border-blue-600 text-blue-600 bg-blue-50/50'
              : 'border-transparent text-slate-500 hover:bg-slate-50'
          ]"
        >
          Lịch sử giao dịch
        </button>
      </div>

      <!-- Tab Content -->
      <div class="flex-1 overflow-y-auto custom-scroll p-6">
        <!-- PENDING TAB -->
        <div v-if="activeTab === 'pending'" class="space-y-4 animate-fade-in">
          <div
            v-if="tuitionData.pending_invoices.length === 0"
            class="flex flex-col items-center justify-center h-64 text-slate-400"
          >
            <i class="fa-solid fa-circle-check text-4xl text-green-500 mb-3"></i>
            <p class="font-medium text-slate-600">Bạn không có khoản phí nào cần đóng.</p>
          </div>
          <div
            v-else
            v-for="(inv, idx) in tuitionData.pending_invoices"
            :key="idx"
            class="border border-slate-200 rounded-xl p-5 hover:shadow-md transition-all relative overflow-hidden group"
          >
            <div
              v-if="inv.status === 'overdue'"
              class="absolute left-0 top-0 bottom-0 w-1 bg-red-500"
            ></div>
            <div v-else class="absolute left-0 top-0 bottom-0 w-1 bg-yellow-400"></div>

            <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 pl-3">
              <div>
                <div class="flex items-center gap-3 mb-1">
                  <h4 class="font-bold text-lg text-slate-800">{{ inv.title }}</h4>
                  <span
                    :class="[
                      'text-[10px] uppercase font-bold px-2 py-0.5 rounded border',
                      getStatusClass(inv.status)
                    ]"
                  >
                    {{ getStatusLabel(inv.status) }}
                  </span>
                </div>
                <p class="text-sm text-slate-500 mb-1">{{ inv.description }}</p>
                <p class="text-xs font-bold text-slate-400">
                  Hạn chót:
                  <span :class="inv.status === 'overdue' ? 'text-red-500' : 'text-slate-600'">
                    {{ inv.dueDate }}
                  </span>
                </p>
              </div>
              <div class="flex items-center gap-4 w-full md:w-auto justify-between md:justify-end">
                <div class="text-right">
                  <div class="text-xl font-bold text-blue-600">{{ formatCurrency(inv.amount) }}</div>
                </div>
                <button
                  @click="openPayment(inv)"
                  class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold rounded-lg shadow-sm transition-colors"
                >
                  Thanh toán
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- HISTORY TAB -->
        <div v-else class="animate-fade-in">
          <div v-if="tuitionData.history.length === 0" class="text-center py-12 text-slate-400">
            <p class="font-medium">Chưa có giao dịch nào</p>
          </div>
          <table v-else class="w-full text-sm text-left">
            <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
              <tr>
                <th class="px-4 py-3">Mã GD</th>
                <th class="px-4 py-3">Nội dung</th>
                <th class="px-4 py-3">Ngày thanh toán</th>
                <th class="px-4 py-3">Số tiền</th>
                <th class="px-4 py-3 text-right">Trạng thái</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-for="(hist, idx) in tuitionData.history" :key="idx" class="hover:bg-slate-50">
                <td class="px-4 py-3 font-mono text-slate-500 text-xs">{{ hist.id }}</td>
                <td class="px-4 py-3 font-medium text-slate-800">{{ hist.title }}</td>
                <td class="px-4 py-3 text-slate-600">{{ hist.date }}</td>
                <td class="px-4 py-3 font-bold text-slate-700">{{ formatCurrency(hist.amount) }}</td>
                <td class="px-4 py-3 text-right">
                  <span class="text-green-600 font-bold text-xs bg-green-50 px-2 py-1 rounded-full border border-green-100">
                    Thành công
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- PAYMENT MODAL -->
    <div
      v-if="showPaymentModal"
      class="absolute inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4 animate-fade-in"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <h3 class="font-bold text-lg text-slate-800">Thanh toán Học phí</h3>
          <button
            @click="showPaymentModal = false"
            class="text-slate-400 hover:text-slate-600"
          >
            <i class="fa-solid fa-xmark text-xl"></i>
          </button>
        </div>
        <div class="p-6 overflow-y-auto custom-scroll text-center">
          <p class="text-sm text-slate-500 mb-4">Quét mã QR bằng ứng dụng ngân hàng để thanh toán.</p>

          <div class="bg-white p-4 border-2 border-blue-100 rounded-xl inline-block shadow-sm mb-4 relative group">
            <!-- Fake QR -->
            <div class="w-48 h-48 bg-slate-800 flex items-center justify-center text-white relative overflow-hidden">
              <i class="fa-solid fa-qrcode text-8xl"></i>
              <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
            </div>
            <p class="text-xs font-bold text-slate-400 mt-2 uppercase tracking-widest">VietQR</p>
          </div>

          <div class="text-left bg-slate-50 p-4 rounded-xl space-y-2 border border-slate-100 mb-6">
            <div class="flex justify-between text-sm">
              <span class="text-slate-500">Nội dung:</span>
              <span class="font-bold text-slate-800">{{ selectedInvoice?.title }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-slate-500">Mã giao dịch:</span>
              <span class="font-mono text-slate-700">{{ selectedInvoice?.id }}</span>
            </div>
            <div class="border-t border-slate-200 my-2 pt-2 flex justify-between items-center">
              <span class="text-slate-500 font-bold">Tổng tiền:</span>
              <span class="text-xl font-bold text-blue-600">{{ formatCurrency(selectedInvoice?.amount) }}</span>
            </div>
          </div>

          <button
            id="payBtn"
            @click="processPayment"
            class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-lg shadow-blue-200 transition-all flex items-center justify-center gap-2"
          >
            <i class="fa-solid fa-check"></i> Xác nhận đã chuyển khoản
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { TuitionData, TuitionInvoice, TuitionStatus } from '@/types/tuition'
import { useTuitionApi } from '@/composables/useTuitionApi'

const { getTuitionDashboard, processPayment } = useTuitionApi()

const tuitionData = ref<TuitionData>({
  total_debt: 0,
  next_due_date: '',
  wallet_balance: 0,
  pending_invoices: [],
  history: []
})

const activeTab = ref<'pending' | 'history'>('pending')
const showPaymentModal = ref(false)
const selectedInvoice = ref<TuitionInvoice | null>(null)

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(value)
}

const getStatusClass = (status: TuitionStatus): string => {
  switch (status) {
    case 'paid':
      return 'bg-green-100 text-green-700 border-green-200'
    case 'pending':
      return 'bg-yellow-100 text-yellow-700 border-yellow-200'
    case 'overdue':
      return 'bg-red-100 text-red-700 border-red-200'
    default:
      return 'bg-slate-100 text-slate-700'
  }
}

const getStatusLabel = (status: TuitionStatus): string => {
  switch (status) {
    case 'paid':
      return 'Đã thanh toán'
    case 'pending':
      return 'Chờ thanh toán'
    case 'overdue':
      return 'Quá hạn'
    default:
      return status
  }
}

const openPayment = (invoice: TuitionInvoice) => {
  selectedInvoice.value = invoice
  showPaymentModal.value = true
}

const processPaymentClick = async () => {
  if (!selectedInvoice.value) return

  const btn = document.getElementById('payBtn')
  if (!btn) return

  const originalText = btn.innerHTML
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...'
  btn.disabled = true

  try {
    const response = await processPayment({
      invoice_id: selectedInvoice.value.id,
      amount: selectedInvoice.value.amount,
      method: 'transfer'
    })

    if (response.success) {
      btn.innerHTML = '<i class="fa-solid fa-check"></i> Thành công!'
      btn.classList.remove('bg-blue-600', 'hover:bg-blue-700')
      btn.classList.add('bg-green-600', 'hover:bg-green-700')

      setTimeout(() => {
        showPaymentModal.value = false
        alert('Thanh toán thành công! Hóa đơn đã được cập nhật.')
        loadTuitionData()
        // Reset button
        btn.innerHTML = originalText
        btn.classList.remove('bg-green-600', 'hover:bg-green-700')
        btn.classList.add('bg-blue-600', 'hover:bg-blue-700')
        btn.disabled = false
      }, 1500)
    }
  } catch (error) {
    btn.innerHTML = originalText
    btn.disabled = false
    console.error('Payment error:', error)
    alert('Thanh toán thất bại. Vui lòng thử lại.')
  }
}

const processPayment = processPaymentClick

const loadTuitionData = async () => {
  try {
    const response = await getTuitionDashboard()
    tuitionData.value = response.data
  } catch (error) {
    console.error('Error loading tuition data:', error)
  }
}

onMounted(() => {
  loadTuitionData()
})
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.custom-scroll::-webkit-scrollbar {
  width: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #93c5fd;
  border-radius: 3px;
}

.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #3b82f6;
}
</style>
