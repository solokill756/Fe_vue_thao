<template>
  <Teleport to="body">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-[9999] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4 animate-fade-in"
      @click.self="$emit('update:modelValue', false)"
    >
      <div
        class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col"
      >
        <div
          class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
        >
          <h3 class="font-bold text-lg text-slate-800">
            {{ $t('teacher.finance.createInvoiceModal.title') }}
          </h3>
          <button
            @click="$emit('update:modelValue', false)"
            class="text-slate-400 hover:text-slate-600"
          >
            <i class="fa-solid fa-xmark text-xl"></i>
          </button>
        </div>
        <div
          class="p-6 space-y-4"
          v-if="student"
        >
          <div
            class="flex items-center gap-3 p-3 bg-purple-50 rounded-xl border border-purple-100"
          >
            <div
              class="w-10 h-10 rounded-full bg-purple-200 flex items-center justify-center text-purple-700 font-bold"
            >
              {{ student.name.charAt(0) }}
            </div>
            <div>
              <div class="font-bold text-slate-800">
                {{ student.name }}
              </div>
              <div class="text-xs text-slate-500">
                {{ $t('teacher.finance.createInvoiceModal.package') }}:
                {{ student.package }}
              </div>
            </div>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
              {{ $t('teacher.finance.createInvoiceModal.title') }}
            </label>
            <input
              v-model="form.title"
              type="text"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm outline-none focus:border-blue-500"
              :placeholder="$t('teacher.finance.createInvoiceModal.titlePlaceholder')"
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
              {{ $t('teacher.finance.createInvoiceModal.description') }}
            </label>
            <textarea
              v-model="form.description"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm outline-none focus:border-blue-500 resize-none"
              rows="2"
              :placeholder="$t('teacher.finance.createInvoiceModal.descriptionPlaceholder')"
            ></textarea>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
              {{ $t('teacher.finance.createInvoiceModal.amount') }}
            </label>
            <div class="relative">
              <input
                v-model.number="form.amount"
                type="number"
                min="0"
                class="w-full pl-4 pr-12 py-3 bg-white border border-slate-300 rounded-lg text-lg font-bold text-purple-600 focus:border-purple-500 outline-none"
              />
              <span
                class="absolute right-4 top-3.5 text-slate-400 font-bold text-sm"
                >VND</span
              >
            </div>
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
              {{ $t('teacher.finance.createInvoiceModal.dueDate') }}
            </label>
            <input
              v-model="form.due_date"
              type="date"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label class="block text-xs font-bold text-slate-500 uppercase mb-1">
              {{ $t('teacher.finance.createInvoiceModal.status') }}
            </label>
            <select
              v-model="form.status"
              class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm outline-none focus:border-blue-500"
            >
              <option value="pending">{{ $t('teacher.finance.createInvoiceModal.statusPending') }}</option>
              <option value="paid">{{ $t('teacher.finance.createInvoiceModal.statusPaid') }}</option>
              <option value="overdue">{{ $t('teacher.finance.createInvoiceModal.statusOverdue') }}</option>
            </select>
          </div>
        </div>
        <div
          class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3"
        >
          <button
            @click="$emit('update:modelValue', false)"
            :disabled="loading"
            class="px-4 py-2 text-slate-500 font-bold text-sm hover:bg-slate-200 rounded-lg transition-colors disabled:opacity-50"
          >
            {{ $t('teacher.finance.createInvoiceModal.cancel') }}
          </button>
          <button
            @click="$emit('confirm', form)"
            :disabled="loading || !form.title || !form.due_date"
            class="px-6 py-2 bg-purple-600 text-white font-bold text-sm rounded-lg hover:bg-purple-700 shadow-sm transition-colors flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i
              v-if="loading"
              class="fa-solid fa-spinner fa-spin"
            ></i>
            <i v-else class="fa-solid fa-check"></i>
            {{ $t('teacher.finance.createInvoiceModal.confirm') }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import type { StudentFinanceInfo } from '@/composables/useTeacherFinanceApi';

interface Props {
  modelValue: boolean;
  student: StudentFinanceInfo | null;
  loading: boolean;
}

const props = defineProps<Props>();

defineEmits<{
  'update:modelValue': [value: boolean];
  confirm: [form: {
    title: string;
    description: string;
    amount: number;
    due_date: string;
    status: 'pending' | 'paid' | 'overdue';
  }];
}>();

const { t } = useI18n();

const form = ref<{
  title: string;
  description: string;
  amount: number;
  due_date: string;
  status: 'pending' | 'paid' | 'overdue';
}>({
  title: '',
  description: '',
  amount: 0,
  due_date: '',
  status: 'pending',
});

// Initialize form when student changes
watch(() => props.student, (newStudent) => {
  if (newStudent) {
    const today = new Date();
    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7);
    
    const dueDateStr = nextWeek.toISOString().split('T')[0] || '';
    
    form.value = {
      title: `Học phí ${newStudent.package} - ${today.toLocaleDateString('vi-VN')}`,
      description: `Học phí cho ${newStudent.package}`,
      amount: newStudent.amount || 0,
      due_date: dueDateStr,
      status: 'pending',
    };
  }
}, { immediate: true });
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
</style>
