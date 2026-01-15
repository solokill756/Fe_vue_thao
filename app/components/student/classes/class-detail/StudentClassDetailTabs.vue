<template>
  <div class="border-b border-slate-200 px-6">
    <div class="flex gap-6 overflow-x-auto">
      <button
        @click="$emit('update:tab', 'overview')"
        :class="[
          'py-4 text-sm font-bold border-b-2 transition-colors whitespace-nowrap',
          currentTab === 'overview'
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-slate-500 hover:text-slate-700',
        ]"
      >
        {{ $t('student.classes.detail.tabs.overview') }}
      </button>
      <button
        @click="$emit('update:tab', 'assignments')"
        :class="[
          'py-4 text-sm font-bold border-b-2 transition-colors relative whitespace-nowrap',
          currentTab === 'assignments'
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-slate-500 hover:text-slate-700',
        ]"
      >
        {{ $t('student.classes.detail.tabs.assignments') }}
        <span
          v-if="assignmentCount > 0"
          class="absolute top-3 -right-2 w-2 h-2 bg-red-500 rounded-full"
        ></span>
      </button>
      <button
        @click="$emit('update:tab', 'attendance')"
        :class="[
          'py-4 text-sm font-bold border-b-2 transition-colors whitespace-nowrap',
          currentTab === 'attendance'
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-slate-500 hover:text-slate-700',
        ]"
      >
        {{ $t('student.classes.detail.tabs.attendance') }}
      </button>
      <button
        @click="$emit('update:tab', 'grades')"
        :class="[
          'py-4 text-sm font-bold border-b-2 transition-colors whitespace-nowrap',
          currentTab === 'grades'
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-slate-500 hover:text-slate-700',
        ]"
      >
        {{ $t('student.classes.detail.tabs.grades') }}
      </button>
      <button
        @click="$emit('update:tab', 'documents')"
        :class="[
          'py-4 text-sm font-bold border-b-2 transition-colors whitespace-nowrap',
          currentTab === 'documents'
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-slate-500 hover:text-slate-700',
        ]"
      >
        {{ $t('student.classes.detail.tabs.documents') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  currentTab: 'overview' | 'assignments' | 'attendance' | 'grades' | 'documents';
  assignmentCount?: number;
}

withDefaults(defineProps<Props>(), {
  assignmentCount: 0,
});

defineEmits<{
  'update:tab': [
    tab: 'overview' | 'assignments' | 'attendance' | 'grades' | 'documents'
  ];
}>();
</script>
