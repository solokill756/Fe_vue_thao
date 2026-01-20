<template>
  <div
    class="p-4 border-b border-slate-200 bg-slate-50 flex flex-col sm:flex-row justify-between items-center gap-4"
  >
    <div class="flex items-center gap-2 w-full sm:w-auto">
      <select
        :value="selectedClassId"
        @change="$emit('update:selectedClassId', ($event.target as HTMLSelectElement).value)"
        class="px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm font-bold text-slate-700 outline-none focus:border-blue-500"
      >
        <option value="">{{ $t('teacher.finance.selectClass') }}</option>
        <option
          v-for="cls in classes"
          :key="cls.id"
          :value="cls.id"
        >
          {{ cls.name }}
        </option>
      </select>
      <div class="relative flex-1 sm:w-64">
        <input
          :model-value="searchQuery"
          @update:model-value="$emit('update:searchQuery', $event)"
          type="text"
          :placeholder="$t('teacher.finance.searchPlaceholder')"
          class="w-full pl-9 pr-4 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500"
          @input="$emit('search')"
        />
        <i
          class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
        ></i>
      </div>
    </div>
    <div class="flex gap-2">
      <button
        v-if="selectedClassId"
        @click="$emit('toggle-pending-transactions')"
        :class="[
          'px-4 py-2 text-sm font-bold rounded-lg transition-colors flex items-center gap-2',
          showPendingTransactions
            ? 'bg-orange-600 text-white'
            : 'bg-orange-100 text-orange-600 hover:bg-orange-200',
        ]"
      >
        <i class="fa-solid fa-clock-rotate-left"></i>
        {{ $t('teacher.finance.pendingTransactions') }}
        <span
          v-if="pendingCount > 0"
          class="bg-white text-orange-600 text-xs px-2 py-0.5 rounded-full font-bold"
        >
          {{ pendingCount }}
        </span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Class {
  id: number;
  name: string;
}

interface Props {
  classes: Class[];
  selectedClassId: number | string;
  searchQuery: string;
  showPendingTransactions: boolean;
  pendingCount: number;
}

defineProps<Props>();

defineEmits<{
  'update:selectedClassId': [value: number | string];
  'update:searchQuery': [value: string];
  search: [];
  'toggle-pending-transactions': [];
}>();
</script>
