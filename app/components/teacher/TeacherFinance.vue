<template>
  <div class="h-full flex flex-col space-y-4">
    <!-- Stats Cards -->
    <FinanceStatsCards :stats="stats" :total-students="totalStudents" />

    <!-- Main Table -->
    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm flex-1 overflow-hidden flex flex-col"
    >
      <!-- Toolbar -->
      <FinanceToolbar
        :classes="classes"
        v-model:selected-class-id="selectedClassId"
        v-model:search-query="searchQuery"
        :show-pending-transactions="activeTab === 'pendingTransactions'"
        :pending-count="pendingTransactionsCount"
        @search="handleSearch"
        @toggle-pending-transactions="activeTab = activeTab === 'pendingTransactions' ? 'students' : 'pendingTransactions'"
      />

      <!-- Loading State -->
      <div
        v-if="pending"
        class="flex-1 flex items-center justify-center"
      >
        <div class="text-center">
          <i class="fa-solid fa-spinner fa-spin text-4xl text-blue-600 mb-2"></i>
          <p class="text-slate-500">{{ $t('teacher.finance.loading') }}</p>
        </div>
      </div>

      <!-- Error State -->
      <div
        v-else-if="error"
        class="flex-1 flex flex-col items-center justify-center text-slate-400 p-8"
      >
        <i class="fa-solid fa-exclamation-triangle text-4xl mb-2 text-red-500"></i>
        <p>{{ $t('teacher.finance.errorLoading') }}</p>
        <button
          @click="loadFinanceData"
          class="mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700"
        >
          {{ $t('teacher.finance.retry') }}
        </button>
      </div>

      <!-- Empty State -->
      <div
        v-else-if="!selectedClassId"
        class="flex-1 flex flex-col items-center justify-center text-slate-400 p-8"
      >
        <i class="fa-solid fa-chalkboard-user text-4xl mb-2"></i>
        <p>{{ $t('teacher.finance.selectClassPrompt') }}</p>
      </div>

      <!-- Pending Transactions Tab -->
      <PendingTransactionsTable
        v-else-if="activeTab === 'pendingTransactions'"
        :transactions="pendingTransactions"
        :loading="loadingPendingTransactions"
        :processing="processingTransaction"
        @approve="handleApproveTransaction"
        @reject="handleRejectTransaction"
      />

      <!-- Students Table -->
      <FinanceStudentsTable
        v-else-if="financeList.length > 0"
        :students="financeList"
        @create-invoice="openCreateInvoiceModal"
        @view-history="openHistoryModal"
      />

      <!-- Empty List -->
      <div
        v-else
        class="flex-1 flex flex-col items-center justify-center text-slate-400 p-8"
      >
        <i class="fa-solid fa-users-slash text-4xl mb-2"></i>
        <p>{{ $t('teacher.finance.noStudents') }}</p>
      </div>
    </div>

    <!-- Payment Modal -->
    <Teleport to="body">
      <div
        v-if="showPaymentModal"
        class="fixed inset-0 z-[9999] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4 animate-fade-in"
        @click.self="showPaymentModal = false"
      >
        <div
          class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col"
        >
          <div
            class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
          >
            <h3 class="font-bold text-lg text-slate-800">
              {{ $t('teacher.finance.paymentModal.title') }}
            </h3>
            <button
              @click="showPaymentModal = false"
              class="text-slate-400 hover:text-slate-600"
            >
              <i class="fa-solid fa-xmark text-xl"></i>
            </button>
          </div>
          <div
            class="p-6 space-y-4"
            v-if="selectedPaymentStudent"
          >
            <div
              class="flex items-center gap-3 p-3 bg-blue-50 rounded-xl border border-blue-100"
            >
              <div
                class="w-10 h-10 rounded-full bg-blue-200 flex items-center justify-center text-blue-700 font-bold"
              >
                {{ selectedPaymentStudent.name.charAt(0) }}
              </div>
              <div>
                <div class="font-bold text-slate-800">
                  {{ selectedPaymentStudent.name }}
                </div>
                <div class="text-xs text-slate-500">
                  {{ $t('teacher.finance.paymentModal.package') }}:
                  {{ selectedPaymentStudent.package }}
                </div>
              </div>
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
                {{ $t('teacher.finance.paymentModal.amount') }}
              </label>
              <div class="relative">
                <input
                  v-model.number="paymentForm.amount"
                  type="number"
                  min="0"
                  :max="selectedPaymentStudent.amount"
                  class="w-full pl-4 pr-12 py-3 bg-white border border-slate-300 rounded-lg text-lg font-bold text-green-600 focus:border-green-500 outline-none"
                />
                <span
                  class="absolute right-4 top-3.5 text-slate-400 font-bold text-sm"
                  >VND</span
                >
              </div>
              <p class="text-xs text-slate-500 mt-1">
                {{ $t('teacher.finance.paymentModal.maxAmount') }}:
                {{ formatCurrency(selectedPaymentStudent.amount) }}
              </p>
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
                {{ $t('teacher.finance.paymentModal.paymentMethod') }}
              </label>
              <div class="grid grid-cols-2 gap-3">
                <button
                  @click="paymentForm.method = 'cash'"
                  :class="[
                    'py-2 border-2 rounded-lg text-sm font-bold flex items-center justify-center gap-2 transition-colors',
                    paymentForm.method === 'cash'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-slate-200 hover:border-slate-300 text-slate-600',
                  ]"
                >
                  <i class="fa-solid fa-money-bill"></i>
                  {{ $t('teacher.finance.paymentModal.cash') }}
                </button>
                <button
                  @click="paymentForm.method = 'transfer'"
                  :class="[
                    'py-2 border-2 rounded-lg text-sm font-bold flex items-center justify-center gap-2 transition-colors',
                    paymentForm.method === 'transfer'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-slate-200 hover:border-slate-300 text-slate-600',
                  ]"
                >
                  <i class="fa-solid fa-building-columns"></i>
                  {{ $t('teacher.finance.paymentModal.transfer') }}
                </button>
              </div>
            </div>

            <div>
              <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
                {{ $t('teacher.finance.paymentModal.note') }}
              </label>
              <textarea
                v-model="paymentForm.note"
                class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm outline-none focus:border-blue-500 resize-none"
                rows="2"
                :placeholder="$t('teacher.finance.paymentModal.notePlaceholder')"
              ></textarea>
            </div>

            <div class="flex items-center gap-2">
              <input
                v-model="paymentForm.sendReceipt"
                type="checkbox"
                id="printReceipt"
                class="w-4 h-4 text-blue-600 rounded"
              />
              <label
                for="printReceipt"
                class="text-sm text-slate-600"
              >
                {{ $t('teacher.finance.paymentModal.sendReceipt') }}
              </label>
            </div>
          </div>
          <div
            class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3"
          >
            <button
              @click="showPaymentModal = false"
              :disabled="recordingPayment"
              class="px-4 py-2 text-slate-500 font-bold text-sm hover:bg-slate-200 rounded-lg transition-colors disabled:opacity-50"
            >
              {{ $t('teacher.finance.paymentModal.cancel') }}
            </button>
            <button
              @click="confirmPayment"
              :disabled="recordingPayment || !paymentForm.amount || paymentForm.amount <= 0"
              class="px-6 py-2 bg-green-600 text-white font-bold text-sm rounded-lg hover:bg-green-700 shadow-sm transition-colors flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <i
                v-if="recordingPayment"
                class="fa-solid fa-spinner fa-spin"
              ></i>
              <i v-else class="fa-solid fa-check"></i>
              {{ $t('teacher.finance.paymentModal.confirm') }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Payment History Modal -->
    <PaymentHistoryModal
      v-model="showHistoryModal"
      :student="selectedHistoryStudent"
      :transactions="paymentHistory"
      :loading="loadingHistory"
    />

    <!-- Create Invoice Modal -->
    <CreateInvoiceModal
      v-model="showCreateInvoiceModal"
      :student="selectedInvoiceStudent"
      :loading="creatingInvoice"
      @confirm="confirmCreateInvoice"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'vue-toastification';
import FinanceStatsCards from './finance/FinanceStatsCards.vue';
import FinanceToolbar from './finance/FinanceToolbar.vue';
import FinanceStudentsTable from './finance/FinanceStudentsTable.vue';
import PendingTransactionsTable from './finance/PendingTransactionsTable.vue';
import PaymentHistoryModal from './finance/PaymentHistoryModal.vue';
import CreateInvoiceModal from './finance/CreateInvoiceModal.vue';

const { t } = useI18n();
const toast = useToast();
const { fetchTeacherClasses } = useTeacherClassApi();
const {
  getAllFinanceStats,
  getClassFinance,
  recordPayment,
  sendReminder,
  sendAllReminders,
  getPendingTransactions,
  approveTransaction,
  rejectTransaction,
  createInvoice,
  getStudentPaymentHistory,
} = useTeacherFinanceApi();

// State
const selectedClassId = ref<number | string>('');
const searchQuery = ref('');
const activeTab = ref<'students' | 'pendingTransactions'>('students');

// Modal state
const showPaymentModal = ref(false);
const showCreateInvoiceModal = ref(false);
const showHistoryModal = ref(false);
const selectedPaymentStudent = ref<StudentFinanceInfo | null>(null);
const selectedInvoiceStudent = ref<StudentFinanceInfo | null>(null);
const selectedHistoryStudent = ref<StudentFinanceInfo | null>(null);
const paymentHistory = ref<Array<{
  id: string;
  date: string;
  amount: number;
  method: string;
  status: string;
}>>([]);
const loadingHistory = ref(false);
const paymentForm = ref({
  amount: 0,
  method: 'cash' as 'cash' | 'transfer',
  note: '',
  sendReceipt: false,
});

// Loading states
const recordingPayment = ref(false);
const sendingReminders = ref(false);
const processingTransaction = ref(false);
const creatingInvoice = ref(false);

const { data: classesData, pending: loadingClasses } = useAsyncData(
  'teacher-finance-classes',
  async () => {
    try {
      const response = await fetchTeacherClasses();
      return response.data.classes.map((cls: any) => ({
        id: cls.id,
        name: cls.name,
      }));
    } catch (err) {
      console.error('Error loading classes:', err);
      return [];
    }
  }
);

const classes = computed(() => classesData.value || []);

// Load finance data with useAsyncData
const { data: financeData, pending: pendingFinance, error: financeError, refresh: refreshFinance } = useAsyncData(
  () => `teacher-finance-${selectedClassId.value}-${searchQuery.value}`,
  async () => {
    if (!selectedClassId.value) {
      return {
        students: [],
        stats: {
          collectedThisMonth: 0,
          collectedCount: 0,
          outstandingDebt: 0,
          debtCount: 0,
          expiringSoon: 0,
        },
      };
    }

    try {
      const response = await getClassFinance(Number(selectedClassId.value), {
        search: searchQuery.value || undefined,
      });
      return response.data;
    } catch (err) {
      console.error('Error loading finance data:', err);
      toast.error(
        getErrorMessage(err, 'teacher.finance', t) ||
          t('teacher.finance.errorLoading')
      );
      throw err;
    }
  },
  {
    watch: [selectedClassId, searchQuery],
    default: () => ({
      students: [],
      stats: {
        collectedThisMonth: 0,
        collectedCount: 0,
        outstandingDebt: 0,
        debtCount: 0,
        expiringSoon: 0,
      },
    }),
  }
);

// Load finance stats for all classes (independent of selectedClassId)
const { data: financeStatsData, pending: pendingStats, error: statsError, refresh: refreshStats } = useAsyncData(
  'teacher-finance-stats-all',
  async () => {
    try {
      const response = await getAllFinanceStats();
      return response.data;
    } catch (err) {
      console.error('Error loading finance stats:', err);
      toast.error(
        getErrorMessage(err, 'teacher.finance', t) ||
          t('teacher.finance.errorLoading')
      );
      return {
        collectedThisMonth: 0,
        collectedCount: 0,
        outstandingDebt: 0,
        debtCount: 0,
        expiringSoon: 0,
        totalStudents: 0,
      };
    }
  },
  {
    default: () => ({
      collectedThisMonth: 0,
      collectedCount: 0,
      outstandingDebt: 0,
      debtCount: 0,
      expiringSoon: 0,
      totalStudents: 0,
    }),
  }
);

const financeList = computed(() => financeData.value?.students || []);
const stats = computed(() => financeStatsData.value || {
  collectedThisMonth: 0,
  collectedCount: 0,
  outstandingDebt: 0,
  debtCount: 0,
  expiringSoon: 0,
  totalStudents: 0,
});
const totalStudents = computed(() => stats.value.totalStudents || 0);

// Load pending transactions with useAsyncData
const { data: pendingTransactionsData, pending: loadingPendingTransactions, refresh: refreshPendingTransactions } = useAsyncData(
  () => `teacher-pending-transactions-${selectedClassId.value}`,
  async () => {
    if (!selectedClassId.value) {
      return { transactions: [] };
    }

    try {
      const response = await getPendingTransactions(Number(selectedClassId.value));
      return response.data;
    } catch (err) {
      console.error('Error loading pending transactions:', err);
      toast.error(
        getErrorMessage(err, 'teacher.finance', t) ||
          t('teacher.finance.errorLoadingTransactions')
      );
      return { transactions: [] };
    }
  },
  {
    watch: [selectedClassId],
    default: () => ({ transactions: [] }),
  }
);

const pendingTransactions = computed(() => pendingTransactionsData.value?.transactions || []);
const pendingTransactionsCount = computed(() => pendingTransactions.value.length);

// Alias for backward compatibility with existing code
const pending = pendingFinance;
const error = financeError;

// Helper function to refresh all data
const loadFinanceData = async () => {
  await Promise.all([
    refreshFinance(),
    refreshStats(),
    refreshPendingTransactions()
  ]);
};

const loadPendingTransactions = async () => {
  await refreshPendingTransactions();
};

// Handle search
const handleSearch = () => {
  loadFinanceData();
};

// Handle send reminder
const handleSendReminder = async (student: StudentFinanceInfo) => {
  if (!selectedClassId.value || !student.enrollment_id) return;

  try {
    await sendReminder(
      Number(selectedClassId.value),
      student.enrollment_id
    );
    toast.success(t('teacher.finance.reminderSent'));
  } catch (err) {
    console.error('Error sending reminder:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance', t) ||
        t('teacher.finance.errorSendingReminder')
    );
  }
};

