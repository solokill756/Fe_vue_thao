<template>
  <div class="flex flex-col gap-2">
    <div class="relative">
      <input
        :value="note"
        @input="$emit('update:note', ($event.target as HTMLInputElement).value)"
        type="text"
        :placeholder="$t('teacher.attendance.notePlaceholder')"
        class="w-full pl-3 pr-8 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-200 outline-none transition-all"
      />
      <i
        class="fa-solid fa-pen text-slate-300 absolute right-3 top-2.5 text-xs"
      ></i>
    </div>

    <!-- Quick Tags -->
    <div class="flex flex-wrap gap-2 items-center">
      <button
        @click="$emit('addTag', $t('teacher.attendance.tags.missingHomework'))"
        class="text-[10px] font-bold px-2 py-1 rounded bg-slate-100 text-slate-500 hover:bg-orange-50 hover:text-orange-600 hover:border-orange-200 border border-transparent transition-colors"
      >
        + {{ $t('teacher.attendance.tags.missingHomework') }}
      </button>
      <button
        @click="$emit('addTag', $t('teacher.attendance.tags.active'))"
        class="text-[10px] font-bold px-2 py-1 rounded bg-slate-100 text-slate-500 hover:bg-green-50 hover:text-green-600 hover:border-green-200 border border-transparent transition-colors"
      >
        + {{ $t('teacher.attendance.tags.active') }}
      </button>

      <!-- Alert Parent Button (Conditional) -->
      <button
        v-if="
          status === 'absent_no_reason' ||
          status === 'absent_w_reason' ||
          status === 'late'
        "
        @click="$emit('alertParent')"
        class="ml-auto text-red-600 hover:text-white hover:bg-red-500 text-xs font-bold px-3 py-1 rounded-full border border-red-200 flex items-center gap-1.5 transition-all shadow-sm animate-pulse"
      >
        <i class="fa-regular fa-paper-plane"></i>
        {{ $t('teacher.attendance.alertParent') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  note: string;
  status:
    | 'present'
    | 'late'
    | 'absent'
    | 'absent_w_reason'
    | 'absent_no_reason';
}>();

defineEmits<{
  'update:note': [value: string];
  addTag: [tag: string];
  alertParent: [];
}>();
</script>
