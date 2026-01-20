<template>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    <div
      class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
    >
      <div>
        <p class="text-xs font-bold text-slate-500 uppercase mb-1">
          {{ $t('teacher.finance.stats.collectedThisMonth') }}
        </p>
        <h3 class="text-2xl font-bold text-green-600">
          {{ formatCurrency(stats.collectedThisMonth) }}
        </h3>
        <!-- <p class="text-xs text-slate-400 mt-1">
          {{ stats.collectedCount }}/{{ totalStudents }}
          {{ $t('teacher.finance.stats.students') }}
        </p> -->
      </div>
      <div
        class="w-10 h-10 rounded-lg bg-green-50 text-green-600 flex items-center justify-center text-xl"
      >
        <i class="fa-solid fa-sack-dollar"></i>
      </div>
    </div>
    <div
      class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
    >
      <div>
        <p class="text-xs font-bold text-slate-500 uppercase mb-1">
          {{ $t('teacher.finance.stats.outstandingDebt') }}
        </p>
        <h3 class="text-2xl font-bold text-red-600">
          {{ formatCurrency(stats.outstandingDebt) }}
        </h3>
        <p class="text-xs text-slate-400 mt-1">
          {{ stats.debtCount }}
          {{ $t('teacher.finance.stats.studentsWithDebt') }}
        </p>
      </div>
      <div
        class="w-10 h-10 rounded-lg bg-red-50 text-red-600 flex items-center justify-center text-xl"
      >
        <i class="fa-solid fa-hand-holding-dollar"></i>
      </div>
    </div>
    <div
      class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between"
    >
      <div>
        <p class="text-xs font-bold text-slate-500 uppercase mb-1">
          {{ $t('teacher.finance.stats.expiringSoon') }}
        </p>
        <h3 class="text-2xl font-bold text-orange-500">
          {{ stats.expiringSoon }}
        </h3>
        <p class="text-xs text-slate-400 mt-1">
          {{ $t('teacher.finance.stats.needRenewal') }}
        </p>
      </div>
      <div
        class="w-10 h-10 rounded-lg bg-orange-50 text-orange-500 flex items-center justify-center text-xl"
      >
        <i class="fa-regular fa-clock"></i>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';
import type { FinanceStats } from '@/composables/useTeacherFinanceApi';

interface Props {
  stats: FinanceStats;
  totalStudents: number;
}

defineProps<Props>();

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