// Handle send all reminders
const handleSendAllReminders = async () => {
  if (!selectedClassId.value) return;

  sendingReminders.value = true;
  try {
    const response = await sendAllReminders(Number(selectedClassId.value));
    toast.success(
      t('teacher.finance.allRemindersSent', { count: response.data.count })
    );
  } catch (err) {
    console.error('Error sending all reminders:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance', t) ||
        t('teacher.finance.errorSendingReminders')
    );
  } finally {
    sendingReminders.value = false;
  }
};

// Open payment modal
const openPaymentModal = (student: StudentFinanceInfo) => {
  selectedPaymentStudent.value = student;
  paymentForm.value = {
    amount: student.amount,
    method: 'cash',
    note: '',
    sendReceipt: false,
  };
  showPaymentModal.value = true;
};

// Confirm payment
const confirmPayment = async () => {
  if (
    !selectedPaymentStudent.value ||
    !selectedClassId.value ||
    !selectedPaymentStudent.value.enrollment_id
  )
    return;

  if (!paymentForm.value.amount || paymentForm.value.amount <= 0) {
    toast.error(t('teacher.finance.paymentModal.invalidAmount'));
    return;
  }

  recordingPayment.value = true;
  try {
    await recordPayment(
      Number(selectedClassId.value),
      selectedPaymentStudent.value.enrollment_id,
      {
        amount: paymentForm.value.amount,
        method: paymentForm.value.method,
        note: paymentForm.value.note || undefined,
      }
    );

    toast.success(t('teacher.finance.paymentModal.success'));
    showPaymentModal.value = false;
    loadFinanceData(); // Refresh data
  } catch (err) {
    console.error('Error recording payment:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance.paymentModal', t) ||
        t('teacher.finance.paymentModal.error')
    );
  } finally {
    recordingPayment.value = false;
  }
};

