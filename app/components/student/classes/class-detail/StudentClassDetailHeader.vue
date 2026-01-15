<template>
  <div
    class="relative h-48 bg-gradient-to-r from-blue-600 to-indigo-700 p-8 flex flex-col justify-end text-white"
  >
    <div class="absolute top-4 left-4">
      <button
        @click="$emit('back')"
        class="flex items-center gap-2 px-3 py-1.5 bg-white/20 hover:bg-white/30 rounded-lg text-sm font-bold backdrop-blur-sm transition-colors"
      >
        <i class="fa-solid fa-arrow-left"></i>
        {{ $t('student.classes.backToList') }}
      </button>
    </div>
    <div class="relative z-10 flex justify-between items-end">
      <div>
        <div class="flex items-center gap-3 mb-2">
          <span
            class="bg-white/20 px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider"
          >
            {{ selectedClass.code }}
          </span>
          <span
            v-if="selectedClass.status === 'active'"
            class="bg-green-500 text-white px-2 py-0.5 rounded text-xs font-bold flex items-center gap-1"
          >
            <span
              class="w-1.5 h-1.5 bg-white rounded-full animate-pulse"
            ></span>
            {{ $t('student.classes.detail.status.active') }}
          </span>
        </div>
        <h1 class="text-3xl font-bold mb-1">{{ selectedClass.name }}</h1>
        <p class="text-blue-100 flex items-center gap-4 text-sm flex-wrap">
          <span
            ><i class="fa-solid fa-user-tie mr-1"></i>
            {{ selectedClass.teacher }}</span
          >
          <span
            ><i class="fa-regular fa-clock mr-1"></i>
            {{ selectedClass.schedule }}</span
          >
          <span
            ><i class="fa-solid fa-location-dot mr-1"></i>
            {{ selectedClass.room }}</span
          >
        </p>
      </div>
      <div class="hidden md:block text-right">
        <div class="text-3xl font-bold">
          {{ selectedClass.attended }}/{{ selectedClass.totalSessions }}
        </div>
        <div class="text-xs text-blue-200">
          {{ $t('student.classes.detail.sessionsAttended') }}
        </div>
      </div>
    </div>
    <!-- Decorative Circles -->
    <div
      class="absolute top-0 right-0 -mr-10 -mt-10 w-48 h-48 bg-white/10 rounded-full blur-3xl"
    ></div>
  </div>
</template>

<script setup lang="ts">
import type { StudentClass } from 'app/types/class';

interface Props {
  selectedClass: StudentClass;
}

defineProps<Props>();
defineEmits<{
  back: [];
}>();
</script>
