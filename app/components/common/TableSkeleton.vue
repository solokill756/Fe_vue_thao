<template>
  <div class="space-y-3 animate-pulse">
    <!-- Header row -->
    <div class="grid gap-4" :style="{ gridTemplateColumns: columnTemplate }">
      <div
        v-for="i in columns"
        :key="`header-${i}`"
        class="h-4 bg-slate-200 rounded w-full"
      ></div>
    </div>

    <!-- Body rows -->
    <div
      v-for="row in rows"
      :key="`row-${row}`"
      class="grid gap-4"
      :style="{ gridTemplateColumns: columnTemplate }"
    >
      <div
        v-for="col in columns"
        :key="`cell-${row}-${col}`"
        class="h-4 bg-slate-100 rounded w-full"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

interface Props {
  rows?: number;
  columns?: number;
  columnTemplate?: string;
}

const props = withDefaults(defineProps<Props>(), {
  rows: 5,
  columns: 4,
  columnTemplate: 'repeat(auto-fit, minmax(100px, 1fr))',
});
</script>