// Open history modal
const openHistoryModal = async (student: StudentFinanceInfo) => {
  if (!selectedClassId.value || !student.enrollment_id) {
    toast.error(t('teacher.finance.historyModal.error.noData'));
    return;
  }

  selectedHistoryStudent.value = student;
  showHistoryModal.value = true;
  loadingHistory.value = true;
  paymentHistory.value = [];

  try {
    const response = await getStudentPaymentHistory(
      Number(selectedClassId.value),
      student.enrollment_id,
      { page: 1, per_page: 50 }
    );
    paymentHistory.value = response.data.transactions || [];
  } catch (err) {
    console.error('Error loading payment history:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance.historyModal', t) ||
        t('teacher.finance.historyModal.error.loading')
    );
  } finally {
    loadingHistory.value = false;
  }
};

// Open create invoice modal
const openCreateInvoiceModal = (student: StudentFinanceInfo) => {
  selectedInvoiceStudent.value = student;
  showCreateInvoiceModal.value = true;
};

// Confirm create invoice
const confirmCreateInvoice = async (form: {
  title: string;
  description: string;
  amount: number;
  due_date: string;
  status: 'pending' | 'paid' | 'overdue';
}) => {
  if (
    !selectedInvoiceStudent.value ||
    !selectedClassId.value ||
    !selectedInvoiceStudent.value.enrollment_id
  )
    return;

  if (!form.title || !form.due_date) {
    toast.error(t('teacher.finance.createInvoiceModal.invalidData'));
    return;
  }
  
  // If amount is 0 or not set, backend will automatically calculate total_debt
  // So we don't need to validate amount here

  creatingInvoice.value = true;
  try {
    // If amount is 0 or not provided, backend will calculate total_debt automatically
    // Otherwise use the provided amount
    await createInvoice(
      Number(selectedClassId.value),
      selectedInvoiceStudent.value.enrollment_id,
      {
        title: form.title,
        description: form.description,
        amount: form.amount || 0, // Backend will calculate total_debt if 0
        due_date: form.due_date,
        status: form.status,
      }
    );
    toast.success(t('teacher.finance.createInvoiceModal.success'));
    showCreateInvoiceModal.value = false;
    loadFinanceData(); // Refresh data
  } catch (err) {
    console.error('Error creating invoice:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance', t) ||
        t('teacher.finance.createInvoiceModal.error')
    );
  } finally {
    creatingInvoice.value = false;
  }
};

