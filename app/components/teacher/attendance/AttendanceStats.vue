<template>
  <div
    class="flex items-center gap-2 bg-slate-50 p-2 rounded-lg border border-slate-100 w-full xl:w-auto justify-between xl:justify-start overflow-x-auto"
  >
    <div
      class="px-4 py-1.5 rounded-lg bg-green-100 text-green-700 text-xs font-bold flex flex-col items-center min-w-[70px]"
    >
      <span class="text-lg leading-none">{{ stats.present }}</span>
      <span class="text-[9px] uppercase tracking-wide mt-0.5">
        {{ $t('teacher.attendance.stats.present') }}
      </span>
    </div>
    <div
      class="px-4 py-1.5 rounded-lg bg-yellow-100 text-yellow-700 text-xs font-bold flex flex-col items-center min-w-[70px]"
    >
      <span class="text-lg leading-none">{{ stats.late }}</span>
      <span class="text-[9px] uppercase tracking-wide mt-0.5">
        {{ $t('teacher.attendance.stats.late') }}
      </span>
    </div>
    <div
      class="px-4 py-1.5 rounded-lg bg-red-100 text-red-700 text-xs font-bold flex flex-col items-center min-w-[70px]"
    >
      <span class="text-lg leading-none">{{ stats.absent }}</span>
      <span class="text-[9px] uppercase tracking-wide mt-0.5">
        {{ $t('teacher.attendance.stats.absent') }}
      </span>
    </div>
    <div class="h-8 w-px bg-slate-200 mx-2 hidden sm:block"></div>
    <div class="flex-col justify-center px-2 hidden sm:flex">
      <span class="text-xs text-slate-500 font-medium">
        {{ $t('teacher.attendance.totalStudents') }}
      </span>
      <span class="text-sm font-bold text-slate-800">
        {{ totalStudents }} {{ $t('teacher.attendance.students') }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  stats: {
    present: number;
    late: number;
    absent: number;
  };
  totalStudents: number;
}>();
</script>
