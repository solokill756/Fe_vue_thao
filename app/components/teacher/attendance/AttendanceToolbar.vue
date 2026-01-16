<template>
  <div
    class="p-3 border-b border-slate-100 flex justify-between items-center bg-slate-50/30"
  >
    <div class="relative w-full max-w-xs">
      <input
        :model-value="searchQuery"
        @update:model-value="$emit('update:searchQuery', $event)"
        type="text"
        :placeholder="$t('teacher.attendance.searchPlaceholder')"
        class="w-full pl-9 pr-4 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 shadow-sm"
      />
      <i
        class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
      ></i>
    </div>
    <div class="text-xs text-slate-400 italic hidden sm:block">
      {{ $t('teacher.attendance.noteHint') }}
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  searchQuery: string;
}>();

defineEmits<{
  'update:searchQuery': [value: string];
}>();
</script>