// Handle approve transaction
const handleApproveTransaction = async (txn: any) => {
  if (!confirm(t('teacher.finance.transactionsTable.confirmApprove'))) {
    return;
  }

  processingTransaction.value = true;
  try {
    await approveTransaction(txn.id);
    toast.success(t('teacher.finance.transactionsTable.approveSuccess'));
    await loadPendingTransactions();
    await loadFinanceData(); // Refresh finance data
  } catch (err) {
    console.error('Error approving transaction:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance', t) ||
        t('teacher.finance.transactionsTable.approveError')
    );
  } finally {
    processingTransaction.value = false;
  }
};

// Handle reject transaction
const handleRejectTransaction = async (txn: any) => {
  if (!confirm(t('teacher.finance.transactionsTable.confirmReject'))) {
    return;
  }

  processingTransaction.value = true;
  try {
    await rejectTransaction(txn.id);
    toast.success(t('teacher.finance.transactionsTable.rejectSuccess'));
    await loadPendingTransactions();
  } catch (err) {
    console.error('Error rejecting transaction:', err);
    toast.error(
      getErrorMessage(err, 'teacher.finance', t) ||
        t('teacher.finance.transactionsTable.rejectError')
    );
  } finally {
    processingTransaction.value = false;
  }
};

// Helpers
const formatCurrency = (amount: number) => {
  // Round up to nearest integer before formatting
  const roundedAmount = Math.ceil(amount || 0);
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(roundedAmount);
};

// Watch for class changes
// Note: useAsyncData already watches selectedClassId and will auto-fetch
// We only need to reset searchQuery and activeTab here
watch(selectedClassId, () => {
  searchQuery.value = '';
  activeTab.value = 'students';
  // Don't call loadFinanceData() here - useAsyncData will auto-fetch
});

// Watch for tab changes
watch(activeTab, (newTab) => {
  if (newTab === 'pendingTransactions' && selectedClassId.value) {
    loadPendingTransactions();
  }
});

// Note: useAsyncData automatically loads data on mount, no need for onMounted
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
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
  height: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
