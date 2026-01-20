<template>
  <div class="overflow-y-auto custom-scroll flex-1">
    <div v-if="loading" class="flex items-center justify-center h-full">
      <div class="text-center">
        <i class="fa-solid fa-spinner fa-spin text-4xl text-blue-600 mb-2"></i>
        <p class="text-slate-500">{{ $t('teacher.finance.loading') }}</p>
      </div>
    </div>
    <div v-else-if="transactions.length === 0" class="flex flex-col items-center justify-center h-full text-slate-400 p-8">
      <i class="fa-solid fa-check-circle text-4xl mb-2 text-green-500"></i>
      <p>{{ $t('teacher.finance.noPendingTransactions') }}</p>
    </div>
    <table v-else class="w-full text-sm text-left border-collapse">
      <thead
        class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0 z-10 shadow-sm"
      >
        <tr>
          <th class="px-6 py-3">{{ $t('teacher.finance.transactionsTable.student') }}</th>
          <th class="px-6 py-3">{{ $t('teacher.finance.transactionsTable.invoice') }}</th>
          <th class="px-6 py-3">{{ $t('teacher.finance.transactionsTable.amount') }}</th>
          <th class="px-6 py-3">{{ $t('teacher.finance.transactionsTable.method') }}</th>
          <th class="px-6 py-3">{{ $t('teacher.finance.transactionsTable.date') }}</th>
          <th class="px-6 py-3 text-right">{{ $t('teacher.finance.transactionsTable.actions') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <tr
          v-for="txn in transactions"
          :key="txn.id"
          class="hover:bg-slate-50 transition-colors"
        >
          <td class="px-6 py-4 font-medium text-slate-800">
            {{ txn.student_name }}
          </td>
          <td class="px-6 py-4 text-slate-600 font-mono text-xs">
            {{ txn.invoice_code }}
          </td>
          <td class="px-6 py-4 font-bold text-blue-600">
            {{ formatCurrency(txn.amount) }}
          </td>
          <td class="px-6 py-4">
            <span
              :class="[
                'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold border',
                txn.method === 'cash'
                  ? 'bg-green-100 text-green-700 border-green-200'
                  : 'bg-blue-100 text-blue-700 border-blue-200',
              ]"
            >
              <i
                :class="[
                  txn.method === 'cash'
                    ? 'fa-solid fa-money-bill'
                    : 'fa-solid fa-building-columns',
                ]"
              ></i>
              {{
                txn.method === 'cash'
                  ? $t('teacher.finance.transactionsTable.cash')
                  : $t('teacher.finance.transactionsTable.transfer')
              }}
            </span>
          </td>
          <td class="px-6 py-4 text-slate-600 text-xs">
            {{ txn.created_at }}
          </td>
          <td class="px-6 py-4 text-right">
            <div class="flex justify-end gap-2">
              <button
                @click="$emit('approve', txn)"
                :disabled="processing"
                class="px-4 py-2 bg-green-600 text-white text-xs font-bold rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                <i class="fa-solid fa-check"></i>
                {{ $t('teacher.finance.transactionsTable.approve') }}
              </button>
              <button
                @click="$emit('reject', txn)"
                :disabled="processing"
                class="px-4 py-2 bg-red-600 text-white text-xs font-bold rounded-lg hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                <i class="fa-solid fa-xmark"></i>
                {{ $t('teacher.finance.transactionsTable.reject') }}
              </button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';

interface Transaction {
  id: number;
  student_name: string;
  invoice_code: string;
  amount: number;
  method: string;
  created_at: string;
}

interface Props {
  transactions: Transaction[];
  loading: boolean;
  processing: boolean;
}

defineProps<Props>();

defineEmits<{
  approve: [txn: Transaction];
  reject: [txn: Transaction];
}>();

const { t } = useI18n();

const formatCurrency = (amount: number) => {
  const roundedAmount = Math.ceil(amount || 0);
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(roundedAmount);
};
</script>

<style scoped>
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
