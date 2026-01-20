<template>
  <Teleport to="body">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-[9999] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4 animate-fade-in"
      @click.self="$emit('update:modelValue', false)"
    >
      <div
        class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]"
      >
        <div
          class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
        >
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold"
            >
              <i class="fa-solid fa-clock-rotate-left"></i>
            </div>
            <div>
              <h3 class="font-bold text-lg text-slate-800">
                {{ $t('teacher.finance.historyModal.title') }}
              </h3>
              <p class="text-xs text-slate-500" v-if="student">
                {{ $t('teacher.finance.historyModal.student') }}:
                {{ student.name }}
              </p>
            </div>
          </div>
          <button
            @click="$emit('update:modelValue', false)"
            class="text-slate-400 hover:text-slate-600 w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-200 transition-colors"
          >
            <i class="fa-solid fa-xmark text-lg"></i>
          </button>
        </div>

        <div class="flex-1 overflow-y-auto custom-scroll p-0" v-if="student">
          <div
            v-if="loading"
            class="flex flex-col items-center justify-center py-12 text-slate-400"
          >
            <i class="fa-solid fa-spinner fa-spin text-3xl mb-3"></i>
            <p>{{ $t('teacher.finance.historyModal.loading') }}</p>
          </div>
          <div
            v-else-if="!transactions || transactions.length === 0"
            class="flex flex-col items-center justify-center py-12 text-slate-400"
          >
            <i
              class="fa-solid fa-file-invoice-dollar text-4xl mb-3 opacity-50"
            ></i>
            <p>{{ $t('teacher.finance.historyModal.noTransactions') }}</p>
          </div>
          <table v-else class="w-full text-sm text-left">
            <thead
              class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0"
            >
              <tr>
                <th class="px-6 py-3">
                  {{ $t('teacher.finance.historyModal.table.date') }}
                </th>
                <th class="px-6 py-3">
                  {{ $t('teacher.finance.historyModal.table.content') }}
                </th>
                <th class="px-6 py-3">
                  {{ $t('teacher.finance.historyModal.table.method') }}
                </th>
                <th class="px-6 py-3 text-right">
                  {{ $t('teacher.finance.historyModal.table.amount') }}
                </th>
                <th class="px-6 py-3 text-right">
                  {{ $t('teacher.finance.historyModal.table.status') }}
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr
                v-for="(tx, idx) in transactions"
                :key="idx"
                class="hover:bg-slate-50 transition-colors"
              >
                <td class="px-6 py-4 text-slate-600 font-mono text-xs">
                  {{ tx.date }}
                </td>
                <td class="px-6 py-4 font-medium text-slate-800">
                  {{ $t('teacher.finance.historyModal.transactionContent') }}
                </td>
                <td class="px-6 py-4">
                  <span
                    class="inline-flex items-center gap-1.5 px-2 py-1 rounded bg-slate-100 text-slate-600 text-xs font-bold border border-slate-200"
                  >
                    <i
                      :class="[
                        'fa-solid',
                        tx.method === 'cash' || tx.method === 'Tiền mặt'
                          ? 'fa-money-bill'
                          : 'fa-building-columns',
                      ]"
                    ></i>
                    {{
                      tx.method === 'cash' || tx.method === 'Tiền mặt'
                        ? $t('teacher.finance.historyModal.method.cash')
                        : $t('teacher.finance.historyModal.method.transfer')
                    }}
                  </span>
                </td>
                <td class="px-6 py-4 text-right font-bold text-green-600">
                  +{{ formatCurrency(tx.amount) }}
                </td>
                <td class="px-6 py-4 text-right">
                  <span
                    v-if="tx.status === 'completed' || tx.status === 'approved'"
                    class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full text-xs font-bold bg-green-100 text-green-700 border border-green-200"
                  >
                    <i class="fa-solid fa-check"></i>
                    {{ $t('teacher.finance.historyModal.status.completed') }}
                  </span>
                  <span
                    v-else-if="tx.status === 'pending'"
                    class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full text-xs font-bold bg-yellow-100 text-yellow-700 border border-yellow-200"
                  >
                    <i class="fa-regular fa-clock"></i>
                    {{ $t('teacher.finance.historyModal.status.pending') }}
                  </span>
                  <span
                    v-else
                    class="inline-flex items-center gap-1.5 px-2 py-1 rounded-full text-xs font-bold bg-red-100 text-red-700 border border-red-200"
                  >
                    <i class="fa-solid fa-xmark"></i>
                    {{ $t('teacher.finance.historyModal.status.failed') }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div
          class="p-4 border-t border-slate-100 bg-slate-50 flex justify-between items-center"
        >
          <span class="text-xs text-slate-500 italic">
            {{ $t('teacher.finance.historyModal.footer') }}
          </span>
          <button
            @click="$emit('update:modelValue', false)"
            class="px-5 py-2 bg-white border border-slate-200 text-slate-600 text-sm font-bold rounded-lg hover:bg-slate-100 transition-colors"
          >
            {{ $t('teacher.finance.historyModal.close') }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { StudentFinanceInfo } from '@/composables/useTeacherFinanceApi';

interface Transaction {
  id: string;
  date: string;
  amount: number;
  method: string;
  status: string;
}

interface Props {
  modelValue: boolean;
  student: StudentFinanceInfo | null;
  transactions: Transaction[];
  loading: boolean;
}

defineProps<Props>();

defineEmits<{
  'update:modelValue': [value: boolean];
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
