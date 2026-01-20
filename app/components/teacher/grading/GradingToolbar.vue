<template>
  <div
    class="flex flex-col sm:flex-row justify-between items-center gap-4 bg-white p-4 rounded-xl shadow-sm border border-slate-200"
  >
    <div class="relative w-full sm:w-64">
      <input
        :model-value="searchQuery"
        @update:model-value="$emit('update:searchQuery', $event)"
        type="text"
        :placeholder="$t('teacher.grading.searchPlaceholder')"
        class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 transition-all"
      />
      <i
        class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
      ></i>
    </div>
    <div class="flex gap-2">
      <select
        :value="selectedClassId"
        @change="$emit('update:selectedClassId', ($event.target as HTMLSelectElement).value)"
        class="px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm text-slate-600 focus:border-blue-500 outline-none"
      >
        <option value="">{{ $t('teacher.grading.selectClass') }}</option>
        <option v-for="cls in classes" :key="cls.id" :value="cls.id">
          {{ cls.name }}
        </option>
      </select>
      <button
        @click="$emit('create-assignment')"
        class="px-4 py-2 bg-blue-600 text-white text-xs font-bold rounded-lg shadow-sm flex items-center gap-2 hover:bg-blue-700 transition-colors"
      >
        <i class="fa-solid fa-plus"></i>
        {{ $t('teacher.grading.newAssignment') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

interface Class {
  id: number;
  name: string;
}

defineProps<{
  classes: Class[];
  searchQuery: string;
  selectedClassId: number | string;
}>();

defineEmits<{
  'update:searchQuery': [value: string];
  'update:selectedClassId': [value: number | string];
  'create-assignment': [];
}>();
</script>
