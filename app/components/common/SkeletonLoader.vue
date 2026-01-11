<template>
  <div class="space-y-4 animate-pulse">
    <!-- Header Skeleton -->
    <div v-if="showHeader" class="space-y-3">
      <div class="h-8 bg-slate-200 rounded-lg w-1/3"></div>
      <div class="h-4 bg-slate-100 rounded w-2/3"></div>
    </div>

    <!-- Card Skeleton -->
    <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
      <!-- Multiple lines -->
      <div v-for="i in lines" :key="i" class="space-y-2">
        <div class="h-4 bg-slate-100 rounded w-full"></div>
        <div class="h-4 bg-slate-100 rounded w-5/6"></div>
      </div>

      <!-- Button skeleton -->
      <div v-if="showButton" class="pt-4 flex gap-3">
        <div class="h-10 bg-slate-200 rounded-lg w-24"></div>
        <div class="h-10 bg-slate-100 rounded-lg w-24"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  lines?: number;
  showHeader?: boolean;
  showButton?: boolean;
}

withDefaults(defineProps<Props>(), {
  lines: 4,
  showHeader: true,
  showButton: true,
});
</script>
