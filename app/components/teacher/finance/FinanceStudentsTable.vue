<template>
  <div class="overflow-y-auto custom-scroll flex-1">
    <table class="w-full text-sm text-left border-collapse">
      <thead
        class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0 z-10 shadow-sm"
      >
        <tr>
          <th class="px-6 py-3">{{ $t('teacher.finance.table.student') }}</th>
          <th class="px-6 py-3">
            {{ $t('teacher.finance.table.package') }}
          </th>
          <th class="px-6 py-3 text-right">
            {{ $t('teacher.finance.table.amount') }}
          </th>
          <th class="px-6 py-3 text-right">
            {{ $t('teacher.finance.table.actions') }}
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <tr
          v-for="item in students"
          :key="item.id"
          class="hover:bg-slate-50 transition-colors group"
        >
          <td class="px-6 py-4 font-medium text-slate-800">
            <div>{{ item.name }}</div>
            <div class="text-xs text-slate-500">
              {{ $t('teacher.finance.table.parent') }}: {{ item.parentName }}
            </div>
          </td>
          <td class="px-6 py-4">
            <div class="flex flex-col gap-1">
              <span class="text-xs font-bold text-slate-700">{{
                item.package
              }}</span>
              <div
                class="w-32 bg-slate-200 rounded-full h-1.5 overflow-hidden"
              >
                <div
                  :class="[
                    'h-full rounded-full',
                    getProgressColor(item.sessionsLeft, item.totalSessions),
                  ]"
                  :style="{
                    width:
                      (item.sessionsLeft / item.totalSessions) * 100 + '%',
                  }"
                ></div>
              </div>
              <div
                class="text-[10px] text-slate-500 flex items-center gap-1"
              >
                {{ $t('teacher.finance.table.remaining') }}
                <span
                  :class="[
                    'font-bold',
                    item.sessionsLeft <= 3
                      ? 'text-red-500'
                      : 'text-slate-700',
                  ]"
                >
                  {{ item.sessionsLeft }}
                </span>
                /{{ item.totalSessions }}
                {{ $t('teacher.finance.table.sessions') }}
                <i
                  v-if="item.sessionsLeft <= 3"
                  class="fa-solid fa-triangle-exclamation text-red-500"
                  :title="$t('teacher.finance.table.expiringSoon')"
                ></i>
              </div>
            </div>
          </td>
          <td class="px-6 py-4 text-right font-bold text-slate-800">
            {{ item.amount > 0 ? formatCurrency(item.amount) : '--' }}
          </td>
          <td class="px-6 py-4 text-right">
            <div class="flex justify-end gap-2">
              <button
                @click="$emit('create-invoice', item)"
                class="p-2 rounded bg-purple-50 text-purple-600 hover:bg-purple-600 hover:text-white transition-colors text-xs font-bold flex items-center gap-1"
                :title="$t('teacher.finance.actions.createInvoice')"
              >
                <i class="fa-solid fa-file-invoice"></i>
                <span class="hidden xl:inline">{{
                  $t('teacher.finance.actions.createInvoice')
                }}</span>
              </button>
              <button
                @click="$emit('view-history', item)"
                class="p-2 rounded bg-slate-100 text-slate-500 hover:bg-slate-200 transition-colors text-xs"
                :title="$t('teacher.finance.actions.viewHistory')"
              >
                <i class="fa-solid fa-clock-rotate-left"></i>
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
import type { StudentFinanceInfo } from '@/composables/useTeacherFinanceApi';

interface Props {
  students: StudentFinanceInfo[];
}

defineProps<Props>();

defineEmits<{
  'create-invoice': [student: StudentFinanceInfo];
  'view-history': [student: StudentFinanceInfo];
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

const getProgressColor = (left: number, total: number) => {
  const ratio = left / total;
  if (ratio <= 0.25) return 'bg-red-500';
  if (ratio <= 0.5) return 'bg-yellow-500';
  return 'bg-blue-500';
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
