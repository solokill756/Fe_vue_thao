<template>
  <div
    class="bg-white rounded-xl border border-slate-200 shadow-sm animate-fade-in overflow-hidden"
  >
    <table class="w-full text-sm text-left">
      <thead
        class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200"
      >
        <tr>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.grades.name') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.grades.date') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.grades.score') }}
          </th>
          <th class="px-6 py-4">
            {{ $t('student.classes.detail.grades.comment') }}
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <tr
          v-for="(grade, idx) in grades"
          :key="idx"
          class="hover:bg-slate-50"
        >
          <td class="px-6 py-4 font-bold text-slate-800">
            {{ grade.title }}
          </td>
          <td class="px-6 py-4 text-slate-600">{{ grade.date }}</td>
          <td
            class="px-6 py-4 font-bold text-lg"
            :class="
              grade.score >= 8
                ? 'text-green-600'
                : grade.score >= 5
                ? 'text-blue-600'
                : 'text-red-600'
            "
          >
            {{ grade.score }}
          </td>
          <td class="px-6 py-4 text-slate-600 italic">
            "{{ grade.comment }}"
          </td>
        </tr>
        <tr v-if="grades.length === 0">
          <td colspan="4" class="px-6 py-12 text-center text-slate-400">
            <i class="fa-solid fa-inbox text-3xl mb-2"></i>
            <p>{{ $t('student.classes.detail.grades.noGrades') }}</p>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
interface Grade {
  title: string;
  score: number;
  date: string;
  comment: string;
}

interface Props {
  grades: Grade[];
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
