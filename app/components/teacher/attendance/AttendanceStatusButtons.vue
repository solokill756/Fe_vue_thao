<template>
  <div
    class="flex justify-center bg-slate-100 rounded-lg p-1.5 gap-1 shadow-inner"
  >
    <button
      @click="$emit('statusChange', 'present')"
      :class="[
        'flex-1 py-1.5 px-3 rounded-md text-xs font-bold transition-all flex flex-col items-center gap-1',
        modelValue === 'present'
          ? 'bg-white text-green-600 shadow ring-1 ring-green-100'
          : 'text-slate-400 hover:bg-slate-200',
      ]"
    >
      <i class="fa-solid fa-check"></i>
      <span>{{ $t('teacher.attendance.status.present') }}</span>
    </button>
    <button
      @click="$emit('statusChange', 'late')"
      :class="[
        'flex-1 py-1.5 px-3 rounded-md text-xs font-bold transition-all flex flex-col items-center gap-1',
        modelValue === 'late'
          ? 'bg-white text-yellow-600 shadow ring-1 ring-yellow-100'
          : 'text-slate-400 hover:bg-slate-200',
      ]"
    >
      <i class="fa-regular fa-clock"></i>
      <span>{{ $t('teacher.attendance.status.late') }}</span>
    </button>
    <button
      @click="$emit('statusChange', 'absent_w_reason')"
      :class="[
        'flex-1 py-1.5 px-3 rounded-md text-xs font-bold transition-all flex flex-col items-center gap-1',
        modelValue === 'absent_w_reason'
          ? 'bg-white text-blue-600 shadow ring-1 ring-blue-100'
          : 'text-slate-400 hover:bg-slate-200',
      ]"
    >
      <i class="fa-regular fa-envelope"></i>
      <span>{{ $t('teacher.attendance.status.excused') }}</span>
    </button>
    <button
      @click="$emit('statusChange', 'absent_no_reason')"
      :class="[
        'flex-1 py-1.5 px-3 rounded-md text-xs font-bold transition-all flex flex-col items-center gap-1',
        modelValue === 'absent_no_reason'
          ? 'bg-white text-red-600 shadow ring-1 ring-red-100'
          : 'text-slate-400 hover:bg-slate-200',
      ]"
    >
      <i class="fa-solid fa-xmark"></i>
      <span>{{ $t('teacher.attendance.status.absent') }}</span>
    </button>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  modelValue:
    | 'present'
    | 'late'
    | 'absent'
    | 'absent_w_reason'
    | 'absent_no_reason';
}>();

defineEmits<{
  statusChange: [
    status:
      | 'present'
      | 'late'
      | 'absent'
      | 'absent_w_reason'
      | 'absent_no_reason'
  ];
}>();
</script>
