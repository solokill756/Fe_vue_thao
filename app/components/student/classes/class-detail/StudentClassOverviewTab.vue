<template>
  <div class="animate-fade-in">
    <!-- Grade Progress - Centered -->
    <div class="flex justify-center">
      <div
        class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm max-w-md w-full"
      >
        <h4 class="font-bold text-slate-700 text-sm mb-3 text-center">
          {{ $t('student.classes.detail.overview.gradeProgress') }}
        </h4>
        <div class="flex items-end gap-2 mb-2 justify-center">
          <span class="text-3xl font-bold text-slate-800">{{
            averageGrade
          }}</span>
          <span
            v-if="gradeChange > 0"
            class="text-xs text-green-500 font-bold mb-1.5"
          >
            <i class="fa-solid fa-arrow-up"></i>
            {{ $t('student.classes.detail.overview.increased') }}
          </span>
        </div>
        <div class="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
          <div
            class="h-full bg-emerald-500"
            :style="{ width: (averageGrade / 10) * 100 + '%' }"
          ></div>
        </div>
        <p class="text-xs text-slate-400 mt-2 text-center">
          {{ $t('student.classes.detail.overview.classAverage') }}:
          {{ classAverage }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  averageGrade: number;
  gradeChange: number;
  classAverage: number;
}

defineProps<Props>();
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
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
